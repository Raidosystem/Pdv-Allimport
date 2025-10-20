-- =====================================================
-- LIMPAR TODOS OS FUNCIONÁRIOS DA EMPRESA
-- =====================================================
-- Solução: Deletar todos os funcionários para recriar do zero
-- =====================================================

-- Desabilitar triggers temporariamente
SET session_replication_role = replica;

-- =====================================================
-- 1. VER FUNCIONÁRIOS ANTES DE DELETAR
-- =====================================================

SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo,
  '⚠️ SERÁ DELETADO' as status
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY nome;

-- =====================================================
-- 2. DELETAR TODOS OS FUNCIONÁRIOS DA EMPRESA
-- =====================================================

DELETE FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- =====================================================
-- 3. VERIFICAR QUE FORAM DELETADOS
-- =====================================================

-- Deve retornar 0
SELECT 
  COUNT(*) as funcionarios_restantes
FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Ver se há funcionários em outras empresas (não devem ser afetados)
SELECT 
  empresa_id,
  COUNT(*) as total_funcionarios,
  '✅ NÃO DELETADO (OUTRA EMPRESA)' as status
FROM funcionarios 
WHERE empresa_id != 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
GROUP BY empresa_id;

-- Reabilitar triggers
SET session_replication_role = DEFAULT;

-- =====================================================
-- RESULTADO ESPERADO:
-- - Todos os funcionários da sua empresa deletados
-- - Funcionários de outras empresas NÃO afetados
-- - Você pode recriar os funcionários do zero na aplicação
-- =====================================================

-- =====================================================
-- PRÓXIMO PASSO:
-- =====================================================
-- 1. Execute este SQL
-- 2. Recarregue a página da aplicação (F5)
-- 3. Faça login normalmente
-- 4. Sistema vai criar automaticamente o admin quando você logar
-- 5. Depois você pode criar outros funcionários pela interface
-- =====================================================
