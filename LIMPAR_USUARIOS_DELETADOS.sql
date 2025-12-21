-- ============================================
-- LIMPAR USUÁRIOS DELETADOS DE user_approvals
-- ============================================

-- PASSO 1: Ver usuários em user_approvals que NÃO existem mais em auth.users
SELECT 
  ua.user_id,
  ua.email,
  ua.full_name,
  '❌ USUÁRIO JÁ FOI DELETADO' as status
FROM user_approvals ua
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users u WHERE u.id = ua.user_id
);

-- PASSO 2: Deletar registros órfãos (usuários que não existem mais)
DELETE FROM user_approvals
WHERE user_id NOT IN (
  SELECT id FROM auth.users
);

-- PASSO 3: Verificar constraint CASCADE da foreign key
SELECT
  con.conname AS constraint_name,
  con.contype AS constraint_type,
  pg_get_constraintdef(con.oid) AS constraint_definition
FROM pg_constraint con
JOIN pg_class rel ON rel.oid = con.conrelid
WHERE rel.relname = 'user_approvals'
  AND con.contype = 'f'; -- foreign keys

-- PASSO 4: Recriar foreign key com CASCADE correto
ALTER TABLE user_approvals 
  DROP CONSTRAINT IF EXISTS user_approvals_user_id_fkey;

ALTER TABLE user_approvals
  ADD CONSTRAINT user_approvals_user_id_fkey
  FOREIGN KEY (user_id)
  REFERENCES auth.users(id)
  ON DELETE CASCADE;

-- PASSO 5: Verificar resultado (deve listar apenas usuários válidos)
SELECT 
  ua.user_id,
  ua.email,
  ua.full_name,
  ua.company_name,
  CASE 
    WHEN EXISTS (SELECT 1 FROM auth.users u WHERE u.id = ua.user_id)
    THEN '✅ EXISTE em auth.users'
    ELSE '❌ NÃO EXISTE em auth.users'
  END as validacao
FROM user_approvals ua
ORDER BY ua.created_at DESC;
