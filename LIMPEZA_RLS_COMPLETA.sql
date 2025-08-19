-- ================================================
-- 🧹 LIMPEZA COMPLETA RLS - REMOVER DUPLICATAS E ERROS
-- Execute APÓS o diagnóstico para limpar problemas
-- ================================================

-- 1. REMOVER TODAS AS POLÍTICAS EXISTENTES (LIMPEZA TOTAL)
SELECT '🧹 REMOVENDO TODAS AS POLÍTICAS EXISTENTES...' as acao;

-- CLIENTES
DROP POLICY IF EXISTS "Enable read access for all users" ON public.clientes;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.clientes;
DROP POLICY IF EXISTS "Enable update for users based on email" ON public.clientes;
DROP POLICY IF EXISTS "Enable delete for users based on email" ON public.clientes;
DROP POLICY IF EXISTS "Users can view clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can insert clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can update clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can delete clientes" ON public.clientes;
DROP POLICY IF EXISTS "clientes_select_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_insert_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_update_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_delete_policy" ON public.clientes;
DROP POLICY IF EXISTS "clientes_isolamento_total" ON public.clientes;
DROP POLICY IF EXISTS "Usuários autenticados podem ver clientes" ON public.clientes;

-- PRODUTOS
DROP POLICY IF EXISTS "Enable read access for all users" ON public.produtos;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.produtos;
DROP POLICY IF EXISTS "Enable update for users based on email" ON public.produtos;
DROP POLICY IF EXISTS "Enable delete for users based on email" ON public.produtos;
DROP POLICY IF EXISTS "Users can view produtos" ON public.produtos;
DROP POLICY IF EXISTS "Users can insert produtos" ON public.produtos;
DROP POLICY IF EXISTS "Users can update produtos" ON public.produtos;
DROP POLICY IF EXISTS "Users can delete produtos" ON public.produtos;
DROP POLICY IF EXISTS "produtos_select_policy" ON public.produtos;
DROP POLICY IF EXISTS "produtos_insert_policy" ON public.produtos;
DROP POLICY IF EXISTS "produtos_update_policy" ON public.produtos;
DROP POLICY IF EXISTS "produtos_delete_policy" ON public.produtos;
DROP POLICY IF EXISTS "produtos_isolamento_total" ON public.produtos;
DROP POLICY IF EXISTS "Usuários autenticados podem ver produtos" ON public.produtos;

-- VENDAS
DROP POLICY IF EXISTS "Enable read access for all users" ON public.vendas;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.vendas;
DROP POLICY IF EXISTS "Enable update for users based on email" ON public.vendas;
DROP POLICY IF EXISTS "Enable delete for users based on email" ON public.vendas;
DROP POLICY IF EXISTS "Users can view vendas" ON public.vendas;
DROP POLICY IF EXISTS "Users can insert vendas" ON public.vendas;
DROP POLICY IF EXISTS "Users can update vendas" ON public.vendas;
DROP POLICY IF EXISTS "Users can delete vendas" ON public.vendas;
DROP POLICY IF EXISTS "vendas_select_policy" ON public.vendas;
DROP POLICY IF EXISTS "vendas_insert_policy" ON public.vendas;
DROP POLICY IF EXISTS "vendas_update_policy" ON public.vendas;
DROP POLICY IF EXISTS "vendas_delete_policy" ON public.vendas;
DROP POLICY IF EXISTS "vendas_isolamento_total" ON public.vendas;
DROP POLICY IF EXISTS "Usuários autenticados podem ver vendas" ON public.vendas;

-- CAIXA
DROP POLICY IF EXISTS "Enable read access for all users" ON public.caixa;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.caixa;
DROP POLICY IF EXISTS "Enable update for users based on email" ON public.caixa;
DROP POLICY IF EXISTS "Enable delete for users based on email" ON public.caixa;
DROP POLICY IF EXISTS "Users can view caixa" ON public.caixa;
DROP POLICY IF EXISTS "Users can insert caixa" ON public.caixa;
DROP POLICY IF EXISTS "Users can update caixa" ON public.caixa;
DROP POLICY IF EXISTS "Users can delete caixa" ON public.caixa;
DROP POLICY IF EXISTS "caixa_select_policy" ON public.caixa;
DROP POLICY IF EXISTS "caixa_insert_policy" ON public.caixa;
DROP POLICY IF EXISTS "caixa_update_policy" ON public.caixa;
DROP POLICY IF EXISTS "caixa_delete_policy" ON public.caixa;
DROP POLICY IF EXISTS "caixa_isolamento_total" ON public.caixa;
DROP POLICY IF EXISTS "Usuários autenticados podem ver caixa" ON public.caixa;

