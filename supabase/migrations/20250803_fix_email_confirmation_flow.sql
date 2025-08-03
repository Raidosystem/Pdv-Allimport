-- Configuração correta para confirmação de email
-- Data: 2025-08-03

-- 1. Verificar configurações atuais de auth
DO $$
BEGIN
    -- Mostrar configurações atuais
    RAISE NOTICE 'Verificando configurações de autenticação...';
END $$;

-- 2. Atualizar configurações de email no auth.config se necessário
-- Nota: Essas configurações são geralmente feitas via Dashboard do Supabase

-- 3. Verificar se as URLs de redirecionamento estão corretas
-- As URLs permitidas devem incluir:
-- - https://pdv-allimport.vercel.app/confirm-email
-- - http://localhost:5174/confirm-email

-- 4. Garantir que o template de email está correto
-- O link de confirmação deve apontar para a URL correta

-- 5. Verificar função de confirmação customizada se houver
CREATE OR REPLACE FUNCTION confirm_email_custom(
  user_id uuid,
  email text
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Marcar email como confirmado
  UPDATE auth.users 
  SET email_confirmed_at = now(),
      confirmation_token = null
  WHERE id = user_id 
  AND email = confirm_email_custom.email;
  
  IF NOT FOUND THEN
    RETURN false;
  END IF;
  
  RETURN true;
END;
$$;

-- 6. Comentários para configuração manual no Dashboard:
/*
CONFIGURAÇÕES NECESSÁRIAS NO DASHBOARD DO SUPABASE:

1. Authentication > Settings > General:
   - Site URL: https://pdv-allimport.vercel.app
   - Redirect URLs: 
     * https://pdv-allimport.vercel.app/confirm-email
     * https://pdv-allimport.vercel.app/reset-password
     * http://localhost:5174/confirm-email
     * http://localhost:5174/reset-password

2. Authentication > Settings > Email:
   - Confirm email: Enabled
   - Email confirmation template:
     * Subject: Confirme seu email - PDV Allimport
     * Body deve conter: {{ .ConfirmationURL }}

3. Authentication > Settings > Security:
   - Email confirmation required: Enabled
   - Double confirmation for password changes: Enabled

4. Verificar se o SMTP está configurado corretamente ou usar o provedor padrão
*/
