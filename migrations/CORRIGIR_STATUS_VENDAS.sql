-- ============================================================================
-- CORRIGIR STATUS DAS VENDAS - Executar SOMENTE se necessário
-- ============================================================================

-- ⚠️ ATENÇÃO: Execute apenas se o diagnóstico mostrar que as vendas 
-- não têm status='completed' ou status é NULL

-- 1️⃣ Ver quantas vendas NÃO têm status 'completed'
SELECT 
  COALESCE(status, 'NULL') as status_atual,
  COUNT(*) as quantidade
FROM vendas
GROUP BY status;

-- 2️⃣ ATUALIZAR todas as vendas para status 'completed' (se necessário)
-- ⚠️ DESCOMENTE APENAS SE CONFIRMAR QUE PRECISA:

-- UPDATE vendas 
-- SET status = 'completed' 
-- WHERE status IS NULL OR status != 'completed';

-- 3️⃣ Verificar resultado
-- SELECT 
--   status,
--   COUNT(*) as quantidade
-- FROM vendas
-- GROUP BY status;

-- ============================================================================
-- ALTERNATIVA: Se a coluna 'status' não existir na tabela vendas
-- ============================================================================

-- Verificar colunas da tabela vendas
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'vendas'
ORDER BY ordinal_position;

-- Se a coluna 'status' não existir, criar:
-- ALTER TABLE vendas ADD COLUMN IF NOT EXISTS status text DEFAULT 'completed';

-- ============================================================================
-- 📝 NOTAS:
-- 1. A função fn_calcular_dre busca vendas com status='completed'
-- 2. Se a coluna não tiver esse valor, DRE ficará zerado
-- 3. Se a coluna não existir, precisa ser criada
-- ============================================================================
