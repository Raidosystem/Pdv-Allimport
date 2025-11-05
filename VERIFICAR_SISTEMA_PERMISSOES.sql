-- 🔍 VERIFICAR SISTEMA DE FUNÇÕES E PERMISSÕES DO PDV

-- ====================================
-- 1. VERIFICAR TABELAS DE FUNÇÕES E PERMISSÕES
-- ====================================
SELECT 
  '📋 TABELAS DO SISTEMA' as categoria,
  table_name,
  CASE 
    WHEN table_name = 'funcoes' THEN 'Funções do sistema (cargos/roles)'
    WHEN table_name = 'permissoes' THEN 'Permissões específicas'
    WHEN table_name = 'funcao_permissoes' THEN 'Relacionamento função-permissão'
    WHEN table_name = 'funcionario_funcoes' THEN 'Funcionários e suas funções'
    ELSE 'Outra tabela'
  END as descricao
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('funcoes', 'permissoes', 'funcao_permissoes', 'funcionario_funcoes')
ORDER BY table_name;

-- ====================================
-- 2. CONTAR DADOS EM CADA TABELA
-- ====================================
SELECT 
  '📊 CONTAGEM DE DADOS' as categoria,
  (SELECT COUNT(*) FROM funcoes) as total_funcoes,
  (SELECT COUNT(*) FROM permissoes) as total_permissoes,
  (SELECT COUNT(*) FROM funcao_permissoes) as total_funcao_permissoes,
  (SELECT COUNT(*) FROM funcionario_funcoes) as total_funcionario_funcoes;

-- ====================================
-- 3. MOSTRAR FUNÇÕES EXISTENTES (SE TABELA EXISTIR)
-- ====================================
DO $$
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcoes') THEN
    PERFORM 1; -- Tabela existe, mas pode não ter as colunas esperadas
  ELSE
    RAISE NOTICE '❌ Tabela funcoes não existe';
  END IF;
END $$;

-- ====================================
-- 4. MOSTRAR PERMISSÕES EXISTENTES (SE TABELA EXISTIR)
-- ====================================
DO $$
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'permissoes') THEN
    PERFORM 1; -- Tabela existe, mas pode não ter as colunas esperadas
  ELSE
    RAISE NOTICE '❌ Tabela permissoes não existe';
  END IF;
END $$;

-- ====================================
-- 5. VERIFICAR RELACIONAMENTOS (SE TABELAS EXISTIREM)
-- ====================================
DO $$
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcoes') 
     AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcao_permissoes')
     AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'permissoes') THEN
    RAISE NOTICE '✅ Tabelas de relacionamento existem';
  ELSE
    RAISE NOTICE '❌ Algumas tabelas de relacionamento não existem';
  END IF;
END $$;

-- ====================================
-- 6. VERIFICAR FUNCIONÁRIOS E SUAS FUNÇÕES (SE TABELAS EXISTIREM)
-- ====================================
DO $$
BEGIN
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcionario_funcoes') THEN
    RAISE NOTICE '✅ Tabela funcionario_funcoes existe';
  ELSE
    RAISE NOTICE '❌ Tabela funcionario_funcoes não existe';
  END IF;
END $$;

-- ====================================
-- 7. ESTRUTURA DAS TABELAS
-- ====================================
SELECT 
  '🏗️ ESTRUTURA TABELA FUNCOES' as categoria,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'funcoes'
ORDER BY ordinal_position;

SELECT 
  '🏗️ ESTRUTURA TABELA PERMISSOES' as categoria,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'permissoes'
ORDER BY ordinal_position;

-- ====================================
-- 8. DIAGNÓSTICO FINAL
-- ====================================
SELECT 
  '💡 DIAGNÓSTICO SISTEMA DE PERMISSÕES' as categoria,
  CASE 
    WHEN NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcoes')
    THEN '❌ TABELA FUNCOES NÃO EXISTE - Sistema de permissões foi removido!'
    WHEN NOT EXISTS (SELECT FROM funcoes)
    THEN '❌ NENHUMA FUNÇÃO CADASTRADA - Tabela existe mas está vazia'
    ELSE '✅ SISTEMA DE PERMISSÕES OK'
  END as resultado;