-- =====================================================
-- 🚨 CORREÇÃO: TRIGGERS CONFLITANTES EM PRODUTOS
-- =====================================================
-- PROBLEMA: 7 triggers tentando preencher user_id/empresa_id
-- SOLUÇÃO: Remover duplicados e manter apenas os essenciais
-- =====================================================

-- 1️⃣ VERIFICAR ESTRUTURA ATUAL
SELECT 
    '🔍 CAMPOS OBRIGATÓRIOS' AS info,
    column_name,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'produtos'
    AND column_name IN ('user_id', 'empresa_id', 'id', 'nome', 'preco')
ORDER BY column_name;

-- 2️⃣ DESABILITAR TRIGGERS CONFLITANTES
-- Manter apenas os essenciais: auditoria, código interno e updated_at

-- ❌ REMOVER trigger set_empresa_id_produtos (duplicado)
DROP TRIGGER IF EXISTS set_empresa_id_produtos ON produtos;

-- ❌ REMOVER trigger set_user_id_produtos (duplicado)
DROP TRIGGER IF EXISTS set_user_id_produtos ON produtos;

-- ❌ REMOVER trigger_auto_fill_produtos (duplicado)
DROP TRIGGER IF EXISTS trigger_auto_fill_produtos ON produtos;

-- 3️⃣ CRIAR UM ÚNICO TRIGGER PARA PREENCHER user_id E empresa_id
-- Apenas se os campos estiverem vazios

CREATE OR REPLACE FUNCTION set_user_and_empresa_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Se user_id não foi fornecido, pegar do auth
    IF NEW.user_id IS NULL THEN
        NEW.user_id := auth.uid();
    END IF;
    
    -- Se empresa_id não foi fornecido, usar o mesmo valor de user_id
    IF NEW.empresa_id IS NULL THEN
        NEW.empresa_id := NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger usando a nova função
DROP TRIGGER IF EXISTS trigger_set_ids_produtos ON produtos;
CREATE TRIGGER trigger_set_ids_produtos
    BEFORE INSERT ON produtos
    FOR EACH ROW
    EXECUTE FUNCTION set_user_and_empresa_id();

-- 4️⃣ GARANTIR QUE empresa_id SEJA NULLABLE (para não quebrar inserts)
ALTER TABLE produtos 
ALTER COLUMN empresa_id DROP NOT NULL;

-- 5️⃣ ATUALIZAR PRODUTOS EXISTENTES SEM empresa_id
UPDATE produtos
SET empresa_id = user_id
WHERE empresa_id IS NULL AND user_id IS NOT NULL;

-- 6️⃣ VERIFICAR TRIGGERS ATIVOS AGORA
SELECT 
    '✅ TRIGGERS ATIVOS' AS info,
    tgname AS trigger_name,
    tgenabled AS habilitado,
    CASE tgtype
        WHEN 7 THEN 'BEFORE INSERT'
        WHEN 19 THEN 'BEFORE UPDATE'
        WHEN 29 THEN 'AFTER INSERT/UPDATE/DELETE'
        ELSE tgtype::text
    END AS tipo
FROM pg_trigger
WHERE tgrelid = 'produtos'::regclass
    AND tgisinternal = false
ORDER BY tgtype, tgname;

-- 7️⃣ VERIFICAR POLÍTICA RLS DE INSERT
SELECT 
    '✅ POLÍTICA INSERT' AS info,
    policyname,
    with_check AS expressao_validacao
FROM pg_policies
WHERE tablename = 'produtos' 
    AND cmd = 'INSERT';

-- 8️⃣ TESTAR INSERT MANUAL
-- IMPORTANTE: Execute este teste para confirmar que funciona

/*
INSERT INTO produtos (
    nome,
    preco,
    estoque,
    ativo
    -- user_id e empresa_id serão preenchidos automaticamente pelo trigger
) VALUES (
    'Teste Trigger Corrigido',
    25.00,
    5,
    true
) RETURNING id, nome, user_id, empresa_id;
*/

-- =====================================================
-- ✅ RESUMO DAS CORREÇÕES:
-- =====================================================
-- 1. ❌ Removidos 3 triggers duplicados:
--    - set_empresa_id_produtos
--    - set_user_id_produtos  
--    - trigger_auto_fill_produtos
--
-- 2. ✅ Criado 1 trigger único:
--    - trigger_set_ids_produtos (preenche user_id E empresa_id)
--
-- 3. ✅ empresa_id tornado NULLABLE
--
-- 4. ✅ Produtos existentes atualizados
--
-- 5. ✅ Mantidos triggers essenciais:
--    - audit_produtos (auditoria)
--    - set_updated_at_produtos (timestamp)
--    - trigger_produtos_codigo_interno_* (códigos)
-- =====================================================

-- 9️⃣ VERIFICAÇÃO FINAL
SELECT 
    '📊 STATUS FINAL' AS info,
    (SELECT COUNT(*) FROM pg_trigger WHERE tgrelid = 'produtos'::regclass AND tgisinternal = false) AS total_triggers,
    (SELECT is_nullable FROM information_schema.columns WHERE table_name = 'produtos' AND column_name = 'empresa_id') AS empresa_id_nullable,
    (SELECT COUNT(*) FROM produtos WHERE empresa_id IS NULL) AS produtos_sem_empresa_id;

-- =====================================================
-- 🎯 PRÓXIMO PASSO:
-- =====================================================
-- 1. Execute TODO este script no Supabase SQL Editor
-- 2. Tente criar um novo produto no sistema
-- 3. Verifique se o erro 409 sumiu
-- 4. Confirme que user_id e empresa_id foram preenchidos:
--    SELECT id, nome, user_id, empresa_id FROM produtos ORDER BY created_at DESC LIMIT 5;
-- =====================================================
