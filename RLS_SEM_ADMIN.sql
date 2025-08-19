-- ================================================
-- REATIVAR RLS COM ISOLAMENTO TOTAL POR USUÁRIO
-- SEM USUÁRIO ADMIN - CADA USUÁRIO VÊ APENAS SEUS DADOS
-- Execute no SQL Editor do Supabase
-- ================================================

-- 1. VERIFICAR STATUS ATUAL
SELECT 
  'STATUS ATUAL RLS' as info,
  tablename,
  rowsecurity as rls_habilitado
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda');

-- 2. REMOVER USUÁRIO ADMIN@PDV.COM COMPLETAMENTE
DELETE FROM auth.users WHERE email = 'admin@pdv.com';

-- 3. GARANTIR QUE USER_ID EXISTE EM TODAS AS TABELAS
-- CLIENTES
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'clientes' 
    AND column_name = 'user_id'
  ) THEN
    ALTER TABLE public.clientes ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE '✅ Coluna user_id adicionada à tabela clientes';
  ELSE
    RAISE NOTICE '✅ Coluna user_id já existe na tabela clientes';
  END IF;
END $$;

-- PRODUTOS
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'produtos' 
    AND column_name = 'user_id'
  ) THEN
    ALTER TABLE public.produtos ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE '✅ Coluna user_id adicionada à tabela produtos';
  ELSE
    RAISE NOTICE '✅ Coluna user_id já existe na tabela produtos';
  END IF;
END $$;

-- VENDAS
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'vendas' 
    AND column_name = 'user_id'
  ) THEN
    ALTER TABLE public.vendas ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE '✅ Coluna user_id adicionada à tabela vendas';
  ELSE
    RAISE NOTICE '✅ Coluna user_id já existe na tabela vendas';
  END IF;
END $$;

-- CAIXA
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'caixa' 
    AND column_name = 'user_id'
  ) THEN
    ALTER TABLE public.caixa ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE '✅ Coluna user_id adicionada à tabela caixa';
  ELSE
    RAISE NOTICE '✅ Coluna user_id já existe na tabela caixa';
  END IF;
END $$;

-- ITENS_VENDA
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'itens_venda' 
    AND column_name = 'user_id'
  ) THEN
    ALTER TABLE public.itens_venda ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE '✅ Coluna user_id adicionada à tabela itens_venda';
  ELSE
    RAISE NOTICE '✅ Coluna user_id já existe na tabela itens_venda';
  END IF;
END $$;

-- 4. LIMPAR REGISTROS ÓRFÃOS (sem user_id válido)
-- Como removemos o admin, todos os registros órfãos serão deletados
DELETE FROM public.clientes WHERE user_id IS NULL OR user_id NOT IN (SELECT id FROM auth.users);
DELETE FROM public.produtos WHERE user_id IS NULL OR user_id NOT IN (SELECT id FROM auth.users);
DELETE FROM public.vendas WHERE user_id IS NULL OR user_id NOT IN (SELECT id FROM auth.users);
DELETE FROM public.caixa WHERE user_id IS NULL OR user_id NOT IN (SELECT id FROM auth.users);
DELETE FROM public.itens_venda WHERE user_id IS NULL OR user_id NOT IN (SELECT id FROM auth.users);

-- 5. REATIVAR RLS EM TODAS AS TABELAS
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_venda ENABLE ROW LEVEL SECURITY;

-- 6. CRIAR POLÍTICAS DE ISOLAMENTO TOTAL
-- CLIENTES - Isolamento total por usuário
DROP POLICY IF EXISTS "clientes_isolamento_total" ON public.clientes;
CREATE POLICY "clientes_isolamento_total" ON public.clientes 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- PRODUTOS - Isolamento total por usuário  
DROP POLICY IF EXISTS "produtos_isolamento_total" ON public.produtos;
CREATE POLICY "produtos_isolamento_total" ON public.produtos 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- VENDAS - Isolamento total por usuário
DROP POLICY IF EXISTS "vendas_isolamento_total" ON public.vendas;
CREATE POLICY "vendas_isolamento_total" ON public.vendas 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- CAIXA - Isolamento total por usuário
DROP POLICY IF EXISTS "caixa_isolamento_total" ON public.caixa;
CREATE POLICY "caixa_isolamento_total" ON public.caixa 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ITENS_VENDA - Isolamento total por usuário
DROP POLICY IF EXISTS "itens_venda_isolamento_total" ON public.itens_venda;
CREATE POLICY "itens_venda_isolamento_total" ON public.itens_venda 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 7. CRIAR TRIGGERS PARA AUTO-ASSIGN USER_ID
CREATE OR REPLACE FUNCTION public.set_user_id()
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

-- APLICAR TRIGGERS
DROP TRIGGER IF EXISTS set_user_id_clientes ON public.clientes;
CREATE TRIGGER set_user_id_clientes
  BEFORE INSERT ON public.clientes
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_id();

DROP TRIGGER IF EXISTS set_user_id_produtos ON public.produtos;
CREATE TRIGGER set_user_id_produtos
  BEFORE INSERT ON public.produtos
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_id();

DROP TRIGGER IF EXISTS set_user_id_vendas ON public.vendas;
CREATE TRIGGER set_user_id_vendas
  BEFORE INSERT ON public.vendas
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_id();

DROP TRIGGER IF EXISTS set_user_id_caixa ON public.caixa;
CREATE TRIGGER set_user_id_caixa
  BEFORE INSERT ON public.caixa
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_id();

DROP TRIGGER IF EXISTS set_user_id_itens_venda ON public.itens_venda;
CREATE TRIGGER set_user_id_itens_venda
  BEFORE INSERT ON public.itens_venda
  FOR EACH ROW
  EXECUTE FUNCTION public.set_user_id();

-- 8. VERIFICAÇÃO FINAL
SELECT 
  '🔒 RLS REATIVADO' as status,
  tablename,
  rowsecurity as rls_habilitado
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda');

SELECT 
  '🔑 POLÍTICAS ATIVAS' as status,
  schemaname,
  tablename,
  policyname,
  cmd
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda');

-- 9. VERIFICAR USUÁRIOS RESTANTES
SELECT 
  'USUÁRIOS ATIVOS' as info,
  id,
  email,
  created_at
FROM auth.users;

-- 10. TESTE DE ISOLAMENTO
SELECT 
  'TESTE: Contagem por tabela (deve mostrar apenas dados do usuário logado)' as teste,
  (SELECT COUNT(*) FROM public.clientes) as clientes,
  (SELECT COUNT(*) FROM public.produtos) as produtos,
  (SELECT COUNT(*) FROM public.vendas) as vendas,
  (SELECT COUNT(*) FROM public.caixa) as caixa;

SELECT '✅ USUÁRIO ADMIN REMOVIDO! RLS ATIVO COM ISOLAMENTO TOTAL! CADA USUÁRIO VÊ APENAS SEUS DADOS' as resultado;
