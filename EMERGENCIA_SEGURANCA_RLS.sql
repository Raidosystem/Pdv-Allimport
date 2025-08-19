-- ===============================================
-- 🚨 EMERGÊNCIA CRÍTICA DE SEGURANÇA - RLS FIX
-- APLICAR IMEDIATAMENTE PARA PROTEGER DADOS
-- ===============================================

-- 1. DIAGNOSTICAR problema atual
SELECT 
  schemaname,
  tablename,
  rowsecurity as "RLS_Habilitado"
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa');

-- 2. VERIFICAR políticas existentes
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd,
  qual
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa');

-- 3. REMOVER todas as políticas problemáticas
DROP POLICY IF EXISTS "Usuários autenticados podem ver clientes" ON clientes;
DROP POLICY IF EXISTS "Usuários autenticados podem ver produtos" ON produtos;
DROP POLICY IF EXISTS "Usuários autenticados podem ver vendas" ON vendas;
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
DROP POLICY IF EXISTS "caixa_select_policy" ON caixa;
DROP POLICY IF EXISTS "caixa_insert_policy" ON caixa;
DROP POLICY IF EXISTS "caixa_update_policy" ON caixa;

-- 4. GARANTIR que RLS está HABILITADO
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY; 
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE itens_venda ENABLE ROW LEVEL SECURITY;

-- 5. VERIFICAR se user_id existe em todas as tabelas
DO $$
BEGIN
  -- CLIENTES
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'clientes' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE clientes ADD COLUMN user_id UUID REFERENCES auth.users(id);
    UPDATE clientes SET user_id = auth.uid() WHERE user_id IS NULL;
  END IF;

  -- PRODUTOS  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'produtos' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE produtos ADD COLUMN user_id UUID REFERENCES auth.users(id);
    UPDATE produtos SET user_id = auth.uid() WHERE user_id IS NULL;
  END IF;

  -- VENDAS
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'vendas' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE vendas ADD COLUMN user_id UUID REFERENCES auth.users(id);
    UPDATE vendas SET user_id = auth.uid() WHERE user_id IS NULL;
  END IF;

  -- CAIXA
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'caixa' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE caixa ADD COLUMN user_id UUID REFERENCES auth.users(id);
    UPDATE caixa SET user_id = auth.uid() WHERE user_id IS NULL;
  END IF;
END $$;

-- 6. CRIAR políticas RIGOROSAMENTE SEGURAS
-- CLIENTES - ISOLAMENTO TOTAL
CREATE POLICY "clientes_isolamento_total" ON clientes 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- PRODUTOS - ISOLAMENTO TOTAL
CREATE POLICY "produtos_isolamento_total" ON produtos 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- VENDAS - ISOLAMENTO TOTAL
CREATE POLICY "vendas_isolamento_total" ON vendas 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- CAIXA - ISOLAMENTO TOTAL
CREATE POLICY "caixa_isolamento_total" ON caixa 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ITENS_VENDA - ISOLAMENTO VIA VENDAS
CREATE POLICY "itens_venda_isolamento_total" ON itens_venda 
FOR ALL 
USING (
  EXISTS (
    SELECT 1 FROM vendas 
    WHERE vendas.id = itens_venda.venda_id 
    AND vendas.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM vendas 
    WHERE vendas.id = itens_venda.venda_id 
    AND vendas.user_id = auth.uid()
  )
);

-- 7. VERIFICAR se as políticas estão ativas
SELECT 
  'POLÍTICAS RLS APLICADAS - DADOS AGORA ISOLADOS POR USUÁRIO' as status,
  COUNT(*) as total_policies
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda');

-- 8. TESTE de verificação
SELECT 
  'RLS STATUS:' as info,
  tablename,
  rowsecurity as habilitado
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda');
