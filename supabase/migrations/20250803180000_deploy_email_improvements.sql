-- Migração para configurações de email e melhorias do PDV
-- Aplicada em: 2025-08-03

-- 1. Verificar e criar função para confirmação de email personalizada se não existir
CREATE OR REPLACE FUNCTION public.handle_email_confirmation()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Log de confirmação de email
  INSERT INTO public.auth_logs (
    user_id,
    action,
    details,
    created_at
  ) VALUES (
    NEW.id,
    'email_confirmed',
    'Email confirmado: ' || NEW.email,
    NOW()
  );
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Se a tabela auth_logs não existir, ignora o erro
    RETURN NEW;
END;
$$;

-- 2. Criar trigger para log de confirmação de email se não existir
DROP TRIGGER IF EXISTS on_email_confirmed ON auth.users;
CREATE TRIGGER on_email_confirmed
  AFTER UPDATE OF email_confirmed_at ON auth.users
  FOR EACH ROW
  WHEN (OLD.email_confirmed_at IS NULL AND NEW.email_confirmed_at IS NOT NULL)
  EXECUTE FUNCTION public.handle_email_confirmation();

-- 3. Comentários sobre configurações necessárias no Dashboard
/*
CONFIGURAÇÕES MANUAIS NECESSÁRIAS NO DASHBOARD DO SUPABASE:

1. Authentication > Settings > General:
   Site URL: https://pdv-allimport.vercel.app

2. Authentication > Settings > Redirect URLs:
   - https://pdv-allimport.vercel.app/confirm-email
   - https://pdv-allimport.vercel.app/dashboard
   - https://pdv-allimport.vercel.app/reset-password
   - http://localhost:5174/confirm-email
   - http://localhost:5174/dashboard
   - http://localhost:5174/reset-password

3. Authentication > Email:
   - Enable email confirmations: true
   - Confirm email: true
   - Double confirm email changes: true
   - Secure password change: true

4. Authentication > Email Templates:
   Verificar se o template de confirmação contém o link correto:
   {{ .ConfirmationURL }}
*/

-- 4. Verificar se todas as tabelas principais existem
DO $$
BEGIN
    -- Verificar tabela categorias
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'categorias') THEN
        RAISE NOTICE 'Tabela categorias não encontrada - execute as migrações principais primeiro';
    END IF;
    
    -- Verificar tabela produtos
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'produtos') THEN
        RAISE NOTICE 'Tabela produtos não encontrada - execute as migrações principais primeiro';
    END IF;
    
    -- Verificar tabela clientes
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'clientes') THEN
        RAISE NOTICE 'Tabela clientes não encontrada - execute as migrações principais primeiro';
    END IF;
    
    RAISE NOTICE 'Verificação de tabelas concluída';
END $$;
