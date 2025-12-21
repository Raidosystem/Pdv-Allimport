-- Habilitar extensão pgcrypto necessária para crypt()
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Verificar se foi habilitada
SELECT 
  '✅ Extensão pgcrypto habilitada' as status,
  extname,
  extversion
FROM pg_extension
WHERE extname = 'pgcrypto';

-- Testar a função crypt
SELECT 
  '🔐 Teste da função crypt()' as teste,
  crypt('teste123', gen_salt('bf')) as senha_hash,
  CASE 
    WHEN crypt('teste123', gen_salt('bf')) IS NOT NULL THEN '✅ Funcionando'
    ELSE '❌ Não funcionando'
  END as resultado;
