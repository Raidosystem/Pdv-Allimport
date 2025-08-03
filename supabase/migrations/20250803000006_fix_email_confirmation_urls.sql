-- Migration: Fix email confirmation URLs for production
-- Date: 2025-08-03
-- Description: Document URL configuration for Supabase Auth

-- IMPORTANT: These settings must be configured manually in Supabase Dashboard
-- Go to: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/auth/settings

-- Create a function to check auth configuration
CREATE OR REPLACE FUNCTION check_auth_config()
RETURNS TABLE (
  setting_name text,
  current_value text,
  recommended_value text,
  status text,
  instructions text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    'site_url'::text,
    'Check Dashboard'::text,
    'https://pdv-allimport.vercel.app'::text,
    'Manual Check Required'::text,
    'Set in Authentication > Settings > Site URL'::text
  UNION ALL
  SELECT 
    'redirect_urls'::text,
    'Check Dashboard'::text,
    'https://pdv-allimport.vercel.app/confirm-email'::text,
    'Manual Check Required'::text,
    'Add to Authentication > Settings > Redirect URLs'::text
  UNION ALL
  SELECT 
    'email_confirmation'::text,
    'Check Dashboard'::text,
    'Enabled'::text,
    'Manual Check Required'::text,
    'Enable in Authentication > Settings > Email Auth'::text;
END;
$$ LANGUAGE plpgsql;

-- Create function to generate proper confirmation URL
CREATE OR REPLACE FUNCTION get_confirmation_url(user_email text)
RETURNS text AS $$
DECLARE
    base_url text := 'https://pdv-allimport.vercel.app';
BEGIN
    RETURN base_url || '/confirm-email';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_auth_config() IS 'Check authentication configuration for email confirmation';
COMMENT ON FUNCTION get_confirmation_url(text) IS 'Generate proper confirmation URL for production';
