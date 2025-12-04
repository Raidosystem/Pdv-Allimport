-- =====================================================
-- DIAGNOSTICAR FUNCIONÁRIOS QUE NÃO APARECEM NO LOGIN
-- =====================================================

-- 1. LISTAR TODOS OS FUNCIONÁRIOS DA EMPRESA
-- =====================================================
SELECT 
  f.id,
  f.nome,
  f.email,
  f.usuario_ativo,
  f.senha_definida,
  f.ativo,
  f.tipo_admin,
  CASE 
    WHEN lf.id IS NOT NULL THEN '✅ Tem login'
    ELSE '❌ SEM login'
  END as status_login,
  lf.usuario as nome_usuario
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id AND lf.ativo = true
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.nome;

-- 2. VERIFICAR FILTROS DA FUNÇÃO listar_usuarios_ativos
-- =====================================================
SELECT 
  f.id,
  f.nome,
  f.email,
  f.usuario_ativo as tem_usuario_ativo,
  f.senha_definida as tem_senha_definida,
  f.ativo as esta_ativo,
  CASE 
    WHEN f.usuario_ativo = true AND f.senha_definida = true AND f.ativo = true THEN '✅ PASSA nos filtros'
    ELSE '❌ NÃO PASSA'
  END as resultado_filtro,
  CASE 
    WHEN f.usuario_ativo = false THEN 'usuario_ativo = false'
    WHEN f.senha_definida = false THEN 'senha_definida = false'
    WHEN f.ativo = false THEN 'ativo = false'
    ELSE 'OK'
  END as motivo
FROM funcionarios f
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.nome;

-- 3. ATIVAR TODOS OS FUNCIONÁRIOS PARA O LOGIN
-- =====================================================
UPDATE funcionarios
SET 
  usuario_ativo = true,
  senha_definida = true,
  ativo = true
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND (usuario_ativo = false OR senha_definida = false OR ativo = false);

-- 4. CRIAR LOGINS PARA FUNCIONÁRIOS SEM LOGIN
-- =====================================================
INSERT INTO login_funcionarios (
  funcionario_id,
  usuario,
  senha,
  ativo,
  created_at,
  updated_at
)
SELECT 
  f.id,
  LOWER(SPLIT_PART(f.nome, ' ', 1)) as usuario,  -- Primeiro nome em minúsculas
  crypt('123456', gen_salt('bf')),  -- Senha padrão: 123456
  true,
  now(),
  now()
FROM funcionarios f
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND NOT EXISTS (
    SELECT 1 FROM login_funcionarios lf 
    WHERE lf.funcionario_id = f.id
  );

-- 5. VERIFICAR RESULTADO - TESTAR listar_usuarios_ativos
-- =====================================================
SELECT * FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- 6. RESULTADO
-- =====================================================
DO $$
DECLARE
  v_total_funcionarios INT;
  v_funcionarios_com_login INT;
  v_funcionarios_ativos INT;
BEGIN
  SELECT COUNT(*) INTO v_total_funcionarios
  FROM funcionarios 
  WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';
  
  SELECT COUNT(*) INTO v_funcionarios_com_login
  FROM funcionarios f
  INNER JOIN login_funcionarios lf ON lf.funcionario_id = f.id
  WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';
  
  SELECT COUNT(*) INTO v_funcionarios_ativos
  FROM funcionarios 
  WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
    AND usuario_ativo = true
    AND senha_definida = true
    AND ativo = true;

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ DIAGNÓSTICO COMPLETO!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Estatísticas:';
  RAISE NOTICE '   Total de funcionários: %', v_total_funcionarios;
  RAISE NOTICE '   Com login criado: %', v_funcionarios_com_login;
  RAISE NOTICE '   Ativos para login: %', v_funcionarios_ativos;
  RAISE NOTICE '';
  RAISE NOTICE '🔧 Ações executadas:';
  RAISE NOTICE '   • Todos funcionários ativados (usuario_ativo, senha_definida, ativo)';
  RAISE NOTICE '   • Logins criados para funcionários sem login';
  RAISE NOTICE '   • Senha padrão: 123456';
  RAISE NOTICE '   • Usuário: primeiro nome em minúsculas';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Próximo passo:';
  RAISE NOTICE '   Recarregue a página (F5) e veja os funcionários!';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
END;
$$;
