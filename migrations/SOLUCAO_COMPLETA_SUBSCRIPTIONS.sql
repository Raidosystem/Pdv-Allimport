-- ========================================
-- 🔧 SOLUÇÃO COMPLETA: CORRIGIR SUBSCRIPTIONS
-- ========================================
-- Este script executa TUDO em ordem correta:
-- 1. Remove constraints antigas
-- 2. Corrige valores inválidos  
-- 3. Adiciona constraints novas
-- ========================================

-- PARTE 1: REMOVER CONSTRAINTS ANTIGAS
-- ========================================

DO $$
DECLARE
  v_constraint_name TEXT;
BEGIN
  -- Remover constraint de plan_type
  FOR v_constraint_name IN 
    SELECT conname
    FROM pg_constraint
    WHERE conrelid = 'subscriptions'::regclass
      AND contype = 'c'
      AND pg_get_constraintdef(oid) LIKE '%plan_type%'
  LOOP
    EXECUTE format('ALTER TABLE subscriptions DROP CONSTRAINT IF EXISTS %I', v_constraint_name);
    RAISE NOTICE '✅ Constraint removida: %', v_constraint_name;
  END LOOP;

  -- Remover constraint de status
  FOR v_constraint_name IN 
    SELECT conname
    FROM pg_constraint
    WHERE conrelid = 'subscriptions'::regclass
      AND contype = 'c'
      AND pg_get_constraintdef(oid) LIKE '%status%'
      AND pg_get_constraintdef(oid) NOT LIKE '%payment_status%'
  LOOP
    EXECUTE format('ALTER TABLE subscriptions DROP CONSTRAINT IF EXISTS %I', v_constraint_name);
    RAISE NOTICE '✅ Constraint removida: %', v_constraint_name;
  END LOOP;
END $$;

-- PARTE 2: CORRIGIR VALORES INVÁLIDOS
-- ========================================

-- Mostrar valores atuais ANTES da correção
SELECT 
  '⚠️ VALORES ANTES DA CORREÇÃO' as titulo;

SELECT plan_type, COUNT(*) as qtd FROM subscriptions GROUP BY plan_type;
SELECT status, COUNT(*) as qtd FROM subscriptions GROUP BY status;

-- Normalizar para minúsculas
UPDATE subscriptions 
SET plan_type = LOWER(TRIM(plan_type))
WHERE plan_type IS NOT NULL;

UPDATE subscriptions 
SET status = LOWER(TRIM(status))
WHERE status IS NOT NULL;

-- Corrigir valores NULL
UPDATE subscriptions 
SET plan_type = 'free'
WHERE plan_type IS NULL;

UPDATE subscriptions 
SET status = 'pending'
WHERE status IS NULL;

-- Mapear variações para valores corretos
UPDATE subscriptions 
SET plan_type = CASE
  WHEN plan_type IN ('premium', 'premiumm', 'premiun') THEN 'premium'
  WHEN plan_type IN ('trial', 'teste', 'test') THEN 'trial'
  WHEN plan_type IN ('basic', 'basico', 'básico') THEN 'basic'
  WHEN plan_type IN ('enterprise', 'empresa', 'empresarial') THEN 'enterprise'
  WHEN plan_type IN ('free', 'gratis', 'gratuito', 'livre') THEN 'free'
  ELSE 'free'
END
WHERE plan_type NOT IN ('free', 'trial', 'basic', 'premium', 'enterprise');

UPDATE subscriptions 
SET status = CASE
  WHEN status IN ('active', 'ativo', 'ativa') THEN 'active'
  WHEN status IN ('trial', 'teste', 'test', 'em teste') THEN 'trial'
  WHEN status IN ('expired', 'expirado', 'expirada', 'vencido') THEN 'expired'
  WHEN status IN ('cancelled', 'cancelado', 'cancelada') THEN 'cancelled'
  WHEN status IN ('pending', 'pendente') THEN 'pending'
  ELSE 'pending'
END
WHERE status NOT IN ('pending', 'trial', 'active', 'expired', 'cancelled');

-- PARTE 3: ADICIONAR CONSTRAINTS NOVAS
-- ========================================

ALTER TABLE subscriptions 
DROP CONSTRAINT IF EXISTS subscriptions_plan_type_check;

ALTER TABLE subscriptions 
DROP CONSTRAINT IF EXISTS subscriptions_status_check;

ALTER TABLE subscriptions 
ADD CONSTRAINT subscriptions_plan_type_check 
CHECK (plan_type IN ('free', 'trial', 'basic', 'premium', 'enterprise'));

ALTER TABLE subscriptions 
ADD CONSTRAINT subscriptions_status_check 
CHECK (status IN ('pending', 'trial', 'active', 'expired', 'cancelled'));

-- PARTE 4: VERIFICAÇÃO FINAL
-- ========================================

SELECT 
  '✅ CORREÇÃO CONCLUÍDA!' as resultado;

SELECT 
  '📊 PLAN_TYPES FINAIS' as info,
  plan_type,
  COUNT(*) as quantidade
FROM subscriptions
GROUP BY plan_type
ORDER BY quantidade DESC;

SELECT 
  '📊 STATUS FINAIS' as info,
  status,
  COUNT(*) as quantidade
FROM subscriptions
GROUP BY status
ORDER BY quantidade DESC;

-- Verificar se há registros problemáticos
SELECT 
  '🔍 VERIFICAÇÃO DE INTEGRIDADE' as titulo;

SELECT 
  'Plan types inválidos:' as check_type,
  COUNT(*) as quantidade
FROM subscriptions
WHERE plan_type NOT IN ('free', 'trial', 'basic', 'premium', 'enterprise');

SELECT 
  'Status inválidos:' as check_type,
  COUNT(*) as quantidade
FROM subscriptions
WHERE status NOT IN ('pending', 'trial', 'active', 'expired', 'cancelled');

SELECT 
  '🎯 RESULTADO' as titulo,
  'Se ambas as quantidades = 0, está pronto para testar!' as mensagem;
