-- ============================================
-- CORRIGIR TRIGGER PARA CRIAR TRIAL DE 5 DIAS
-- ============================================
-- O trigger atual cria subscription 'active' por 1 ano
-- Precisa criar 'trial' por 5 dias

-- 1. RECRIAR FUNÇÃO COM TRIAL DE 5 DIAS
CREATE OR REPLACE FUNCTION create_empresa_for_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_cnpj_temp TEXT;
BEGIN
  -- Gerar CNPJ temporário único baseado no timestamp
  v_cnpj_temp := LPAD(EXTRACT(EPOCH FROM NOW())::BIGINT::TEXT, 14, '0');
  v_cnpj_temp := SUBSTRING(v_cnpj_temp, 1, 2) || '.' || 
                 SUBSTRING(v_cnpj_temp, 3, 3) || '.' || 
                 SUBSTRING(v_cnpj_temp, 6, 3) || '/' || 
                 SUBSTRING(v_cnpj_temp, 9, 4) || '-' || 
                 SUBSTRING(v_cnpj_temp, 13, 2);

  -- Criar empresa para o novo usuário
  INSERT INTO public.empresas (
    user_id,
    nome,
    cnpj,
    telefone,
    email,
    endereco,
    cidade,
    estado,
    cep
  ) VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Minha Empresa'),
    v_cnpj_temp,
    COALESCE(NEW.phone, '(00) 00000-0000'),
    NEW.email,
    'Endereço não informado',
    'São Paulo',
    'SP',
    '00000-000'
  )
  ON CONFLICT (user_id) DO NOTHING; -- Não duplicar se já existir

  -- 🎯 CRIAR SUBSCRIPTION DE TESTE POR 5 DIAS (NÃO 1 ANO!)
  INSERT INTO public.subscriptions (
    user_id,
    email,
    plan_type,
    status,
    trial_start_date,
    trial_end_date,
    subscription_start_date,
    subscription_end_date
  ) VALUES (
    NEW.id,
    NEW.email,
    'free',
    'trial',  -- ✅ STATUS TRIAL
    NOW(),
    NOW() + INTERVAL '5 days',  -- ✅ 5 DIAS DE TESTE
    NOW(),
    NOW() + INTERVAL '5 days'
  )
  ON CONFLICT (user_id) DO NOTHING; -- Não duplicar se já existir

  RAISE NOTICE '✅ Empresa e trial de 5 dias criados para: %', NEW.email;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. VERIFICAR SE O TRIGGER EXISTE
SELECT tgname 
FROM pg_trigger 
WHERE tgname = 'on_auth_user_created';

-- 3. SE NÃO EXISTIR, CRIAR O TRIGGER
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_empresa_for_new_user();

-- ============================================
-- VERIFICAR RESULTADO
-- ============================================
-- Execute após criar nova conta:
SELECT 
  u.email,
  s.status,
  s.plan_type,
  EXTRACT(DAY FROM (s.trial_end_date - NOW())) as dias_restantes,
  s.trial_end_date
FROM auth.users u
LEFT JOIN subscriptions s ON s.user_id = u.id
WHERE u.email = 'SEU-EMAIL-TESTE@example.com';
