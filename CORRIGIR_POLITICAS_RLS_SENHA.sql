-- ============================================
-- CORRIGIR POLÍTICAS RLS APÓS ADICIONAR SENHA_APARELHO
-- ============================================
-- Este script corrige as políticas RLS para permitir
-- operações com o novo campo senha_aparelho
-- ============================================

-- 1. REMOVER POLÍTICAS ANTIGAS (se existirem)
DROP POLICY IF EXISTS "Usuários podem visualizar suas ordens" ON ordens_servico;
DROP POLICY IF EXISTS "Usuários podem criar suas ordens" ON ordens_servico;
DROP POLICY IF EXISTS "Usuários podem atualizar suas ordens" ON ordens_servico;
DROP POLICY IF EXISTS "Usuários podem deletar suas ordens" ON ordens_servico;

-- 2. RECRIAR POLÍTICAS SIMPLIFICADAS

-- Política de SELECT (visualizar)
CREATE POLICY "Usuários podem visualizar suas ordens"
ON ordens_servico
FOR SELECT
TO authenticated
USING (usuario_id = auth.uid());

-- Política de INSERT (criar)
CREATE POLICY "Usuários podem criar suas ordens"
ON ordens_servico
FOR INSERT
TO authenticated
WITH CHECK (usuario_id = auth.uid());

-- Política de UPDATE (atualizar)
CREATE POLICY "Usuários podem atualizar suas ordens"
ON ordens_servico
FOR UPDATE
TO authenticated
USING (usuario_id = auth.uid())
WITH CHECK (usuario_id = auth.uid());

-- Política de DELETE (deletar)
CREATE POLICY "Usuários podem deletar suas ordens"
ON ordens_servico
FOR DELETE
TO authenticated
USING (usuario_id = auth.uid());

-- 3. VERIFICAR SE RLS ESTÁ ATIVADO
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- 4. VERIFICAR POLÍTICAS CRIADAS
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
WHERE tablename = 'ordens_servico'
ORDER BY policyname;

-- 5. TESTE: Verificar se consegue acessar os dados
SELECT 
    id,
    numero_os,
    tipo,
    marca,
    modelo,
    cor,
    senha_aparelho,
    usuario_id
FROM ordens_servico
ORDER BY created_at DESC
LIMIT 5;
