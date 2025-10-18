-- 🔧 CORRIGIR empresa_id da Maria Silva

-- ✅ ANTES: Verificar estado atual
SELECT 
  '❌ ANTES DA CORREÇÃO' as status,
  id,
  nome,
  empresa_id as empresa_id_errado
FROM funcionarios
WHERE id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- 🔧 ATUALIZAR para o empresa_id correto (auth.uid())
UPDATE funcionarios 
SET empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' 
WHERE id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ DEPOIS: Verificar correção
SELECT 
  '✅ DEPOIS DA CORREÇÃO' as status,
  id,
  nome,
  empresa_id as empresa_id_correto
FROM funcionarios
WHERE id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ VERIFICAR: Agora deve aparecer na query do frontend
SELECT 
  '✅ QUERY DO FRONTEND AGORA FUNCIONA' as status,
  f.id,
  f.nome,
  f.status,
  f.tipo_admin,
  f.empresa_id
FROM funcionarios f
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND f.tipo_admin != 'admin_empresa';

-- ✅ VERIFICAR: Login também deve aparecer
SELECT 
  '✅ LOGIN TAMBÉM APARECE' as status,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  get_funcionario_empresa_id(lf.funcionario_id) as empresa_verificada
FROM login_funcionarios lf
WHERE lf.funcionario_id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';
