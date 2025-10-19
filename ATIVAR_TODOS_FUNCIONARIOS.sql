-- 🔧 CORRIGIR: Ativar todos os funcionários que deveriam estar ativos

-- ✅ 1. Ver funcionários que precisam ser ativados
SELECT 
  '⚠️ FUNCIONÁRIOS INATIVOS' as status,
  f.id,
  f.nome,
  f.empresa_id,
  f.usuario_ativo,
  f.tipo_admin,
  e.nome as empresa_nome,
  CASE 
    WHEN EXISTS (SELECT 1 FROM login_funcionarios lf WHERE lf.funcionario_id = f.id) 
    THEN '✅ TEM LOGIN'
    ELSE '❌ SEM LOGIN'
  END as tem_login
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id
WHERE (f.usuario_ativo IS NULL OR f.usuario_ativo = FALSE)
AND f.tipo_admin != 'admin_empresa'
ORDER BY f.created_at DESC;

-- ✅ 2. ATIVAR todos os funcionários não-admin
UPDATE funcionarios
SET 
  usuario_ativo = TRUE,
  senha_definida = TRUE,
  primeiro_acesso = FALSE
WHERE (usuario_ativo IS NULL OR usuario_ativo = FALSE)
AND tipo_admin != 'admin_empresa';

-- ✅ 3. Verificar resultado
SELECT 
  '✅ DEPOIS DA CORREÇÃO' as status,
  COUNT(*) as total_funcionarios_ativos
FROM funcionarios
WHERE usuario_ativo = TRUE
AND tipo_admin != 'admin_empresa';

-- ✅ 4. Verificar funcionários SEM login
SELECT 
  '⚠️ FUNCIONÁRIOS SEM LOGIN' as problema,
  f.id,
  f.nome,
  f.empresa_id,
  f.usuario_ativo,
  e.nome as empresa_nome
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.usuario_ativo = TRUE
AND lf.id IS NULL
AND f.tipo_admin != 'admin_empresa';

-- ✅ 5. Testar função listar_usuarios_ativos novamente
SELECT 
  '🧪 TESTE FUNÇÃO APÓS CORREÇÃO' as teste,
  e.id as empresa_id,
  e.nome as empresa_nome,
  (
    SELECT COUNT(*) 
    FROM listar_usuarios_ativos(e.id)
  ) as usuarios_ativos_agora
FROM empresas e
WHERE (
  SELECT COUNT(*) 
  FROM funcionarios f
  WHERE f.empresa_id = e.id 
  AND f.usuario_ativo = TRUE
  AND f.tipo_admin != 'admin_empresa'
) > 0
ORDER BY e.created_at DESC;

-- 📊 RESUMO FINAL
SELECT 
  '📊 RESULTADO FINAL' as titulo,
  (SELECT COUNT(*) FROM funcionarios WHERE usuario_ativo = TRUE) as total_ativos,
  (SELECT COUNT(*) FROM funcionarios WHERE usuario_ativo = TRUE AND tipo_admin != 'admin_empresa') as funcionarios_ativos,
  (SELECT COUNT(*) FROM login_funcionarios) as total_logins,
  (
    SELECT COUNT(*) FROM funcionarios f
    LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
    WHERE f.usuario_ativo = TRUE
    AND lf.id IS NULL
    AND f.tipo_admin != 'admin_empresa'
  ) as funcionarios_sem_login;

-- 🎯 PRÓXIMO PASSO
SELECT 
  '🎯 SE AINDA HÁ FUNCIONÁRIOS SEM LOGIN' as titulo,
  'Execute o script CRIAR_LOGINS_FALTANTES.sql' as acao,
  'Isso criará usuários para todos os funcionários ativos' as resultado;
