-- 🔍 VERIFICAÇÃO SIMPLES - SISTEMA DE FUNÇÕES E PERMISSÕES

-- ====================================
-- 1. VERIFICAR QUAIS TABELAS EXISTEM
-- ====================================
SELECT 
  '📋 TABELAS EXISTENTES' as categoria,
  table_name,
  CASE 
    WHEN table_name = 'funcoes' THEN '✅ Funções (cargos/roles)'
    WHEN table_name = 'permissoes' THEN '✅ Permissões específicas'
    WHEN table_name = 'funcao_permissoes' THEN '✅ Relacionamento função-permissão'
    WHEN table_name = 'funcionario_funcoes' THEN '✅ Funcionários e suas funções'
    ELSE '✅ Outra tabela'
  END as status
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('funcoes', 'permissoes', 'funcao_permissoes', 'funcionario_funcoes')
ORDER BY table_name;

-- ====================================
-- 2. CONTAR REGISTROS (APENAS SE TABELAS EXISTIREM)
-- ====================================
DO $$
DECLARE
  v_count INTEGER;
BEGIN
  -- Verificar funcoes
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcoes') THEN
    SELECT COUNT(*) INTO v_count FROM funcoes;
    RAISE NOTICE '📊 Tabela funcoes: % registros', v_count;
  ELSE
    RAISE NOTICE '❌ Tabela funcoes NÃO EXISTE';
  END IF;
  
  -- Verificar permissoes
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'permissoes') THEN
    SELECT COUNT(*) INTO v_count FROM permissoes;
    RAISE NOTICE '📊 Tabela permissoes: % registros', v_count;
  ELSE
    RAISE NOTICE '❌ Tabela permissoes NÃO EXISTE';
  END IF;
  
  -- Verificar funcao_permissoes
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcao_permissoes') THEN
    SELECT COUNT(*) INTO v_count FROM funcao_permissoes;
    RAISE NOTICE '📊 Tabela funcao_permissoes: % registros', v_count;
  ELSE
    RAISE NOTICE '❌ Tabela funcao_permissoes NÃO EXISTE';
  END IF;
  
  -- Verificar funcionario_funcoes
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcionario_funcoes') THEN
    SELECT COUNT(*) INTO v_count FROM funcionario_funcoes;
    RAISE NOTICE '📊 Tabela funcionario_funcoes: % registros', v_count;
  ELSE
    RAISE NOTICE '❌ Tabela funcionario_funcoes NÃO EXISTE';
  END IF;
END $$;

-- ====================================
-- 3. VERIFICAR ESTRUTURA DAS TABELAS EXISTENTES
-- ====================================
SELECT 
  '🏗️ ESTRUTURA DAS TABELAS' as categoria,
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('funcoes', 'permissoes', 'funcao_permissoes', 'funcionario_funcoes')
ORDER BY table_name, ordinal_position;

-- ====================================
-- 4. DIAGNÓSTICO FINAL
-- ====================================
SELECT 
  '💡 DIAGNÓSTICO FINAL' as categoria,
  CASE 
    WHEN NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcoes')
    THEN '❌ SISTEMA DE FUNÇÕES COMPLETAMENTE REMOVIDO - Execute RESTAURAR_SISTEMA_FUNCOES_PERMISSOES.sql'
    WHEN EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcoes')
         AND NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'funcoes' AND column_name = 'nome')
    THEN '❌ TABELA FUNCOES EXISTE MAS ESTRUTURA INCORRETA - Execute RESTAURAR_SISTEMA_FUNCOES_PERMISSOES.sql'
    ELSE '✅ ESTRUTURA BÁSICA OK - Verifique se tem dados'
  END as resultado;