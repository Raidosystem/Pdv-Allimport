-- ============================================
-- CORRIGIR: NOVOS CADASTROS = OWNER (NÃO FUNCIONÁRIO)
-- Todo novo cadastro deve ser DONO da empresa
-- ============================================

-- 1️⃣ Atualizar trigger para criar usuários como OWNER
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Criar registro na tabela empresas com 15 dias de teste
  INSERT INTO public.empresas (
    user_id,
    nome,
    razao_social,
    cnpj,
    email,
    telefone,
    cep,
    logradouro,
    numero,
    complemento,
    bairro,
    cidade,
    estado,
    uf,
    tipo_conta,
    data_cadastro,
    data_fim_teste
  ) VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'company_name', 'Empresa'),
    COALESCE(NEW.raw_user_meta_data->>'company_name', NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'cpf_cnpj', ''),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'whatsapp', ''),
    COALESCE(NEW.raw_user_meta_data->>'cep', ''),
    COALESCE(NEW.raw_user_meta_data->>'street', ''),
    COALESCE(NEW.raw_user_meta_data->>'number', ''),
    COALESCE(NEW.raw_user_meta_data->>'complement', ''),
    COALESCE(NEW.raw_user_meta_data->>'neighborhood', ''),
    COALESCE(NEW.raw_user_meta_data->>'city', ''),
    COALESCE(NEW.raw_user_meta_data->>'state', ''),
    COALESCE(NEW.raw_user_meta_data->>'state', ''),
    'teste_ativo',
    NOW(),
    NOW() + INTERVAL '15 days'
  )
  ON CONFLICT (user_id) DO NOTHING;
  
  -- ✅ CRIAR REGISTRO EM user_approvals COMO OWNER (DONO DA EMPRESA)
  -- Só criar se NÃO for funcionário (funcionários têm parent_user_id)
  IF NEW.raw_user_meta_data->>'role' IS NULL OR NEW.raw_user_meta_data->>'role' != 'employee' THEN
    INSERT INTO public.user_approvals (
      user_id,
      email,
      full_name,
      company_name,
      cpf_cnpj,
      whatsapp,
      document_type,
      status,
      user_role,
      approved_at,
      created_at
    ) VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NEW.raw_user_meta_data->>'full_name', 'Usuário'),
      COALESCE(NEW.raw_user_meta_data->>'company_name', 'Empresa'),
      COALESCE(NEW.raw_user_meta_data->>'cpf_cnpj', ''),
      COALESCE(NEW.raw_user_meta_data->>'whatsapp', ''),
      COALESCE(NEW.raw_user_meta_data->>'document_type', 'CPF'),
      'approved',  -- ✅ AUTO-APROVADO: Dono da empresa tem acesso imediato
      'owner',     -- ✅ ROLE: OWNER (não funcionário)
      NOW(),       -- ✅ Aprovado automaticamente
      NOW()
    )
    ON CONFLICT (user_id) DO NOTHING;
  END IF;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Erro ao criar empresa/usuário: %', SQLERRM;
    RETURN NEW;
END;
$$;

-- 2️⃣ Recriar trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 3️⃣ CORRIGIR USUÁRIOS EXISTENTES - Marcar como OWNER
UPDATE public.user_approvals
SET 
  user_role = 'owner',
  status = 'approved',
  approved_at = COALESCE(approved_at, NOW())
WHERE user_role IS NULL 
   OR user_role = 'user'
   OR (user_role = 'employee' AND parent_user_id IS NULL);  -- Funcionários sem parent são na verdade owners

-- 4️⃣ Garantir que todos tenham empresa
INSERT INTO public.empresas (
  user_id,
  nome,
  razao_social,
  email,
  tipo_conta,
  data_cadastro,
  data_fim_teste
)
SELECT 
  ua.user_id,
  COALESCE(ua.full_name, 'Empresa'),
  COALESCE(ua.company_name, ua.full_name, 'Empresa'),
  ua.email,
  'teste_ativo',
  NOW(),
  NOW() + INTERVAL '15 days'
FROM user_approvals ua
LEFT JOIN empresas e ON e.user_id = ua.user_id
WHERE e.id IS NULL
  AND ua.user_role = 'owner'
ON CONFLICT (user_id) DO NOTHING;

-- 5️⃣ VERIFICAR RESULTADO
SELECT 
  '✅ VERIFICAÇÃO FINAL' as status,
  COUNT(*) as total_owners,
  COUNT(*) FILTER (WHERE status = 'approved') as owners_aprovados
FROM user_approvals
WHERE user_role = 'owner';

-- Listar owners recém-criados
SELECT 
  '👤 OWNERS CADASTRADOS' as info,
  ua.email,
  ua.full_name,
  ua.user_role,
  ua.status,
  e.tipo_conta,
  e.data_fim_teste,
  EXTRACT(DAY FROM (e.data_fim_teste - NOW()))::INTEGER as dias_teste
FROM user_approvals ua
LEFT JOIN empresas e ON e.user_id = ua.user_id
WHERE ua.user_role = 'owner'
ORDER BY ua.created_at DESC
LIMIT 5;

-- ============================================
-- MENSAGEM FINAL
-- ============================================
SELECT 
  '✅ CORREÇÃO APLICADA' as status,
  'Novos cadastros agora são OWNERS (donos da empresa)' as mensagem,
  'Funcionários devem ser criados separadamente pelo owner' as nota;
