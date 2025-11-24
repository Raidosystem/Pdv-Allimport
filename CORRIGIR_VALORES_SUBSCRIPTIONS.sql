-- ========================================
-- 🔧 CORRIGIR VALORES ANTES DAS CONSTRAINTS
-- ========================================
-- Este script corrige os valores ANTES de adicionar constraints
-- Executar este primeiro, depois CORRIGIR_CONSTRAINT_SUBSCRIPTIONS.sql
-- ========================================

-- 1️⃣ MOSTRAR VALORES PROBLEMÁTICOS
SELECT 
  '⚠️ DIAGNÓSTICO DE VALORES' as titulo,
  '' as espaco;

-- Plan types problemáticos
SELECT 
  '🔍 Plan Types que causarão erro:' as aviso,
  plan_type,
  COUNT(*) as quantidade,
  STRING_AGG(DISTINCT email, ', ') as emails_afetados
FROM subscriptions
WHERE plan_type NOT IN ('free', 'trial', 'basic', 'premium', 'enterprise')
   OR plan_type IS NULL
GROUP BY plan_type;

-- Status problemáticos  
SELECT 
  '🔍 Status que causarão erro:' as aviso,
  status,
  COUNT(*) as quantidade,
  STRING_AGG(DISTINCT email, ', ') as emails_afetados
FROM subscriptions
WHERE status NOT IN ('pending', 'trial', 'active', 'expired', 'cancelled')
   OR status IS NULL
GROUP BY status;

-- 2️⃣ CORRIGIR VALORES INVÁLIDOS

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

-- Mapear valores antigos para novos (caso existam)
UPDATE subscriptions 
SET plan_type = CASE
  WHEN plan_type LIKE '%premium%' THEN 'premium'
  WHEN plan_type LIKE '%trial%' OR plan_type LIKE '%teste%' THEN 'trial'
  WHEN plan_type LIKE '%basic%' OR plan_type LIKE '%basico%' THEN 'basic'
  WHEN plan_type LIKE '%enterprise%' OR plan_type LIKE '%empresa%' THEN 'enterprise'
  WHEN plan_type LIKE '%free%' OR plan_type LIKE '%gratis%' THEN 'free'
  ELSE 'free'
END
WHERE plan_type NOT IN ('free', 'trial', 'basic', 'premium', 'enterprise');

UPDATE subscriptions 
SET status = CASE
  WHEN status LIKE '%active%' OR status LIKE '%ativo%' THEN 'active'
  WHEN status LIKE '%trial%' OR status LIKE '%teste%' THEN 'trial'
  WHEN status LIKE '%expired%' OR status LIKE '%expirado%' THEN 'expired'
  WHEN status LIKE '%cancelled%' OR status LIKE '%cancelado%' THEN 'cancelled'
  WHEN status LIKE '%pending%' OR status LIKE '%pendente%' THEN 'pending'
  ELSE 'pending'
END
WHERE status NOT IN ('pending', 'trial', 'active', 'expired', 'cancelled');

-- 3️⃣ VERIFICAÇÃO PÓS-CORREÇÃO
SELECT 
  '✅ VALORES APÓS CORREÇÃO' as titulo,
  '' as espaco;

-- Verificar se ainda há valores inválidos
SELECT 
  '🔍 Plan Types inválidos restantes:' as verificacao,
  COALESCE(COUNT(*), 0) as quantidade
FROM subscriptions
WHERE plan_type NOT IN ('free', 'trial', 'basic', 'premium', 'enterprise');

SELECT 
  '🔍 Status inválidos restantes:' as verificacao,
  COALESCE(COUNT(*), 0) as quantidade
FROM subscriptions
WHERE status NOT IN ('pending', 'trial', 'active', 'expired', 'cancelled');

-- Mostrar distribuição final
SELECT 
  '📊 Plan Types Finais:' as info,
  plan_type,
  COUNT(*) as quantidade
FROM subscriptions
GROUP BY plan_type
ORDER BY quantidade DESC;

SELECT 
  '📊 Status Finais:' as info,
  status,
  COUNT(*) as quantidade
FROM subscriptions
GROUP BY status
ORDER BY quantidade DESC;

SELECT 
  '🎯 PRÓXIMO PASSO' as titulo,
  'Se quantidade de inválidos = 0, execute CORRIGIR_CONSTRAINT_SUBSCRIPTIONS.sql' as acao;
