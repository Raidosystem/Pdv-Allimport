-- =============================================
-- ?? DIAGNÓSTICO: Por que Jennifer não aparece?
-- =============================================

-- 1?? Ver TODOS os funcionários da empresa
SELECT 
  '1?? TODOS OS FUNCIONÁRIOS' as secao,
  id,
  nome,
  email,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  status,
  ativo
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY nome;

-- 2?? Ver registros em login_funcionarios
SELECT 
  '2?? LOGIN_FUNCIONARIOS' as secao,
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  lf.precisa_trocar_senha,
  f.nome as funcionario_nome,
  f.tipo_admin,
  f.senha_definida as senha_definida_funcionario
FROM login_funcionarios lf
JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.nome;

-- 3?? Testar a RPC diretamente
SELECT 
  '3?? RESULTADO DA RPC' as secao,
  *
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- 4?? Análise de Jennifer especificamente
SELECT 
  '4?? JENNIFER - ANÁLISE DETALHADA' as secao,
  f.id,
  f.nome,
  f.email,
  f.usuario_ativo,
  f.senha_definida,
  f.status,
  f.ativo,
  f.tipo_admin,
  CASE 
    WHEN f.usuario_ativo IS NULL OR f.usuario_ativo = FALSE THEN '? usuario_ativo bloqueando'
    WHEN f.senha_definida IS NULL OR f.senha_definida = FALSE THEN '? senha_definida bloqueando'
    WHEN f.status != 'ativo' THEN '? status bloqueando'
    WHEN f.ativo = FALSE THEN '? ativo=false bloqueando'
    ELSE '? Deveria aparecer'
  END as diagnostico
FROM funcionarios f
WHERE f.nome ILIKE '%jennifer%'
  AND f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 5?? Verificar se Jennifer tem login criado
SELECT 
  '5?? JENNIFER TEM LOGIN?' as secao,
  f.nome,
  f.id as funcionario_id,
  f.senha_definida as senha_definida_funcionario,
  lf.id as login_id,
  lf.usuario,
  lf.ativo as login_ativo,
  lf.precisa_trocar_senha,
  CASE 
    WHEN lf.id IS NULL THEN '? SEM LOGIN CRIADO'
    WHEN lf.ativo = FALSE THEN '? LOGIN DESATIVADO'
    ELSE '? LOGIN OK'
  END as status_login
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.nome ILIKE '%jennifer%'
  AND f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- =============================================
-- ?? CORREÇÃO AUTOMÁTICA: Ativar Jennifer
-- =============================================

-- PASSO 1: Ativar Jennifer na tabela funcionarios
UPDATE funcionarios
SET 
  usuario_ativo = TRUE,
  senha_definida = TRUE,
  status = 'ativo',
  ativo = TRUE,
  primeiro_acesso = TRUE
WHERE nome ILIKE '%jennifer%'
  AND empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- PASSO 2: Criar/Atualizar login para Jennifer
-- Verificar se já existe
DO $$
DECLARE
  v_funcionario_id UUID;
  v_login_exists BOOLEAN;
BEGIN
  -- Buscar ID de Jennifer
  SELECT id INTO v_funcionario_id
  FROM funcionarios
  WHERE nome ILIKE '%jennifer%'
    AND empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  LIMIT 1;

  IF v_funcionario_id IS NULL THEN
    RAISE NOTICE '? Jennifer não encontrada';
    RETURN;
  END IF;

  -- Verificar se login existe
  SELECT EXISTS (
    SELECT 1 FROM login_funcionarios WHERE funcionario_id = v_funcionario_id
  ) INTO v_login_exists;

  IF v_login_exists THEN
    -- Atualizar login existente
    UPDATE login_funcionarios
    SET 
      ativo = TRUE,
      precisa_trocar_senha = TRUE,
      senha_hash = crypt('123456', gen_salt('bf')),
      senha = crypt('123456', gen_salt('bf'))
    WHERE funcionario_id = v_funcionario_id;
    
    RAISE NOTICE '? Login de Jennifer ATUALIZADO com senha: 123456';
  ELSE
    -- Criar novo login
    INSERT INTO login_funcionarios (funcionario_id, usuario, senha_hash, ativo, precisa_trocar_senha)
    VALUES (
      v_funcionario_id,
      'jennifer',
      crypt('123456', gen_salt('bf')),
      TRUE,
      TRUE
    );
    
    RAISE NOTICE '? Login de Jennifer CRIADO com senha: 123456';
  END IF;
END $$;

-- =============================================
-- ? VERIFICAÇÃO FINAL
-- =============================================

-- Testar RPC novamente
SELECT 
  '? VERIFICAÇÃO FINAL - RPC' as secao,
  id,
  nome,
  email,
  tipo_admin,
  usuario
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1')
ORDER BY nome;

-- Contar quantos devem aparecer
SELECT 
  '?? RESUMO' as titulo,
  (SELECT COUNT(*) FROM funcionarios WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1') as total_funcionarios,
  (SELECT COUNT(*) FROM funcionarios WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' AND tipo_admin != 'admin_empresa') as funcionarios_nao_admin,
  (SELECT COUNT(*) FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1')) as aparecendo_no_login;

-- Ver estado final de todos os funcionários
SELECT 
  '?? ESTADO FINAL' as secao,
  f.nome,
  f.tipo_admin,
  f.usuario_ativo,
  f.senha_definida,
  f.ativo,
  f.status,
  lf.usuario as username,
  lf.ativo as login_ativo,
  CASE 
    WHEN f.usuario_ativo = TRUE 
     AND f.senha_definida = TRUE 
     AND (f.ativo = TRUE OR f.ativo IS NULL)
     AND (f.status = 'ativo' OR f.status IS NULL)
    THEN '? DEVE APARECER'
    ELSE '? NÃO VAI APARECER'
  END as vai_aparecer
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.nome;

-- =============================================
-- ?? INFORMAÇÃO IMPORTANTE
-- =============================================
-- 
-- ?? CRISTIANO (admin_empresa) TAMBÉM aparece no login local
-- Se você NÃO quer que ele apareça (pois admin deve usar /login),
-- execute este comando:
-- 
-- UPDATE funcionarios
-- SET tipo_admin = 'admin_empresa'
-- WHERE nome = 'Cristiano Ramos Mendes'
--   AND empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';
-- 
-- E modifique a RPC listar_usuarios_ativos para excluir admin_empresa:
-- 
-- WHERE f.empresa_id = p_empresa_id
--   AND (f.ativo = true OR f.ativo IS NULL)
--   AND (f.usuario_ativo = true OR f.usuario_ativo IS NULL)
--   AND (f.status = 'ativo' OR f.status IS NULL)
--   AND f.senha_definida = true
--   AND (f.tipo_admin IS NULL OR f.tipo_admin NOT IN ('admin_empresa', 'super_admin'))
-- 
-- =============================================
