-- ALTERNATIVA AO CORS: CONFIGURAR RLS PARA PERMITIR ACESSO
-- Execute CADA COMANDO SEPARADAMENTE no SQL Editor do Supabase

-- ═══════════════════════════════════════════════════════════
-- PASSO 1: Desabilitar RLS temporariamente para testar
-- ═══════════════════════════════════════════════════════════

ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_venda DISABLE ROW LEVEL SECURITY;

-- ═══════════════════════════════════════════════════════════
-- PASSO 2: Verificar se existem usuários
-- ═══════════════════════════════════════════════════════════

SELECT email, email_confirmed_at, created_at FROM auth.users ORDER BY created_at DESC;

-- ═══════════════════════════════════════════════════════════
-- PASSO 3: Limpar sessões ativas (se necessário)
-- ═══════════════════════════════════════════════════════════

DELETE FROM auth.sessions;
DELETE FROM auth.refresh_tokens;

-- ═══════════════════════════════════════════════════════════
-- PASSO 4: Confirmar emails não confirmados
-- ═══════════════════════════════════════════════════════════

UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email_confirmed_at IS NULL;

-- ═══════════════════════════════════════════════════════════
-- INSTRUÇÕES:
-- ═══════════════════════════════════════════════════════════
-- 1. Execute PASSO 1 (desabilitar RLS temporariamente)
-- 2. Execute PASSO 2 (verificar usuários)
-- 3. Execute PASSO 3 (limpar sessões)
-- 4. Execute PASSO 4 (confirmar emails)
-- 5. Teste login em: https://pdv.crmvsystem.com/
-- 
-- Se funcionar, o problema não era CORS, era RLS bloqueando
-- ═══════════════════════════════════════════════════════════
