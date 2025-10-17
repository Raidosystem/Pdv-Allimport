-- ============================================
-- VERIFICAR E CORRIGIR RLS DA TABELA EMPRESAS
-- ============================================
-- Execute este script no Supabase SQL Editor

-- 1. VERIFICAR POLÍTICAS EXISTENTES
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
WHERE tablename = 'empresas'
ORDER BY policyname;

-- 2. VERIFICAR SE RLS ESTÁ ATIVO
SELECT 
  tablename,
  rowsecurity
FROM pg_tables 
WHERE tablename = 'empresas';

-- 3. VERIFICAR ESTRUTURA DA TABELA
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'empresas'
ORDER BY ordinal_position;

-- 4. REMOVER POLÍTICAS ANTIGAS (se existirem)
DROP POLICY IF EXISTS "Usuários podem ver suas próprias empresas" ON empresas;
DROP POLICY IF EXISTS "Usuários podem inserir suas próprias empresas" ON empresas;
DROP POLICY IF EXISTS "Usuários podem atualizar suas próprias empresas" ON empresas;
DROP POLICY IF EXISTS "Usuários podem deletar suas próprias empresas" ON empresas;

-- 5. RECRIAR POLÍTICAS DE SELECT (mais permissiva)
CREATE POLICY "select_own_empresa"
ON empresas
FOR SELECT
TO authenticated
USING (
  user_id = auth.uid()
);

-- 6. RECRIAR POLÍTICAS DE INSERT
CREATE POLICY "insert_own_empresa"
ON empresas
FOR INSERT
TO authenticated
WITH CHECK (
  user_id = auth.uid()
);

-- 7. RECRIAR POLÍTICAS DE UPDATE
CREATE POLICY "update_own_empresa"
ON empresas
FOR UPDATE
TO authenticated
USING (
  user_id = auth.uid()
)
WITH CHECK (
  user_id = auth.uid()
);

-- 8. RECRIAR POLÍTICAS DE DELETE
CREATE POLICY "delete_own_empresa"
ON empresas
FOR DELETE
TO authenticated
USING (
  user_id = auth.uid()
);

-- 9. GARANTIR QUE RLS ESTÁ ATIVO
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;

-- 10. VERIFICAR SE O USUÁRIO TEM EMPRESA
SELECT 
  id,
  nome,
  user_id,
  created_at
FROM empresas
WHERE user_id = auth.uid();

-- 11. SE NÃO EXISTIR, CRIAR EMPRESA PARA O ADMIN
-- Substitua 'c6864d69-a55c-4aca-8fe4-87841ac1084a' pelo seu user_id real
DO $$
DECLARE
  v_user_id uuid := 'c6864d69-a55c-4aca-8fe4-87841ac1084a'; -- SUBSTITUA AQUI
  v_empresa_count int;
BEGIN
  -- Verificar se já existe empresa
  SELECT COUNT(*) INTO v_empresa_count
  FROM empresas
  WHERE user_id = v_user_id;

  -- Se não existir, criar
  IF v_empresa_count = 0 THEN
    INSERT INTO empresas (
      user_id,
      nome,
      cnpj,
      telefone,
      email,
      endereco,
      cidade,
      estado,
      cep
    ) VALUES (
      v_user_id,
      'Assistência All-Import',
      '00.000.000/0000-00',
      '(11) 99999-9999',
      'contato@allimport.com.br',
      'Rua Exemplo, 123',
      'São Paulo',
      'SP',
      '00000-000'
    );
    
    RAISE NOTICE 'Empresa criada com sucesso!';
  ELSE
    RAISE NOTICE 'Empresa já existe para este usuário';
  END IF;
END $$;

-- 12. VERIFICAR NOVAMENTE
SELECT 
  id,
  nome,
  user_id,
  created_at
FROM empresas
WHERE user_id = 'c6864d69-a55c-4aca-8fe4-87841ac1084a'; -- SUBSTITUA AQUI
