-- ============================================================================
-- CORREÇÃO COMPLETA: USUÁRIOS ATUAIS + GARANTIR FUTUROS CADASTROS
-- ============================================================================

-- ============================================================================
-- PARTE 1: CORRIGIR USUÁRIOS JÁ CADASTRADOS
-- ============================================================================

-- Ver usuários que precisam ser corrigidos
SELECT 
  '❌ USUÁRIOS QUE PRECISAM SER CORRIGIDOS:' as info,
  email,
  full_name,
  status,
  user_role,
  approved_at
FROM user_approvals
WHERE status = 'approved' 
  AND (user_role IS NULL OR user_role != 'owner');

-- EXECUTAR: Corrigir user_role para 'owner'
UPDATE user_approvals 
SET user_role = 'owner'
WHERE status = 'approved' 
  AND (user_role IS NULL OR user_role != 'owner')
RETURNING email, user_role, status;

-- Verificar resultado
SELECT 
  '✅ APÓS CORREÇÃO:' as resultado,
  COUNT(*) as total_que_aparecem_no_admin
FROM user_approvals
WHERE status = 'approved' 
  AND user_role = 'owner';

-- ============================================================================
-- PARTE 2: GARANTIR QUE FUTUROS CADASTROS FUNCIONEM
-- ============================================================================

-- Verificar se a função activate_trial_for_new_user existe
SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'activate_trial_for_new_user')
    THEN '✅ Função activate_trial_for_new_user existe'
    ELSE '❌ PROBLEMA: Função não existe - Execute FIX_TESTE_15_DIAS_COMPLETO.sql'
  END as status_funcao;

-- Verificar estrutura da tabela user_approvals
SELECT 
  '📋 COLUNAS DA TABELA user_approvals:' as info,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'user_approvals'
  AND column_name IN ('status', 'user_role', 'email_verified', 'approved_at')
ORDER BY column_name;

-- ============================================================================
-- PARTE 3: CRIAR TRIGGER PARA AUTO-CORREÇÃO (OPCIONAL)
-- ============================================================================

-- Este trigger garante que todo usuário aprovado seja 'owner' automaticamente
CREATE OR REPLACE FUNCTION auto_set_owner_role()
RETURNS TRIGGER AS $$
BEGIN
  -- Se status mudou para 'approved' e user_role está vazio
  IF NEW.status = 'approved' AND (NEW.user_role IS NULL OR NEW.user_role = '') THEN
    NEW.user_role := 'owner';
    RAISE NOTICE '✅ user_role definido automaticamente como owner para: %', NEW.email;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger
DROP TRIGGER IF EXISTS trigger_auto_set_owner_role ON user_approvals;
CREATE TRIGGER trigger_auto_set_owner_role
  BEFORE INSERT OR UPDATE ON user_approvals
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_owner_role();

SELECT '✅ Trigger criado com sucesso!' as resultado;

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

SELECT 
  '📊 RESUMO FINAL:' as tipo,
  (SELECT COUNT(*) FROM user_approvals) as total_usuarios,
  (SELECT COUNT(*) FROM user_approvals WHERE status = 'approved') as aprovados,
  (SELECT COUNT(*) FROM user_approvals WHERE status = 'approved' AND user_role = 'owner') as aparecem_no_admin,
  CASE 
    WHEN (SELECT COUNT(*) FROM user_approvals WHERE status = 'approved') = 
         (SELECT COUNT(*) FROM user_approvals WHERE status = 'approved' AND user_role = 'owner')
    THEN '✅ TODOS OS APROVADOS APARECEM NO ADMIN!'
    ELSE '⚠️ Ainda há usuários aprovados que não aparecem'
  END as status;
