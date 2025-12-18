-- ============================================================================
-- CORREÇÃO DEFINITIVA: Políticas RLS para categorias
-- ============================================================================
-- Este script remove TODAS as políticas conflitantes e cria uma política
-- simples e funcional que permite acesso baseado em user_id
-- ============================================================================

-- PASSO 1: Remover TODAS as políticas RLS existentes em categorias
SELECT 'REMOVENDO TODAS AS POLÍTICAS RLS DE CATEGORIAS...' as info;

DROP POLICY IF EXISTS "users_own_categorias" ON categorias;
DROP POLICY IF EXISTS "categorias_authenticated_policy" ON categorias;
DROP POLICY IF EXISTS "Users can only see their own categorias" ON categorias;
DROP POLICY IF EXISTS "Users can only see own categorias" ON categorias;
DROP POLICY IF EXISTS "Users can only insert own categorias" ON categorias;
DROP POLICY IF EXISTS "Users can only update own categorias" ON categorias;
DROP POLICY IF EXISTS "Users can only delete own categorias" ON categorias;
DROP POLICY IF EXISTS "Acesso público a categorias" ON categorias;
DROP POLICY IF EXISTS "public_read_categorias" ON categorias;

SELECT '✅ Políticas antigas removidas' as status;

-- PASSO 2: Garantir que RLS está habilitado
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;

SELECT '✅ RLS habilitado em categorias' as status;

-- PASSO 3: Criar política SIMPLES e FUNCIONAL
-- Esta política permite que usuários acessem apenas categorias onde user_id = auth.uid()
CREATE POLICY "categorias_user_policy" 
ON categorias
FOR ALL
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

SELECT '✅ Nova política RLS criada: categorias_user_policy' as status;

-- PASSO 4: Verificar a política criada
SELECT 'POLÍTICA RLS ATIVA EM CATEGORIAS' as info;
SELECT 
    policyname as nome,
    cmd as comando,
    qual as condicao_using,
    with_check as condicao_check
FROM pg_policies
WHERE schemaname = 'public' 
    AND tablename = 'categorias';

-- PASSO 5: Verificar se a categoria específica do usuário está acessível
SELECT 'TESTE: Categoria 1cc47ed2-af1c-4353-b179-d5bae34e07e3' as info;
SELECT 
    id,
    nome,
    user_id,
    user_id = '922d4f20-6c99-4438-a922-e275eb527c0b' as pertence_ao_usuario
FROM categorias
WHERE id = '1cc47ed2-af1c-4353-b179-d5bae34e07e3';

-- PASSO 6: Contar categorias visíveis
SELECT 'TOTAL DE CATEGORIAS VISÍVEIS PARA O USUÁRIO' as info;
SELECT COUNT(*) as total
FROM categorias;

SELECT '✅ CORREÇÃO APLICADA COM SUCESSO!' as status;

-- ============================================================================
-- EXPLICAÇÃO:
-- ============================================================================
-- 1. Remove todas as políticas conflitantes
-- 2. Cria UMA política simples que funciona para SELECT, INSERT, UPDATE e DELETE
-- 3. A política usa auth.uid() que é gerenciado automaticamente pelo Supabase
-- 4. user_id na tabela categorias deve corresponder ao auth.uid() do usuário logado
-- 
-- IMPORTANTE: Depois de executar este SQL, o frontend deve conseguir:
-- - Ver categorias onde user_id = auth.uid()
-- - Inserir novas categorias com user_id = auth.uid()
-- - Atualizar suas próprias categorias
-- - Deletar suas próprias categorias
-- ============================================================================
