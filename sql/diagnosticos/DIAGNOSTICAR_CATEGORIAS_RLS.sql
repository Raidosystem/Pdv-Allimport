-- ============================================================================
-- DIAGNÓSTICO COMPLETO: Políticas RLS em categorias
-- ============================================================================
-- Este script verifica todas as políticas RLS ativas em categorias
-- e identifica possíveis conflitos ou problemas
-- ============================================================================

-- PASSO 1: Ver status RLS da tabela categorias
SELECT 'STATUS RLS EM CATEGORIAS' as info;
SELECT 
    tablename,
    rowsecurity as rls_habilitado
FROM pg_tables
WHERE schemaname = 'public' 
    AND tablename = 'categorias';

-- PASSO 2: Listar TODAS as políticas RLS ativas em categorias
SELECT 'TODAS AS POLÍTICAS RLS EM CATEGORIAS' as info;
SELECT 
    policyname as nome_politica,
    cmd as comando,
    permissive as permissiva,
    roles as funcoes,
    qual as condicao_using,
    with_check as condicao_check
FROM pg_policies
WHERE schemaname = 'public' 
    AND tablename = 'categorias'
ORDER BY policyname;

-- PASSO 3: Verificar dados da categoria específica
SELECT 'DADOS DA CATEGORIA (1cc47ed2-af1c-4353-b179-d5bae34e07e3)' as info;
SELECT 
    id,
    nome,
    user_id,
    created_at,
    -- Verificar se user_id corresponde ao usuário atual
    user_id = '922d4f20-6c99-4438-a922-e275eb527c0b' as pertence_ao_usuario,
    -- Verificar se user_id está no auth.users
    EXISTS(SELECT 1 FROM auth.users WHERE id = categorias.user_id) as user_id_valido
FROM categorias
WHERE id = '1cc47ed2-af1c-4353-b179-d5bae34e07e3';

-- PASSO 4: Testar query de validação (simulando o que o frontend faz)
SELECT 'TESTE: Query de validação do frontend' as info;
SELECT 
    id,
    nome,
    user_id
FROM categorias
WHERE id = '1cc47ed2-af1c-4353-b179-d5bae34e07e3'
LIMIT 1;

-- PASSO 5: Contar total de categorias visíveis para o usuário atual
SELECT 'TOTAL DE CATEGORIAS VISÍVEIS' as info;
SELECT COUNT(*) as total_categorias_visiveis
FROM categorias;

-- ============================================================================
-- RESULTADO ESPERADO:
-- ============================================================================
-- Se a categoria existe mas não aparece:
-- - RLS está bloqueando o acesso
-- - user_id da categoria não corresponde ao auth.uid()
-- - Políticas RLS estão muito restritivas ou conflitantes
-- ============================================================================
