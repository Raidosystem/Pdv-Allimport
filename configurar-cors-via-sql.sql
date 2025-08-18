-- CONFIGURAR CORS VIA SQL (MÉTODO ALTERNATIVO)
-- Execute no SQL Editor do Supabase

-- Método 1: Configurar CORS diretamente
ALTER SYSTEM SET cors.allowed_origins = 
  'https://pdv.crmvsystem.com,http://localhost:3000,http://localhost:5173,https://localhost:5173';

-- Recarregar configuração
SELECT pg_reload_conf();

-- Método 2: Verificar configuração atual
SHOW cors.allowed_origins;

-- Método 3: Configurar headers CORS manualmente (se necessário)
CREATE OR REPLACE FUNCTION set_cors_headers()
RETURNS void AS $$
BEGIN
    -- Headers CORS para permitir requisições
    PERFORM set_config('response.headers', 
        '[{"Access-Control-Allow-Origin": "https://pdv.crmvsystem.com"}, ' ||
         '{"Access-Control-Allow-Methods": "GET,POST,PUT,PATCH,DELETE,OPTIONS"}, ' ||
         '{"Access-Control-Allow-Headers": "Content-Type,Authorization,Accept,Accept-Language,X-Requested-With"}]', 
        false);
END;
$$ LANGUAGE plpgsql;

-- Executar função
SELECT set_cors_headers();

-- Verificar se funcionou
SELECT 
  'CORS configurado via SQL' as status,
  current_timestamp as configurado_em;

-- Comentários:
-- 1. Execute estes comandos no SQL Editor
-- 2. Aguarde 1-2 minutos para propagação  
-- 3. Limpe cache do navegador
-- 4. Teste login em https://pdv.crmvsystem.com/
