-- ================================================
-- SISTEMA DE VERIFICAÇÃO POR EMAIL
-- ================================================
-- Criado em: 10/10/2025
-- Função: Permitir verificação de contas via código por email
-- VERSÃO SIMPLIFICADA: Sem WhatsApp, apenas CPF/CNPJ

-- 1. CRIAR TABELA DE CÓDIGOS DE VERIFICAÇÃO
-- ================================================
-- Primeiro, deletar tabela antiga se existir (com estrutura diferente)
DROP TABLE IF EXISTS public.verification_codes CASCADE;

-- Criar tabela nova
CREATE TABLE public.verification_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    attempts INT DEFAULT 0,
    max_attempts INT DEFAULT 3,
    CONSTRAINT unique_active_code UNIQUE (user_id, email)
);

-- Índices para performance
CREATE INDEX idx_verification_codes_user ON public.verification_codes(user_id);
CREATE INDEX idx_verification_codes_email ON public.verification_codes(email);
CREATE INDEX idx_verification_codes_expires ON public.verification_codes(expires_at);

-- Comentários
COMMENT ON TABLE public.verification_codes IS 'Códigos de verificação enviados por email';
COMMENT ON COLUMN public.verification_codes.code IS 'Código de 6 dígitos';
COMMENT ON COLUMN public.verification_codes.expires_at IS 'Código expira em 10 minutos';
COMMENT ON COLUMN public.verification_codes.attempts IS 'Número de tentativas de validação';


-- 2. ATUALIZAR TABELA user_approvals (APENAS CPF/CNPJ)
-- ================================================
ALTER TABLE public.user_approvals 
ADD COLUMN IF NOT EXISTS cpf_cnpj VARCHAR(18),
ADD COLUMN IF NOT EXISTS document_type VARCHAR(10), -- 'CPF' ou 'CNPJ'
ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE;

-- Índices
CREATE INDEX IF NOT EXISTS idx_user_approvals_cpf_cnpj ON public.user_approvals(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_user_approvals_email_verified ON public.user_approvals(email_verified);

-- Comentários
COMMENT ON COLUMN public.user_approvals.cpf_cnpj IS 'CPF (11 dígitos) ou CNPJ (14 dígitos)';
COMMENT ON COLUMN public.user_approvals.document_type IS 'Tipo de documento: CPF ou CNPJ';
COMMENT ON COLUMN public.user_approvals.email_verified IS 'Email foi verificado com código';


-- 3. FUNÇÃO PARA GERAR CÓDIGO DE VERIFICAÇÃO
-- ================================================
CREATE OR REPLACE FUNCTION public.generate_email_verification_code(
    p_user_id UUID,
    p_email VARCHAR(255)
)
RETURNS TABLE(code VARCHAR(6), expires_at TIMESTAMPTZ) 
LANGUAGE plpgsql
SECURITY INVOKER
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
    
    -- Deletar códigos antigos deste usuário/email
    DELETE FROM public.verification_codes 
    WHERE user_id = p_user_id OR email = p_email;
    
    -- Inserir novo código
    INSERT INTO public.verification_codes (
        user_id,
        email,
        code,
        expires_at
    ) VALUES (
        p_user_id,
        p_email,
        v_code,
        v_expires_at
    );
    
    RETURN QUERY SELECT v_code, v_expires_at;
END;
$$;

COMMENT ON FUNCTION public.generate_email_verification_code IS 'Gera código de 6 dígitos válido por 10 minutos para email';


-- 4. FUNÇÃO PARA VERIFICAR CÓDIGO
-- ================================================
CREATE OR REPLACE FUNCTION public.verify_email_code(
    p_user_id UUID,
    p_code VARCHAR(6)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY INVOKER
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
            email_verified = TRUE,
            status = 'approved',
            approved_at = NOW(),
            approved_by = p_user_id
        WHERE user_id = p_user_id;
        
        v_valid := TRUE;
    END IF;
    
    RETURN v_valid;
END;
$$;

COMMENT ON FUNCTION public.verify_email_code IS 'Verifica código de email e ativa conta automaticamente';


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

-- Policy: Usuário pode atualizar seus próprios códigos
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


-- 6. FUNÇÃO PARA LIMPAR CÓDIGOS EXPIRADOS
-- ================================================
CREATE OR REPLACE FUNCTION public.cleanup_expired_verification_codes()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_deleted INT;
BEGIN
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
    '✅ Tabela verification_codes criada' as status,
    COUNT(*) as total
FROM public.verification_codes;

SELECT 
    '✅ Colunas adicionadas em user_approvals' as status,
    COUNT(*) as usuarios_com_cpf_cnpj
FROM public.user_approvals
WHERE cpf_cnpj IS NOT NULL;

SELECT 
    '✅ Funções criadas' as status,
    routine_name as funcao
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('generate_email_verification_code', 'verify_email_code', 'cleanup_expired_verification_codes');

-- ================================================
-- FIM DO SCRIPT
-- ================================================
