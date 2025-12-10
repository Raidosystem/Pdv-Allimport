-- ========================================
-- 🔧 CORRIGIR CONSTRAINT DA TABELA SUBSCRIPTIONS
-- ========================================
-- Este script corrige o problema do check constraint
-- que está impedindo adicionar dias às assinaturas
-- ========================================

-- 1️⃣ REMOVER CONSTRAINT ANTIGA DE PLAN_TYPE
DO $$
DECLARE
  v_constraint_name TEXT;
BEGIN
  -- Buscar nome da constraint
  SELECT conname INTO v_constraint_name
  FROM pg_constraint
  WHERE conrelid = 'subscriptions'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) LIKE '%plan_type%';
  
  IF v_constraint_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE subscriptions DROP CONSTRAINT IF EXISTS %I', v_constraint_name);
    RAISE NOTICE '✅ Constraint antiga removida: %', v_constraint_name;
  ELSE
    RAISE NOTICE '⚠️ Nenhuma constraint de plan_type encontrada';
  END IF;
END $$;

-- 2️⃣ REMOVER CONSTRAINT ANTIGA DE STATUS (se existir)
DO $$
DECLARE
  v_constraint_name TEXT;
BEGIN
  -- Buscar nome da constraint
  SELECT conname INTO v_constraint_name
  FROM pg_constraint
  WHERE conrelid = 'subscriptions'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) LIKE '%status%'
    AND pg_get_constraintdef(oid) NOT LIKE '%payment_status%';
  
  IF v_constraint_name IS NOT NULL THEN
    EXECUTE format('ALTER TABLE subscriptions DROP CONSTRAINT IF EXISTS %I', v_constraint_name);
    RAISE NOTICE '✅ Constraint antiga de status removida: %', v_constraint_name;
  END IF;
END $$;

-- 3️⃣ PRIMEIRO: ATUALIZAR VALORES INVÁLIDOS
-- Mostrar valores atuais antes da correção
SELECT 
  '⚠️ VALORES ANTES DA CORREÇÃO' as aviso,
  '' as espaco;

SELECT 
  'Plan Types existentes:' as info,
  plan_type,
  COUNT(*) as quantidade
FROM subscriptions
GROUP BY plan_type;

SELECT 
  'Status existentes:' as info,
  status,
  COUNT(*) as quantidade
FROM subscriptions
GROUP BY status;

-- Normalizar todos os valores para minúsculas
UPDATE subscriptions 
SET plan_type = LOWER(TRIM(plan_type))
WHERE plan_type IS NOT NULL;

UPDATE subscriptions 
SET status = LOWER(TRIM(status))
WHERE status IS NOT NULL;

-- Corrigir valores específicos conhecidos
UPDATE subscriptions 
SET plan_type = 'premium'
WHERE plan_type NOT IN ('free', 'trial', 'basic', 'premium', 'enterprise')
  AND plan_type IS NOT NULL;

UPDATE subscriptions 
SET status = 'active'
WHERE status NOT IN ('pending', 'trial', 'active', 'expired', 'cancelled')
  AND status IS NOT NULL;

-- Setar valores NULL para padrão
UPDATE subscriptions 
SET plan_type = 'free'
WHERE plan_type IS NULL;

UPDATE subscriptions 
SET status = 'pending'
WHERE status IS NULL;

-- 4️⃣ DEPOIS: ADICIONAR CONSTRAINTS
ALTER TABLE subscriptions 
ADD CONSTRAINT subscriptions_plan_type_check 
CHECK (plan_type IN ('free', 'trial', 'basic', 'premium', 'enterprise'));

ALTER TABLE subscriptions 
ADD CONSTRAINT subscriptions_status_check 
CHECK (status IN ('pending', 'trial', 'active', 'expired', 'cancelled'));

-- 5️⃣ VERIFICAÇÃO FINAL
SELECT 
  '✅ CORREÇÃO CONCLUÍDA!' as titulo,
  '' as espaco;

SELECT 
  '📊 PLAN_TYPES ATUAIS' as info,
  plan_type,
  COUNT(*) as quantidade
FROM subscriptions
GROUP BY plan_type
ORDER BY quantidade DESC;

SELECT 
  '📊 STATUS ATUAIS' as info,
  status,
  COUNT(*) as quantidade
FROM subscriptions
GROUP BY status
ORDER BY quantidade DESC;

SELECT 
  '🎯 PRÓXIMO PASSO' as info,
  'Teste adicionar dias novamente no Admin Dashboard' as acao;
