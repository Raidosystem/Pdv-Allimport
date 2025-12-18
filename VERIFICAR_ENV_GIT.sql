-- =====================================================
-- 🔍 VERIFICAR SE .ENV FOI COMMITADO (Executar no Supabase)
-- =====================================================
-- Use este SQL para registrar se as chaves precisam ser rotacionadas
-- =====================================================

CREATE TABLE IF NOT EXISTS public.security_audit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    check_type TEXT NOT NULL,
    status TEXT NOT NULL,
    details JSONB,
    action_required BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Registrar verificação de .env
INSERT INTO public.security_audit (check_type, status, details, action_required)
VALUES (
    'env_file_check',
    'pending_verification',
    jsonb_build_object(
        'message', 'Verificar no terminal local se .env está no git history',
        'command', 'git log --all --full-history -- ".env"',
        'action_if_found', 'ROTACIONAR TODAS AS CHAVES IMEDIATAMENTE',
        'keys_to_rotate', ARRAY[
            'VITE_SUPABASE_ANON_KEY',
            'VITE_MP_ACCESS_TOKEN',
            'VITE_MP_CLIENT_SECRET'
        ]
    ),
    true
);

-- Consultar status
SELECT * FROM public.security_audit 
WHERE check_type = 'env_file_check' 
ORDER BY created_at DESC 
LIMIT 1;
