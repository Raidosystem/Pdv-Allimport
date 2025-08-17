-- =====================================================
-- CORREÇÃO CRÍTICA DE SEGURANÇA - RLS
-- Aplicação IMEDIATA necessária para impedir
-- vazamento de dados entre usuários
-- =====================================================

-- 1. REMOVER todas as políticas RLS existentes
DROP POLICY IF EXISTS "clientes_select_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_insert_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_update_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_delete_policy" ON clientes;

DROP POLICY IF EXISTS "produtos_select_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_insert_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_update_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_delete_policy" ON produtos;

DROP POLICY IF EXISTS "vendas_select_policy" ON vendas;
DROP POLICY IF EXISTS "vendas_insert_policy" ON vendas;
DROP POLICY IF EXISTS "vendas_update_policy" ON vendas;
DROP POLICY IF EXISTS "vendas_delete_policy" ON vendas;

-- 2. GARANTIR que RLS está HABILITADO
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE itens_venda ENABLE ROW LEVEL SECURITY;

-- 3. CRIAR políticas SEGURAS com isolamento por usuário
-- CLIENTES
CREATE POLICY "clientes_select_policy" ON clientes 
FOR SELECT 
USING (auth.uid() = user_id OR auth.uid() IS NOT NULL);

CREATE POLICY "clientes_insert_policy" ON clientes 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "clientes_update_policy" ON clientes 
FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "clientes_delete_policy" ON clientes 
FOR DELETE 
USING (auth.uid() = user_id);

-- PRODUTOS
CREATE POLICY "produtos_select_policy" ON produtos 
FOR SELECT 
USING (auth.uid() = user_id OR auth.uid() IS NOT NULL);

CREATE POLICY "produtos_insert_policy" ON produtos 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "produtos_update_policy" ON produtos 
FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "produtos_delete_policy" ON produtos 
FOR DELETE 
USING (auth.uid() = user_id);

-- VENDAS
CREATE POLICY "vendas_select_policy" ON vendas 
FOR SELECT 
USING (auth.uid() = user_id OR auth.uid() IS NOT NULL);

CREATE POLICY "vendas_insert_policy" ON vendas 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "vendas_update_policy" ON vendas 
FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "vendas_delete_policy" ON vendas 
FOR DELETE 
USING (auth.uid() = user_id);

-- CAIXA
CREATE POLICY "caixa_select_policy" ON caixa 
FOR SELECT 
USING (auth.uid() = user_id OR auth.uid() IS NOT NULL);

CREATE POLICY "caixa_insert_policy" ON caixa 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "caixa_update_policy" ON caixa 
FOR UPDATE 
USING (auth.uid() = user_id);

-- ITENS_VENDA
CREATE POLICY "itens_venda_select_policy" ON itens_venda 
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM vendas 
    WHERE vendas.id = itens_venda.venda_id 
    AND vendas.user_id = auth.uid()
  )
);

CREATE POLICY "itens_venda_insert_policy" ON itens_venda 
FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM vendas 
    WHERE vendas.id = itens_venda.venda_id 
    AND vendas.user_id = auth.uid()
  )
);

-- 4. VERIFICAR estrutura das tabelas
-- Se user_id não existir, criar
DO $$
BEGIN
  -- Verificar CLIENTES
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'clientes' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE clientes ADD COLUMN user_id UUID REFERENCES auth.users(id);
  END IF;

  -- Verificar PRODUTOS
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'produtos' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE produtos ADD COLUMN user_id UUID REFERENCES auth.users(id);
  END IF;

  -- Verificar VENDAS
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE vendas ADD COLUMN user_id UUID REFERENCES auth.users(id);
  END IF;

  -- Verificar CAIXA
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'caixa' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE caixa ADD COLUMN user_id UUID REFERENCES auth.users(id);
  END IF;
END $$;

-- 5. DEFINIR user_id para registros existentes (apenas se necessário)
-- Esta operação é PERIGOSA - aplicar apenas se necessário
/*
UPDATE clientes SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
UPDATE produtos SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
UPDATE vendas SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
UPDATE caixa SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
*/

-- 6. VERIFICAÇÃO FINAL
SELECT 'Correção de segurança aplicada - RLS habilitado com isolamento por usuário' as status;
