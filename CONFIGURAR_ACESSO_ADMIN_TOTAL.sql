-- ============================================
-- 🔐 POLÍTICAS RLS PARA ADMIN TER ACESSO TOTAL
-- Execute no SQL Editor do Supabase
-- ============================================

-- ============================================
-- PASSO 1: DAR ACESSO TOTAL À TABELA SUBSCRIPTIONS
-- ============================================

-- Habilitar RLS
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas se existirem
DROP POLICY IF EXISTS "Admins total access to subscriptions" ON public.subscriptions;
DROP POLICY IF EXISTS "Users can view own subscription" ON public.subscriptions;
DROP POLICY IF EXISTS "Admins can view all subscriptions" ON public.subscriptions;
DROP POLICY IF EXISTS "System can manage subscriptions" ON public.subscriptions;

-- Criar política para ADMINS terem ACESSO TOTAL
CREATE POLICY "Admins total access to subscriptions"
ON public.subscriptions
FOR ALL
TO authenticated
USING (
  -- Admin pode ver TUDO
  auth.email() IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com'
  )
  OR auth.jwt() ->> 'role' = 'admin'
)
WITH CHECK (
  -- Admin pode modificar TUDO
  auth.email() IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com'
  )
  OR auth.jwt() ->> 'role' = 'admin'
);

-- Política para usuários verem apenas suas próprias assinaturas
CREATE POLICY "Users view own subscription"
ON public.subscriptions
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()
  OR auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
);

-- ============================================
-- PASSO 2: DAR ACESSO TOTAL À TABELA USER_APPROVALS
-- ============================================

-- Habilitar RLS
ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas
DROP POLICY IF EXISTS "Admins total access to user_approvals" ON public.user_approvals;
DROP POLICY IF EXISTS "Users can view own approval" ON public.user_approvals;

-- Política para ADMINS terem ACESSO TOTAL
CREATE POLICY "Admins total access to user_approvals"
ON public.user_approvals
FOR ALL
TO authenticated
USING (
  auth.email() IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com'
  )
  OR auth.jwt() ->> 'role' = 'admin'
)
WITH CHECK (
  auth.email() IN (
    'admin@pdvallimport.com',
    'novaradiosystem@outlook.com'
  )
  OR auth.jwt() ->> 'role' = 'admin'
);

-- Usuários podem ver apenas seus próprios dados
CREATE POLICY "Users view own approval"
ON public.user_approvals
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()
  OR auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
);

-- ============================================
-- PASSO 3: CONCEDER ACESSO A OUTRAS TABELAS IMPORTANTES
-- ============================================

-- TABELA: payments (se existir)
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payments') THEN
    ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
    
    DROP POLICY IF EXISTS "Admins total access to payments" ON public.payments;
    
    CREATE POLICY "Admins total access to payments"
    ON public.payments
    FOR ALL
    TO authenticated
    USING (
      auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
      OR auth.jwt() ->> 'role' = 'admin'
    );
  END IF;
END $$;

-- TABELA: empresas (se existir)
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'empresas') THEN
    ALTER TABLE public.empresas ENABLE ROW LEVEL SECURITY;
    
    DROP POLICY IF EXISTS "Admins total access to empresas" ON public.empresas;
    
    CREATE POLICY "Admins total access to empresas"
    ON public.empresas
    FOR ALL
    TO authenticated
    USING (
      auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
      OR auth.jwt() ->> 'role' = 'admin'
      OR id = auth.uid()
    );
  END IF;
END $$;

-- TABELA: funcionarios (se existir)
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'funcionarios') THEN
    ALTER TABLE public.funcionarios ENABLE ROW LEVEL SECURITY;
    
    DROP POLICY IF EXISTS "Admins total access to funcionarios" ON public.funcionarios;
    
    CREATE POLICY "Admins total access to funcionarios"
    ON public.funcionarios
    FOR ALL
    TO authenticated
    USING (
      auth.email() IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com')
      OR auth.jwt() ->> 'role' = 'admin'
    );
  END IF;
END $$;

-- ============================================
-- PASSO 4: VERIFICAR SE AS POLÍTICAS FORAM CRIADAS
-- ============================================

-- Ver políticas da tabela subscriptions
SELECT 
  '✅ POLÍTICAS - subscriptions' as tabela,
  policyname as politica,
  cmd as comando,
  CASE 
    WHEN roles = '{authenticated}' THEN 'authenticated'
    ELSE roles::text
  END as roles
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'subscriptions'
ORDER BY policyname;

-- Ver políticas da tabela user_approvals
SELECT 
  '✅ POLÍTICAS - user_approvals' as tabela,
  policyname as politica,
  cmd as comando,
  CASE 
    WHEN roles = '{authenticated}' THEN 'authenticated'
    ELSE roles::text
  END as roles
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'user_approvals'
ORDER BY policyname;

-- ============================================
-- PASSO 5: TORNAR SEU USUÁRIO ADMIN (OPCIONAL)
-- ============================================

-- Se você quiser que outro email seja admin, execute:
-- Substitua 'seu-email@exemplo.com' pelo email desejado

-- EXEMPLO (descomente e ajuste o email):
-- UPDATE auth.users
-- SET raw_app_meta_data = 
--   COALESCE(raw_app_meta_data, '{}'::jsonb) || '{"role": "admin"}'::jsonb
-- WHERE email = 'seu-email@exemplo.com';

-- ============================================
-- PASSO 6: TESTE DE ACESSO
-- ============================================

-- Verificar se você consegue ver as assinaturas
SELECT 
  '🧪 TESTE DE ACESSO' as status,
  email,
  status as subscription_status,
  trial_end_date,
  created_at
FROM subscriptions
ORDER BY created_at DESC
LIMIT 5;

-- Verificar se você consegue ver os usuários
SELECT 
  '🧪 TESTE DE ACESSO' as status,
  email,
  full_name,
  status,
  created_at
FROM user_approvals
ORDER BY created_at DESC
LIMIT 5;

-- ============================================
-- RESULTADO ESPERADO
-- ============================================

SELECT 
  '🎉 CONFIGURAÇÃO CONCLUÍDA!' as mensagem,
  'Admins agora têm acesso TOTAL ao banco de dados' as info,
  'Emails com permissão: admin@pdvallimport.com, novaradiosystem@outlook.com' as admins;

-- ============================================
-- 📋 EMAILS COM ACESSO ADMIN
-- ============================================

-- Os seguintes emails têm acesso TOTAL:
-- ✅ admin@pdvallimport.com
-- ✅ novaradiosystem@outlook.com

-- Para adicionar mais admins:
-- 1. Edite as políticas acima
-- 2. Adicione o email na lista OR auth.email() IN (...)
-- 3. Execute o script novamente
