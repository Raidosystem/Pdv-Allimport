-- ========================================
-- 🔧 SOLUÇÃO EXTREMA - ISOLAMENTO FORÇADO
-- Para casos onde RLS não funciona devido a privilégios
-- ========================================

-- 1. CRIAR VIEWS ISOLADAS QUE SUBSTITUEM AS TABELAS
-- Essas views vão funcionar MESMO com bypass de RLS

-- View para produtos isolados
CREATE OR REPLACE VIEW produtos_isolados AS
SELECT *
FROM produtos
WHERE user_id = COALESCE(auth.uid(), (SELECT id FROM auth.users WHERE email = current_setting('app.user_email', true)));

-- View para clientes isolados
CREATE OR REPLACE VIEW clientes_isolados AS
SELECT *
FROM clientes
WHERE user_id = COALESCE(auth.uid(), (SELECT id FROM auth.users WHERE email = current_setting('app.user_email', true)));

-- View para vendas isoladas
CREATE OR REPLACE VIEW vendas_isoladas AS
SELECT *
FROM vendas
WHERE user_id = COALESCE(auth.uid(), (SELECT id FROM auth.users WHERE email = current_setting('app.user_email', true)));

-- 2. TESTAR AS VIEWS
SELECT 'PRODUTOS ISOLADOS' as teste, COUNT(*) as quantidade FROM produtos_isolados;
SELECT 'CLIENTES ISOLADOS' as teste, COUNT(*) as quantidade FROM clientes_isolados;
SELECT 'VENDAS ISOLADAS' as teste, COUNT(*) as quantidade FROM vendas_isoladas;

-- 3. VERIFICAR SEU CONTEXTO
SELECT 
    'SEU CONTEXTO' as info,
    auth.uid() as auth_uid,
    auth.email() as auth_email,
    current_user as db_user;

SELECT '🔒 VIEWS ISOLADAS CRIADAS!' as resultado;