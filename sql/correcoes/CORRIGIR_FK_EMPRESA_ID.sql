-- ============================================================================
-- DIAGNÓSTICO E CORREÇÃO: FK empresa_id em produtos
-- ============================================================================
-- PROBLEMA: Trigger está setando empresa_id = user_id, mas user_id não existe
--           na tabela empresas como um registro válido
-- SOLUÇÃO: Verificar estrutura e corrigir trigger para buscar empresa_id correto
-- ============================================================================

-- PASSO 1: Verificar estrutura da tabela empresas
SELECT 'ESTRUTURA DA TABELA EMPRESAS' as info;
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns
WHERE table_name = 'empresas'
ORDER BY ordinal_position;

-- PASSO 2: Verificar FK constraint em produtos
SELECT 'FOREIGN KEY CONSTRAINT EM PRODUTOS' as info;
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name = 'produtos'
    AND tc.constraint_name LIKE '%empresa%';

-- PASSO 3: Verificar se usuário atual tem empresa
-- (Se auth.uid() retornar NULL, não haverá resultados)
SELECT 'EMPRESAS DO USUÁRIO ATUAL' as info;
SELECT 
    CASE 
        WHEN auth.uid() IS NULL THEN '⚠️ Sem contexto de autenticação'
        ELSE '✅ Usuário: ' || auth.uid()::text
    END as status;

SELECT id, nome, user_id, created_at
FROM empresas
WHERE user_id = auth.uid();

-- PASSO 4: Listar todas as empresas (para debug)
SELECT 'TODAS AS EMPRESAS (PRIMEIRAS 10)' as info;
SELECT id, nome, user_id, created_at
FROM empresas
ORDER BY created_at DESC
LIMIT 10;

-- ============================================================================
-- SOLUÇÃO 1: Se usuário NÃO tem empresa, criar uma automaticamente
-- ============================================================================

-- ⚠️ ATENÇÃO: Esta parte só funciona se executada em contexto autenticado
-- (por exemplo, via função RPC ou trigger, não no SQL Editor diretamente)

-- Verificar se há contexto de autenticação
DO $$
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE NOTICE '⚠️ AVISO: Não há usuário autenticado no contexto atual.';
        RAISE NOTICE '💡 Para criar empresa, execute este SQL via aplicação ou use o user_id específico.';
    ELSE
        RAISE NOTICE '✅ Usuário autenticado: %', auth.uid();
        
        -- Criar empresa para usuário se não existir
        INSERT INTO empresas (
            nome,
            user_id,
            created_at,
            updated_at
        )
        SELECT
            'Empresa de ' || COALESCE(auth.email(), 'Usuário'),
            auth.uid(),
            NOW(),
            NOW()
        WHERE NOT EXISTS (
            SELECT 1 FROM empresas WHERE user_id = auth.uid()
        );
        
        IF FOUND THEN
            RAISE NOTICE '✅ Empresa criada com sucesso!';
        ELSE
            RAISE NOTICE 'ℹ️ Empresa já existe para este usuário.';
        END IF;
    END IF;
END $$;

-- ============================================================================
-- SOLUÇÃO 2: Atualizar trigger para buscar empresa_id correto
-- ============================================================================

-- REMOVER triggers e função antigos (CASCADE remove dependências)
DROP TRIGGER IF EXISTS trg_set_user_and_empresa_id ON produtos;
DROP TRIGGER IF EXISTS trigger_set_ids_produtos ON produtos;
DROP FUNCTION IF EXISTS set_user_and_empresa_id() CASCADE;

-- CRIAR nova função que busca empresa_id corretamente
CREATE OR REPLACE FUNCTION set_user_and_empresa_id_correto()
RETURNS TRIGGER AS $$
DECLARE
    v_empresa_id UUID;
BEGIN
    -- Se user_id não foi fornecido, pegar do auth
    IF NEW.user_id IS NULL THEN
        NEW.user_id := auth.uid();
    END IF;
    
    -- Buscar empresa_id do usuário na tabela empresas
    SELECT id INTO v_empresa_id
    FROM empresas
    WHERE user_id = NEW.user_id
    LIMIT 1;
    
    -- Se encontrou empresa, setar empresa_id
    IF v_empresa_id IS NOT NULL THEN
        NEW.empresa_id := v_empresa_id;
    ELSE
        -- Se não encontrou empresa, CRIAR AUTOMATICAMENTE (sistema multi-tenant)
        INSERT INTO empresas (nome, user_id, created_at, updated_at)
        VALUES (
            'Empresa de ' || COALESCE((SELECT email FROM auth.users WHERE id = NEW.user_id), 'Usuário'),
            NEW.user_id,
            NOW(),
            NOW()
        )
        RETURNING id INTO v_empresa_id;
        
        NEW.empresa_id := v_empresa_id;
        
        RAISE NOTICE '✅ Empresa criada automaticamente: % (ID: %)', 
            'Empresa de ' || COALESCE((SELECT email FROM auth.users WHERE id = NEW.user_id), 'Usuário'),
            v_empresa_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger ANTES de INSERT ou UPDATE
CREATE TRIGGER trg_set_user_and_empresa_id_correto
    BEFORE INSERT OR UPDATE ON produtos
    FOR EACH ROW
    EXECUTE FUNCTION set_user_and_empresa_id_correto();

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

SELECT 'VERIFICAÇÃO: Trigger atualizado' as info;
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing
FROM information_schema.triggers
WHERE event_object_table = 'produtos'
    AND trigger_name LIKE '%user_and_empresa%'
ORDER BY trigger_name;

SELECT '✅ CORREÇÃO APLICADA COM SUCESSO!' as status;
