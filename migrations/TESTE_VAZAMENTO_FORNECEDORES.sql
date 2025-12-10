-- =====================================================
-- 🚨 DIAGNÓSTICO URGENTE - VAZAMENTO DE FORNECEDORES
-- =====================================================
-- cris-ramos30@hotmail.com vê fornecedores de outras empresas
-- =====================================================

-- 1️⃣ VERIFICAR EXATAMENTE O QUE O USUÁRIO ATUAL VÊ
SELECT 
  'TESTE_USUARIO_ATUAL' as teste,
  auth.uid() as meu_user_id,
  au.email as meu_email,
  e.nome as minha_empresa
FROM auth.users au
JOIN empresas e ON e.user_id = au.id
WHERE au.id = auth.uid();

-- 2️⃣ TESTE DIRETO: CONTAR FORNECEDORES QUE EU VEJO
SELECT 
  'FORNECEDORES_QUE_VEJO' as teste,
  COUNT(*) as total_visiveis
FROM fornecedores;

-- 3️⃣ LISTAR TODOS OS FORNECEDORES QUE EU CONSIGO VER
SELECT 
  f.nome as fornecedor_nome,
  f.cnpj,
  f.empresa_id,
  e.nome as empresa_dona,
  au.email as email_dono
FROM fornecedores f
LEFT JOIN empresas e ON e.id = f.empresa_id  
LEFT JOIN auth.users au ON au.id = e.user_id
ORDER BY f.nome;

-- 4️⃣ VERIFICAR SE POLÍTICAS RLS ESTÃO ATIVAS
SELECT 
  policyname,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'fornecedores'
ORDER BY policyname;

-- 5️⃣ VERIFICAR SE RLS ESTÁ HABILITADO
SELECT 
  tablename,
  rowsecurity
FROM pg_tables 
WHERE tablename = 'fornecedores';

-- 6️⃣ TESTAR A POLÍTICA MANUALMENTE
SELECT 
  'TESTE_POLITICA' as teste,
  empresa_id,
  empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()) as deveria_ver
FROM fornecedores;

-- 7️⃣ VERIFICAR MINHA EMPRESA_ID
SELECT 
  'MINHA_EMPRESA' as teste,
  id as minha_empresa_id,
  nome as minha_empresa_nome
FROM empresas 
WHERE user_id = auth.uid();

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- Se RLS estiver funcionando:
-- - Devo ver APENAS fornecedores da minha empresa
-- - COUNT(*) deve ser 0 ou apenas meus fornecedores
-- - Política deve estar bloqueando outros
-- =====================================================