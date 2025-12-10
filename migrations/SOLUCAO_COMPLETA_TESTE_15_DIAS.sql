-- ============================================
-- SOLUÇÃO COMPLETA - TESTE 15 DIAS
-- Execute TODOS os passos nesta ordem
-- ============================================

-- PASSO 1: Recriar trigger para novos usuários
-- ============================================
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
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Erro ao criar empresa: %', SQLERRM;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- PASSO 2: Criar empresas para usuários existentes SEM empresa
-- ============================================
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
  u.id,
  COALESCE(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'company_name', 'Empresa'),
  COALESCE(u.raw_user_meta_data->>'company_name', u.raw_user_meta_data->>'full_name', 'Empresa'),
  u.email,
  'teste_ativo',
  NOW(),
  NOW() + INTERVAL '15 days'
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
WHERE e.id IS NULL
ON CONFLICT (user_id) DO NOTHING;

-- PASSO 3: Atualizar empresas com teste expirado ou incorreto
-- ============================================
UPDATE public.empresas
SET 
  tipo_conta = 'teste_ativo',
  data_fim_teste = GREATEST(data_cadastro + INTERVAL '15 days', NOW() + INTERVAL '15 days')
WHERE tipo_conta IN ('teste_ativo', 'teste_expirado', 'pendente')
  AND (data_fim_teste IS NULL OR data_fim_teste < NOW() OR data_fim_teste < data_cadastro + INTERVAL '15 days');

-- PASSO 4: Recriar função check_subscription_status
-- ============================================
CREATE OR REPLACE FUNCTION public.check_subscription_status(user_email TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_empresa RECORD;
  v_user_id UUID;
  v_now TIMESTAMPTZ := NOW();
  v_days_remaining INTEGER := 0;
BEGIN
  
  -- Buscar user_id
  SELECT id INTO v_user_id FROM auth.users WHERE email = user_email LIMIT 1;
  
  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false,
      'days_remaining', 0
    );
  END IF;
  
  -- Buscar empresa
  SELECT * INTO v_empresa FROM empresas WHERE user_id = v_user_id LIMIT 1;
  
  IF NOT FOUND THEN
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false,
      'days_remaining', 0
    );
  END IF;
  
  -- Verificar TESTE ATIVO
  IF v_empresa.tipo_conta = 'teste_ativo' AND v_empresa.data_fim_teste > v_now THEN
    v_days_remaining := CEILING(EXTRACT(EPOCH FROM (v_empresa.data_fim_teste - v_now)) / 86400)::INTEGER;
    
    RETURN json_build_object(
      'has_subscription', true,
      'status', 'trial',
      'access_allowed', true,
      'days_remaining', v_days_remaining,
      'trial_end_date', v_empresa.data_fim_teste
    );
  END IF;
  
  -- Teste expirado
  IF v_empresa.tipo_conta = 'teste_ativo' AND v_empresa.data_fim_teste <= v_now THEN
    RETURN json_build_object(
      'has_subscription', true,
      'status', 'expired',
      'access_allowed', false,
      'days_remaining', 0
    );
  END IF;
  
  -- Sem teste
  RETURN json_build_object(
    'has_subscription', false,
    'status', 'no_subscription',
    'access_allowed', false,
    'days_remaining', 0
  );
  
END;
$$;

GRANT EXECUTE ON FUNCTION check_subscription_status(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION check_subscription_status(TEXT) TO anon;

-- PASSO 5: Verificar resultado
-- ============================================
SELECT 
  '✅ VERIFICAÇÃO FINAL' as status,
  (SELECT COUNT(*) FROM auth.users) as total_usuarios,
  (SELECT COUNT(*) FROM empresas) as total_empresas,
  (SELECT COUNT(*) FROM empresas WHERE tipo_conta = 'teste_ativo' AND data_fim_teste > NOW()) as testes_ativos;

-- Testar função para todos os usuários
SELECT 
  u.email,
  e.tipo_conta,
  e.data_fim_teste,
  EXTRACT(DAY FROM (e.data_fim_teste - NOW()))::INTEGER as dias_restantes,
  check_subscription_status(u.email) as status_api
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
ORDER BY u.created_at DESC
LIMIT 5;
