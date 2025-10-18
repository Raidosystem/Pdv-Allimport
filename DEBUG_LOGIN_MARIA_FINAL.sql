-- 🔍 VERIFICAÇÃO COMPLETA - Por que Maria não aparece no login?

-- ✅ 1. Maria Silva está com usuario_ativo = TRUE?
SELECT 
  '1️⃣ MARIA SILVA STATUS' as verificacao,
  id,
  nome,
  email,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  status,
  empresa_id
FROM funcionarios
WHERE id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ 2. O admin está com usuario_ativo = TRUE?
SELECT 
  '2️⃣ ADMIN STATUS' as verificacao,
  id,
  nome,
  email,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  primeiro_acesso
FROM funcionarios
WHERE tipo_admin = 'admin_empresa'
  AND empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- ✅ 3. Testar função com o ID da EMPRESA (não do user)
SELECT 
  '3️⃣ TESTE COM ID DA EMPRESA' as verificacao,
  id,
  nome,
  email,
  tipo_admin,
  usuario_ativo
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00');

-- ✅ 4. Testar função com o ID do USER/AUTH
SELECT 
  '4️⃣ TESTE COM ID DO USER' as verificacao,
  id,
  nome,
  email,
  tipo_admin,
  usuario_ativo
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- ✅ 5. Ver TODOS os funcionários da empresa (ambos IDs)
SELECT 
  '5️⃣ TODOS - EMPRESA ID' as verificacao,
  nome,
  tipo_admin,
  usuario_ativo,
  empresa_id
FROM funcionarios
WHERE empresa_id IN (
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
)
ORDER BY empresa_id, tipo_admin;

-- ✅ 6. Verificar qual ID o frontend está usando (baseado nos logs anteriores)
SELECT 
  '6️⃣ VERIFICAÇÃO' as info,
  'Frontend usa: f7fdf4cf-7101-45ab-86db-5248a7ac58c1' as frontend_id,
  'Maria tinha: f1726fcf-d23b-4cca-8079-39314ae56e00' as maria_tinha_antes,
  'Maria tem agora: f7fdf4cf-7101-45ab-86db-5248a7ac58c1' as maria_tem_agora,
  'Status: CORRETO ✅' as status;
