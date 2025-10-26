-- ============================================
-- VERIFICAR ESTRUTURA DE ORDENS_SERVICO
-- ============================================
-- Checar quais colunas existem na tabela
-- ============================================

-- 1. Ver todas as colunas da tabela ordens_servico
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'ordens_servico'
ORDER BY ordinal_position;

-- 2. Ver dados de exemplo (5 ordens)
SELECT *
FROM ordens_servico
ORDER BY data_entrada DESC
LIMIT 5;

-- 3. Ver quais campos estão NULL (baseado nas colunas que existem)
SELECT 
  COUNT(*) as total_ordens,
  COUNT(data_entrada) as tem_data_entrada,
  COUNT(CASE WHEN data_entrada IS NULL THEN 1 END) as sem_data_entrada
FROM ordens_servico;

-- ============================================
-- Isso vai mostrar:
-- - Query 1: Todas as colunas disponíveis
-- - Query 2: Exemplo de dados reais
-- - Query 3: Quantos registros têm cada campo preenchido
-- ============================================
