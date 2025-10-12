-- ================================================
-- SISTEMA DE VERIFICAÇÃO DE WHATSAPP
-- ================================================
-- Criado em: 10/10/2025
-- Função: Permitir verificação de contas via código WhatsApp

-- 1. CRIAR TABELA DE CÓDIGOS DE VERIFICAÇÃO
-- ================================================
CREATE TABLE IF NOT EXISTS public.verification_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    phone VARCHAR(20) NOT NULL,
    code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    attempts INT DEFAULT 0,
    max_attempts INT DEFAULT 3,
    CONSTRAINT unique_active_code UNIQUE (user_id, phone)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_verification_codes_user ON public.verification_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_verification_codes_phone ON public.verification_codes(phone);
CREATE INDEX IF NOT EXISTS idx_verification_codes_expires ON public.verification_codes(expires_at);

-- Comentários
COMMENT ON TABLE public.verification_codes IS 'Códigos de verificação enviados via WhatsApp';
COMMENT ON COLUMN public.verification_codes.code IS 'Código de 6 dígitos';
COMMENT ON COLUMN public.verification_codes.expires_at IS 'Código expira em 10 minutos';
COMMENT ON COLUMN public.verification_codes.attempts IS 'Número de tentativas de validação';


-- 2. ATUALIZAR TABELA user_approvals
-- ================================================
ALTER TABLE public.user_approvals 
ADD COLUMN IF NOT EXISTS cpf_cnpj VARCHAR(18),
ADD COLUMN IF NOT EXISTS whatsapp VARCHAR(20),
ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS document_type VARCHAR(10); -- 'CPF' ou 'CNPJ'

