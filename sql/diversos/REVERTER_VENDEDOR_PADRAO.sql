-- ============================================
-- REVERTER FUNÇÃO VENDEDOR PARA PADRÃO CORRETO
-- ============================================
-- PROBLEMA: Função Vendedor tem 35 permissões (quase admin)
-- CORRETO: Vendedor deve ter apenas vendas e clientes básico

-- PASSO 1: Ver permissões ATUAIS da função Vendedor
SELECT 
  '❌ PERMISSÕES ATUAIS (INCORRETAS)' as info,
  COUNT(*) as total_permissoes
FROM funcao_permissoes fp
INNER JOIN funcoes f ON f.id = fp.funcao_id
WHERE LOWER(f.nome) LIKE '%vendedor%'
  AND f.empresa_id IN (
    SELECT id FROM empresas WHERE email LIKE '%allimport%'
  );

-- PASSO 2: LIMPAR todas as permissões da função Vendedor
DELETE FROM funcao_permissoes
WHERE funcao_id IN (
  SELECT id FROM funcoes 
  WHERE LOWER(nome) LIKE '%vendedor%'
    AND empresa_id IN (
      SELECT id FROM empresas WHERE email LIKE '%allimport%'
    )
);

-- PASSO 3: ADICIONAR apenas permissões CORRETAS para Vendedor
-- Baseado em DEPLOY_SISTEMA_PERMISSOES.md:
-- 🔵 VENDEDOR: Apenas vendas e cadastro de clientes

INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
SELECT 
  f.id as funcao_id,
  p.id as permissao_id,
  f.empresa_id
FROM funcoes f
CROSS JOIN permissoes p
WHERE LOWER(f.nome) LIKE '%vendedor%'
  AND f.empresa_id IN (
    SELECT id FROM empresas WHERE email LIKE '%allimport%'
  )
  AND (
    -- VENDAS: read, create, print
    (p.recurso = 'vendas' AND p.acao IN ('read', 'create', 'print')) OR
    
    -- CLIENTES: read, create, update (básico)
    (p.recurso = 'clientes' AND p.acao IN ('read', 'create', 'update')) OR
    
    -- PRODUTOS: apenas read (consulta)
    (p.recurso = 'produtos' AND p.acao = 'read')
  )
ON CONFLICT DO NOTHING;

-- PASSO 4: Verificar permissões CORRETAS aplicadas
SELECT 
  '✅ PERMISSÕES CORRETAS APLICADAS' as resultado,
  func.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcoes func
INNER JOIN funcao_permissoes fp ON fp.funcao_id = func.id
INNER JOIN permissoes p ON p.id = fp.permissao_id
WHERE LOWER(func.nome) LIKE '%vendedor%'
  AND func.empresa_id IN (
    SELECT id FROM empresas WHERE email LIKE '%allimport%'
  )
ORDER BY p.recurso, p.acao;

-- PASSO 5: Contar total de permissões
SELECT 
  '📊 RESUMO' as info,
  func.nome,
  COUNT(fp.id) as total_permissoes,
  CASE 
    WHEN COUNT(fp.id) <= 10 THEN '✅ CORRETO (Vendedor básico)'
    WHEN COUNT(fp.id) > 30 THEN '❌ ERRO (Muitas permissões)'
    ELSE '⚠️ VERIFICAR'
  END as status
FROM funcoes func
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE LOWER(func.nome) LIKE '%vendedor%'
  AND func.empresa_id IN (
    SELECT id FROM empresas WHERE email LIKE '%allimport%'
  )
GROUP BY func.id, func.nome;

-- ============================================
-- RESULTADO ESPERADO:
-- ✅ Vendedor com ~7 permissões:
--    - vendas:read, vendas:create, vendas:print
--    - clientes:read, clientes:create, clientes:update
--    - produtos:read
-- ============================================
