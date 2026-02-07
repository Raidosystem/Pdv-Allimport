-- ============================================================================
-- DIAGNÓSTICO E CORREÇÃO: FK categoria_id em produtos
-- ============================================================================
-- PROBLEMA: A categoria validada pelo frontend existe, mas FK constraint falha
--           Possível problema: categoria pertence a outro usuário ou RLS bloqueando
-- SOLUÇÃO: Verificar isolamento de categorias e ajustar se necessário
-- ============================================================================

-- PASSO 1: Verificar estrutura da tabela categorias
SELECT 'ESTRUTURA DA TABELA CATEGORIAS' as info;
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns
WHERE table_name = 'categorias'
ORDER BY ordinal_position;

-- PASSO 2: Verificar FK constraint produtos -> categorias
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
    AND tc.constraint_name LIKE '%categoria%';

-- PASSO 3: Verificar categorias do usuário atual
-- ID da categoria que está falhando: 1cc47ed2-af1c-4353-b179-d5bae34e07e3
SELECT 'CATEGORIA QUE ESTÁ FALHANDO' as info;
SELECT id, nome, user_id, created_at
FROM categorias
WHERE id = '1cc47ed2-af1c-4353-b179-d5bae34e07e3';

-- PASSO 4: Verificar TODAS as categorias (para comparar user_id)
SELECT 'TODAS AS CATEGORIAS (PRIMEIRAS 10)' as info;
SELECT id, nome, user_id, created_at
FROM categorias
ORDER BY created_at DESC
LIMIT 10;

-- PASSO 5: Verificar RLS policies em categorias
SELECT 'POLÍTICAS RLS EM CATEGORIAS' as info;
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'categorias'
ORDER BY policyname;

-- ============================================================================
-- DIAGNÓSTICO: Verificar se categoria pertence ao usuário
-- ============================================================================

-- Se a query abaixo retornar 0, significa que a categoria não pertence ao usuário atual
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Categoria pertence ao usuário atual'
        ELSE '❌ Categoria NÃO pertence ao usuário atual - PROBLEMA!'
    END as diagnostico,
    COUNT(*) as total
FROM categorias c
WHERE c.id = '1cc47ed2-af1c-4353-b179-d5bae34e07e3'
    AND c.user_id = (SELECT user_id FROM empresas WHERE user_id = auth.uid() LIMIT 1);

-- ============================================================================
-- SOLUÇÃO 1: Atualizar user_id das categorias existentes
-- ============================================================================

-- ⚠️ ATENÇÃO: Isso vai atualizar categorias órfãs ou com user_id incorreto

-- Verificar categorias que precisam de correção
SELECT 
    'CATEGORIAS QUE PRECISAM DE CORREÇÃO' as info,
    COUNT(*) as total
FROM categorias c
WHERE c.user_id IS NULL 
    OR c.user_id != (
        SELECT e.user_id 
        FROM empresas e 
        WHERE e.id = c.user_id 
        LIMIT 1
    );

-- Atualizar categorias órfãs para o primeiro usuário que tem empresa
-- (Ajuste o user_id conforme necessário)
UPDATE categorias
SET user_id = '922d4f20-6c99-4438-a922-e275eb527c0b'
WHERE id = '1cc47ed2-af1c-4353-b179-d5bae34e07e3'
    AND (user_id IS NULL OR user_id != '922d4f20-6c99-4438-a922-e275eb527c0b');

-- Verificar resultado
SELECT 'CATEGORIA ATUALIZADA' as info;
SELECT id, nome, user_id, created_at
FROM categorias
WHERE id = '1cc47ed2-af1c-4353-b179-d5bae34e07e3';

-- ============================================================================
-- SOLUÇÃO 2: Criar trigger para auto-preencher user_id em categorias
-- ============================================================================

-- Criar função para setar user_id automaticamente em categorias
CREATE OR REPLACE FUNCTION set_user_id_categoria()
RETURNS TRIGGER AS $$
BEGIN
    -- Se user_id não foi fornecido, pegar do auth
    IF NEW.user_id IS NULL THEN
        NEW.user_id := auth.uid();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Remover trigger antigo se existir
DROP TRIGGER IF EXISTS trg_set_user_id_categoria ON categorias;

-- Aplicar trigger ANTES de INSERT ou UPDATE
CREATE TRIGGER trg_set_user_id_categoria
    BEFORE INSERT OR UPDATE ON categorias
    FOR EACH ROW
    EXECUTE FUNCTION set_user_id_categoria();

-- ============================================================================
-- SOLUÇÃO 3: Verificar e ajustar RLS em categorias
-- ============================================================================

-- Se RLS estiver muito restritivo, pode estar bloqueando o acesso
-- Verificar se há política que permita acesso para produtos

-- Criar política para permitir SELECT de categorias do mesmo usuário
DROP POLICY IF EXISTS "users_own_categorias" ON categorias;

CREATE POLICY "users_own_categorias" 
ON categorias
FOR ALL
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

SELECT 'VERIFICAÇÃO: Triggers e políticas atualizadas' as info;

-- Verificar triggers
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing
FROM information_schema.triggers
WHERE event_object_table IN ('categorias', 'produtos')
ORDER BY event_object_table, trigger_name;

-- Verificar se categoria agora está acessível
SELECT 'TESTE FINAL: Categoria acessível?' as info;
SELECT 
    id, 
    nome, 
    user_id,
    user_id = auth.uid() as pertence_ao_usuario
FROM categorias
WHERE id = '1cc47ed2-af1c-4353-b179-d5bae34e07e3';

SELECT '✅ CORREÇÃO APLICADA COM SUCESSO!' as status;
