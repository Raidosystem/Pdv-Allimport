-- 🔧 CORRIGIR empresa_id da Maria Silva DEFINITIVO

-- ✅ Mostrar situação atual
SELECT 
  '❌ ANTES' as status,
  'Maria Silva tem empresa_id:' as info,
  f.empresa_id as maria_empresa_id,
  'Deveria ser (empresa real):' as deveria,
  'f1726fcf-d23b-4cca-8079-39314ae56e00'::uuid as empresa_id_correto
FROM funcionarios f
WHERE f.id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- 🔧 ATUALIZAR Maria Silva para o empresa_id CORRETO da tabela empresas
UPDATE funcionarios
SET empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
WHERE id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ Verificar correção
SELECT 
  '✅ DEPOIS' as status,
  f.id,
  f.nome,
  f.empresa_id,
  f.usuario_ativo,
  'ID da tabela empresas ✅' as confirmacao
FROM funcionarios f
WHERE f.id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ Testar função com o empresa_id CORRETO (da tabela empresas)
SELECT 
  '✅ TESTE COM EMPRESA_ID CORRETO' as status,
  id,
  nome,
  email,
  tipo_admin
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00');

-- ✅ Contar
SELECT 
  '✅ TOTAL' as status,
  COUNT(*) as total,
  COUNT(CASE WHEN tipo_admin = 'admin_empresa' THEN 1 END) as admins,
  COUNT(CASE WHEN tipo_admin = 'funcionario' THEN 1 END) as funcionarios
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00');
