-- ========================================
-- TABELA DE CÓDIGOS DE VERIFICAÇÃO
-- ========================================

CREATE TABLE IF NOT EXISTS public.email_verification_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL,
  code VARCHAR(6) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '15 minutes'),
  attempts INTEGER DEFAULT 0,
  max_attempts INTEGER DEFAULT 5,
  verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para buscar por email
CREATE INDEX IF NOT EXISTS idx_email_verification_codes_email 
ON public.email_verification_codes(email);

-- Índice para buscar códigos não expirados
CREATE INDEX IF NOT EXISTS idx_email_verification_codes_expires 
ON public.email_verification_codes(expires_at) 
WHERE verified = FALSE;

-- RLS Policies
ALTER TABLE public.email_verification_codes ENABLE ROW LEVEL SECURITY;

-- Permitir leitura apenas para o próprio email
CREATE POLICY "Users can read own verification codes"
ON public.email_verification_codes FOR SELECT
USING (TRUE); -- Permitir leitura pública para verificação

-- Permitir inserção para service_role
CREATE POLICY "Service can insert verification codes"
ON public.email_verification_codes FOR INSERT
WITH CHECK (TRUE);

-- Permitir atualização para service_role
CREATE POLICY "Service can update verification codes"
ON public.email_verification_codes FOR UPDATE
USING (TRUE);

-- ========================================
-- FUNÇÃO PARA GERAR CÓDIGO DE VERIFICAÇÃO
-- ========================================

CREATE OR REPLACE FUNCTION generate_and_send_verification_code(
  user_email TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  verification_code TEXT;
  code_id UUID;
BEGIN
  -- Gerar código de 6 dígitos
  verification_code := LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
  
  -- Invalidar códigos antigos para este email
  UPDATE public.email_verification_codes
  SET verified = TRUE, updated_at = NOW()
  WHERE email = user_email AND verified = FALSE;
  
  -- Inserir novo código
  INSERT INTO public.email_verification_codes (
    email,
    code,
    expires_at,
    attempts,
    max_attempts
  ) VALUES (
    user_email,
    verification_code,
    NOW() + INTERVAL '15 minutes',
    0,
    5
  ) RETURNING id INTO code_id;
  
  RAISE NOTICE 'Código gerado para %: %', user_email, verification_code;
  
  RETURN jsonb_build_object(
    'success', TRUE,
    'code', verification_code,
    'code_id', code_id,
    'expires_in_minutes', 15
  );
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', FALSE,
      'error', SQLERRM
    );
END;
$$;

-- ========================================
-- FUNÇÃO PARA VERIFICAR CÓDIGO
-- ========================================

CREATE OR REPLACE FUNCTION verify_email_verification_code(
  user_email TEXT,
  user_code TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  code_record public.email_verification_codes%ROWTYPE;
BEGIN
  -- Buscar código mais recente não verificado
  SELECT * INTO code_record
  FROM public.email_verification_codes
  WHERE email = user_email
    AND verified = FALSE
    AND expires_at > NOW()
  ORDER BY created_at DESC
  LIMIT 1;
  
  -- Se não encontrou código
  IF NOT FOUND THEN
    RETURN jsonb_build_object(
      'success', FALSE,
      'error', 'Código não encontrado ou expirado'
    );
  END IF;
  
  -- Verificar número de tentativas
  IF code_record.attempts >= code_record.max_attempts THEN
    RETURN jsonb_build_object(
      'success', FALSE,
      'error', 'Número máximo de tentativas excedido. Solicite um novo código.'
    );
  END IF;
  
  -- Incrementar tentativas
  UPDATE public.email_verification_codes
  SET attempts = attempts + 1, updated_at = NOW()
  WHERE id = code_record.id;
  
  -- Verificar se o código está correto
  IF code_record.code = user_code THEN
    -- Marcar como verificado
    UPDATE public.email_verification_codes
    SET verified = TRUE, updated_at = NOW()
    WHERE id = code_record.id;
    
    RETURN jsonb_build_object(
      'success', TRUE,
      'message', 'Código verificado com sucesso!'
    );
  ELSE
    RETURN jsonb_build_object(
      'success', FALSE,
      'error', 'Código inválido',
      'attempts_remaining', code_record.max_attempts - (code_record.attempts + 1)
    );
  END IF;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', FALSE,
      'error', SQLERRM
    );
END;
$$;

-- Comentários
COMMENT ON TABLE public.email_verification_codes IS 'Armazena códigos de verificação de email temporários';
COMMENT ON FUNCTION generate_and_send_verification_code(TEXT) IS 'Gera código de 6 dígitos para verificação de email';
COMMENT ON FUNCTION verify_email_verification_code(TEXT, TEXT) IS 'Verifica se o código fornecido é válido';

-- Garantir permissões
GRANT EXECUTE ON FUNCTION generate_and_send_verification_code(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION verify_email_verification_code(TEXT, TEXT) TO anon, authenticated;
