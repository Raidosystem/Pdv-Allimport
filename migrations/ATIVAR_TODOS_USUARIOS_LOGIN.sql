-- =============================================
-- ?? CORREÇÃO: Ativar todos os funcionários para login local
-- =============================================
-- Execute este script para garantir que TODOS os funcionários
-- apareçam no login local
-- =============================================

-- PASSO 1: Ativar todos os funcionários na tabela funcionarios
UPDATE funcionarios
SET 
  usuario_ativo = TRUE,
  senha_definida = TRUE,
  status = 'ativo'
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND tipo_admin != 'admin_empresa'
  AND (usuario_ativo IS NULL OR usuario_ativo = FALSE OR senha_definida IS NULL OR senha_definida = FALSE);

-- PASSO 2: Ativar todos os registros em login_funcionarios
UPDATE login_funcionarios
SET ativo = TRUE
WHERE funcionario_id IN (
  SELECT id FROM funcionarios 
  WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
    AND tipo_admin != 'admin_empresa'
);

-- PASSO 3: Criar registros de login para funcionários que não têm
INSERT INTO login_funcionarios (funcionario_id, usuario, senha_hash, ativo, senha_definida, precisa_trocar_senha)
SELECT 
  f.id,
  lower(regexp_replace(f.nome, '[^a-zA-Z0-9]', '', 'g')) as usuario,
  crypt('123456', gen_salt('bf')) as senha_hash,
  TRUE as ativo,
  TRUE as senha_definida,
  TRUE as precisa_trocar_senha
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND f.tipo_admin != 'admin_empresa'
  AND lf.id IS NULL;

-- =============================================
-- ? VERIFICAÇÃO PÓS-CORREÇÃO
-- =============================================

-- Ver quantos funcionários foram atualizados
SELECT 
  '? VERIFICAÇÃO PÓS-CORREÇÃO' as titulo,
  (SELECT COUNT(*) FROM funcionarios WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' AND tipo_admin != 'admin_empresa') as total_funcionarios_nao_admin,
  (SELECT COUNT(*) FROM funcionarios WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' AND usuario_ativo = TRUE AND tipo_admin != 'admin_empresa') as funcionarios_ativos,
  (SELECT COUNT(*) FROM login_funcionarios lf JOIN funcionarios f ON f.id = lf.funcionario_id WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' AND f.tipo_admin != 'admin_empresa') as logins_criados,
  (SELECT COUNT(*) FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1')) as aparecendo_no_login;

-- Listar todos os usuários que agora devem aparecer
SELECT 
  '?? USUÁRIOS QUE DEVEM APARECER' as titulo,
  f.nome,
  lf.usuario,
  f.usuario_ativo,
  f.senha_definida,
  lf.ativo,
  '? Senha padrão: 123456' as info
FROM funcionarios f
JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND f.tipo_admin != 'admin_empresa'
ORDER BY f.nome;

-- Testar a RPC
SELECT 
  '?? TESTE DA RPC' as titulo,
  *
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');
