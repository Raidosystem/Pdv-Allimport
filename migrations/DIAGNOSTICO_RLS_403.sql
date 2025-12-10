-- ============================================
-- DIAGNÓSTICO COMPLETO: HTTP 403 FORBIDDEN
-- ============================================
-- ✅ usuario_id correto: f7fdf4cf-7101-45ab-86db-5248a7ac58c1
-- ✅ 160 ordens vinculadas ao usuário correto
-- ❌ Browser recebe 403 Forbidden
-- Hipótese: Falta empresa_id ou problema na tabela auth.users
-- ============================================

-- 1. Verificar se auth.uid() retorna o usuário correto
SELECT 
  auth.uid() as user_id_autenticado,
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' as user_id_esperado,
  CASE 
    WHEN auth.uid()::text = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' 
    THEN '✅ AUTH FUNCIONANDO'
    ELSE '❌ AUTH DIFERENTE'
  END as status;

-- 2. Verificar empresa_id do usuário (pode estar NULL)
SELECT 
  id,
  email,
  raw_user_meta_data->>'empresa_id' as empresa_id,
  raw_user_meta_data as metadata_completo
FROM auth.users
WHERE id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 3. Testar política manualmente (simular RLS)
SELECT 
  os.numero_os,
  os.usuario_id,
  c.nome as cliente_nome,
  -- Testar condições da política
  CASE 
    WHEN os.usuario_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN '✅ MATCH usuario_id'
    WHEN os.user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN '✅ MATCH user_id'
    ELSE '❌ NO MATCH'
  END as condicao_rls
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
LIMIT 5;

-- 4. Verificar se existe coluna user_id (pode causar erro na política)
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'ordens_servico'
  AND column_name IN ('usuario_id', 'user_id')
ORDER BY column_name;

-- 5. Verificar se clientes tem user_id correto
SELECT 
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as meus_clientes,
  COUNT(CASE WHEN user_id IS NULL THEN 1 END) as clientes_sem_user_id
FROM clientes;

-- 6. Listar TODAS as políticas ativas (incluindo antigas)
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename IN ('ordens_servico', 'clientes')
ORDER BY tablename, policyname;

-- 7. Verificar se RLS está causando o problema - DESABILITAR temporariamente
-- ⚠️ APENAS PARA TESTE! Remova o comentário abaixo:
-- ALTER TABLE ordens_servico DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;

-- 8. SOLUÇÃO ALTERNATIVA: Criar política ultra-permissiva
-- Se diagnóstico confirmar que tudo está OK, mas ainda dá 403:
/*
DROP POLICY IF EXISTS "ordens_servico_select_autenticados" ON ordens_servico;
DROP POLICY IF EXISTS "clientes_select_autenticados" ON clientes;

-- Política super permissiva para ordens_servico
CREATE POLICY "ordens_select_all"
ON ordens_servico
FOR SELECT
TO authenticated
USING (true);

-- Política super permissiva para clientes
CREATE POLICY "clientes_select_all"
ON clientes
FOR SELECT
TO authenticated
USING (true);
*/

-- ============================================
-- INSTRUÇÕES:
-- 1. Execute Query 1-6 para diagnóstico completo
-- 2. Se Query 6 mostrar políticas conflitantes, execute Query 8
-- 3. Teste no navegador após Query 8
-- ============================================
