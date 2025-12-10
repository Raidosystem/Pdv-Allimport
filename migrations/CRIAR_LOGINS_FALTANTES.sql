-- 🔧 CRIAR LOGINS para funcionários que não têm

-- ✅ 1. Ver funcionários que precisam de login
SELECT 
  '⚠️ FUNCIONÁRIOS SEM LOGIN' as status,
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
AND f.tipo_admin != 'admin_empresa'
ORDER BY e.nome, f.nome;

-- ✅ 2. CRIAR logins automaticamente
-- Gera usuário a partir do nome (remove espaços e acentos)
INSERT INTO login_funcionarios (funcionario_id, usuario, senha, ativo)
SELECT 
  f.id as funcionario_id,
  LOWER(
    REGEXP_REPLACE(
      TRANSLATE(
        f.nome,
        'ÁÀÃÂÄáàãâäÉÈÊËéèêëÍÌÎÏíìîïÓÒÕÔÖóòõôöÚÙÛÜúùûüÇç',
        'AAAAAaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuCc'
      ),
      '[^a-zA-Z0-9]',
      '',
      'g'
    )
  ) as usuario,
  encode(digest('senha123', 'sha256'), 'base64') as senha, -- Senha padrão temporária
  TRUE as ativo
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.usuario_ativo = TRUE
AND lf.id IS NULL
AND f.tipo_admin != 'admin_empresa'
ON CONFLICT (usuario) DO NOTHING;

-- ✅ 3. Verificar logins criados
SELECT 
  '✅ LOGINS CRIADOS' as status,
  lf.id,
  lf.usuario,
  lf.ativo,
  f.nome as funcionario_nome,
  e.nome as empresa_nome
FROM login_funcionarios lf
JOIN funcionarios f ON f.id = lf.funcionario_id
JOIN empresas e ON e.id = f.empresa_id
WHERE lf.created_at > NOW() - INTERVAL '1 minute'
ORDER BY lf.created_at DESC;

-- ✅ 4. Verificar se ainda há funcionários sem login
SELECT 
  '⚠️ AINDA SEM LOGIN?' as status,
  COUNT(*) as total_sem_login
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.usuario_ativo = TRUE
AND lf.id IS NULL
AND f.tipo_admin != 'admin_empresa';

-- ✅ 5. Testar função listar_usuarios_ativos para cada empresa
SELECT 
  '🧪 TESTE FUNÇÃO FINAL' as teste,
  e.id as empresa_id,
  e.nome as empresa_nome,
  e.email as empresa_email,
  (
    SELECT COUNT(*) 
    FROM listar_usuarios_ativos(e.id)
  ) as usuarios_visiveis_no_login,
  (
    SELECT COUNT(*)
    FROM funcionarios f
    WHERE f.empresa_id = e.id
    AND f.usuario_ativo = TRUE
    AND f.tipo_admin != 'admin_empresa'
  ) as funcionarios_esperados
FROM empresas e
ORDER BY e.created_at DESC;

-- 📊 RESUMO FINAL
SELECT 
  '📊 RESUMO COMPLETO' as titulo,
  (SELECT COUNT(*) FROM empresas) as total_empresas,
  (SELECT COUNT(*) FROM funcionarios WHERE usuario_ativo = TRUE AND tipo_admin != 'admin_empresa') as funcionarios_ativos,
  (SELECT COUNT(*) FROM login_funcionarios) as total_logins_criados,
  (
    SELECT COUNT(*) FROM funcionarios f
    LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
    WHERE f.usuario_ativo = TRUE
    AND lf.id IS NULL
    AND f.tipo_admin != 'admin_empresa'
  ) as ainda_faltam_logins,
  CASE 
    WHEN (
      SELECT COUNT(*) FROM funcionarios f
      LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
      WHERE f.usuario_ativo = TRUE
      AND lf.id IS NULL
      AND f.tipo_admin != 'admin_empresa'
    ) = 0 THEN '✅ TUDO CERTO!'
    ELSE '⚠️ Ainda faltam logins'
  END as status;

-- 🎯 PRÓXIMOS PASSOS
SELECT 
  '🎯 PRÓXIMO PASSO' as titulo,
  'Recarregue a página de login (F5)' as acao_1,
  'Os funcionários devem aparecer agora' as acao_2,
  'Senha padrão temporária: senha123' as acao_3,
  'Peça para os funcionários trocarem a senha após o primeiro login' as acao_4;
