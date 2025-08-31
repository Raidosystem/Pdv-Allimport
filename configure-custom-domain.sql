-- Configurar domínio personalizado pdv.crmvsystem.com no Supabase
-- Execute este SQL no painel do Supabase > SQL Editor

-- 1. Adicionar domínio aos allowed origins
UPDATE auth.config 
SET allowed_origins = array_append(
  COALESCE(allowed_origins, ARRAY[]::text[]),
  'https://pdv.crmvsystem.com'
) 
WHERE key = 'allowed_origins';

-- Inserir se não existir
INSERT INTO auth.config (key, allowed_origins)
SELECT 'allowed_origins', ARRAY['https://pdv.crmvsystem.com', 'https://pdv-allimport.vercel.app']
WHERE NOT EXISTS (SELECT 1 FROM auth.config WHERE key = 'allowed_origins');

-- 2. Configurar redirect URLs para o domínio personalizado
INSERT INTO auth.config (key, value) VALUES 
('site_url', 'https://pdv.crmvsystem.com'),
('redirect_urls', 'https://pdv.crmvsystem.com,https://pdv-allimport.vercel.app')
ON CONFLICT (key) DO UPDATE SET 
  value = EXCLUDED.value;

-- 3. Atualizar configurações CORS
-- Esta parte deve ser feita no painel do Supabase > Settings > API > CORS
-- Adicionar: https://pdv.crmvsystem.com

-- 4. Verificar configurações
SELECT * FROM auth.config;
