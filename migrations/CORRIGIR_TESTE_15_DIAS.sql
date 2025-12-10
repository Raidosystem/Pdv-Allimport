-- ============================================
-- CORRIGIR PERÍODO DE TESTE PARA 15 DIAS
-- Problema: Trigger está criando apenas 7 dias
-- Solução: Atualizar para 15 dias de teste
-- ============================================

-- 1️⃣ Atualizar função handle_new_user para 15 dias de teste
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
    NOW() + INTERVAL '15 days'  -- ✅ CORRIGIDO: 15 dias de teste
  )
  ON CONFLICT (user_id) DO NOTHING;
  
  -- Criar registro de assinatura trial na tabela subscriptions
  INSERT INTO public.subscriptions (
    user_id,
    company_id,
    status,
    plan_type,
    trial_start,
    trial_end,
    created_at
  ) VALUES (
    NEW.id,
    NEW.email,
    'trialing',
    'mensal',
    NOW(),
    NOW() + INTERVAL '15 days',  -- ✅ 15 dias de teste
    NOW()
  )
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Logar erro mas não bloquear signup
    RAISE WARNING 'Erro ao criar empresa/assinatura: %', SQLERRM;
    RETURN NEW;
END;
$$;

-- 2️⃣ Recriar trigger (garantir que está ativo)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 3️⃣ CORRIGIR USUÁRIOS EXISTENTES COM 7 DIAS
-- Estender para 15 dias os usuários que ainda estão em teste
UPDATE public.empresas
SET data_fim_teste = data_cadastro + INTERVAL '15 days'
WHERE tipo_conta = 'teste_ativo'
  AND data_fim_teste < data_cadastro + INTERVAL '15 days'
  AND data_fim_teste >= NOW();  -- Apenas testes ativos

-- 4️⃣ Atualizar subscriptions para 15 dias
UPDATE public.subscriptions
SET trial_end = trial_start + INTERVAL '15 days'
WHERE status = 'trialing'
  AND trial_end < trial_start + INTERVAL '15 days'
  AND trial_end >= NOW();  -- Apenas trials ativos

-- 5️⃣ Verificar resultado
SELECT 
  '✅ Trigger Corrigido' as status,
  'Novos cadastros terão 15 dias de teste' as mensagem
UNION ALL
SELECT 
  '✅ Usuários Atualizados' as status,
  COUNT(*)::text || ' usuários tiveram o período estendido' as mensagem
FROM empresas
WHERE tipo_conta = 'teste_ativo'
  AND data_fim_teste = data_cadastro + INTERVAL '15 days';

-- 6️⃣ Verificar próximos vencimentos
SELECT 
  e.nome,
  e.email,
  e.tipo_conta,
  e.data_cadastro,
  e.data_fim_teste,
  EXTRACT(DAY FROM (e.data_fim_teste - NOW()))::integer as dias_restantes
FROM empresas e
WHERE e.tipo_conta = 'teste_ativo'
  AND e.data_fim_teste >= NOW()
ORDER BY e.data_fim_teste
LIMIT 10;
