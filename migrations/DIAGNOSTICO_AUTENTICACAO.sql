-- 🔐 DIAGNÓSTICO COMPLETO DE AUTENTICAÇÃO

-- 1️⃣ Verificar auth.uid() - Deve retornar UUID do usuário logado
SELECT 
  '1. auth.uid()' as teste,
  auth.uid() as resultado,
  CASE 
    WHEN auth.uid() IS NULL THEN '❌ Usuário NÃO autenticado'
    ELSE '✅ Usuário autenticado'
  END as status;

-- 2️⃣ Verificar JWT claims (informações do token)
SELECT 
  '2. JWT Claims' as teste,
  auth.jwt() as jwt_completo;

-- 3️⃣ Verificar usuário na tabela auth.users (requer service_role)
-- ⚠️ Este query pode falhar se você estiver usando anon_key
SELECT 
  '3. Usuários no Auth' as teste,
  COUNT(*) as total_usuarios
FROM auth.users;

-- 4️⃣ Verificar suas empresas (se conseguir acessar)
SELECT 
  '4. Minhas Empresas' as teste,
  id,
  nome,
  user_id,
  created_at
FROM empresas
WHERE user_id = auth.uid()
LIMIT 5;

-- 5️⃣ Verificar funcionário vinculado
SELECT 
  '5. Meu Funcionário' as teste,
  id,
  nome,
  user_id,
  empresa_id,
  funcao_id,
  ativo
FROM funcionarios
WHERE user_id = auth.uid()
LIMIT 5;

-- 6️⃣ Verificar se você está em user_approvals
SELECT 
  '6. User Approvals' as teste,
  id,
  user_id,
  email,
  full_name,
  company_name,
  status,
  approved_by,
  approved_at,
  created_at
FROM user_approvals
WHERE user_id = auth.uid();

-- 7️⃣ Buscar empresa_id via funcionarios (alternativa à função)
SELECT 
  '7. Empresa via Funcionários' as teste,
  empresa_id
FROM funcionarios
WHERE user_id = auth.uid()
LIMIT 1;

-- 8️⃣ Verificar se a função get_funcionario_empresa_id existe
SELECT 
  '8. Função get_funcionario_empresa_id' as teste,
  EXISTS (
    SELECT 1 FROM pg_proc 
    WHERE proname = 'get_funcionario_empresa_id'
  ) as funcao_existe;

-- 9️⃣ Verificar políticas RLS ativas
SELECT 
  '9. Políticas RLS Funcionarios' as teste,
  policyname,
  cmd,
  permissive,
  roles
FROM pg_policies
WHERE tablename = 'funcionarios'
ORDER BY policyname;

-- 🔥 SOLUÇÃO SE auth.uid() = NULL:
-- Você precisa fazer login no sistema. O SQL Editor do Supabase
-- usa o service_role_key por padrão, que não tem auth.uid()
-- 
-- OPÇÕES:
-- 1. Usar o dashboard web do PDV e fazer login normalmente
-- 2. No SQL Editor, testar com um user_id específico:
--    SELECT * FROM funcionarios WHERE user_id = '[seu-uuid-aqui]';