-- Índices
CREATE INDEX IF NOT EXISTS idx_user_approvals_cpf_cnpj ON public.user_approvals(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_user_approvals_whatsapp ON public.user_approvals(whatsapp);
CREATE INDEX IF NOT EXISTS idx_user_approvals_phone_verified ON public.user_approvals(phone_verified);

-- Comentários
COMMENT ON COLUMN public.user_approvals.cpf_cnpj IS 'CPF (11 dígitos) ou CNPJ (14 dígitos)';
COMMENT ON COLUMN public.user_approvals.whatsapp IS 'Número do WhatsApp com DDD (ex: 11999999999)';
COMMENT ON COLUMN public.user_approvals.phone_verified IS 'WhatsApp foi verificado com código';
COMMENT ON COLUMN public.user_approvals.document_type IS 'Tipo de documento: CPF ou CNPJ';


-- 3. FUNÇÃO PARA GERAR CÓDIGO DE VERIFICAÇÃO
-- ================================================
-- REMOVIDO SECURITY DEFINER para permitir chamada direta do frontend
CREATE OR REPLACE FUNCTION public.generate_verification_code(
    p_user_id UUID,
    p_phone VARCHAR(20)
)
RETURNS TABLE(code VARCHAR(6), expires_at TIMESTAMPTZ) 
LANGUAGE plpgsql
SECURITY INVOKER  -- Executa com permissões do usuário que chamou
AS $$
DECLARE
    v_code VARCHAR(6);
    v_expires_at TIMESTAMPTZ;
BEGIN
    -- Verificar se o usuário está autenticado
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    -- Verificar se o usuário está tentando gerar código para si mesmo
    IF auth.uid() != p_user_id THEN
        RAISE EXCEPTION 'Você só pode gerar códigos para sua própria conta';
    END IF;
    
    -- Gerar código de 6 dígitos
    v_code := LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
    
    -- Código expira em 10 minutos
    v_expires_at := NOW() + INTERVAL '10 minutes';
    
    -- Deletar códigos antigos deste usuário/telefone
    DELETE FROM public.verification_codes 
    WHERE user_id = p_user_id OR phone = p_phone;
    
    -- Inserir novo código
    INSERT INTO public.verification_codes (
        user_id,
        phone,
        code,
        expires_at
    ) VALUES (
        p_user_id,
        p_phone,
        v_code,
        v_expires_at
    );
    
    RETURN QUERY SELECT v_code, v_expires_at;
END;
$$;

COMMENT ON FUNCTION public.generate_verification_code IS 'Gera código de 6 dígitos válido por 10 minutos (chamável do frontend)';


-- 4. FUNÇÃO PARA VERIFICAR CÓDIGO
-- ================================================
-- REMOVIDO SECURITY DEFINER para permitir chamada direta do frontend
CREATE OR REPLACE FUNCTION public.verify_whatsapp_code(
    p_user_id UUID,
    p_code VARCHAR(6)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER  -- Executa com permissões do usuário que chamou
AS $$
DECLARE
    v_record RECORD;
    v_valid BOOLEAN := FALSE;
BEGIN
    -- Verificar se o usuário está autenticado
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    -- Verificar se o usuário está tentando verificar sua própria conta
    IF auth.uid() != p_user_id THEN
        RAISE EXCEPTION 'Você só pode verificar sua própria conta';
    END IF;
    
    -- Buscar código ativo
    SELECT * INTO v_record
    FROM public.verification_codes
    WHERE user_id = p_user_id
    AND verified_at IS NULL
    ORDER BY created_at DESC
    LIMIT 1;
    
    -- Se não encontrou código
    IF v_record IS NULL THEN
        RAISE EXCEPTION 'Código não encontrado';
    END IF;
    
    -- Verificar se expirou
    IF v_record.expires_at < NOW() THEN
        RAISE EXCEPTION 'Código expirado';
    END IF;
    
    -- Verificar tentativas
    IF v_record.attempts >= v_record.max_attempts THEN
        RAISE EXCEPTION 'Número máximo de tentativas excedido';
    END IF;
    
    -- Incrementar tentativas
    UPDATE public.verification_codes
    SET attempts = attempts + 1
    WHERE id = v_record.id;
    
    -- Verificar código
    IF v_record.code = p_code THEN
        -- Marcar como verificado
        UPDATE public.verification_codes
        SET verified_at = NOW()
        WHERE id = v_record.id;
        
        -- Atualizar user_approvals
        UPDATE public.user_approvals
        SET 
            phone_verified = TRUE,
            status = 'approved',
            approved_at = NOW(),
            approved_by = p_user_id
        WHERE user_id = p_user_id;
        
        v_valid := TRUE;
    END IF;
    
    RETURN v_valid;
END;
$$;

COMMENT ON FUNCTION public.verify_whatsapp_code IS 'Verifica código e ativa conta automaticamente (chamável do frontend)';


-- 5. RLS POLICIES
-- ================================================

-- Habilitar RLS
ALTER TABLE public.verification_codes ENABLE ROW LEVEL SECURITY;

-- Policy: Usuário pode ver apenas seus próprios códigos
DROP POLICY IF EXISTS "Users can view own codes" ON public.verification_codes;
CREATE POLICY "Users can view own codes" ON public.verification_codes
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Usuário pode inserir seus próprios códigos
DROP POLICY IF EXISTS "Users can insert own codes" ON public.verification_codes;
CREATE POLICY "Users can insert own codes" ON public.verification_codes
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Usuário pode atualizar (incrementar tentativas) seus próprios códigos
DROP POLICY IF EXISTS "Users can update own codes" ON public.verification_codes;
CREATE POLICY "Users can update own codes" ON public.verification_codes
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Usuário pode deletar seus próprios códigos antigos
DROP POLICY IF EXISTS "Users can delete own codes" ON public.verification_codes;
CREATE POLICY "Users can delete own codes" ON public.verification_codes
    FOR DELETE
    USING (auth.uid() = user_id);


-- 6. FUNÇÃO PARA LIMPAR CÓDIGOS EXPIRADOS (MANUTENÇÃO)
-- ================================================
CREATE OR REPLACE FUNCTION public.cleanup_expired_verification_codes()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_deleted INT;
BEGIN
    -- Deletar códigos expirados há mais de 1 hora
    DELETE FROM public.verification_codes
    WHERE expires_at < NOW() - INTERVAL '1 hour';
    
    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    
    RETURN v_deleted;
END;
$$;

COMMENT ON FUNCTION public.cleanup_expired_verification_codes IS 'Remove códigos expirados (executar periodicamente)';


-- 7. VERIFICAÇÕES
-- ================================================
SELECT 
    '✅ Tabela verification_codes' as status,
    COUNT(*) as total
FROM public.verification_codes;

SELECT 
    '✅ Colunas adicionadas em user_approvals' as status,
    COUNT(*) as usuarios_com_whatsapp
FROM public.user_approvals
WHERE whatsapp IS NOT NULL;

SELECT 
    '✅ Funções criadas' as status,
    routine_name as funcao
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('generate_verification_code', 'verify_whatsapp_code', 'cleanup_expired_verification_codes');

-- ================================================
-- FIM DO SCRIPT
-- ================================================
