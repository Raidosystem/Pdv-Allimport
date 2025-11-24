-- ============================================
-- SISTEMA DE CÓDIGO INTERNO AUTOMÁTICO
-- ============================================
-- Funcionalidades:
-- 1. Gera código sequencial começando em 00001
-- 2. Preenche automaticamente se vazio
-- 3. Valida unicidade por usuário
-- 4. Atualiza produtos sem código
-- ============================================

-- 1. ADICIONAR coluna codigo_interno se não existir
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'produtos' AND column_name = 'codigo_interno'
    ) THEN
        ALTER TABLE produtos ADD COLUMN codigo_interno TEXT;
        RAISE NOTICE 'Coluna codigo_interno criada';
    ELSE
        RAISE NOTICE 'Coluna codigo_interno já existe';
    END IF;
END $$;

-- 2. CRIAR índice único por usuário (user_id + codigo_interno)
DROP INDEX IF EXISTS idx_produtos_codigo_interno_user;
CREATE UNIQUE INDEX idx_produtos_codigo_interno_user 
ON produtos(user_id, codigo_interno) 
WHERE codigo_interno IS NOT NULL;

-- 3. FUNÇÃO para gerar próximo código
CREATE OR REPLACE FUNCTION gerar_proximo_codigo_interno(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
    v_ultimo_numero INTEGER;
    v_novo_codigo TEXT;
BEGIN
    -- Buscar o maior número atual do usuário
    SELECT COALESCE(
        MAX(CAST(REGEXP_REPLACE(codigo_interno, '[^0-9]', '', 'g') AS INTEGER)),
        0
    )
    INTO v_ultimo_numero
    FROM produtos
    WHERE user_id = p_user_id
    AND codigo_interno IS NOT NULL
    AND codigo_interno ~ '^[0-9]+$'; -- Apenas códigos numéricos
    
    -- Incrementar e formatar com zeros à esquerda
    v_novo_codigo := LPAD((v_ultimo_numero + 1)::TEXT, 5, '0');
    
    RETURN v_novo_codigo;
END;
$$ LANGUAGE plpgsql;

-- 4. TRIGGER para auto-gerar código antes de INSERT
CREATE OR REPLACE FUNCTION trigger_gerar_codigo_interno()
RETURNS TRIGGER AS $$
BEGIN
    -- Se codigo_interno está vazio, gerar automaticamente
    IF NEW.codigo_interno IS NULL OR NEW.codigo_interno = '' THEN
        NEW.codigo_interno := gerar_proximo_codigo_interno(NEW.user_id);
        RAISE NOTICE 'Código interno gerado: %', NEW.codigo_interno;
    END IF;
    
    -- Validar que não é duplicado (segurança extra)
    IF EXISTS (
        SELECT 1 FROM produtos 
        WHERE user_id = NEW.user_id 
        AND codigo_interno = NEW.codigo_interno
        AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)
    ) THEN
        RAISE EXCEPTION 'Código interno % já está em uso', NEW.codigo_interno;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. APLICAR trigger em INSERT
DROP TRIGGER IF EXISTS trigger_produtos_codigo_interno_insert ON produtos;
CREATE TRIGGER trigger_produtos_codigo_interno_insert
BEFORE INSERT ON produtos
FOR EACH ROW
EXECUTE FUNCTION trigger_gerar_codigo_interno();

-- 6. TRIGGER para UPDATE (preencher vazios ao editar)
CREATE OR REPLACE FUNCTION trigger_atualizar_codigo_interno()
RETURNS TRIGGER AS $$
BEGIN
    -- Se estava vazio e continua vazio, gerar código
    IF (OLD.codigo_interno IS NULL OR OLD.codigo_interno = '') 
       AND (NEW.codigo_interno IS NULL OR NEW.codigo_interno = '') THEN
        NEW.codigo_interno := gerar_proximo_codigo_interno(NEW.user_id);
        RAISE NOTICE 'Código interno gerado no UPDATE: %', NEW.codigo_interno;
    END IF;
    
    -- Validar unicidade se mudou o código
    IF NEW.codigo_interno != OLD.codigo_interno OR OLD.codigo_interno IS NULL THEN
        IF EXISTS (
            SELECT 1 FROM produtos 
            WHERE user_id = NEW.user_id 
            AND codigo_interno = NEW.codigo_interno
            AND id != NEW.id
        ) THEN
            RAISE EXCEPTION 'Código interno % já está em uso', NEW.codigo_interno;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. APLICAR trigger em UPDATE
DROP TRIGGER IF EXISTS trigger_produtos_codigo_interno_update ON produtos;
CREATE TRIGGER trigger_produtos_codigo_interno_update
BEFORE UPDATE ON produtos
FOR EACH ROW
EXECUTE FUNCTION trigger_atualizar_codigo_interno();

-- 8. ATUALIZAR produtos existentes SEM código interno
DO $$
DECLARE
    v_user_id UUID;
    v_produto RECORD;
    v_novo_codigo TEXT;
BEGIN
    -- Para cada usuário com produtos
    FOR v_user_id IN (
        SELECT DISTINCT user_id 
        FROM produtos 
        WHERE codigo_interno IS NULL OR codigo_interno = ''
    ) LOOP
        -- Para cada produto sem código deste usuário
        FOR v_produto IN (
            SELECT id 
            FROM produtos 
            WHERE user_id = v_user_id 
            AND (codigo_interno IS NULL OR codigo_interno = '')
            ORDER BY updated_at, id
        ) LOOP
            -- Gerar e atribuir código
            v_novo_codigo := gerar_proximo_codigo_interno(v_user_id);
            
            UPDATE produtos 
            SET codigo_interno = v_novo_codigo
            WHERE id = v_produto.id;
            
            RAISE NOTICE 'Produto % recebeu código %', v_produto.id, v_novo_codigo;
        END LOOP;
    END LOOP;
    
    RAISE NOTICE 'Atualização de códigos internos concluída';
END $$;

-- 9. VERIFICAR resultados
SELECT 
    user_id,
    COUNT(*) as total_produtos,
    COUNT(codigo_interno) as com_codigo,
    COUNT(*) - COUNT(codigo_interno) as sem_codigo
FROM produtos
GROUP BY user_id;

-- 10. MOSTRAR alguns produtos com seus códigos
SELECT 
    id,
    nome,
    codigo_interno,
    updated_at
FROM produtos
WHERE user_id = auth.uid()
ORDER BY codigo_interno
LIMIT 10;
