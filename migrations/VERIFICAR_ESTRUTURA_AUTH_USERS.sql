-- ============================================================================
-- VERIFICAR ESTRUTURA COMPLETA DE auth.users
-- ============================================================================
-- Precisamos ver TODAS as colunas para identificar qual está NULL
-- ============================================================================

-- 1. Ver TODAS as colunas da tabela auth.users
SELECT 
  column_name,
  ordinal_position,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'auth'
  AND table_name = 'users'
ORDER BY ordinal_position;

-- 2. Ver especificamente o valor da coluna na posição 8 (índice 8 = posição 9)
-- E todas as colunas relacionadas a email_change
SELECT 
  id,
  email,
  email_change,
  email_change_token_new,
  email_change_token_current,
  email_change_sent_at,
  email_change_confirm_status
FROM auth.users
WHERE email = 'novaradiosystem@outlook.com';
