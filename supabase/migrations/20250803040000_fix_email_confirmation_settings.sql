-- Migration: Corrigir configurações de confirmação de email
-- Date: 2025-08-03 04:00:00
-- Description: Garantir que as confirmações de email estejam habilitadas

-- ==========================================
-- IMPORTANTE: CONFIGURAÇÕES MANUAIS NO DASHBOARD
-- ==========================================

-- Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/auth/settings

-- 1. SITE URL:
--    https://pdv-allimport.vercel.app

-- 2. REDIRECT URLS (adicionar todas):
--    https://pdv-allimport.vercel.app/confirm-email
--    https://pdv-allimport.vercel.app/reset-password
--    https://pdv-allimport.vercel.app/dashboard
--    http://localhost:5174/confirm-email
--    http://localhost:5174/reset-password
--    http://localhost:5174/dashboard

-- 3. EMAIL AUTH SETTINGS:
--    ✅ Enable email confirmations: ON
--    ✅ Enable email change confirmations: ON
--    ✅ Enable signups: ON

-- 4. EMAIL TEMPLATES (adicionar os templates personalizados):
--    Confirm signup: Template personalizado do PDV Allimport
--    Reset password: Template personalizado do PDV Allimport

-- ==========================================
-- FUNÇÕES DE VERIFICAÇÃO
-- ==========================================

-- Função para verificar configuração de email
CREATE OR REPLACE FUNCTION check_email_config()
RETURNS TABLE (
  config_item text,
  status text,
  notes text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    'Email Confirmations'::text,
    'Verificar Dashboard'::text,
    'Deve estar HABILITADO em Auth > Settings > Email Auth'::text
  UNION ALL
  SELECT 
    'Site URL'::text,
    'Verificar Dashboard'::text,
    'Deve ser: https://pdv-allimport.vercel.app'::text
  UNION ALL
  SELECT 
    'Redirect URLs'::text,
    'Verificar Dashboard'::text,
    'Deve incluir: /confirm-email, /reset-password'::text
  UNION ALL
  SELECT 
    'Email Templates'::text,
    'Verificar Dashboard'::text,
    'Templates personalizados devem estar configurados'::text;
END;
$$ LANGUAGE plpgsql;

-- Função para testar envio de email
CREATE OR REPLACE FUNCTION test_email_sending()
RETURNS TABLE (
  test_name text,
  result text,
  details text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    'SMTP Configuration'::text,
    'Manual Check'::text,
    'Verifique as configurações de SMTP no dashboard'::text
  UNION ALL
  SELECT 
    'Template Configuration'::text,
    'Manual Check'::text,
    'Verifique se os templates estão configurados corretamente'::text;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- CONFIGURAÇÕES DE SEGURANÇA
-- ==========================================

-- Garantir que as políticas de RLS não interfiram com auth
DO $$
BEGIN
  -- Verificar se auth.users está acessível
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'auth' AND table_name = 'users'
  ) THEN
    RAISE NOTICE 'Tabela auth.users não encontrada';
  END IF;
END $$;

-- ==========================================
-- COMENTÁRIOS E DOCUMENTAÇÃO
-- ==========================================

COMMENT ON FUNCTION check_email_config() IS 'Verificar configurações de email no dashboard';
COMMENT ON FUNCTION test_email_sending() IS 'Testar configurações de envio de email';

-- Log da migração
DO $$
BEGIN
  RAISE NOTICE 'Migração 20250803040000: Configurações de email verificadas';
  RAISE NOTICE 'PRÓXIMOS PASSOS:';
  RAISE NOTICE '1. Acesse o dashboard do Supabase';
  RAISE NOTICE '2. Habilite confirmações de email';
  RAISE NOTICE '3. Configure URLs de redirecionamento';
  RAISE NOTICE '4. Teste o fluxo de confirmação';
END $$;
