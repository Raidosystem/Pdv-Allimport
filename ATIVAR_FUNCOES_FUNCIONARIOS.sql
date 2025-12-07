-- =====================================================
-- ATIVAR FUNÇÕES PARA FUNCIONÁRIOS EXISTENTES
-- =====================================================
-- Este script associa funções aos funcionários que ainda
-- não possuem função atribuída
-- =====================================================

BEGIN;

-- =====================================================
-- PASSO 1: Verificar funcionários sem função
-- =====================================================
SELECT 
  '📋 FUNCIONÁRIOS SEM FUNÇÃO' as status,
  id,
  nome,
  email,
  funcao_id
FROM funcionarios
WHERE funcao_id IS NULL
ORDER BY nome;

-- =====================================================
-- PASSO 2: Atribuir função "Vendedor" como padrão
-- para funcionários sem função
-- =====================================================
DO $$
DECLARE
  v_funcao_vendedor_id UUID;
  v_count INTEGER := 0;
BEGIN
  -- Buscar ID da função Vendedor
  SELECT id INTO v_funcao_vendedor_id
  FROM funcoes
  WHERE nome = 'Vendedor'
  LIMIT 1;
  
  IF v_funcao_vendedor_id IS NULL THEN
    RAISE EXCEPTION '❌ ERRO: Função Vendedor não encontrada! Execute primeiro: ATIVAR_PERMISSOES_PADRAO_FUNCOES_CORRIGIDO.sql';
  END IF;
  
  -- Atualizar funcionários sem função para Vendedor
  UPDATE funcionarios
  SET funcao_id = v_funcao_vendedor_id
  WHERE funcao_id IS NULL;
  
  GET DIAGNOSTICS v_count = ROW_COUNT;
  
  RAISE NOTICE '✅ % funcionário(s) recebeu(ram) a função Vendedor por padrão', v_count;
END $$;

COMMIT;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- 1. Resumo de funcionários por função
SELECT 
  '📊 FUNCIONÁRIOS POR FUNÇÃO' as status,
  f.nome as funcao,
  COUNT(func.id) as total_funcionarios
FROM funcoes f
LEFT JOIN funcionarios func ON func.funcao_id = f.id
GROUP BY f.id, f.nome
ORDER BY COUNT(func.id) DESC, f.nome;

-- 2. Detalhe completo: Funcionário → Função → Permissões
SELECT 
  '🔍 FUNCIONÁRIOS COM PERMISSÕES' as status,
  func.nome as funcionario,
  func.email,
  f.nome as funcao,
  COUNT(DISTINCT fp.permissao_id) as total_permissoes,
  COUNT(DISTINCT p.categoria) as categorias
FROM funcionarios func
LEFT JOIN funcoes f ON func.funcao_id = f.id
LEFT JOIN funcao_permissoes fp ON f.id = fp.funcao_id
LEFT JOIN permissoes p ON fp.permissao_id = p.id
GROUP BY func.id, func.nome, func.email, f.nome
ORDER BY func.nome;

-- 3. Verificar se algum funcionário ainda está sem função
SELECT 
  '⚠️ FUNCIONÁRIOS AINDA SEM FUNÇÃO' as status,
  COUNT(*) as total
FROM funcionarios
WHERE funcao_id IS NULL;

-- =====================================================
-- ✅ PRONTO! FUNÇÕES ATIVADAS PARA FUNCIONÁRIOS!
-- =====================================================
-- 
-- 🎯 PRÓXIMOS PASSOS:
-- 
-- 1. Se quiser mudar a função de um funcionário específico:
--    UPDATE funcionarios 
--    SET funcao_id = (SELECT id FROM funcoes WHERE nome = 'Gerente')
--    WHERE email = 'email@exemplo.com';
-- 
-- 2. Para atribuir função Administrador a alguém:
--    UPDATE funcionarios 
--    SET funcao_id = (SELECT id FROM funcoes WHERE nome = 'Administrador')
--    WHERE email = 'admin@empresa.com';
-- 
-- 3. Verificar permissões de um funcionário específico:
--    SELECT p.categoria, p.recurso, p.acao
--    FROM funcionarios func
--    JOIN funcoes f ON func.funcao_id = f.id
--    JOIN funcao_permissoes fp ON f.id = fp.funcao_id
--    JOIN permissoes p ON fp.permissao_id = p.id
--    WHERE func.email = 'email@exemplo.com'
--    ORDER BY p.categoria, p.recurso, p.acao;
-- =====================================================
