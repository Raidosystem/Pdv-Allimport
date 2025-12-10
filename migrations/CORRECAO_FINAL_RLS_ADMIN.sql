-- ================================================
-- CORREÇÃO FINAL: GARANTIR ADMIN VÊ TODAS ASSINATURAS
-- ================================================

-- 1️⃣ LIMPAR ASSINATURAS DE USUÁRIOS DELETADOS
DELETE FROM public.subscriptions
WHERE email LIKE 'DELETED_%@deleted.invalid';

-- 2️⃣ REMOVER **TODAS** AS POLÍTICAS RLS DE SUBSCRIPTIONS
DO $$ 
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'subscriptions' 
        AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.subscriptions', pol.policyname);
    END LOOP;
END $$;

-- 3️⃣ CRIAR APENAS 2 POLÍTICAS SIMPLES E FUNCIONAIS

-- POLÍTICA A: Admins veem TODAS as assinaturas
CREATE POLICY "admin_full_access_subscriptions" 
ON public.subscriptions 
FOR ALL
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR 
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  OR
  EXISTS (
    SELECT 1 FROM public.user_approvals 
    WHERE user_approvals.user_id = auth.uid() 
    AND user_approvals.user_role = 'admin'
  )
)
WITH CHECK (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR 
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  OR
  EXISTS (
    SELECT 1 FROM public.user_approvals 
    WHERE user_approvals.user_id = auth.uid() 
    AND user_approvals.user_role = 'admin'
  )
  OR
  auth.uid() = user_id
);

-- POLÍTICA B: Usuários comuns veem apenas sua própria assinatura
CREATE POLICY "users_own_subscription" 
ON public.subscriptions 
FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 4️⃣ REPETIR PARA USER_APPROVALS
-- Remover todas as políticas
DO $$ 
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'user_approvals' 
        AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.user_approvals', pol.policyname);
    END LOOP;
END $$;

-- Criar políticas simples
CREATE POLICY "admin_full_access_approvals" 
ON public.user_approvals 
FOR ALL
USING (
  auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
  OR 
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  OR
  user_role = 'admin'
);

CREATE POLICY "users_own_approval" 
ON public.user_approvals 
FOR ALL
USING (auth.uid() = user_id);

-- 5️⃣ GARANTIR RLS ESTÁ HABILITADO
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;

-- 6️⃣ VERIFICAÇÃO FINAL
SELECT 
  '6. POLÍTICAS ATIVAS EM SUBSCRIPTIONS' as etapa,
  policyname,
  cmd as tipo
FROM pg_policies
WHERE tablename = 'subscriptions'
ORDER BY policyname;

SELECT 
  '6. POLÍTICAS ATIVAS EM USER_APPROVALS' as etapa,
  policyname,
  cmd as tipo
FROM pg_policies
WHERE tablename = 'user_approvals'
ORDER BY policyname;

-- 7️⃣ TESTAR CONTAGEM
SELECT 
  '7. TOTAL DE ASSINATURAS VISÍVEIS' as etapa,
  COUNT(*) as total
FROM public.subscriptions;

-- 8️⃣ LISTAR TODAS (SEM DELETED)
SELECT 
  '8. TODAS AS ASSINATURAS (SEM DELETADOS)' as etapa,
  email,
  status,
  plan_type,
  TO_CHAR(created_at, 'DD/MM/YYYY') as data_cadastro
FROM public.subscriptions
WHERE email NOT LIKE 'DELETED_%'
ORDER BY created_at DESC;

-- ================================================
-- ✅ RESULTADO ESPERADO:
-- - Apenas 2 políticas por tabela (admin + users)
-- - Admin vê TODAS as 6 assinaturas ativas
-- - Sem usuários deletados
-- - Erro 403 RESOLVIDO
-- ================================================
