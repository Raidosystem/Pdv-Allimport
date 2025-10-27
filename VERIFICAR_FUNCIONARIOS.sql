-- Verificar todos os funcionários cadastrados
SELECT 
  f.id,
  f.nome,
  f.email,
  f.status,
  f.ativo,
  f.usuario_ativo,
  f.senha_definida,
  f.primeiro_acesso,
  f.empresa_id,
  e.nome as empresa_nome,
  func.nome as funcao_nome,
  f.created_at
FROM funcionarios f
LEFT JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN funcoes func ON func.id = f.funcao_id
ORDER BY f.created_at DESC;

-- Verificar a RPC listar_usuarios_ativos
SELECT routine_name, routine_definition
FROM information_schema.routines
WHERE routine_name = 'listar_usuarios_ativos'
AND routine_schema = 'public';