-- ITENS_VENDA
DROP POLICY IF EXISTS "Enable read access for all users" ON public.itens_venda;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.itens_venda;
DROP POLICY IF EXISTS "Enable update for users based on email" ON public.itens_venda;
DROP POLICY IF EXISTS "Enable delete for users based on email" ON public.itens_venda;
DROP POLICY IF EXISTS "Users can view itens_venda" ON public.itens_venda;
DROP POLICY IF EXISTS "Users can insert itens_venda" ON public.itens_venda;
DROP POLICY IF EXISTS "Users can update itens_venda" ON public.itens_venda;
DROP POLICY IF EXISTS "Users can delete itens_venda" ON public.itens_venda;
DROP POLICY IF EXISTS "itens_venda_select_policy" ON public.itens_venda;
DROP POLICY IF EXISTS "itens_venda_insert_policy" ON public.itens_venda;
DROP POLICY IF EXISTS "itens_venda_update_policy" ON public.itens_venda;
DROP POLICY IF EXISTS "itens_venda_delete_policy" ON public.itens_venda;
DROP POLICY IF EXISTS "itens_venda_isolamento_total" ON public.itens_venda;
DROP POLICY IF EXISTS "Usuários autenticados podem ver itens_venda" ON public.itens_venda;

-- 2. GARANTIR QUE RLS ESTÁ HABILITADO
SELECT '🔒 HABILITANDO RLS EM TODAS AS TABELAS...' as acao;

ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_venda ENABLE ROW LEVEL SECURITY;

-- 3. GARANTIR COLUNAS USER_ID
SELECT '👤 GARANTINDO COLUNAS USER_ID...' as acao;

ALTER TABLE public.clientes ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.produtos ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.vendas ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.caixa ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.itens_venda ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- 4. CRIAR APENAS UMA POLÍTICA POR TABELA (ISOLAMENTO TOTAL)
SELECT '🔑 CRIANDO POLÍTICAS DE ISOLAMENTO SIMPLES...' as acao;

-- CLIENTES - Uma única política para tudo
CREATE POLICY "rls_isolamento_clientes" ON public.clientes 
FOR ALL 
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- PRODUTOS - Uma única política para tudo
CREATE POLICY "rls_isolamento_produtos" ON public.produtos 
FOR ALL 
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- VENDAS - Uma única política para tudo
CREATE POLICY "rls_isolamento_vendas" ON public.vendas 
FOR ALL 
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- CAIXA - Uma única política para tudo
CREATE POLICY "rls_isolamento_caixa" ON public.caixa 
FOR ALL 
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ITENS_VENDA - Uma única política para tudo
CREATE POLICY "rls_isolamento_itens_venda" ON public.itens_venda 
FOR ALL 
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 5. GARANTIR TRIGGERS PARA AUTO USER_ID
SELECT '⚙️ CRIANDO TRIGGERS AUTO USER_ID...' as acao;

CREATE OR REPLACE FUNCTION public.auto_user_id()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.user_id IS NULL THEN
    NEW.user_id = auth.uid();
  END IF;
  RETURN NEW;
END;
$$;

-- Aplicar triggers
DROP TRIGGER IF EXISTS trigger_auto_user_id_clientes ON public.clientes;
CREATE TRIGGER trigger_auto_user_id_clientes
  BEFORE INSERT ON public.clientes
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_user_id();

DROP TRIGGER IF EXISTS trigger_auto_user_id_produtos ON public.produtos;
CREATE TRIGGER trigger_auto_user_id_produtos
  BEFORE INSERT ON public.produtos
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_user_id();

DROP TRIGGER IF EXISTS trigger_auto_user_id_vendas ON public.vendas;
CREATE TRIGGER trigger_auto_user_id_vendas
  BEFORE INSERT ON public.vendas
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_user_id();

DROP TRIGGER IF EXISTS trigger_auto_user_id_caixa ON public.caixa;
CREATE TRIGGER trigger_auto_user_id_caixa
  BEFORE INSERT ON public.caixa
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_user_id();

DROP TRIGGER IF EXISTS trigger_auto_user_id_itens_venda ON public.itens_venda;
CREATE TRIGGER trigger_auto_user_id_itens_venda
  BEFORE INSERT ON public.itens_venda
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_user_id();

-- 6. VERIFICAÇÃO FINAL APÓS LIMPEZA
SELECT '✅ VERIFICAÇÃO APÓS LIMPEZA' as resultado;

SELECT 
  'RLS FINAL' as status,
  tablename,
  rowsecurity as rls_ativo
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda');

SELECT 
  'POLÍTICAS FINAIS' as status,
  tablename,
  policyname
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda');

SELECT '🎉 LIMPEZA COMPLETA FINALIZADA - RLS LIMPO E ISOLAMENTO TOTAL ATIVO' as resultado;
