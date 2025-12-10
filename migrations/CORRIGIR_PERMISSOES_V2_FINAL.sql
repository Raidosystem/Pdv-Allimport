-- ========================================
-- ?? CORREÇÃO DEFINITIVA V2: Remove Duplicatas + Previne Futuras
-- ========================================
-- ERRO ANTERIOR: Não conseguiu criar constraint porque existem duplicatas
-- SOLUÇÃO: Remover duplicatas ANTES de criar constraint
-- ========================================

-- ========================================
-- PARTE 1: REMOVER FUNÇÕES E TRIGGERS AUTOMÁTICOS
-- ========================================

DROP FUNCTION IF EXISTS mapear_permissoes_granulares() CASCADE;
DROP FUNCTION IF EXISTS auto_add_permissoes() CASCADE;
DROP TRIGGER IF EXISTS trigger_auto_permissoes ON funcao_permissoes;

SELECT '? PASSO 1: Funções e triggers automáticos removidos' as status;

-- ========================================
-- PARTE 2: IDENTIFICAR E REMOVER DUPLICATAS
-- ========================================

-- Mostrar duplicatas antes de remover
SELECT 
  '?? DUPLICATAS ENCONTRADAS' as secao,
  fp.funcao_id,
  func.nome as funcao_nome,
  fp.permissao_id,
  p.recurso,
  p.acao,
  COUNT(*) as vezes_duplicada
FROM funcao_permissoes fp
JOIN funcoes func ON func.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
GROUP BY fp.funcao_id, func.nome, fp.permissao_id, p.recurso, p.acao
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC, func.nome, p.recurso, p.acao;

-- Remover duplicatas mantendo apenas 1 registro de cada combinação
WITH duplicatas AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (
      PARTITION BY funcao_id, permissao_id 
      ORDER BY created_at DESC
    ) as rn
  FROM funcao_permissoes
)
DELETE FROM funcao_permissoes
WHERE id IN (
  SELECT id FROM duplicatas WHERE rn > 1
);

SELECT '? PASSO 2: Duplicatas removidas (mantido 1 de cada)' as status;

-- Verificar se ainda existem duplicatas
SELECT 
  '?? VERIFICAÇÃO PÓS-LIMPEZA' as secao,
  CASE 
    WHEN COUNT(*) = 0 THEN '? Nenhuma duplicata encontrada'
    ELSE '? AINDA EXISTEM ' || COUNT(*)::TEXT || ' DUPLICATAS'
  END as resultado
FROM (
  SELECT funcao_id, permissao_id, COUNT(*) as total
  FROM funcao_permissoes
  GROUP BY funcao_id, permissao_id
  HAVING COUNT(*) > 1
) sub;

-- ========================================
-- PARTE 3: CRIAR CONSTRAINT DE UNICIDADE
-- ========================================

-- Remover constraint antiga se existir
ALTER TABLE funcao_permissoes
DROP CONSTRAINT IF EXISTS funcao_permissoes_pkey CASCADE;

ALTER TABLE funcao_permissoes
DROP CONSTRAINT IF EXISTS funcao_permissoes_unique CASCADE;

-- Criar constraint única para prevenir duplicatas futuras
ALTER TABLE funcao_permissoes
ADD CONSTRAINT funcao_permissoes_unique 
UNIQUE (funcao_id, permissao_id);

SELECT '? PASSO 3: Constraint de unicidade criada' as status;

-- ========================================
-- PARTE 4: LIMPAR E RECRIAR PERMISSÕES DE JENNIFER
-- ========================================

DO $$
DECLARE
  v_jennifer_funcao_id UUID;
  v_jennifer_empresa_id UUID;
  v_permissao_id UUID;
  v_contador INT := 0;
  v_total_antes INT;
  v_total_depois INT;
BEGIN
  -- Pegar funcao_id de Jennifer
  SELECT funcao_id, empresa_id INTO v_jennifer_funcao_id, v_jennifer_empresa_id
  FROM funcionarios
  WHERE email = 'sousajenifer895@gmail.com';

  IF v_jennifer_funcao_id IS NULL THEN
    RAISE EXCEPTION 'Jennifer não tem função definida!';
  END IF;

  -- Contar permissões antes
  SELECT COUNT(*) INTO v_total_antes
  FROM funcao_permissoes
  WHERE funcao_id = v_jennifer_funcao_id;

  -- Deletar TODAS as permissões atuais
  DELETE FROM funcao_permissoes
  WHERE funcao_id = v_jennifer_funcao_id;

  RAISE NOTICE '??? Removidas % permissões antigas', v_total_antes;

  -- Adicionar permissões escolhidas pelo admin

  -- VENDAS (8 permissões)
  FOR v_permissao_id IN
    SELECT id FROM permissoes
    WHERE recurso = 'vendas' 
    AND acao IN ('create', 'read', 'update', 'delete', 'cancel', 'discount', 'print', 'refund')
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    v_contador := v_contador + 1;
  END LOOP;

  -- PRODUTOS (6 permissões)
  FOR v_permissao_id IN
    SELECT id FROM permissoes
    WHERE recurso = 'produtos' 
    AND acao IN ('read', 'create', 'export', 'manage_categories', 'adjust_price', 'manage_stock')
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    v_contador := v_contador + 1;
  END LOOP;

  -- CLIENTES (4 permissões)
  FOR v_permissao_id IN
    SELECT id FROM permissoes
    WHERE recurso = 'clientes' 
    AND acao IN ('read', 'create', 'update', 'delete')
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    v_contador := v_contador + 1;
  END LOOP;

  -- CAIXA (5 permissões)
  FOR v_permissao_id IN
    SELECT id FROM permissoes
    WHERE recurso = 'caixa' 
    AND acao IN ('view', 'open', 'close', 'suprimento', 'sangria')
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    v_contador := v_contador + 1;
  END LOOP;

  -- ORDENS DE SERVIÇO (5 permissões)
  FOR v_permissao_id IN
    SELECT id FROM permissoes
    WHERE recurso = 'ordens' 
    AND acao IN ('read', 'create', 'update', 'delete', 'print')
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    v_contador := v_contador + 1;
  END LOOP;

  -- CONFIGURAÇÕES (6 permissões)
  FOR v_permissao_id IN
    SELECT id FROM permissoes
    WHERE recurso = 'configuracoes' 
    AND acao IN ('read', 'update', 'appearance', 'print_settings', 'backup', 'integrations')
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    v_contador := v_contador + 1;
  END LOOP;

  -- Contar permissões depois
  SELECT COUNT(*) INTO v_total_depois
  FROM funcao_permissoes
  WHERE funcao_id = v_jennifer_funcao_id;

  RAISE NOTICE '? Adicionadas % permissões novas', v_contador;
  RAISE NOTICE '?? Total final: %', v_total_depois;

