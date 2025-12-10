-- =============================================
-- ?? DEBUG: Por que só aparece 1 usuário no login local?
-- =============================================

-- 1?? Ver TODOS os funcionários da empresa
SELECT 
  '1?? TODOS OS FUNCIONÁRIOS' as secao,
  f.id,
  f.nome,
  f.email,
  f.empresa_id,
  f.user_id,
  f.usuario_ativo,
  f.senha_definida,
  f.primeiro_acesso,
  f.status,
  f.tipo_admin
FROM funcionarios f
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.nome;

-- 2?? Ver registros em login_funcionarios
SELECT 
  '2?? LOGIN_FUNCIONARIOS' as secao,
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  lf.senha_definida,
  lf.precisa_trocar_senha,
  f.nome as funcionario_nome
FROM login_funcionarios lf
JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.nome;

-- 3?? Testar a RPC listar_usuarios_ativos
SELECT 
  '3?? RESULTADO DA RPC' as secao,
  *
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- 4?? Verificar se há usuários SEM login criado
SELECT 
  '4?? FUNCIONÁRIOS SEM LOGIN' as secao,
  f.id,
  f.nome,
  f.email,
  f.usuario_ativo,
  f.senha_definida,
  f.tipo_admin
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND lf.id IS NULL
  AND f.tipo_admin != 'admin_empresa';

-- 5?? Verificar campos que podem estar bloqueando
SELECT 
  '5?? ANÁLISE DE CAMPOS' as secao,
  f.nome,
  f.usuario_ativo as usuario_ativo_tabela,
  f.senha_definida as senha_definida_tabela,
  f.primeiro_acesso,
  f.status,
  lf.ativo as ativo_login,
  lf.senha_definida as senha_definida_login,
  CASE 
    WHEN f.usuario_ativo IS NULL OR f.usuario_ativo = FALSE THEN '? usuario_ativo bloqueando'
    WHEN f.senha_definida IS NULL OR f.senha_definida = FALSE THEN '? senha_definida bloqueando'
    WHEN f.status != 'ativo' THEN '? status bloqueando'
    WHEN lf.ativo IS NULL OR lf.ativo = FALSE THEN '? login_funcionarios.ativo bloqueando'
    ELSE '? Deveria aparecer'
  END as diagnostico
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND f.tipo_admin != 'admin_empresa'
ORDER BY f.nome;

-- =============================================
-- ?? RESUMO FINAL
-- =============================================
SELECT 
  '?? RESUMO' as titulo,
  (SELECT COUNT(*) FROM funcionarios WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1') as total_funcionarios,
  (SELECT COUNT(*) FROM funcionarios WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' AND usuario_ativo = TRUE) as com_usuario_ativo,
  (SELECT COUNT(*) FROM funcionarios WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' AND senha_definida = TRUE) as com_senha_definida,
  (SELECT COUNT(*) FROM login_funcionarios lf JOIN funcionarios f ON f.id = lf.funcionario_id WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1') as total_logins,
  (SELECT COUNT(*) FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1')) as retornados_pela_rpc;
