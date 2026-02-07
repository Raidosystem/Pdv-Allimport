-- =============================================
-- ATRIBUIR PERMISSÕES PADRÃO PARA FUNÇÕES
-- =============================================

-- 1️⃣ ATRIBUIR PERMISSÕES PARA TÉCNICO (Victor e futuros técnicos)
INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
SELECT 
  f.id as funcao_id,
  p.id as permissao_id,
  f.empresa_id
FROM funcoes f
CROSS JOIN permissoes p
WHERE f.nome = 'Técnico'
AND p.modulo || ':' || p.acao IN (
  -- Ordens de Serviço (principal)
  'ordens:read',
  'ordens:create',
  'ordens:update',
  'ordens:change_status',
  'ordens:print',
  
  -- Clientes (visualizar e criar)
  'clientes:read',
  'clientes:create',
  'clientes:view_history',
  
  -- Produtos (visualizar)
  'produtos:read',
  
  -- Dashboard (visualizar)
  'dashboard:view',
  'dashboard.metricas:view',
  
  -- Configurações (leitura básica)
  'configuracoes:read',
  'configuracoes.impressao:read'
)
ON CONFLICT (funcao_id, permissao_id, empresa_id) DO NOTHING;

SELECT '✅ Permissões atribuídas para Técnico!' as passo_1;

-- 2️⃣ ATRIBUIR PERMISSÕES PARA VENDEDOR
INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
SELECT 
  f.id as funcao_id,
  p.id as permissao_id,
  f.empresa_id
FROM funcoes f
CROSS JOIN permissoes p
WHERE f.nome = 'Vendedor'
AND p.modulo || ':' || p.acao IN (
  -- Vendas (principal)
  'vendas:read',
  'vendas:create',
  'vendas:print',
  
  -- Clientes
  'clientes:read',
  'clientes:create',
  'clientes:update',
  'clientes:view_history',
  
  -- Produtos (visualizar)
  'produtos:read',
  
  -- Dashboard
  'dashboard:view',
  'dashboard.metricas:view',
  
  -- Configurações
  'configuracoes:read',
  'configuracoes.impressao:read'
)
ON CONFLICT (funcao_id, permissao_id, empresa_id) DO NOTHING;

SELECT '✅ Permissões atribuídas para Vendedor!' as passo_2;

-- 3️⃣ ATRIBUIR PERMISSÕES PARA OPERADOR DE CAIXA
INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
SELECT 
  f.id as funcao_id,
  p.id as permissao_id,
  f.empresa_id
FROM funcoes f
CROSS JOIN permissoes p
WHERE f.nome = 'Operador de Caixa'
AND p.modulo || ':' || p.acao IN (
  -- Caixa (principal)
  'caixa:read',
  'caixa:view',
  'caixa:open',
  'caixa:close',
  
  -- Vendas
  'vendas:read',
  'vendas:create',
  'vendas:print',
  
  -- Clientes (básico)
  'clientes:read',
  'clientes:create',
  
  -- Produtos (visualizar)
  'produtos:read',
  
  -- Dashboard
  'dashboard:view',
  
  -- Configurações
  'configuracoes:read',
  'configuracoes.impressao:read'
)
ON CONFLICT (funcao_id, permissao_id, empresa_id) DO NOTHING;

SELECT '✅ Permissões atribuídas para Operador de Caixa!' as passo_3;

-- 4️⃣ ATRIBUIR PERMISSÕES PARA ESTOQUISTA
INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
SELECT 
  f.id as funcao_id,
  p.id as permissao_id,
  f.empresa_id
FROM funcoes f
CROSS JOIN permissoes p
WHERE f.nome = 'Estoquista'
AND p.modulo || ':' || p.acao IN (
  -- Produtos (principal)
  'produtos:read',
  'produtos:create',
  'produtos:update',
  'produtos:manage_stock',
  'produtos:manage_categories',
  
  -- Dashboard
  'dashboard:view',
  'dashboard.metricas:view',
  
  -- Relatórios (estoque)
  'relatorios:read',
  'relatorios:inventory',
  
  -- Configurações
  'configuracoes:read'
)
ON CONFLICT (funcao_id, permissao_id, empresa_id) DO NOTHING;

SELECT '✅ Permissões atribuídas para Estoquista!' as passo_4;

-- 5️⃣ VERIFICAR RESULTADO (Victor agora tem permissões)
SELECT 
  '📊 RESUMO FINAL' as info,
  f.nome as funcao,
  COUNT(fp.id) as total_permissoes
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
WHERE f.nome IN ('Técnico', 'Vendedor', 'Operador de Caixa', 'Estoquista')
GROUP BY f.id, f.nome
ORDER BY f.nome;

-- 6️⃣ DISPARAR EVENTO PARA RECARREGAR PERMISSÕES NO FRONTEND
NOTIFY pdv_permissions_reload, '{"message": "Permissões atualizadas"}';

SELECT '🎉 Permissões configuradas! Victor e todos os funcionários dessas funções agora têm acesso!' as resultado;

-- =============================================
-- 📝 INSTRUÇÕES PARA O USUÁRIO
-- =============================================
/*
APÓS EXECUTAR ESTE SQL:

1. Victor precisa FAZER LOGOUT e LOGIN novamente
2. Suas permissões serão carregadas automaticamente
3. Ele verá: Dashboard, Ordens de Serviço, Clientes, Produtos

PARA NOVOS FUNCIONÁRIOS:
- Ao criar, escolha a função adequada
- As permissões já estarão atribuídas automaticamente!

PARA AJUSTAR PERMISSÕES:
- Vá em: Administração → Funções → Editar Função
- Marque/desmarque as permissões desejadas
*/
