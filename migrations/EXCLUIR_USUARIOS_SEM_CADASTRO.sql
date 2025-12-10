-- ============================================
-- 🗑️ EXCLUIR USUÁRIOS SEM CADASTRO COMPLETO
-- Remove usuários que não têm dados no user_approvals
-- ============================================

-- ⚠️ ATENÇÃO: Isto vai DELETAR permanentemente:
-- - Assinaturas de usuários sem cadastro
-- - Dados relacionados desses usuários
-- - NÃO é possível desfazer!

-- ============================================
-- PASSO 1: Ver quais usuários serão excluídos
-- ============================================

SELECT 
  '📋 PREVIEW - Usuários que serão EXCLUÍDOS:' as info;

SELECT 
  s.user_id,
  s.email as email_subscription,
  s.status,
  s.trial_end_date,
  s.subscription_end_date,
  s.created_at,
  CASE 
    WHEN ua.user_id IS NULL THEN '❌ SEM CADASTRO - SERÁ EXCLUÍDO'
    ELSE '✅ TEM CADASTRO - MANTIDO'
  END as situacao
FROM subscriptions s
LEFT JOIN user_approvals ua ON s.user_id = ua.user_id
ORDER BY situacao DESC, s.created_at DESC;

-- ============================================
-- PASSO 2: Contar quantos serão excluídos
-- ============================================

SELECT 
  COUNT(*) as total_sem_cadastro,
  '⚠️ assinaturas serão DELETADAS' as aviso
FROM subscriptions s
LEFT JOIN user_approvals ua ON s.user_id = ua.user_id
WHERE ua.user_id IS NULL;

-- ============================================
-- PASSO 3: EXECUTAR EXCLUSÃO
-- ⚠️ ATENÇÃO: Isto vai DELETAR permanentemente!
-- ============================================

-- Deletar assinaturas SEM cadastro no user_approvals
DELETE FROM subscriptions
WHERE user_id IN (
  SELECT s.user_id
  FROM subscriptions s
  LEFT JOIN user_approvals ua ON s.user_id = ua.user_id
  WHERE ua.user_id IS NULL
);

-- Confirmar exclusão
SELECT 
  '✅ EXCLUÍDO COM SUCESSO!' as status,
  COUNT(*) as total_restantes,
  'assinaturas mantidas (com cadastro completo)' as info
FROM subscriptions s
INNER JOIN user_approvals ua ON s.user_id = ua.user_id;

-- ============================================
-- ✅ INSTRUÇÕES:
-- 1. Execute até o PASSO 2 para VER quem será excluído
-- 2. Se estiver certo, DESCOMENTE o PASSO 3
-- 3. Execute novamente para DELETAR permanentemente
-- ============================================
