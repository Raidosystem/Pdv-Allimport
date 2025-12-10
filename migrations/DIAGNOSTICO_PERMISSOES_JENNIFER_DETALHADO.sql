-- =====================================================
-- DIAGNÓSTICO DETALHADO: PERMISSÕES DE JENNIFER
-- =====================================================

-- 1. Identificar o funcionário Jennifer e sua função
SELECT 
  f.id as funcionario_id,
  f.nome as funcionario_nome,
  f.funcao_id,
  func.nome as funcao_nome,
  func.empresa_id
FROM funcionarios f
JOIN funcoes func ON func.id = f.funcao_id
WHERE f.email = 'sousajenifer895@gmail.com';

-- 2. Ver TODAS as permissões atualmente salvas para a função "Vendedor"
SELECT 
  fp.id as funcao_permissao_id,
  fp.funcao_id,
  fp.permissao_id,
  p.recurso,
  p.acao,
  p.descricao,
  p.categoria,
  CONCAT(p.recurso, ':', p.acao) as permissao_completa
FROM funcao_permissoes fp
JOIN funcoes func ON func.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE func.nome = 'Vendedor'
  AND func.empresa_id = (
    SELECT empresa_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com'
  )
ORDER BY p.categoria, p.recurso, p.acao;

-- 3. Contar total de permissões por função
SELECT 
  func.nome as funcao_nome,
  COUNT(fp.id) as total_permissoes
FROM funcoes func
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE func.empresa_id = (
  SELECT empresa_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com'
)
GROUP BY func.id, func.nome
ORDER BY func.nome;

-- 4. Ver quais permissões DEVERIAM estar (com base no print da interface)
-- VENDAS: 7 selecionadas
WITH permissoes_esperadas AS (
  SELECT UNNEST(ARRAY[
    'vendas:cancel',
    'vendas:delete', -- ❌ NÃO MARCADA
    'vendas:update',
    'vendas:create',
    'vendas:read',
    'vendas:discount',
    'vendas:refund',
    'vendas:print'
  ]) as permissao_esperada
  UNION ALL
  -- PRODUTOS: 6 selecionadas
  SELECT UNNEST(ARRAY[
    'produtos:manage_stock',
    'produtos:delete', -- ❌ NÃO MARCADA
    'produtos:update',
    'produtos:create',
    'produtos:read',
    'produtos:export', -- ❌ NÃO MARCADA
    'produtos:import', -- ❌ NÃO MARCADA
    'produtos:manage_categories',
    'produtos:adjust_price'
  ])
  UNION ALL
  -- CLIENTES: 5 selecionadas
  SELECT UNNEST(ARRAY[
    'clientes:update',
    'clientes:export', -- ❌ NÃO MARCADA
    'clientes:import', -- ❌ NÃO MARCADA
    'clientes:manage_debt',
    'clientes:view_history',
    'clientes:read',
    'clientes:create',
    'clientes:delete' -- ❌ NÃO MARCADA
  ])
  UNION ALL
  -- ORDENS: 5 selecionadas
  SELECT UNNEST(ARRAY[
    'ordens:update',
    'ordens:delete', -- ❌ NÃO MARCADA
    'ordens:change_status',
    'ordens:print',
    'ordens:create',
    'ordens:read'
  ])
  UNION ALL
  -- CONFIGURAÇÕES: 5 selecionadas
  SELECT UNNEST(ARRAY[
    'configuracoes:integrations', -- ❌ NÃO MARCADA
    'configuracoes:read',
    'configuracoes:update',
    'configuracoes:company_info', -- ❌ NÃO MARCADA
    'configuracoes:backup',
    'configuracoes.aparencia:update',
    'configuracoes.aparencia:read',
    'configuracoes.dashboard:update', -- ❌ NÃO MARCADA
    'configuracoes.dashboard:read', -- ❌ NÃO MARCADA
    'configuracoes.impressao:read',
    'configuracoes.impressao:update'
  ])
  UNION ALL
  -- CAIXA (OUTROS): 7 selecionadas
  SELECT UNNEST(ARRAY[
    'caixa:view',
    'caixa:view_history',
    'caixa:suprimento',
    'caixa:sangria',
    'caixa:close',
    'caixa:open',
    'caixa:read',
    'dashboard:view', -- ❌ NÃO MARCADA
    'dashboard.graficos:view', -- ❌ NÃO MARCADA
    'dashboard.metricas:view' -- ❌ NÃO MARCADA
  ])
)
SELECT 
  pe.permissao_esperada,
  p.id as permissao_id_banco,
  CASE 
    WHEN p.id IS NULL THEN '❌ PERMISSÃO NÃO EXISTE NO BANCO'
    WHEN fp.id IS NULL THEN '⚠️ EXISTE MAS NÃO ESTÁ SALVA'
    ELSE '✅ SALVA CORRETAMENTE'
  END as status
FROM permissoes_esperadas pe
LEFT JOIN permissoes p ON CONCAT(p.recurso, ':', p.acao) = pe.permissao_esperada
LEFT JOIN funcao_permissoes fp ON fp.permissao_id = p.id 
  AND fp.funcao_id = (
    SELECT funcao_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com'
  )
ORDER BY pe.permissao_esperada;

-- 5. Ver permissões que ESTÃO salvas mas NÃO DEVERIAM estar
SELECT 
  CONCAT(p.recurso, ':', p.acao) as permissao_atual,
  p.descricao,
  '❌ NÃO DEVERIA ESTAR SALVA' as status
FROM funcao_permissoes fp
JOIN permissoes p ON p.id = fp.permissao_id
WHERE fp.funcao_id = (
  SELECT funcao_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com'
)
AND CONCAT(p.recurso, ':', p.acao) NOT IN (
  -- Lista de permissões marcadas na interface (baseado no print)
  'vendas:cancel', 'vendas:update', 'vendas:create', 'vendas:read', 'vendas:discount', 'vendas:refund', 'vendas:print',
  'produtos:manage_stock', 'produtos:update', 'produtos:create', 'produtos:read', 'produtos:manage_categories', 'produtos:adjust_price',
  'clientes:update', 'clientes:manage_debt', 'clientes:view_history', 'clientes:read', 'clientes:create',
  'ordens:update', 'ordens:change_status', 'ordens:print', 'ordens:create', 'ordens:read',
  'configuracoes:read', 'configuracoes:update', 'configuracoes:backup',
  'configuracoes.aparencia:update', 'configuracoes.aparencia:read',
  'configuracoes.impressao:read', 'configuracoes.impressao:update',
  'caixa:view', 'caixa:view_history', 'caixa:suprimento', 'caixa:sangria', 'caixa:close', 'caixa:open', 'caixa:read'
);

-- 6. Resumo comparativo
SELECT 
  '🔍 RESUMO COMPARATIVO' as tipo,
  (SELECT COUNT(*) FROM funcao_permissoes fp 
   WHERE fp.funcao_id = (SELECT funcao_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com')
  ) as total_salvas_banco,
  33 as total_marcadas_interface,
  (SELECT COUNT(*) FROM funcao_permissoes fp 
   WHERE fp.funcao_id = (SELECT funcao_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com')
  ) - 33 as diferenca;
