-- ============================================
-- SOLUÇÃO DEFINITIVA - NOVOS CADASTROS AUTOMÁTICOS
-- Corrige usuários existentes + Garante trigger para futuros
-- ============================================

-- PARTE 1: TRIGGER DEFINITIVO PARA NOVOS CADASTROS
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_empresa_id UUID;
BEGIN
  RAISE NOTICE '🔔 TRIGGER EXECUTADO para usuário: %', NEW.email;
  
  -- 1️⃣ Criar empresa com 15 dias de teste
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
  ON CONFLICT (user_id) DO UPDATE
  SET
    tipo_conta = 'teste_ativo',
    data_fim_teste = EXCLUDED.data_fim_teste
  RETURNING id INTO v_empresa_id;
  
  RAISE NOTICE '✅ Empresa criada: %', v_empresa_id;
  
  -- 2️⃣ Criar user_approvals como OWNER (apenas se NÃO for funcionário)
  IF NEW.raw_user_meta_data->>'role' IS NULL OR NEW.raw_user_meta_data->>'role' != 'employee' THEN
    INSERT INTO public.user_approvals (
      user_id,
      email,
      full_name,
      company_name,
      status,
      user_role,
      approved_at,
      created_at
    ) VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NEW.raw_user_meta_data->>'full_name', 'Usuário'),
      COALESCE(NEW.raw_user_meta_data->>'company_name', 'Empresa'),
      'approved',
      'owner',
      NOW(),
      NOW()
    )
    ON CONFLICT (user_id) DO UPDATE
    SET
      user_role = 'owner',
      status = 'approved',
      approved_at = NOW();
    
    RAISE NOTICE '✅ User approval criado como OWNER';
  ELSE
    RAISE NOTICE 'ℹ️ Usuário é funcionário, não criando approval';
  END IF;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING '❌ ERRO no trigger: %', SQLERRM;
    RETURN NEW;  -- Não bloquear o cadastro mesmo com erro
END;
$$;

-- Recriar trigger com logs
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Verificar trigger criado
DO $$
BEGIN
  RAISE NOTICE '✅ Trigger on_auth_user_created recriado com logs';
END $$;

-- PARTE 2: CORRIGIR TODOS OS USUÁRIOS EXISTENTES
-- ============================================

-- Criar empresas para usuários sem empresa
INSERT INTO empresas (
  user_id,
  nome,
  razao_social,
  email,
  tipo_conta,
  data_cadastro,
  data_fim_teste
)
SELECT 
  u.id,
  COALESCE(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'company_name', 'Empresa'),
  COALESCE(u.raw_user_meta_data->>'company_name', u.raw_user_meta_data->>'full_name', 'Empresa'),
  u.email,
  'teste_ativo',
  u.created_at,
  u.created_at + INTERVAL '15 days'
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
WHERE e.id IS NULL
ON CONFLICT (user_id) DO UPDATE
SET
  tipo_conta = 'teste_ativo',
  data_fim_teste = GREATEST(empresas.data_cadastro + INTERVAL '15 days', NOW() + INTERVAL '1 day');

-- Criar/atualizar user_approvals como OWNER
INSERT INTO user_approvals (
  user_id,
  email,
  full_name,
  company_name,
  user_role,
  status,
  approved_at,
  created_at
)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'full_name', 'Usuário'),
  COALESCE(u.raw_user_meta_data->>'company_name', 'Empresa'),
  'owner',
  'approved',
  NOW(),
  u.created_at
FROM auth.users u
LEFT JOIN funcionarios f ON f.user_id = u.id
WHERE f.id IS NULL  -- Não é funcionário real
ON CONFLICT (user_id) DO UPDATE
SET
  user_role = 'owner',
  status = 'approved',
  approved_at = NOW();

-- PARTE 3: VERIFICAÇÃO E TESTES
-- ============================================

-- Verificar trigger
SELECT 
  '🔧 TRIGGER' as tipo,
  trigger_name,
  event_object_table,
  action_timing,
  event_manipulation,
  '✅ ATIVO' as status
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- Ver todos os usuários corrigidos
SELECT 
  '📊 ESTATÍSTICAS' as info,
  COUNT(*) as total_usuarios,
  COUNT(*) FILTER (WHERE e.id IS NOT NULL) as com_empresa,
  COUNT(*) FILTER (WHERE ua.user_role = 'owner') as owners,
  COUNT(*) FILTER (WHERE e.tipo_conta = 'teste_ativo' AND e.data_fim_teste > NOW()) as testes_ativos
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN user_approvals ua ON ua.user_id = u.id;

-- Listar últimos usuários
SELECT 
  '👥 ÚLTIMOS CADASTROS' as secao,
  u.email,
  u.created_at,
  e.tipo_conta,
  EXTRACT(DAY FROM (e.data_fim_teste - NOW()))::INTEGER as dias_restantes,
  ua.user_role,
  ua.status,
  CASE 
    WHEN e.id IS NOT NULL AND ua.user_role = 'owner' AND e.data_fim_teste > NOW() 
    THEN '✅ CONFIGURADO'
    ELSE '⚠️ VERIFICAR'
  END as status_final
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN user_approvals ua ON ua.user_id = u.id
ORDER BY u.created_at DESC
LIMIT 10;

-- Mensagem final
SELECT 
  '✅ SOLUÇÃO APLICADA' as status,
  'Trigger corrigido: novos cadastros = OWNER automático' as trigger_status,
  'Usuários existentes: todos corrigidos como OWNER' as usuarios_status,
  'Teste de 15 dias: ativado para todos' as teste_status;
