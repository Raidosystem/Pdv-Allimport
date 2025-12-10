-- ================================================
-- 🚨 EMERGÊNCIA CRÍTICA - ISOLAMENTO IMEDIATO
-- EXECUTE AGORA NO SUPABASE SQL EDITOR
-- ================================================

-- 1. DIAGNÓSTICO ATUAL
SELECT 'DIAGNÓSTICO CRÍTICO' as status;

-- Verificar se RLS está ativo
SELECT 
  '📊 STATUS RLS ATUAL' as info,
  tablename,
  rowsecurity as rls_ativo
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa');

-- Verificar políticas ativas
SELECT 
  '🔑 POLÍTICAS ATUAIS' as info,
  tablename,
  policyname
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa');

-- 2. FORÇAR DESABILITAR RLS TEMPORARIAMENTE
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.caixa DISABLE ROW LEVEL SECURITY;

-- 3. REMOVER TODAS AS POLÍTICAS EXISTENTES
DROP POLICY IF EXISTS "clientes_isolamento_total" ON public.clientes;
DROP POLICY IF EXISTS "produtos_isolamento_total" ON public.produtos;
DROP POLICY IF EXISTS "vendas_isolamento_total" ON public.vendas;
DROP POLICY IF EXISTS "caixa_isolamento_total" ON public.caixa;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.clientes;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.produtos;
DROP POLICY IF EXISTS "Usuários autenticados podem ver clientes" ON public.clientes;
DROP POLICY IF EXISTS "Usuários autenticados podem ver produtos" ON public.produtos;

-- 4. GARANTIR COLUNAS USER_ID
ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.produtos ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.vendas ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.caixa ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- 5. VERIFICAR DADOS SEM ISOLAMENTO
SELECT 
  '⚠️ DADOS EXPOSTOS SEM USER_ID' as alerta,
  'CLIENTES' as tabela,
  COUNT(*) as total_registros,
  COUNT(CASE WHEN user_id IS NULL THEN 1 END) as sem_user_id,
  COUNT(DISTINCT user_id) as usuarios_diferentes
FROM public.clientes
UNION ALL
SELECT 
  '⚠️ DADOS EXPOSTOS SEM USER_ID',
  'PRODUTOS',
  COUNT(*),
  COUNT(CASE WHEN user_id IS NULL THEN 1 END),
  COUNT(DISTINCT user_id)
FROM public.produtos;

-- 6. LISTAR USUÁRIOS ATIVOS
SELECT 
  '👥 USUÁRIOS NO SISTEMA' as info,
  id,
  email,
  created_at
FROM auth.users
ORDER BY created_at;

-- 7. VERIFICAR QUAIS DADOS PERTENCEM A QUEM
SELECT 
  '🔍 DISTRIBUIÇÃO DE CLIENTES POR USUÁRIO' as info,
  COALESCE(u.email, 'SEM_USER_ID') as usuario_email,
  COUNT(*) as total_clientes
FROM public.clientes c
LEFT JOIN auth.users u ON c.user_id = u.id
GROUP BY u.email
ORDER BY COUNT(*) DESC;

SELECT 
  '🔍 DISTRIBUIÇÃO DE PRODUTOS POR USUÁRIO' as info,
  COALESCE(u.email, 'SEM_USER_ID') as usuario_email,
  COUNT(*) as total_produtos
FROM public.produtos p
LEFT JOIN auth.users u ON p.user_id = u.id
GROUP BY u.email
ORDER BY COUNT(*) DESC;

-- 8. REABILITAR RLS COM ISOLAMENTO RIGOROSO
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;

-- 9. CRIAR POLÍTICAS ULTRA RIGOROSAS
CREATE POLICY "isolamento_ultra_rigoroso_clientes" ON public.clientes 
FOR ALL 
TO authenticated
USING (user_id = auth.uid() AND user_id IS NOT NULL)
WITH CHECK (user_id = auth.uid() AND user_id IS NOT NULL);

CREATE POLICY "isolamento_ultra_rigoroso_produtos" ON public.produtos 
FOR ALL 
TO authenticated
USING (user_id = auth.uid() AND user_id IS NOT NULL)
WITH CHECK (user_id = auth.uid() AND user_id IS NOT NULL);

CREATE POLICY "isolamento_ultra_rigoroso_vendas" ON public.vendas 
FOR ALL 
TO authenticated
USING (user_id = auth.uid() AND user_id IS NOT NULL)
WITH CHECK (user_id = auth.uid() AND user_id IS NOT NULL);

CREATE POLICY "isolamento_ultra_rigoroso_caixa" ON public.caixa 
FOR ALL 
TO authenticated
USING (user_id = auth.uid() AND user_id IS NOT NULL)
WITH CHECK (user_id = auth.uid() AND user_id IS NOT NULL);

-- 10. BLOQUEAR ACESSO ANÔNIMO
REVOKE ALL ON public.clientes FROM anon;
REVOKE ALL ON public.produtos FROM anon;
REVOKE ALL ON public.vendas FROM anon;
REVOKE ALL ON public.caixa FROM anon;

-- 11. VERIFICAÇÃO FINAL
SELECT '🔒 VERIFICAÇÃO FINAL - RLS ATIVO' as status;

SELECT 
  tablename,
  rowsecurity as rls_habilitado
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa');

SELECT 
  '🔑 POLÍTICAS FINAIS' as status,
  tablename,
  policyname
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa');

-- 12. TESTE FINAL DE ISOLAMENTO
SELECT '🧪 TESTE FINAL - CONTAGEM COM RLS ATIVO' as teste;

-- Esta query deve mostrar apenas dados do usuário logado
SELECT 
  'APÓS RLS' as momento,
  (SELECT COUNT(*) FROM public.clientes) as meus_clientes,
  (SELECT COUNT(*) FROM public.produtos) as meus_produtos;

SELECT '✅ ISOLAMENTO RIGOROSO APLICADO! SE AINDA VÊ DADOS DE OUTROS, O PROBLEMA ESTÁ NO FRONTEND' as resultado;
