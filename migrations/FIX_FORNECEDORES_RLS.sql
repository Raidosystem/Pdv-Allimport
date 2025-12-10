-- =====================================================
-- FIX POLÍTICAS RLS DA TABELA FORNECEDORES
-- =====================================================
-- Este script corrige as políticas de segurança (RLS)
-- para permitir que usuários autenticados possam:
-- 1. INSERIR fornecedores
-- 2. LER seus próprios fornecedores
-- 3. ATUALIZAR seus próprios fornecedores
-- 4. DELETAR seus próprios fornecedores
-- =====================================================

-- 1. Remover políticas antigas (se existirem)
DROP POLICY IF EXISTS "Usuários podem ver seus fornecedores" ON fornecedores;
DROP POLICY IF EXISTS "Usuários podem inserir fornecedores" ON fornecedores;
DROP POLICY IF EXISTS "Usuários podem atualizar seus fornecedores" ON fornecedores;
DROP POLICY IF EXISTS "Usuários podem deletar seus fornecedores" ON fornecedores;

-- 2. Garantir que RLS está habilitado
ALTER TABLE fornecedores ENABLE ROW LEVEL SECURITY;

-- 3. Criar política para SELECT (leitura)
CREATE POLICY "Usuários podem ver seus fornecedores"
ON fornecedores
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()
);

-- 4. Criar política para INSERT (criação)
CREATE POLICY "Usuários podem inserir fornecedores"
ON fornecedores
FOR INSERT
TO authenticated
WITH CHECK (
  user_id = auth.uid()
);

-- 5. Criar política para UPDATE (atualização)
CREATE POLICY "Usuários podem atualizar seus fornecedores"
ON fornecedores
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 6. Criar política para DELETE (exclusão)
CREATE POLICY "Usuários podem deletar seus fornecedores"
ON fornecedores
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- 7. Verificar se a coluna user_id existe e tem o tipo correto
DO $$
BEGIN
  -- Verificar se a coluna existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'fornecedores' AND column_name = 'user_id'
  ) THEN
    -- Adicionar coluna user_id se não existir
    ALTER TABLE fornecedores ADD COLUMN user_id UUID REFERENCES auth.users(id);
    RAISE NOTICE 'Coluna user_id adicionada à tabela fornecedores';
  END IF;
END $$;

-- 8. Criar índice para melhorar performance
CREATE INDEX IF NOT EXISTS idx_fornecedores_user_id ON fornecedores(user_id);

-- =====================================================
-- VALIDAÇÃO: Verificar políticas criadas
-- =====================================================
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
WHERE tablename = 'fornecedores'
ORDER BY cmd, policyname;

-- =====================================================
-- SUCESSO!
-- =====================================================
-- Execute este script no SQL Editor do Supabase:
-- 1. Acesse: https://supabase.com/dashboard
-- 2. Selecione seu projeto: kmcaaqetxtwkdcczdomw
-- 3. Vá em: SQL Editor
-- 4. Cole este script completo
-- 5. Clique em RUN
-- =====================================================
