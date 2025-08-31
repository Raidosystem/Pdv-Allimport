-- SISTEMA RLS MULTI-TENANT - ISOLAMENTO COMPLETO POR USUÁRIO
-- Cada usuário só acessa seus próprios dados (clientes, vendas, produtos, etc.)

-- 1. VERIFICAR ESTRUTURA ATUAL DA TABELA DE USUÁRIOS
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('profiles', 'users', 'auth_users') 
AND table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- 2. VERIFICAR TABELAS QUE PRECISAM DE ISOLAMENTO
SELECT table_name
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
AND table_name IN ('clientes', 'produtos', 'vendas', 'caixa', 'ordens_servico', 'sales', 'products', 'customers');

-- 3. ADICIONAR COLUNA user_id EM TODAS AS TABELAS (SE NÃO EXISTIR)

-- Tabela clientes
ALTER TABLE public.clientes 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Tabela produtos (se existir)
ALTER TABLE public.produtos 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Tabela vendas/sales (se existir)  
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'vendas' AND table_schema = 'public') THEN
        ALTER TABLE public.vendas ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sales' AND table_schema = 'public') THEN
        ALTER TABLE public.sales ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- Tabela caixa (se existir)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'caixa' AND table_schema = 'public') THEN
        ALTER TABLE public.caixa ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'cash_registers' AND table_schema = 'public') THEN
        ALTER TABLE public.cash_registers ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- Tabela ordens de serviço (se existir)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'ordens_servico' AND table_schema = 'public') THEN
        ALTER TABLE public.ordens_servico ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
    END IF;
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'service_orders' AND table_schema = 'public') THEN
        ALTER TABLE public.service_orders ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- 4. CRIAR FUNÇÃO PARA OBTER USER_ID ATUAL
CREATE OR REPLACE FUNCTION auth.uid() RETURNS UUID AS $$
  SELECT auth.jwt() ->> 'sub'::UUID;
$$ LANGUAGE sql SECURITY DEFINER;

-- OU se a função já existir, usar esta versão alternativa
CREATE OR REPLACE FUNCTION get_current_user_id() RETURNS UUID AS $$
BEGIN
  RETURN COALESCE(
    (auth.jwt() ->> 'sub')::UUID,
    (SELECT id FROM auth.users WHERE email = current_user LIMIT 1),
    '00000000-0000-0000-0000-000000000000'::UUID
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. HABILITAR RLS EM TODAS AS TABELAS CRÍTICAS
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE
    tbl text;
BEGIN
    FOR tbl IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name IN ('produtos', 'vendas', 'sales', 'caixa', 'cash_registers', 'ordens_servico', 'service_orders')
    LOOP
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', tbl);
    END LOOP;
END $$;

-- Verificar se RLS foi habilitado
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('clientes', 'produtos', 'vendas', 'sales', 'caixa', 'cash_registers', 'ordens_servico', 'service_orders');
