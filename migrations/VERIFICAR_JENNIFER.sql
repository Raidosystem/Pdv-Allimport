-- DIAGNÓSTICO RÁPIDO - Jennifer
SELECT 
  f.nome,
  f.email,
  f.tipo_admin,
  f.empresa_id = f.user_id as is_admin_empresa_calculado,
  fc.nome as funcao_nome,
  (SELECT COUNT(*) FROM funcao_permissoes WHERE funcao_id = f.funcao_id) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes fc ON fc.id = f.funcao_id
WHERE f.email = 'sousajenifer895@gmail.com';
