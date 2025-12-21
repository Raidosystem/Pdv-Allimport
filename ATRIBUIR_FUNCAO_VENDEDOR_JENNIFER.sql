-- ========================================
-- CRIAR/ATRIBUIR FUNÇÃO VENDEDOR PARA JENNIFER
-- ========================================
-- Problema: Jennifer não tem função atribuída (funcao_id = NULL)
-- Solução: Criar função Vendedor e atribuir com todas as permissões corretas

-- ========================================
-- 1️⃣ VERIFICAR EMPRESA DA JENNIFER
-- ========================================
SELECT 
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.empresa_id,
  f.funcao_id,
  e.nome as empresa_nome
FROM funcionarios f
LEFT JOIN empresas e ON e.id = f.empresa_id
WHERE f.email LIKE '%jennifer%' OR f.email LIKE '%sousajenifer%';

-- ========================================
-- 2️⃣ CRIAR FUNÇÃO VENDEDOR (se não existir)
-- ========================================
-- Buscar UUID da empresa da Jennifer do resultado acima
-- Substitua 'SEU_EMPRESA_ID_AQUI' pelo empresa_id real

DO $$
DECLARE
  v_empresa_id UUID;
  v_funcao_id UUID;
BEGIN
  -- Buscar empresa da Jennifer
  SELECT empresa_id INTO v_empresa_id
  FROM funcionarios
  WHERE email LIKE '%sousajenifer%'
  LIMIT 1;

  -- Verificar se já existe função Vendedor
  SELECT id INTO v_funcao_id
  FROM funcoes
  WHERE empresa_id = v_empresa_id
    AND nome = 'Vendedor'
  LIMIT 1;

  -- Criar se não existir
  IF v_funcao_id IS NULL THEN
    INSERT INTO funcoes (empresa_id, nome, descricao)
    VALUES (
      v_empresa_id,
      'Vendedor',
      'Vendas, clientes e produtos - Acesso operacional'
    )
    RETURNING id INTO v_funcao_id;
    
    RAISE NOTICE '✅ Função Vendedor criada: %', v_funcao_id;
  ELSE
    RAISE NOTICE '✅ Função Vendedor já existe: %', v_funcao_id;
  END IF;

  -- Limpar permissões antigas (se houver)
  DELETE FROM funcao_permissoes 
  WHERE funcao_id = v_funcao_id;
  
  RAISE NOTICE '🧹 Permissões antigas limpas';

  -- Atribuir permissões corretas para VENDEDOR
  INSERT INTO funcao_permissoes (empresa_id, funcao_id, permissao_id)
  SELECT 
    v_empresa_id,
    v_funcao_id,
    p.id
  FROM permissoes p
  WHERE 
    -- Vendas: TODAS as ações
    (p.recurso = 'vendas' AND p.acao IN ('read', 'create', 'update', 'delete'))
    -- Clientes: criar, ler, atualizar (NÃO deletar)
    OR (p.recurso = 'clientes' AND p.acao IN ('read', 'create', 'update'))
    -- Produtos: APENAS leitura
    OR (p.recurso = 'produtos' AND p.acao = 'read')
    -- Caixa: APENAS leitura (não abre/fecha)
    OR (p.recurso = 'caixa' AND p.acao = 'read')
    -- Relatórios: leitura básica
    OR (p.recurso = 'relatorios' AND p.acao = 'read')
  ON CONFLICT DO NOTHING;

  RAISE NOTICE '✅ Permissões de Vendedor atribuídas';

  -- Atribuir função à Jennifer
  UPDATE funcionarios
  SET funcao_id = v_funcao_id
  WHERE email LIKE '%sousajenifer%';

  RAISE NOTICE '✅ Função Vendedor atribuída à Jennifer';
END $$;

-- ========================================
-- 3️⃣ VERIFICAÇÃO: Confirmar configuração
-- ========================================
SELECT 
  f.nome,
  f.email,
  f.tipo_admin,
  func.nome as funcao,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE f.email LIKE '%jennifer%' OR f.email LIKE '%sousajenifer%'
GROUP BY f.id, f.nome, f.email, f.tipo_admin, func.nome;

-- Resultado esperado:
-- Jennifer | sousajenifer895@gmail.com | funcionario | Vendedor | 13 permissões

-- ========================================
-- 4️⃣ LISTAR PERMISSÕES ATRIBUÍDAS
-- ========================================
SELECT 
  f.nome as funcionario,
  func.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcionarios f
JOIN funcoes func ON func.id = f.funcao_id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email LIKE '%jennifer%' OR f.email LIKE '%sousajenifer%'
ORDER BY p.recurso, p.acao;

-- ========================================
-- 5️⃣ TESTE FINAL: Verificar tipo_admin
-- ========================================
SELECT 
  nome,
  email,
  tipo_admin,
  CASE 
    WHEN tipo_admin = 'funcionario' THEN '✅ CORRETO'
    WHEN tipo_admin = 'admin_empresa' THEN '❌ ERRO - Tem acesso de ADMIN!'
    ELSE '⚠️ VERIFICAR'
  END as validacao
FROM funcionarios
WHERE email LIKE '%jennifer%' OR email LIKE '%sousajenifer%';

-- ✅ DEVE MOSTRAR:
-- Jennifer | sousajenifer895@gmail.com | funcionario | ✅ CORRETO

-- ========================================
-- 📋 PERMISSÕES DO VENDEDOR (13 total)
-- ========================================
-- ✅ vendas:read
-- ✅ vendas:create
-- ✅ vendas:update
-- ✅ vendas:delete
-- ✅ clientes:read
-- ✅ clientes:create
-- ✅ clientes:update
-- ✅ produtos:read
-- ✅ caixa:read
-- ✅ relatorios:read
-- 
-- ❌ NÃO TEM:
-- - clientes:delete (só admin)
-- - produtos:create/update/delete (só admin/gerente)
-- - caixa:open/close/supply/withdraw (só caixa/admin)
-- - ordens_servico:* (só técnico)
-- - configuracoes:* (só admin)
-- - administracao:* (só admin)
