-- 🧪 TESTAR FUNÇÃO - PARTE 2 (DEPOIS DE CRIAR AS COLUNAS)

-- ✅ Passo 1: Testar a função listar_usuarios_ativos
SELECT 
  '✅ FUNÇÃO AGORA FUNCIONA' as status,
  id,
  nome,
  email,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  primeiro_acesso
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- ✅ Passo 2: Contar quantos retornou
SELECT 
  '✅ TOTAL DE USUÁRIOS' as status,
  COUNT(*) as total,
  COUNT(CASE WHEN tipo_admin = 'admin_empresa' THEN 1 END) as admins,
  COUNT(CASE WHEN tipo_admin = 'funcionario' THEN 1 END) as funcionarios
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- ✅ Passo 3: Verificar se Maria Silva está incluída
SELECT 
  '✅ MARIA ESTÁ NA FUNÇÃO?' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1')
      WHERE id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa'
    ) THEN 'SIM! Maria Silva aparece ✅'
    ELSE 'NÃO! Maria Silva NÃO aparece ❌'
  END as resultado;