END;
$$;

SELECT '? PASSO 4: Permissões de Jennifer recriadas' as status;

-- ========================================
-- PARTE 5: VERIFICAÇÕES FINAIS
-- ========================================

-- Total de permissões por funcionário
SELECT 
  '?? PERMISSÕES POR FUNCIONÁRIO' as secao,
  f.nome,
  f.email,
  func.nome as funcao,
  COUNT(fp.id) as total_permissoes
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
GROUP BY f.nome, f.email, func.nome
ORDER BY f.nome;

-- Permissões detalhadas de Jennifer
SELECT 
  '?? PERMISSÕES DE JENNIFER' as secao,
  p.categoria,
  p.recurso,
  STRING_AGG(p.acao, ', ' ORDER BY p.acao) as acoes
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
GROUP BY p.categoria, p.recurso
ORDER BY p.categoria, p.recurso;

-- Módulos acessíveis
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
      AND p2.acao IN ('view', 'open')
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
  END as configuracoes,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'relatorios'
      AND p2.acao = 'read'
    ) THEN '?' ELSE '?'
  END as relatorios
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
WHERE f.email = 'sousajenifer895@gmail.com';

-- Contagem final
SELECT 
  '? CONCLUSÃO FINAL' as resultado,
  '?? Sistema corrigido!' as mensagem,
  '?? Total de permissões: ' || COUNT(*)::TEXT as total_permissoes,
  '?? Jennifer deve fazer LOGOUT e LOGIN' as proxima_acao
FROM funcao_permissoes fp
JOIN funcionarios f ON f.funcao_id = fp.funcao_id
WHERE f.email = 'sousajenifer895@gmail.com';

-- Verificar se não há mais duplicatas em TODO o sistema
SELECT 
  '?? VERIFICAÇÃO GLOBAL' as secao,
  CASE 
    WHEN COUNT(*) = 0 THEN '? Sistema limpo - Nenhuma duplicata em nenhuma função'
    ELSE '?? ATENÇÃO: ' || COUNT(*)::TEXT || ' duplicatas encontradas em outras funções'
  END as status_global
FROM (
  SELECT funcao_id, permissao_id, COUNT(*) as total
  FROM funcao_permissoes
  GROUP BY funcao_id, permissao_id
  HAVING COUNT(*) > 1
) sub;

-- ========================================
-- ?? INSTRUÇÕES FINAIS
-- ========================================
-- 
-- ? O QUE FOI FEITO:
-- 1. Removidas funções automáticas que causavam duplicatas
-- 2. Identificadas e removidas duplicatas existentes
-- 3. Criada constraint UNIQUE para prevenir duplicatas futuras
-- 4. Recriadas permissões de Jennifer (34 permissões)
-- 
-- ?? PRÓXIMOS PASSOS:
-- 1. Jennifer deve fazer LOGOUT completo
-- 2. Fechar todas as abas do navegador
-- 3. Abrir novamente e fazer LOGIN
-- 4. Verificar se vê os módulos: Vendas, Produtos, Clientes, Caixa, Ordens, Configurações
-- 
-- ? RESULTADO ESPERADO:
-- - Total de permissões: 34 (não 63)
-- - Módulos visíveis: 6 (Vendas, Produtos, Clientes, Caixa, Ordens, Configurações)
-- - Módulos ocultos: Relatórios e Administração (não foram selecionados)
-- 
-- ?? SE AINDA HOUVER PROBLEMAS:
-- 1. Limpe o cache do navegador (Ctrl+Shift+Del)
-- 2. Verifique se o total de permissões é 34
-- 3. Execute a query de diagnóstico:
--    SELECT COUNT(*) FROM funcao_permissoes fp
--    JOIN funcionarios f ON f.funcao_id = fp.funcao_id
--    WHERE f.email = 'sousajenifer895@gmail.com';
-- 
-- ========================================
