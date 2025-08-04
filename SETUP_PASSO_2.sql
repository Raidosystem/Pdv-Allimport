-- ================================
-- PASSO 2: ÍNDICES E RLS
-- ================================

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_user_approvals_user_id ON public.user_approvals(user_id);
CREATE INDEX IF NOT EXISTS idx_user_approvals_status ON public.user_approvals(status);
CREATE INDEX IF NOT EXISTS idx_user_approvals_email ON public.user_approvals(email);

-- Habilitar RLS
ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;
