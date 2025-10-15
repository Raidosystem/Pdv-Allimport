-- ============================================
-- PREVENIR CADASTROS DUPLICADOS
-- CPF, CNPJ e Email devem ser únicos no sistema
-- ============================================

-- 1️⃣ ADICIONAR ÍNDICES ÚNICOS NA TABELA EMPRESAS
-- ============================================

-- CPF único (ignorar nulos e vazios)
CREATE UNIQUE INDEX IF NOT EXISTS idx_empresas_cpf_unique 
ON empresas (cnpj) 
WHERE cnpj IS NOT NULL 
  AND cnpj != '' 
  AND LENGTH(REGEXP_REPLACE(cnpj, '[^0-9]', '', 'g')) = 11;  -- CPF tem 11 dígitos

-- CNPJ único (ignorar nulos e vazios)
CREATE UNIQUE INDEX IF NOT EXISTS idx_empresas_cnpj_unique 
ON empresas (cnpj) 
WHERE cnpj IS NOT NULL 
  AND cnpj != '' 
  AND LENGTH(REGEXP_REPLACE(cnpj, '[^0-9]', '', 'g')) = 14;  -- CNPJ tem 14 dígitos

-- Email único na tabela empresas (complementar ao do auth.users)
CREATE UNIQUE INDEX IF NOT EXISTS idx_empresas_email_unique 
ON empresas (LOWER(TRIM(email))) 
WHERE email IS NOT NULL 
  AND email != '';

-- 2️⃣ FUNÇÃO: Validar se CPF/CNPJ já existe antes de cadastrar
-- ============================================
CREATE OR REPLACE FUNCTION validate_document_uniqueness(
  p_document text,
  p_user_id uuid DEFAULT NULL  -- Para permitir atualização do próprio registro
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
      'existing_email', SUBSTRING(v_existing_email FROM 1 FOR 3) || '***@***'  -- Email parcialmente oculto
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

-- 3️⃣ TRIGGER: Validar automaticamente antes de INSERT/UPDATE
-- ============================================
CREATE OR REPLACE FUNCTION trigger_validate_document_before_save()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_validation json;
BEGIN
  -- Validar apenas se CNPJ/CPF foi fornecido
  IF NEW.cnpj IS NOT NULL AND NEW.cnpj != '' THEN
    -- Validar unicidade
    v_validation := validate_document_uniqueness(NEW.cnpj, NEW.user_id);
    
    -- Se inválido, impedir inserção
    IF (v_validation->>'valid')::boolean = false THEN
      RAISE EXCEPTION '%', v_validation->>'error';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;

-- Dropar trigger se já existir
DROP TRIGGER IF EXISTS trigger_validate_document ON empresas;

-- Criar trigger para validar antes de inserir/atualizar
CREATE TRIGGER trigger_validate_document
  BEFORE INSERT OR UPDATE ON empresas
  FOR EACH ROW
  EXECUTE FUNCTION trigger_validate_document_before_save();

-- 4️⃣ LIMPAR DUPLICATAS EXISTENTES (SE HOUVER)
-- ============================================

-- Ver se há duplicatas de CPF/CNPJ
WITH duplicates AS (
  SELECT 
    REGEXP_REPLACE(e.cnpj, '[^0-9]', '', 'g') as documento_limpo,
    COUNT(*) as quantidade,
    ARRAY_AGG(e.user_id ORDER BY e.created_at) as user_ids,
    ARRAY_AGG(u.email ORDER BY e.created_at) as emails
  FROM empresas e
  JOIN auth.users u ON u.id = e.user_id
  WHERE e.cnpj IS NOT NULL AND e.cnpj != ''
  GROUP BY documento_limpo
  HAVING COUNT(*) > 1
)
SELECT 
  CASE 
    WHEN LENGTH(documento_limpo) = 11 THEN 'CPF'
    WHEN LENGTH(documento_limpo) = 14 THEN 'CNPJ'
    ELSE 'Desconhecido'
  END as tipo,
  documento_limpo,
  quantidade,
  emails
FROM duplicates;

-- Se encontrar duplicatas, você pode deletar os mais recentes manualmente:
-- DELETE FROM empresas WHERE user_id = 'UUID_DO_MAIS_RECENTE';

-- 5️⃣ FUNÇÃO AUXILIAR: Buscar usuário por CPF/CNPJ
-- ============================================
CREATE OR REPLACE FUNCTION find_user_by_document(p_document text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_clean_document text;
  v_result record;
BEGIN
  v_clean_document := REGEXP_REPLACE(p_document, '[^0-9]', '', 'g');
  
  SELECT 
    u.id,
    u.email,
    e.nome,
    e.razao_social,
    e.cnpj,
    e.created_at
  INTO v_result
  FROM empresas e
  JOIN auth.users u ON u.id = e.user_id
  WHERE REGEXP_REPLACE(e.cnpj, '[^0-9]', '', 'g') = v_clean_document
  LIMIT 1;
  
  IF NOT FOUND THEN
    RETURN json_build_object(
      'found', false,
      'message', 'Documento não encontrado'
    );
  END IF;
  
  RETURN json_build_object(
    'found', true,
    'email', SUBSTRING(v_result.email FROM 1 FOR 3) || '***@' || SPLIT_PART(v_result.email, '@', 2),
    'nome', v_result.nome,
    'cadastrado_em', v_result.created_at
  );
END;
$$;

-- ============================================
-- TESTES
-- ============================================

-- Teste 1: Validar documento disponível
SELECT validate_document_uniqueness('123.456.789-00');

-- Teste 2: Validar documento que já existe (use um CPF/CNPJ real do seu banco)
SELECT validate_document_uniqueness('SEU_CPF_EXISTENTE_AQUI');

-- Teste 3: Buscar usuário por documento
SELECT find_user_by_document('SEU_CPF_EXISTENTE_AQUI');

-- Teste 4: Ver todos os documentos cadastrados
SELECT 
  u.email,
  e.nome,
  e.cnpj,
  CASE 
    WHEN LENGTH(REGEXP_REPLACE(e.cnpj, '[^0-9]', '', 'g')) = 11 THEN 'CPF'
    WHEN LENGTH(REGEXP_REPLACE(e.cnpj, '[^0-9]', '', 'g')) = 14 THEN 'CNPJ'
    ELSE 'Inválido'
  END as tipo_documento
FROM empresas e
JOIN auth.users u ON u.id = e.user_id
WHERE e.cnpj IS NOT NULL AND e.cnpj != ''
ORDER BY e.created_at DESC;

-- ============================================
-- RESUMO DO QUE FOI IMPLEMENTADO
-- ============================================
-- ✅ Índices únicos para CPF e CNPJ (não permite duplicatas)
-- ✅ Índice único para Email na tabela empresas
-- ✅ Função de validação antes de cadastrar
-- ✅ Trigger automático que impede INSERT/UPDATE com documento duplicado
-- ✅ Função auxiliar para buscar usuário por documento
-- ✅ Proteção em nível de banco de dados (não depende do frontend)
