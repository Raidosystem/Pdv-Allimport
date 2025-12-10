-- ===============================================
-- 🚨 EMERGÊNCIA CRÍTICA DE SEGURANÇA - RLS
-- COPIE E COLE ESTE SCRIPT NO SUPABASE SQL EDITOR
-- ===============================================

-- 1. VERIFICAR ESTRUTURA ATUAL (diagnóstico)
SELECT 
  'DIAGNÓSTICO INICIAL' as status,
  tablename,
  rowsecurity as "RLS_Habilitado"
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa');

-- 2. VERIFICAR COLUNAS USER_ID
SELECT 
  'VERIFICAÇÃO COLUNAS' as status,
  table_name,
  column_name,
  data_type
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name IN ('clientes', 'produtos', 'vendas', 'caixa')
AND column_name = 'user_id';

-- 3. REMOVER TODAS AS POLÍTICAS PERIGOSAS
DROP POLICY IF EXISTS "Usuários autenticados podem ver clientes" ON public.clientes;
DROP POLICY IF EXISTS "Usuários autenticados podem ver produtos" ON public.produtos;
DROP POLICY IF EXISTS "Usuários autenticados podem ver vendas" ON public.vendas;
DROP POLICY IF EXISTS "Usuários autenticados podem ver caixa" ON public.caixa;
DROP POLICY IF EXISTS "clientes_select_policy" ON public.clientes;
DROP POLICY IF EXISTS "produtos_select_policy" ON public.produtos;
DROP POLICY IF EXISTS "vendas_select_policy" ON public.vendas;
DROP POLICY IF EXISTS "caixa_select_policy" ON public.caixa;

-- 4. GARANTIR QUE USER_ID EXISTE EM TODAS AS TABELAS
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
    RAISE NOTICE 'Coluna user_id adicionada à tabela clientes';
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
    RAISE NOTICE 'Coluna user_id adicionada à tabela produtos';
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
    RAISE NOTICE 'Coluna user_id adicionada à tabela vendas';
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
    RAISE NOTICE 'Coluna user_id adicionada à tabela caixa';
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
    -- Para itens_venda, vamos relacionar via venda_id
    ALTER TABLE public.itens_venda ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    RAISE NOTICE 'Coluna user_id adicionada à tabela itens_venda';
  END IF;
END $$;

-- 5. ATUALIZAR REGISTROS EXISTENTES COM USER_ID (APENAS ADMIN)
-- ATENÇÃO: Esto atribuirá todos os dados existentes ao primeiro usuário admin
UPDATE public.clientes 
SET user_id = (
  SELECT id FROM auth.users 
  WHERE email = 'admin@pdv.com' 
  LIMIT 1
) 
WHERE user_id IS NULL;

UPDATE public.produtos 
SET user_id = (
  SELECT id FROM auth.users 
  WHERE email = 'admin@pdv.com' 
  LIMIT 1
) 
WHERE user_id IS NULL;

UPDATE public.vendas 
SET user_id = (
  SELECT id FROM auth.users 
  WHERE email = 'admin@pdv.com' 
  LIMIT 1
) 
WHERE user_id IS NULL;

UPDATE public.caixa 
SET user_id = (
  SELECT id FROM auth.users 
  WHERE email = 'admin@pdv.com' 
  LIMIT 1
) 
WHERE user_id IS NULL;

UPDATE public.itens_venda 
SET user_id = (
  SELECT id FROM auth.users 
  WHERE email = 'admin@pdv.com' 
  LIMIT 1
) 
WHERE user_id IS NULL;

-- 6. HABILITAR RLS EM TODAS AS TABELAS
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_venda ENABLE ROW LEVEL SECURITY;

-- 7. CRIAR POLÍTICAS DE ISOLAMENTO TOTAL
-- CLIENTES - Cada usuário vê apenas seus clientes
CREATE POLICY "clientes_isolamento_total" ON public.clientes 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- PRODUTOS - Cada usuário vê apenas seus produtos
CREATE POLICY "produtos_isolamento_total" ON public.produtos 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- VENDAS - Cada usuário vê apenas suas vendas
CREATE POLICY "vendas_isolamento_total" ON public.vendas 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- CAIXA - Cada usuário vê apenas seu caixa
CREATE POLICY "caixa_isolamento_total" ON public.caixa 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ITENS_VENDA - Isolamento via vendas
CREATE POLICY "itens_venda_isolamento_total" ON public.itens_venda 
FOR ALL 
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 8. CRIAR FUNÇÃO PARA AUTO-ASSIGN USER_ID
CREATE OR REPLACE FUNCTION public.set_user_id()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  NEW.user_id = auth.uid();
  RETURN NEW;
END;
$$;

-- 9. CRIAR TRIGGERS PARA AUTO-ASSIGN
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

-- 10. VERIFICAÇÃO FINAL
SELECT 
  '🔒 VERIFICAÇÃO FINAL - RLS STATUS' as status,
  tablename,
  rowsecurity as "RLS_Habilitado"
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda');

SELECT 
  '🔑 POLÍTICAS CRIADAS' as status,
  schemaname,
  tablename,
  policyname
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa', 'itens_venda');

SELECT '✅ SEGURANÇA RLS APLICADA COM SUCESSO! DADOS AGORA ISOLADOS POR USUÁRIO' as resultado;
