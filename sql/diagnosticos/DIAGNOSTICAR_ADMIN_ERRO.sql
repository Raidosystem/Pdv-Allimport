-- ============================================
-- DIAGNOSTICAR ERRO ADMIN DASHBOARD
-- ============================================

-- PASSO 1: Verificar se user_approvals existe
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name = 'user_approvals'
    )
    THEN '✅ Tabela user_approvals EXISTE'
    ELSE '❌ Tabela user_approvals NÃO EXISTE - CRIAR!'
  END as status;

-- PASSO 2: Verificar constraint de status
SELECT 
  con.conname as constraint_name,
  pg_get_constraintdef(con.oid) as constraint_definition
FROM pg_constraint con
WHERE conrelid = 'user_approvals'::regclass
AND conname = 'user_approvals_status_check';

-- PASSO 3: Remover constraint antiga se existir
ALTER TABLE user_approvals DROP CONSTRAINT IF EXISTS user_approvals_status_check;

-- PASSO 4: Criar constraint correta (aceita: pending, approved, rejected, active)
ALTER TABLE user_approvals 
  ADD CONSTRAINT user_approvals_status_check 
  CHECK (status IN ('pending', 'approved', 'rejected', 'active'));

-- PASSO 5: Popular user_approvals com dados de auth.users + empresas
INSERT INTO user_approvals (user_id, email, full_name, company_name, created_at, status, user_role)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'full_name', 'Usuário'),
  COALESCE(e.nome, 'Empresa'),
  u.created_at,
  'approved',  -- Mudado de 'active' para 'approved'
  'owner'
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
WHERE NOT EXISTS (
  SELECT 1 FROM user_approvals ua WHERE ua.user_id = u.id
)
ON CONFLICT (user_id) DO NOTHING;

-- PASSO 6: Habilitar RLS
ALTER TABLE user_approvals ENABLE ROW LEVEL SECURITY;

-- PASSO 7: Criar política para super admin ver todos
DROP POLICY IF EXISTS "Super admin vê todos user_approvals" ON user_approvals;

CREATE POLICY "Super admin vê todos user_approvals" ON user_approvals
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE id = auth.uid()
      AND email = 'novaradiosystem@outlook.com'
    )
  );

-- PASSO 8: Criar política para usuários verem apenas próprio registro
DROP POLICY IF EXISTS "Usuários veem próprio registro" ON user_approvals;

CREATE POLICY "Usuários veem próprio registro" ON user_approvals
  FOR ALL
  USING (user_id = auth.uid());

-- PASSO 9: Verificar resultado
SELECT 
  user_id,
  email,
  full_name,
  company_name,
  status,
  user_role,
  created_at
FROM user_approvals
ORDER BY created_at DESC
LIMIT 10;
