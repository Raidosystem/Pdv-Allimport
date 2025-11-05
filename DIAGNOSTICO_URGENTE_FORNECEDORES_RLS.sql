-- =====================================================
-- 🚨 DIAGNÓSTICO URGENTE - FORNECEDORES RLS NÃO FUNCIONANDO
-- =====================================================
-- Usuário cris-ramos30@hotmail.com ainda vê fornecedores de outros
-- =====================================================

-- 1️⃣ VERIFICAR SE RLS ESTÁ ATIVADO
SELECT 
  schemaname, 
  tablename, 
  rowsecurity
FROM pg_tables 
WHERE tablename = 'fornecedores';

-- 2️⃣ VERIFICAR POLÍTICAS CRIADAS
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'fornecedores'
ORDER BY policyname;

-- 3️⃣ VERIFICAR SE EMPRESA_ID EXISTE NA TABELA
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'fornecedores' 
  AND column_name = 'empresa_id';

-- 4️⃣ VERIFICAR DADOS ATUAIS
SELECT 
  f.id,
  f.nome,
  f.empresa_id,
  e.nome as empresa_nome,
  au.email as user_email
FROM fornecedores f
LEFT JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN auth.users au ON au.id = e.user_id
ORDER BY f.id;

-- 5️⃣ VERIFICAR SE TRIGGER EXISTE
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_timing,
  action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'fornecedores';

-- 6️⃣ TESTE DE ISOLAMENTO (deve mostrar apenas fornecedores da empresa do usuário logado)
SELECT 
  'TESTE ISOLAMENTO' as teste,
  auth.uid() as current_user_id,
  COUNT(*) as fornecedores_visiveis
FROM fornecedores;

-- 7️⃣ VERIFICAR QUANTOS FORNECEDORES POR EMPRESA
SELECT 
  COALESCE(e.nome, 'SEM EMPRESA') as empresa,
  COALESCE(au.email, 'SEM EMAIL') as email,
  COUNT(f.id) as total_fornecedores,
  array_agg(f.nome ORDER BY f.nome) as lista_fornecedores
FROM fornecedores f
LEFT JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN auth.users au ON au.id = e.user_id
GROUP BY e.id, e.nome, au.email
ORDER BY total_fornecedores DESC;

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ RLS deve estar ATIVADO (rowsecurity = true)
-- ✅ 4 políticas devem existir
-- ✅ empresa_id deve existir na tabela
-- ✅ Trigger deve existir
-- ✅ Usuário atual deve ver APENAS seus fornecedores
-- =====================================================