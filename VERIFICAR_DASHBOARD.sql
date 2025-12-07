-- =====================================================
-- VERIFICAR PERMISSÕES DE DASHBOARD
-- =====================================================

-- Ver todas as permissões com recurso 'dashboard'
SELECT 
  id,
  recurso,
  acao,
  descricao,
  categoria,
  created_at
FROM permissoes
WHERE recurso = 'dashboard'
ORDER BY acao;

-- Ver se existe alguma permissão com categoria 'dashboard'
SELECT 
  id,
  recurso,
  acao,
  descricao,
  categoria
FROM permissoes
WHERE categoria = 'dashboard'
ORDER BY recurso, acao;

-- Contar permissões por recurso = 'dashboard'
SELECT COUNT(*) as "Total Dashboard" 
FROM permissoes 
WHERE recurso = 'dashboard';
