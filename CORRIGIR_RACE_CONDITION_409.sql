-- =====================================================
-- 🚨 CORREÇÃO DEFINITIVA: ERRO 409 - RACE CONDITION
-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- O trigger de codigo_interno pode gerar códigos duplicados
-- quando múltiplos INSERTs acontecem simultaneamente
-- =====================================================

-- 1️⃣ VERIFICAR ESTADO ATUAL
SELECT 
    '📊 ESTADO ATUAL' AS info,
    (SELECT COUNT(*) FROM pg_trigger WHERE tgrelid = 'produtos'::regclass AND tgisinternal = false) AS total_triggers,
    (SELECT COUNT(*) FROM produtos WHERE codigo_interno IS NULL) AS produtos_sem_codigo,
    (SELECT MAX(codigo_interno) FROM produtos WHERE user_id = auth.uid() AND codigo_interno ~ '^[0-9]+$') AS ultimo_codigo;

-- 2️⃣ CORRIGIR FUNÇÃO gerar_proximo_codigo_interno
-- Adicionar SELECT FOR UPDATE para evitar race condition
CREATE OR REPLACE FUNCTION gerar_proximo_codigo_interno(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
    v_ultimo_numero INTEGER;
    v_novo_codigo TEXT;
    v_tentativas INTEGER := 0;
BEGIN
    -- Buscar o maior número atual do usuário COM LOCK
    SELECT COALESCE(
        MAX(CAST(REGEXP_REPLACE(codigo_interno, '[^0-9]', '', 'g') AS INTEGER)),
        0
    )
    INTO v_ultimo_numero
    FROM produtos
    WHERE user_id = p_user_id
    AND codigo_interno IS NOT NULL
    AND codigo_interno ~ '^[0-9]+$'
    FOR UPDATE; -- LOCK para evitar race condition
    
    -- Loop para tentar gerar código único (máximo 10 tentativas)
    LOOP
        v_tentativas := v_tentativas + 1;
        
        -- Incrementar e formatar com zeros à esquerda
        v_novo_codigo := LPAD((v_ultimo_numero + v_tentativas)::TEXT, 5, '0');
        
        -- Verificar se já existe
        IF NOT EXISTS (
            SELECT 1 FROM produtos 
            WHERE user_id = p_user_id 
            AND codigo_interno = v_novo_codigo
        ) THEN
            RETURN v_novo_codigo;
        END IF;
        
        -- Se chegou em 10 tentativas, abortar
        IF v_tentativas >= 10 THEN
            RAISE EXCEPTION 'Não foi possível gerar código único após 10 tentativas';
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 3️⃣ SIMPLIFICAR TRIGGER - REMOVER VALIDAÇÃO DUPLICADA
-- O índice UNIQUE já faz essa validação
CREATE OR REPLACE FUNCTION trigger_gerar_codigo_interno()
RETURNS TRIGGER AS $$
BEGIN
    -- Se codigo_interno está vazio, gerar automaticamente
    IF NEW.codigo_interno IS NULL OR NEW.codigo_interno = '' THEN
        NEW.codigo_interno := gerar_proximo_codigo_interno(NEW.user_id);
    END IF;
    
    -- Não precisa validar duplicata - o UNIQUE INDEX faz isso
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4️⃣ RECRIAR TRIGGER DE INSERT (garantir ordem correta)
DROP TRIGGER IF EXISTS trigger_produtos_codigo_interno_insert ON produtos;
CREATE TRIGGER trigger_produtos_codigo_interno_insert
BEFORE INSERT ON produtos
FOR EACH ROW
EXECUTE FUNCTION trigger_gerar_codigo_interno();

-- 5️⃣ SIMPLIFICAR TRIGGER DE UPDATE
CREATE OR REPLACE FUNCTION trigger_atualizar_codigo_interno()
RETURNS TRIGGER AS $$
BEGIN
    -- Se estava vazio e continua vazio, gerar código
    IF (OLD.codigo_interno IS NULL OR OLD.codigo_interno = '') 
       AND (NEW.codigo_interno IS NULL OR NEW.codigo_interno = '') THEN
        NEW.codigo_interno := gerar_proximo_codigo_interno(NEW.user_id);
    END IF;
    
    -- Não precisa validar duplicata - o UNIQUE INDEX faz isso
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6️⃣ RECRIAR TRIGGER DE UPDATE
DROP TRIGGER IF EXISTS trigger_produtos_codigo_interno_update ON produtos;
CREATE TRIGGER trigger_produtos_codigo_interno_update
BEFORE UPDATE ON produtos
FOR EACH ROW
EXECUTE FUNCTION trigger_atualizar_codigo_interno();

-- 7️⃣ GARANTIR QUE O ÍNDICE UNIQUE EXISTE
DROP INDEX IF EXISTS idx_produtos_codigo_interno_user;
CREATE UNIQUE INDEX idx_produtos_codigo_interno_user 
ON produtos(user_id, codigo_interno) 
WHERE codigo_interno IS NOT NULL;

-- 8️⃣ PREENCHER PRODUTOS SEM codigo_interno
DO $$
DECLARE
    v_produto RECORD;
    v_novo_codigo TEXT;
BEGIN
    FOR v_produto IN 
        SELECT id, user_id 
        FROM produtos 
        WHERE codigo_interno IS NULL 
        ORDER BY id
    LOOP
        v_novo_codigo := gerar_proximo_codigo_interno(v_produto.user_id);
        
        UPDATE produtos 
        SET codigo_interno = v_novo_codigo
        WHERE id = v_produto.id;
        
        RAISE NOTICE 'Produto % recebeu código %', v_produto.id, v_novo_codigo;
    END LOOP;
END $$;

-- 9️⃣ VERIFICAR TRIGGERS FINAIS
SELECT 
    '✅ TRIGGERS ATIVOS' AS info,
    tgname AS trigger_name,
    CASE tgtype
        WHEN 7 THEN 'BEFORE INSERT'
        WHEN 19 THEN 'BEFORE UPDATE'
        WHEN 27 THEN 'BEFORE INSERT OR UPDATE'
        ELSE tgtype::text
    END AS tipo
FROM pg_trigger
WHERE tgrelid = 'produtos'::regclass
    AND tgisinternal = false
ORDER BY tgtype, tgname;

-- 🔟 TESTE FINAL - Tentar inserir produto
/*
INSERT INTO produtos (
    nome,
    preco,
    estoque,
    ativo
    -- user_id e codigo_interno serão preenchidos automaticamente
) VALUES (
    'Teste após correção race condition',
    15.50,
    10,
    true
) RETURNING id, nome, codigo_interno, user_id;
*/

-- =====================================================
-- ✅ RESUMO DAS CORREÇÕES:
-- =====================================================
-- 1. ✅ Adicionado SELECT FOR UPDATE na geração de código
-- 2. ✅ Loop de 10 tentativas para código único
-- 3. ✅ Removida validação duplicada do trigger (índice faz isso)
-- 4. ✅ Índice UNIQUE recriado e garantido
-- 5. ✅ Produtos sem código preenchidos sequencialmente
-- =====================================================

-- 📊 VERIFICAÇÃO FINAL
SELECT 
    '📊 STATUS FINAL' AS info,
    (SELECT COUNT(*) FROM produtos WHERE codigo_interno IS NULL) AS sem_codigo,
    (SELECT COUNT(DISTINCT codigo_interno) FROM produtos WHERE codigo_interno IS NOT NULL) AS codigos_unicos,
    (SELECT COUNT(*) FROM produtos) AS total_produtos;

-- =====================================================
-- 🎯 PRÓXIMOS PASSOS:
-- =====================================================
-- 1. Execute TODO este script no Supabase SQL Editor
-- 2. Aguarde a mensagem de sucesso
-- 3. Tente criar um novo produto no sistema
-- 4. Se ainda der erro 409, execute:
--    DIAGNOSTICO_ERRO_409_DETALHADO.sql
--    e compartilhe os resultados
-- =====================================================
