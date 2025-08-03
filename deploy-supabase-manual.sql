-- Script SQL para executar manualmente no Dashboard do Supabase
-- Data: 2025-08-03
-- Objetivo: Deploy de melhorias no fluxo de confirmação de email

-- 1. Verificar estrutura atual do banco
SELECT 
  schemaname,
  tablename
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- 2. Verificar se as tabelas principais existem
DO $$
BEGIN
    -- Verificar e reportar status das tabelas
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'categorias') THEN
        RAISE NOTICE 'Tabela categorias: ✅ OK';
    ELSE
        RAISE NOTICE 'Tabela categorias: ❌ Não encontrada';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'produtos') THEN
        RAISE NOTICE 'Tabela produtos: ✅ OK';
    ELSE
        RAISE NOTICE 'Tabela produtos: ❌ Não encontrada';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'clientes') THEN
        RAISE NOTICE 'Tabela clientes: ✅ OK';
    ELSE
        RAISE NOTICE 'Tabela clientes: ❌ Não encontrada';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'vendas') THEN
        RAISE NOTICE 'Tabela vendas: ✅ OK';
    ELSE
        RAISE NOTICE 'Tabela vendas: ❌ Não encontrada';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'caixa') THEN
        RAISE NOTICE 'Tabela caixa: ✅ OK';
    ELSE
        RAISE NOTICE 'Tabela caixa: ❌ Não encontrada';
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'ordens_servico') THEN
        RAISE NOTICE 'Tabela ordens_servico: ✅ OK';
    ELSE
        RAISE NOTICE 'Tabela ordens_servico: ❌ Não encontrada';
    END IF;
END $$;

-- 3. Função para logging de confirmação de email
CREATE OR REPLACE FUNCTION public.log_email_confirmation()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Log simples para confirmação de email
    RAISE NOTICE 'Email confirmado para usuário: %', NEW.email;
    RETURN NEW;
END;
$$;

-- 4. Trigger para log de confirmação (opcional)
DROP TRIGGER IF EXISTS email_confirmation_log ON auth.users;
CREATE TRIGGER email_confirmation_log
    AFTER UPDATE OF email_confirmed_at ON auth.users
    FOR EACH ROW
    WHEN (OLD.email_confirmed_at IS NULL AND NEW.email_confirmed_at IS NOT NULL)
    EXECUTE FUNCTION public.log_email_confirmation();

-- 5. Verificar configurações de RLS
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true;

-- Finalizar
SELECT 'Deploy de melhorias concluído! ✅' as status;
