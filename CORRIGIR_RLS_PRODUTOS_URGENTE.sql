-- =====================================================
-- 🚨 CORREÇÃO URGENTE - ISOLAMENTO DE PRODUTOS
-- =====================================================
-- Produtos estão aparecendo para todos os usuários!
-- Este script corrige o RLS e garante isolamento total
-- =====================================================

-- 1️⃣ VERIFICAR STATUS ATUAL DO RLS
SELECT 
    tablename,
    rowsecurity AS rls_habilitado,
    CASE 
        WHEN rowsecurity THEN '✅ RLS ATIVO'
        ELSE '🚨 RLS DESABILITADO - VULNERÁVEL!'
    END AS status
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename = 'produtos';

-- 2️⃣ VERIFICAR POLÍTICAS EXISTENTES
SELECT 
    policyname,
    cmd,
    qual AS using_expression
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename = 'produtos'
ORDER BY policyname;

-- 3️⃣ HABILITAR RLS (se não estiver habilitado)
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

-- 4️⃣ REMOVER POLÍTICAS ANTIGAS (TODAS AS ENCONTRADAS)
-- ⚠️ Estas políticas conflitantes estão causando o vazamento de dados
DROP POLICY IF EXISTS "produtos_select_public" ON produtos;
DROP POLICY IF EXISTS "produtos_select" ON produtos;
DROP POLICY IF EXISTS "produtos_select_own" ON produtos;
DROP POLICY IF EXISTS "produtos_insert_own" ON produtos;
DROP POLICY IF EXISTS "produtos_update_own" ON produtos;
DROP POLICY IF EXISTS "produtos_delete_own" ON produtos;
DROP POLICY IF EXISTS "usuarios_podem_ver_seus_produtos" ON produtos;
DROP POLICY IF EXISTS "usuarios_podem_inserir_seus_produtos" ON produtos;
DROP POLICY IF EXISTS "usuarios_podem_atualizar_seus_produtos" ON produtos;
DROP POLICY IF EXISTS "usuarios_podem_deletar_seus_produtos" ON produtos;

-- Políticas conflitantes adicionais encontradas no sistema
DROP POLICY IF EXISTS "Acesso público a produtos de lojas ativas" ON produtos;
DROP POLICY IF EXISTS "Users can only see their own produtos" ON produtos;
DROP POLICY IF EXISTS "produtos_empresa_isolation" ON produtos;
DROP POLICY IF EXISTS "public_read_produtos_loja_online" ON produtos;

-- Remover qualquer outra política restante
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'produtos'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON produtos', pol.policyname);
        RAISE NOTICE 'Política removida: %', pol.policyname;
    END LOOP;
END $$;

-- 5️⃣ CRIAR POLÍTICAS RLS CORRETAS (VERSÃO LIMPA)
-- ✅ IMPORTANTE: Usando apenas user_id para isolamento

-- Política de SELECT - Usuário autenticado vê APENAS seus produtos
CREATE POLICY "produtos_select_own_only"
ON produtos FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Política de INSERT - Usuário pode criar produtos (com user_id = auth.uid())
CREATE POLICY "produtos_insert_own_only"
ON produtos FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Política de UPDATE - Usuário pode atualizar APENAS seus produtos
CREATE POLICY "produtos_update_own_only"
ON produtos FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Política de DELETE - Usuário pode deletar APENAS seus produtos
CREATE POLICY "produtos_delete_own_only"
ON produtos FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Política de SELECT para ANÔNIMOS - Ver produtos de lojas online ativas
-- Permite catálogo público funcionar
CREATE POLICY "produtos_public_catalog_read"
ON produtos FOR SELECT
TO anon
USING (
    ativo = true 
    AND EXISTS (
        SELECT 1 FROM lojas_online 
        WHERE lojas_online.empresa_id = produtos.user_id 
        AND lojas_online.ativa = true
    )
);

-- 6️⃣ VERIFICAR SE AS POLÍTICAS FORAM CRIADAS CORRETAMENTE
SELECT 
    '✅ PRODUTOS' AS tabela,
    policyname,
    cmd,
    qual AS using_expression,
    with_check
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename = 'produtos'
ORDER BY cmd, policyname;

-- Deve retornar EXATAMENTE 5 políticas:
-- 1. produtos_delete_own_only (DELETE)
-- 2. produtos_insert_own_only (INSERT)
-- 3. produtos_select_own_only (SELECT - authenticated)
-- 4. produtos_public_catalog_read (SELECT - anon)
-- 5. produtos_update_own_only (UPDATE)

-- 7️⃣ TESTAR ISOLAMENTO
-- Execute estas queries em contextos de usuários diferentes para testar
-- SELECT * FROM produtos; -- Deve retornar apenas produtos do usuário logado
-- SELECT COUNT(*) FROM produtos; -- Deve contar apenas produtos do usuário logado

