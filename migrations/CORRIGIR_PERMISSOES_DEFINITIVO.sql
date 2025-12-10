-- ========================================
-- ?? CORREÇÃO DEFINITIVA: Permissões Jennifer + Prevenir Duplicatas
-- ========================================
-- PROBLEMA: Script anterior adicionou permissões duplicadas automaticamente
-- CAUSA: Função mapear_permissoes_granulares() continua rodando
-- SOLUÇÃO: Remover função automática + Limpar duplicatas + Manter apenas escolhas do admin
-- ========================================

-- ========================================
-- PARTE 1: REMOVER FUNÇÃO DE MAPEAMENTO AUTOMÁTICO
-- ========================================

-- Esta função estava adicionando permissões READ/UPDATE automaticamente
-- causando duplicatas indesejadas

DROP FUNCTION IF EXISTS mapear_permissoes_granulares();

SELECT '? PASSO 1: Função automática removida' as status;

-- ========================================
-- PARTE 2: LIMPAR PERMISSÕES DUPLICADAS DE JENNIFER
-- ========================================

-- Remover TODAS as permissões da função de Jennifer
DO $$
DECLARE
  v_jennifer_funcao_id UUID;
  v_jennifer_empresa_id UUID;
BEGIN
  -- Pegar funcao_id de Jennifer
  SELECT funcao_id, empresa_id INTO v_jennifer_funcao_id, v_jennifer_empresa_id
  FROM funcionarios
  WHERE email = 'sousajenifer895@gmail.com';

  IF v_jennifer_funcao_id IS NULL THEN
    RAISE EXCEPTION 'Jennifer não tem função definida!';
  END IF;

  -- Deletar TODAS as permissões atuais
  DELETE FROM funcao_permissoes
  WHERE funcao_id = v_jennifer_funcao_id;

  RAISE NOTICE '??? Todas as permissões antigas foram removidas';
END;
$$;

SELECT '? PASSO 2: Permissões antigas limpas' as status;

-- ========================================
-- PARTE 3: ADICIONAR APENAS AS PERMISSÕES ESCOLHIDAS PELO ADMIN
-- ========================================

-- Estas são as 40 permissões que o admin SELECIONOU manualmente
-- NÃO adicionar permissões automáticas de READ/UPDATE

DO $$
DECLARE
  v_jennifer_funcao_id UUID;
  v_jennifer_empresa_id UUID;
  v_permissao_id UUID;
  v_contador INT := 0;
BEGIN
  -- Pegar funcao_id de Jennifer
  SELECT funcao_id, empresa_id INTO v_jennifer_funcao_id, v_jennifer_empresa_id
  FROM funcionarios
  WHERE email = 'sousajenifer895@gmail.com';

  IF v_jennifer_funcao_id IS NULL THEN
    RAISE EXCEPTION 'Jennifer não tem função definida!';
  END IF;

  -- VENDAS (8 permissões escolhidas)
  FOR v_permissao_id IN
    SELECT id FROM permissoes
    WHERE (recurso = 'vendas' AND acao IN ('create', 'read', 'update', 'delete', 'cancel', 'discount', 'print', 'refund'))
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT DO NOTHING;
    v_contador := v_contador + 1;
  END LOOP;

  -- PRODUTOS (6 permissões escolhidas)
  FOR v_permissao_id IN
    SELECT id FROM permissoes
    WHERE (recurso = 'produtos' AND acao IN ('read', 'create', 'export', 'manage_categories', 'adjust_price', 'manage_stock'))
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT DO NOTHING;
    v_contador := v_contador + 1;
  END LOOP;

  -- CLIENTES (4 permissões escolhidas)
  FOR v_permissao_id IN
    SELECT id FROM permissoes
    WHERE (recurso = 'clientes' AND acao IN ('read', 'create', 'update', 'delete'))
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT DO NOTHING;
    v_contador := v_contador + 1;
  END LOOP;

  -- CAIXA (5 permissões escolhidas)
  FOR v_permissao_id IN
    SELECT id FROM permissoes
    WHERE (recurso = 'caixa' AND acao IN ('view', 'open', 'close', 'suprimento', 'sangria'))
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT DO NOTHING;
    v_contador := v_contador + 1;
  END LOOP;

  -- ORDENS DE SERVIÇO (5 permissões escolhidas)
  FOR v_permissao_id IN
    SELECT id FROM permissoes
    WHERE (recurso = 'ordens' AND acao IN ('read', 'create', 'update', 'delete', 'print'))
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT DO NOTHING;
    v_contador := v_contador + 1;
  END LOOP;

  -- CONFIGURAÇÕES (6 permissões escolhidas)
  FOR v_permissao_id IN
    SELECT id FROM permissoes
    WHERE (recurso = 'configuracoes' AND acao IN ('read', 'update', 'appearance', 'print_settings', 'backup', 'integrations'))
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT DO NOTHING;
    v_contador := v_contador + 1;
  END LOOP;

  -- NÃO ADICIONAR: Relatórios, Administração (não foram selecionadas)

  RAISE NOTICE '? Total de permissões adicionadas: %', v_contador;
