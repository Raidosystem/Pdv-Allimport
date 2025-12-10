-- ============================================
-- CORRIGIR PERMISSÕES DA JENNIFER (SEM COLUNA ATIVO)
-- ============================================

-- ============================================
-- 1️⃣ VER PERMISSÕES ATUAIS DA JENNIFER
-- ============================================
SELECT 
  f.nome as funcionario,
  fn.nome as funcao,
  p.modulo,
  p.recurso,
  p.acao,
  fp.id as funcao_permissao_id
FROM funcionarios f
JOIN funcoes fn ON f.funcao_id = fn.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = fn.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE LOWER(f.nome) LIKE '%jennifer%'
ORDER BY p.modulo, p.recurso, p.acao;

-- ============================================
-- 2️⃣ REMOVER PERMISSÕES PERIGOSAS (EXCLUIR)
-- ============================================

-- Remover permissão de EXCLUIR produtos
DELETE FROM funcao_permissoes
WHERE funcao_id IN (
  SELECT funcao_id FROM funcionarios WHERE LOWER(nome) LIKE '%jennifer%'
)
AND permissao_id IN (
  SELECT id FROM permissoes WHERE recurso = 'produtos' AND acao = 'delete'
);

-- Remover permissão de EXCLUIR clientes
DELETE FROM funcao_permissoes
WHERE funcao_id IN (
  SELECT funcao_id FROM funcionarios WHERE LOWER(nome) LIKE '%jennifer%'
)
AND permissao_id IN (
  SELECT id FROM permissoes WHERE recurso = 'clientes' AND acao = 'delete'
);

-- ============================================
-- 3️⃣ REMOVER ACESSO A CONFIGURAÇÕES
-- ============================================

-- Remover TODAS as permissões do módulo "configuracoes"
DELETE FROM funcao_permissoes
WHERE funcao_id IN (
  SELECT funcao_id FROM funcionarios WHERE LOWER(nome) LIKE '%jennifer%'
)
AND permissao_id IN (
  SELECT id FROM permissoes WHERE modulo = 'configuracoes'
);

-- Remover TODAS as permissões do módulo "administracao"
DELETE FROM funcao_permissoes
WHERE funcao_id IN (
  SELECT funcao_id FROM funcionarios WHERE LOWER(nome) LIKE '%jennifer%'
)
AND permissao_id IN (
  SELECT id FROM permissoes WHERE modulo = 'administracao'
);

-- ============================================
-- 4️⃣ GARANTIR PERMISSÕES BÁSICAS (READ)
-- ============================================

-- Inserir permissões de LEITURA se não existirem
DO $$
DECLARE
  v_funcao_id uuid;
  v_empresa_id uuid;
  v_permissao_id uuid;
BEGIN
  -- Buscar funcao_id da Jennifer
  SELECT funcao_id, empresa_id 
  INTO v_funcao_id, v_empresa_id
  FROM funcionarios 
  WHERE LOWER(nome) LIKE '%jennifer%'
  LIMIT 1;
  
  IF v_funcao_id IS NULL THEN
    RAISE NOTICE '❌ Jennifer não encontrada';
    RETURN;
  END IF;
  
  RAISE NOTICE '✅ Jennifer encontrada: funcao_id = %, empresa_id = %', v_funcao_id, v_empresa_id;
  
  -- Inserir permissões de READ para vendas
  FOR v_permissao_id IN 
    SELECT id FROM permissoes 
    WHERE modulo = 'vendas' AND acao = 'read'
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao_id, v_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;
  
  -- Inserir permissões de READ para produtos
  FOR v_permissao_id IN 
    SELECT id FROM permissoes 
    WHERE recurso = 'produtos' AND acao = 'read'
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao_id, v_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;
  
  -- Inserir permissões de READ para clientes
  FOR v_permissao_id IN 
    SELECT id FROM permissoes 
    WHERE recurso = 'clientes' AND acao = 'read'
  LOOP
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_permissao_id, v_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;
  
  RAISE NOTICE '✅ Permissões de leitura garantidas';
END $$;

-- ============================================
-- 5️⃣ VERIFICAÇÃO FINAL
-- ============================================
SELECT 
  f.nome as funcionario,
  fn.nome as funcao,
  p.modulo,
  p.recurso,
  p.acao,
  CASE 
    WHEN p.modulo = 'configuracoes' THEN '❌ NÃO DEVERIA EXISTIR'
    WHEN p.modulo = 'administracao' THEN '❌ NÃO DEVERIA EXISTIR'
    WHEN p.acao = 'delete' AND p.recurso IN ('produtos', 'clientes') THEN '❌ NÃO DEVERIA EXISTIR'
    ELSE '✅ OK'
  END as status
FROM funcionarios f
JOIN funcoes fn ON f.funcao_id = fn.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = fn.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE LOWER(f.nome) LIKE '%jennifer%'
ORDER BY p.modulo, p.recurso, p.acao;

-- ============================================
-- ✅ RESUMO ESPERADO PARA JENNIFER
-- ============================================
-- ✅ Vendas: Apenas READ (visualizar)
-- ✅ Produtos: Apenas READ (visualizar)
-- ✅ Clientes: Apenas READ (visualizar)
-- ❌ Configurações: NENHUMA permissão
-- ❌ Administração: NENHUMA permissão
-- ❌ Delete (excluir): NENHUMA permissão
