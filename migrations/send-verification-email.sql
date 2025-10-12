-- ========================================
-- FUNÇÃO PARA ENVIAR EMAIL COM CÓDIGO VIA SMTP
-- ========================================
-- 
-- IMPORTANTE: Esta função usa o sistema de Auth do Supabase
-- para enviar emails via SMTP configurado
--
-- O Supabase não permite enviar emails customizados diretamente do PostgreSQL
-- por questões de segurança. A solução é:
-- 1. Gerar código no banco
-- 2. Retornar código ao frontend
-- 3. Frontend chama API de email (Resend, SendGrid, ou SMTP próprio)

CREATE OR REPLACE FUNCTION send_custom_verification_email(
  user_email TEXT,
  verification_code TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  email_html TEXT;
BEGIN
  -- Template HTML do email
  email_html := format('
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <title>Código de Verificação</title>
    </head>
    <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
      <div style="background: linear-gradient(135deg, #667eea 0%%, #764ba2 100%%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
        <h1 style="color: white; margin: 0;">🛒 PDV Allimport</h1>
      </div>
      
      <div style="background: #f7f7f7; padding: 40px; border-radius: 0 0 10px 10px;">
        <h2 style="color: #333; margin-top: 0;">Código de Verificação</h2>
        <p style="color: #666; font-size: 16px;">Seu código de verificação é:</p>
        
        <div style="background: white; padding: 20px; border-radius: 8px; text-align: center; margin: 30px 0;">
          <span style="font-size: 48px; font-weight: bold; color: #667eea; letter-spacing: 8px;">%s</span>
        </div>
        
        <p style="color: #666; font-size: 14px;">
          ⏰ Este código expira em <strong>15 minutos</strong>.<br>
          🔒 Não compartilhe este código com ninguém.
        </p>
        
        <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
        
        <p style="color: #999; font-size: 12px; text-align: center;">
          Se você não solicitou este código, ignore este email.
        </p>
      </div>
    </body>
    </html>
  ', verification_code);
  
  -- Log para debug
  RAISE NOTICE 'Código de verificação preparado para %: %', user_email, verification_code;
  RAISE NOTICE 'HTML do email gerado com sucesso';
  
  -- NOTA: O Supabase não permite envio direto de emails via PostgreSQL
  -- O email deve ser enviado pelo frontend usando:
  -- 1. Resend API
  -- 2. SendGrid API  
  -- 3. Supabase Edge Functions
  -- 4. Ou outro serviço de email
  
  RETURN jsonb_build_object(
    'success', TRUE,
    'message', 'Template de email gerado',
    'code', verification_code,
    'email', user_email,
    'html', email_html,
    'note', 'Email deve ser enviado pelo frontend via API de terceiros'
  );
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', FALSE,
      'error', SQLERRM
    );
END;
$$;

COMMENT ON FUNCTION send_custom_verification_email(TEXT, TEXT) IS 
'Gera template HTML de email com código de verificação';

GRANT EXECUTE ON FUNCTION send_custom_verification_email(TEXT, TEXT) TO anon, authenticated;
