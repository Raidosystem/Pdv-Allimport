-- ============================================
-- TESTE DE ISOLAMENTO - VERIFICAR SE FUNCIONOU
-- ============================================

-- 1️⃣ VERIFICAR RLS ESTÁ ATIVO
SELECT 
  '1. STATUS RLS' as etapa,
  tablename,
  CASE WHEN rowsecurity THEN '✅ ATIVO' ELSE '❌ DESATIVADO' END as status
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename IN ('produtos', 'clientes', 'vendas', 'caixa', 'ordens_servico')
ORDER BY tablename;

-- 2️⃣ VERIFICAR POLÍTICAS CRIADAS
SELECT 
  '2. POLÍTICAS RLS' as etapa,
  tablename,
  policyname
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN ('produtos', 'clientes', 'vendas', 'caixa', 'ordens_servico')
ORDER BY tablename;

-- 3️⃣ VERIFICAR EMPRESAS E SEUS DONOS
SELECT 
  '3. EMPRESAS' as etapa,
  e.id as empresa_id,
  e.nome as empresa_nome,
  au.email as dono_email
FROM empresas e
JOIN auth.users au ON au.id = e.user_id
ORDER BY e.nome;

-- 4️⃣ VERIFICAR DISTRIBUIÇÃO DE PRODUTOS POR EMPRESA
SELECT 
  '4. PRODUTOS POR EMPRESA' as etapa,
  e.nome as empresa,
  COUNT(p.id) as total_produtos
FROM empresas e
LEFT JOIN produtos p ON p.empresa_id = e.id
GROUP BY e.nome
ORDER BY total_produtos DESC;

-- 5️⃣ VERIFICAR DISTRIBUIÇÃO DE CLIENTES POR EMPRESA
SELECT 
  '5. CLIENTES POR EMPRESA' as etapa,
  e.nome as empresa,
  COUNT(c.id) as total_clientes
FROM empresas e
LEFT JOIN clientes c ON c.empresa_id = e.id
GROUP BY e.nome
ORDER BY total_clientes DESC;

-- 6️⃣ TESTE: Verificar se há produtos/clientes sem empresa_id (PROBLEMA!)
SELECT 
  '6. ⚠️ PRODUTOS SEM EMPRESA' as problema,
  COUNT(*) as total_sem_empresa
FROM produtos
WHERE empresa_id IS NULL;

SELECT 
  '6. ⚠️ CLIENTES SEM EMPRESA' as problema,
  COUNT(*) as total_sem_empresa
FROM clientes
WHERE empresa_id IS NULL;

-- ============================================
-- RESULTADO ESPERADO:
-- ============================================
-- ✅ Todas as tabelas com RLS ATIVO
-- ✅ Uma política por tabela (ex: produtos_empresa_isolation)
-- ✅ Duas empresas:
--    - Assistência All-Import (assistenciaallimport10@gmail.com)
--    - Grupo RaVal (cristiano@gruporaval.com.br)
-- ✅ Produtos e clientes divididos entre as empresas
-- ✅ ZERO produtos/clientes sem empresa_id
-- ============================================

-- 7️⃣ PRÓXIMO PASSO: TESTE REAL NO FRONTEND
-- Faça LOGOUT e LOGIN com cada usuário:
-- - cristiano@gruporaval.com.br → Deve ver apenas Grupo RaVal
-- - assistenciaallimport10@gmail.com → Deve ver apenas Assistência All-Import
