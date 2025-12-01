-- =====================================================
-- DIAGNÓSTICO FINAL - VERIFICAR SE RECURSÃO FOI CORRIGIDA
-- =====================================================

-- 🔍 PASSO 1: Verificar políticas atuais
SELECT 
  '✅ Políticas da tabela permissoes:' as titulo;

SELECT 
  policyname as "Política",
  cmd as "Comando",
  CASE 
    WHEN cmd = 'SELECT' THEN '📖 Leitura'
    WHEN cmd = 'INSERT' THEN '✏️ Inserção'
    WHEN cmd = 'UPDATE' THEN '🔄 Atualização'
    WHEN cmd = 'DELETE' THEN '🗑️ Exclusão'
  END as "Tipo"
FROM pg_policies
WHERE tablename = 'permissoes'
  AND schemaname = 'public'
ORDER BY cmd;

-- 🔍 PASSO 2: Verificar se há referências circulares
SELECT 
  '⚠️ Políticas que podem causar recursão (deveria estar vazio):' as titulo;

SELECT 
  tablename as "Tabela",
  policyname as "Política",
  cmd as "Comando"
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'permissoes'
  AND (
    qual::text LIKE '%permissoes%' 
    OR with_check::text LIKE '%permissoes%'
  )
ORDER BY tablename, policyname;

-- 🔍 PASSO 3: Testar queries sem recursão
SELECT 
  '📊 Teste 1: Contar permissões' as teste;

SELECT 
  COUNT(*) as total_permissoes,
  COUNT(DISTINCT categoria) as total_categorias,
  COUNT(DISTINCT recurso) as total_recursos
FROM permissoes;

SELECT 
  '📊 Teste 2: Agrupar por categoria' as teste;

SELECT 
  categoria,
  COUNT(*) as quantidade
FROM permissoes
GROUP BY categoria
ORDER BY categoria;

SELECT 
  '📊 Teste 3: Permissões por recurso' as teste;

SELECT 
  recurso,
  COUNT(*) as total_acoes,
  STRING_AGG(DISTINCT acao, ', ') as acoes
FROM permissoes
GROUP BY recurso
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 🔍 PASSO 4: Verificar estrutura da tabela
SELECT 
  '🗂️ Estrutura da tabela permissoes:' as titulo;

SELECT 
  column_name as "Coluna",
  data_type as "Tipo",
  is_nullable as "Nullable",
  column_default as "Padrão"
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'permissoes'
ORDER BY ordinal_position;

-- 🔍 PASSO 5: Verificar índices
SELECT 
  '📑 Índices da tabela permissoes:' as titulo;

SELECT 
  indexname as "Índice",
  indexdef as "Definição"
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'permissoes'
ORDER BY indexname;

-- ✅ PASSO 6: Resultado final
DO $$
DECLARE
  total_policies INTEGER;
  total_permissoes INTEGER;
  tem_recursao BOOLEAN;
BEGIN
  -- Contar políticas
  SELECT COUNT(*) INTO total_policies
  FROM pg_policies
  WHERE tablename = 'permissoes';
  
  -- Contar permissões
  SELECT COUNT(*) INTO total_permissoes
  FROM permissoes;
  
  -- Verificar se há recursão
  SELECT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'permissoes'
      AND (qual::text LIKE '%permissoes%' OR with_check::text LIKE '%permissoes%')
  ) INTO tem_recursao;
  
  RAISE NOTICE '================================';
  RAISE NOTICE '🎯 DIAGNÓSTICO FINAL';
  RAISE NOTICE '================================';
  RAISE NOTICE '📊 Total de políticas RLS: %', total_policies;
  RAISE NOTICE '📊 Total de permissões: %', total_permissoes;
  
  IF tem_recursao THEN
    RAISE WARNING '⚠️ ATENÇÃO: Ainda há risco de recursão nas políticas!';
  ELSE
    RAISE NOTICE '✅ Sem recursão detectada';
  END IF;
  
  IF total_policies = 4 AND total_permissoes >= 90 AND NOT tem_recursao THEN
    RAISE NOTICE '✅✅✅ TUDO CORRETO! Sistema funcionando normalmente.';
  ELSE
    RAISE WARNING '⚠️ Pode haver problemas. Verifique os resultados acima.';
  END IF;
  
  RAISE NOTICE '================================';
END $$;

-- 🔍 PASSO 7: Testar query complexa (simula o que o frontend faz)
SELECT 
  '🧪 Teste avançado: Simulando query do frontend' as teste;

WITH user_context AS (
  SELECT 
    auth.uid() as current_user_id,
    EXISTS (
      SELECT 1 FROM empresas WHERE user_id = auth.uid()
    ) as is_admin
)
SELECT 
  p.id,
  p.recurso,
  p.acao,
  p.descricao,
  p.categoria,
  uc.is_admin
FROM permissoes p
CROSS JOIN user_context uc
ORDER BY p.categoria, p.recurso, p.acao
LIMIT 10;

-- =====================================================
-- 🎯 RESULTADO ESPERADO:
-- =====================================================
-- ✅ 4 políticas (SELECT, INSERT, UPDATE, DELETE)
-- ✅ 91 permissões carregadas
-- ✅ Sem recursão detectada
-- ✅ Todos os testes executam sem erro 42P17
-- =====================================================