-- =====================================================
-- 8️⃣ VERIFICAR TAMBÉM RLS DA TABELA lojas_online
-- =====================================================
-- Esta tabela também precisa de RLS para o catálogo online

-- Verificar status do RLS
SELECT 
    tablename,
    rowsecurity AS rls_habilitado
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename = 'lojas_online';

-- Habilitar RLS
ALTER TABLE lojas_online ENABLE ROW LEVEL SECURITY;

-- Remover TODAS as políticas antigas (encontradas 12 políticas duplicadas!)
DROP POLICY IF EXISTS "lojas_online_select" ON lojas_online;
DROP POLICY IF EXISTS "lojas_online_insert" ON lojas_online;
DROP POLICY IF EXISTS "lojas_online_update" ON lojas_online;
DROP POLICY IF EXISTS "lojas_online_delete" ON lojas_online;
DROP POLICY IF EXISTS "usuarios_podem_ver_sua_loja" ON lojas_online;
DROP POLICY IF EXISTS "usuarios_podem_criar_sua_loja" ON lojas_online;
DROP POLICY IF EXISTS "usuarios_podem_atualizar_sua_loja" ON lojas_online;
DROP POLICY IF EXISTS "usuarios_podem_deletar_sua_loja" ON lojas_online;
DROP POLICY IF EXISTS "lojas_publicas_podem_ser_vistas" ON lojas_online;

-- Políticas duplicadas adicionais encontradas
DROP POLICY IF EXISTS "Empresas podem deletar suas lojas" ON lojas_online;
DROP POLICY IF EXISTS "Empresas podem criar lojas" ON lojas_online;
DROP POLICY IF EXISTS "Acesso público a lojas ativas" ON lojas_online;
DROP POLICY IF EXISTS "Empresas podem ver suas lojas" ON lojas_online;
DROP POLICY IF EXISTS "Leitura pública de lojas ativas" ON lojas_online;
DROP POLICY IF EXISTS "public_read_lojas_ativas" ON lojas_online;
DROP POLICY IF EXISTS "Empresas podem atualizar suas lojas" ON lojas_online;

-- Remover qualquer outra política restante (loop de segurança)
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'lojas_online'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON lojas_online', pol.policyname);
        RAISE NOTICE 'Política removida de lojas_online: %', pol.policyname;
    END LOOP;
END $$;

-- Criar políticas para lojas_online (VERSÃO LIMPA)
-- SELECT - Usuário autenticado vê sua própria loja
CREATE POLICY "lojas_online_select_own"
ON lojas_online FOR SELECT
TO authenticated
USING (auth.uid() = empresa_id);

-- SELECT - Público vê lojas ativas (catálogo)
CREATE POLICY "lojas_online_public_read"
ON lojas_online FOR SELECT
TO anon
USING (ativa = true);

-- INSERT - Usuário pode criar sua loja
CREATE POLICY "lojas_online_insert_own"
ON lojas_online FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = empresa_id);

-- UPDATE - Usuário pode atualizar sua loja
CREATE POLICY "lojas_online_update_own"
ON lojas_online FOR UPDATE
TO authenticated
USING (auth.uid() = empresa_id)
WITH CHECK (auth.uid() = empresa_id);

-- DELETE - Usuário pode deletar sua loja
CREATE POLICY "lojas_online_delete_own"
ON lojas_online FOR DELETE
TO authenticated
USING (auth.uid() = empresa_id);

-- Verificar políticas criadas
SELECT 
    '✅ LOJAS_ONLINE' AS tabela,
    policyname,
    cmd,
    qual AS using_expression
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename = 'lojas_online'
ORDER BY cmd, policyname;

-- Deve retornar EXATAMENTE 5 políticas:
-- 1. lojas_online_delete_own (DELETE - authenticated)
-- 2. lojas_online_insert_own (INSERT - authenticated)
-- 3. lojas_online_public_read (SELECT - anon)
-- 4. lojas_online_select_own (SELECT - authenticated)
-- 5. lojas_online_update_own (UPDATE - authenticated)

-- =====================================================
-- ✅ APÓS EXECUTAR ESTE SCRIPT:
-- =====================================================
-- 1. Cada usuário verá APENAS seus próprios produtos
-- 2. O RLS estará ativo e funcionando em produtos e lojas_online
-- 3. Não será necessário filtrar por user_id no código
-- 4. O isolamento será garantido pelo banco de dados
-- 5. O botão "Catálogo Online" aparecerá corretamente
-- 6. Usuários anônimos poderão ver catálogos públicos
-- =====================================================
