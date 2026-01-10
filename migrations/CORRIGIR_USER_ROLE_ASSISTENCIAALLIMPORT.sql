-- ============================================================================
-- CORRIGIR user_role de assistenciaallimport10 para OWNER
-- ============================================================================
-- Esse usuário tem subscription premium ativa, então deve ser owner
-- ============================================================================

-- 1. Verificar estado atual
SELECT 
  user_id,
  email,
  user_role,
  status,
  'ANTES DA CORREÇÃO' as momento
FROM user_approvals
WHERE email = 'assistenciaallimport10@gmail.com';

-- 2. CORRIGIR: Alterar de employee para owner
UPDATE user_approvals
SET 
  user_role = 'owner',
  updated_at = NOW()
WHERE email = 'assistenciaallimport10@gmail.com';

-- 3. Verificar após correção
SELECT 
  user_id,
  email,
  user_role,
  status,
  'DEPOIS DA CORREÇÃO' as momento
FROM user_approvals
WHERE email = 'assistenciaallimport10@gmail.com';

-- 4. Verificar todos os owners agora
SELECT 
  email,
  user_role,
  'Deve aparecer no painel' as resultado
FROM user_approvals
WHERE user_role = 'owner'
ORDER BY created_at DESC;
