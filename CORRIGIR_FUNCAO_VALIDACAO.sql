-- ============================================
-- CORRIGIR FUNÇÃO DE VALIDAÇÃO DE DOCUMENTOS
-- Script para resolver erro 404 ao criar conta
-- ============================================

-- 1️⃣ Criar função de validação de documentos
-- ============================================
CREATE OR REPLACE FUNCTION validate_document_uniqueness(
  p_document text,
  p_user_id uuid DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_clean_document text;
  v_document_type text;
  v_existing_user_id uuid;
  v_existing_email text;
BEGIN
  -- Limpar documento (remover pontos, traços, etc.)
  v_clean_document := REGEXP_REPLACE(p_document, '[^0-9]', '', 'g');
  
  -- Validar formato
  IF v_clean_document IS NULL OR v_clean_document = '' THEN
    RETURN json_build_object(
      'valid', false,
      'error', 'Documento não pode ser vazio'
    );
  END IF;
  
  -- Determinar tipo (CPF = 11 dígitos, CNPJ = 14 dígitos)
  IF LENGTH(v_clean_document) = 11 THEN
    v_document_type := 'CPF';
  ELSIF LENGTH(v_clean_document) = 14 THEN
    v_document_type := 'CNPJ';
  ELSE
    RETURN json_build_object(
      'valid', false,
      'error', 'Documento inválido. CPF deve ter 11 dígitos e CNPJ 14 dígitos'
    );
  END IF;
  
  -- Buscar se já existe (ignorando o próprio usuário se fornecido)
  SELECT e.user_id, u.email INTO v_existing_user_id, v_existing_email
  FROM empresas e
  JOIN auth.users u ON u.id = e.user_id
  WHERE REGEXP_REPLACE(e.cnpj, '[^0-9]', '', 'g') = v_clean_document
    AND (p_user_id IS NULL OR e.user_id != p_user_id)
  LIMIT 1;
  
  -- Se encontrou, retornar erro
  IF v_existing_user_id IS NOT NULL THEN
    RETURN json_build_object(
      'valid', false,
      'error', format('%s já cadastrado no sistema', v_document_type),
      'document_type', v_document_type,
      'existing_email', SUBSTRING(v_existing_email FROM 1 FOR 3) || '***@***'
    );
  END IF;
  
  -- Documento disponível
  RETURN json_build_object(
    'valid', true,
    'document_type', v_document_type,
    'message', format('%s disponível para cadastro', v_document_type)
  );
END;
$$;

-- 2️⃣ Conceder permissões de execução
-- ============================================
GRANT EXECUTE ON FUNCTION validate_document_uniqueness TO authenticated;
GRANT EXECUTE ON FUNCTION validate_document_uniqueness TO anon;

-- 3️⃣ Testar a função
-- ============================================
-- Teste com CPF fictício (deve retornar válido se não existir)
SELECT validate_document_uniqueness('123.456.789-00');

-- ============================================
-- ✅ SCRIPT CONCLUÍDO
-- ============================================
-- Agora a função está disponível e o cadastro deve funcionar!
