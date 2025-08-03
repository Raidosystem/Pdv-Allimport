-- Migration: Configure email templates for password recovery
-- Date: 2025-08-03
-- Description: Setup email templates and configuration for password recovery

-- Note: This migration contains SQL that should be executed in Supabase Dashboard
-- Go to Authentication > Settings > Email Templates

-- The following templates should be configured in the Supabase Dashboard:

/*
1. MAGIC LINK EMAIL TEMPLATE:
Subject: Confirme seu email - PDV Allimport

Body:
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Confirme seu email - PDV Allimport</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
        <h1 style="color: white; margin: 0;">PDV Allimport</h1>
        <p style="color: white; margin: 10px 0 0 0;">Sistema de Vendas</p>
    </div>
    
    <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
        <h2 style="color: #333; margin-top: 0;">Confirme seu email</h2>
        <p>Clique no botão abaixo para confirmar seu email e ativar sua conta:</p>
        
        <div style="text-align: center; margin: 30px 0;">
            <a href="{{ .ConfirmationURL }}" 
               style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                      color: white; 
                      padding: 15px 30px; 
                      text-decoration: none; 
                      border-radius: 5px; 
                      font-weight: bold;
                      display: inline-block;">
                Confirmar Email
            </a>
        </div>
        
        <p style="font-size: 12px; color: #666; margin-top: 30px;">
            Se você não conseguir clicar no botão, copie e cole este link no seu navegador:<br>
            <span style="word-break: break-all;">{{ .ConfirmationURL }}</span>
        </p>
        
        <p style="font-size: 12px; color: #666;">
            Se você não solicitou esta confirmação, pode ignorar este email.
        </p>
    </div>
</body>
</html>

2. RECOVERY EMAIL TEMPLATE:
Subject: Recuperação de senha - PDV Allimport

Body:
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Recuperação de senha - PDV Allimport</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
        <h1 style="color: white; margin: 0;">PDV Allimport</h1>
        <p style="color: white; margin: 10px 0 0 0;">Sistema de Vendas</p>
    </div>
    
    <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
        <h2 style="color: #333; margin-top: 0;">Recuperação de senha</h2>
        <p>Você solicitou a recuperação de senha para sua conta. Clique no botão abaixo para criar uma nova senha:</p>
        
        <div style="text-align: center; margin: 30px 0;">
            <a href="{{ .ConfirmationURL }}" 
               style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); 
                      color: white; 
                      padding: 15px 30px; 
                      text-decoration: none; 
                      border-radius: 5px; 
                      font-weight: bold;
                      display: inline-block;">
                Redefinir Senha
            </a>
        </div>
        
        <p style="font-size: 12px; color: #666; margin-top: 30px;">
            Se você não conseguir clicar no botão, copie e cole este link no seu navegador:<br>
            <span style="word-break: break-all;">{{ .ConfirmationURL }}</span>
        </p>
        
        <div style="background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <h4 style="color: #856404; margin: 0 0 10px 0;">⚠️ Importante:</h4>
            <p style="color: #856404; margin: 0; font-size: 14px;">
                Este link expira em 60 minutos por segurança. Se não foi você quem solicitou esta recuperação, ignore este email.
            </p>
        </div>
        
        <p style="font-size: 12px; color: #666;">
            Para sua segurança, não compartilhe este link com ninguém.
        </p>
    </div>
</body>
</html>
*/

-- Enable email confirmations (this should be set in Supabase Dashboard)
-- Go to Authentication > Settings > Email auth > Enable email confirmations: true

-- Set the redirect URLs (this should be set in Supabase Dashboard)
-- Go to Authentication > URL Configuration
-- Site URL: https://pdv-allimport.vercel.app
-- Redirect URLs: 
--   - https://pdv-allimport.vercel.app/reset-password
--   - https://pdv-allimport.vercel.app/auth/callback
--   - http://localhost:5174/reset-password
--   - http://localhost:5174/auth/callback

-- Create a function to check email configuration
CREATE OR REPLACE FUNCTION check_email_config()
RETURNS TABLE (
  setting_name text,
  current_value text,
  recommended_value text,
  status text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    'email_confirmations'::text,
    'Check in Dashboard'::text,
    'Enabled'::text,
    'Manual Check Required'::text
  UNION ALL
  SELECT 
    'smtp_configuration'::text,
    'Check in Dashboard'::text,
    'Configured'::text,
    'Manual Check Required'::text
  UNION ALL
  SELECT 
    'recovery_email_template'::text,
    'Check in Dashboard'::text,
    'Custom Template'::text,
    'Manual Check Required'::text;
END;
$$ LANGUAGE plpgsql;
