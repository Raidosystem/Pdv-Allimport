-- Configurar domínio personalizado pdv.crmvsystem.com no Supabase
-- IMPORTANTE: A configuração de autenticação deve ser feita via Dashboard do Supabase
-- Este SQL é apenas para verificar o ambiente

-- 1. CONFIGURAÇÕES VIA DASHBOARD (NÃO SQL):
-- Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw
-- Vá em: Authentication > Settings > Site URL
-- Defina: https://pdv.crmvsystem.com

-- 2. CONFIGURAÇÕES CORS VIA DASHBOARD:
-- Acesse: Settings > API > CORS Origins
-- Adicione: https://pdv.crmvsystem.com

-- 3. REDIRECT URLs VIA DASHBOARD:
-- Vá em: Authentication > URL Configuration
-- Adicione em "Redirect URLs": 
-- https://pdv.crmvsystem.com
-- https://pdv.crmvsystem.com/auth/callback
-- https://pdv-allimport.vercel.app
-- https://pdv-allimport.vercel.app/auth/callback

-- 4. Verificar se RLS está ativo nas tabelas (via SQL):
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('clientes', 'produtos', 'sales', 'financial_movements')
ORDER BY tablename;

-- 5. Verificar políticas RLS existentes:
SELECT schemaname, tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public' 
ORDER BY tablename, policyname;

-- 6. Testar conexão básica:
SELECT 'Configuração de domínio - teste de conexão' as status, now() as timestamp;