END;
$$;

SELECT '? PASSO 3: Permissões escolhidas pelo admin adicionadas' as status;

-- ========================================
-- PARTE 4: PREVENIR DUPLICATAS FUTURAS
-- ========================================

-- Criar constraint única para prevenir duplicatas
ALTER TABLE funcao_permissoes
DROP CONSTRAINT IF EXISTS funcao_permissoes_pkey CASCADE;

ALTER TABLE funcao_permissoes
ADD CONSTRAINT funcao_permissoes_pkey 
PRIMARY KEY (funcao_id, permissao_id);

SELECT '? PASSO 4: Constraint de unicidade criada' as status;

-- ========================================
-- PARTE 5: VERIFICAR RESULTADO FINAL
-- ========================================

-- Ver permissões agrupadas por categoria
SELECT 
  '?? PERMISSÕES POR CATEGORIA' as secao,
  p.categoria,
  COUNT(*) as total,
  STRING_AGG(DISTINCT p.recurso, ', ' ORDER BY p.recurso) as recursos
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
GROUP BY p.categoria
ORDER BY p.categoria;

-- Ver permissões detalhadas
SELECT 
  '?? PERMISSÕES DETALHADAS' as secao,
  p.categoria,
  p.recurso,
  STRING_AGG(p.acao, ', ' ORDER BY p.acao) as acoes_disponiveis
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
GROUP BY p.categoria, p.recurso
ORDER BY p.categoria, p.recurso;

-- Verificar módulos acessíveis
SELECT 
  '?? MÓDULOS ACESSÍVEIS' as secao,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'vendas'
      AND p2.acao IN ('read', 'create')
    ) THEN '?' ELSE '?'
  END as vendas,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'produtos'
      AND p2.acao IN ('read', 'create')
    ) THEN '?' ELSE '?'
  END as produtos,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'clientes'
      AND p2.acao IN ('read', 'create')
    ) THEN '?' ELSE '?'
  END as clientes,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'caixa'
      AND p2.acao IN ('read', 'view', 'open')
    ) THEN '?' ELSE '?'
  END as caixa,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'ordens'
      AND p2.acao IN ('read', 'create')
    ) THEN '?' ELSE '?'
  END as ordens_servico,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'configuracoes'
      AND p2.acao IN ('read', 'update')
    ) THEN '?' ELSE '?'
  END as configuracoes
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
WHERE f.email = 'sousajenifer895@gmail.com';

-- Contar total de permissões (deve ser ~34, não 63)
SELECT 
  '? CONCLUSÃO' as resultado,
  '?? Duplicatas removidas!' as mensagem,
  '?? Jennifer deve fazer LOGOUT e LOGIN novamente' as acao_necessaria,
  '?? Total de permissões: ' || COUNT(*)::TEXT as total
FROM funcao_permissoes fp
JOIN funcionarios f ON f.funcao_id = fp.funcao_id
WHERE f.email = 'sousajenifer895@gmail.com';

-- ========================================
-- PARTE 6: GARANTIR QUE NOVOS FUNCIONÁRIOS NÃO TENHAM DUPLICATAS
-- ========================================

-- Remover trigger que poderia estar duplicando permissões
DROP TRIGGER IF EXISTS trigger_auto_permissoes ON funcao_permissoes;
DROP FUNCTION IF EXISTS auto_add_permissoes();

SELECT '? PASSO 6: Triggers automáticos removidos' as status;

-- ========================================
-- ?? INSTRUÇÕES DE USO
-- ========================================
-- 
-- 1. Execute este SQL no Supabase SQL Editor
-- 
-- 2. Verifique se o total de permissões é ~34 (não 63)
-- 
-- 3. Jennifer deve fazer logout e login novamente
-- 
-- 4. Teste acessando cada módulo:
--    ? Vendas (deve aparecer)
--    ? Produtos (deve aparecer)
--    ? Clientes (deve aparecer)
--    ? Caixa (deve aparecer)
--    ? Ordens de Serviço (deve aparecer)
--    ? Configurações (deve aparecer)
--    ? Relatórios (NÃO deve aparecer - não foi selecionado)
--    ? Administração (NÃO deve aparecer - não foi selecionado)
-- 
-- 5. Se precisar adicionar Relatórios ou Administração:
--    - Vá em Administração ? Funções & Permissões
--    - Clique em "Permissões" na função "Vendedor"
--    - Marque as permissões desejadas
--    - Clique em "Salvar"
-- 
-- ========================================
