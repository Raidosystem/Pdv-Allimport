-- CONFIGURAR CORS VIA SQL - VERSÃO CORRIGIDA
-- Execute CADA COMANDO SEPARADAMENTE no SQL Editor do Supabase

-- ═══════════════════════════════════════════════════════════
-- PASSO 1: Execute APENAS este comando primeiro
-- ═══════════════════════════════════════════════════════════

ALTER SYSTEM SET cors.allowed_origins = 'https://pdv.crmvsystem.com,http://localhost:3000,http://localhost:5173,https://localhost:5173';

-- ═══════════════════════════════════════════════════════════
-- PASSO 2: Depois execute APENAS este comando
-- ═══════════════════════════════════════════════════════════

SELECT pg_reload_conf();

-- ═══════════════════════════════════════════════════════════
-- PASSO 3: Depois execute APENAS este comando para verificar
-- ═══════════════════════════════════════════════════════════

SHOW cors.allowed_origins;

-- ═══════════════════════════════════════════════════════════
-- INSTRUÇÕES:
-- ═══════════════════════════════════════════════════════════
-- 1. Copie o PASSO 1 e execute
-- 2. Copie o PASSO 2 e execute  
-- 3. Copie o PASSO 3 e execute
-- 4. Aguarde 2-3 minutos
-- 5. Limpe cache: Ctrl + Shift + Delete
-- 6. Teste: https://pdv.crmvsystem.com/
-- ═══════════════════════════════════════════════════════════
