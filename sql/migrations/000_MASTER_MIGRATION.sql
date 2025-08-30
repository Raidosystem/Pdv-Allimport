-- ===================================================
-- 🗂️ MIGRAÇÃO MASTER - PDV ALLIMPORT
-- ===================================================
-- Script consolidado compatível com Supabase SQL Editor
-- Execute este script APENAS UMA VEZ no Supabase
-- Data: 28/08/2025
-- Versão: 1.0.0
-- ===================================================

-- ===================================================
-- 1. SCHEMA INICIAL (Tabelas principais)
-- ===================================================

-- Criar tabela de usuários (estende auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email text UNIQUE NOT NULL,
  name text NOT NULL,
  role text NOT NULL DEFAULT 'operator' CHECK (role IN ('admin', 'manager', 'operator')),
  avatar_url text,
  phone text,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Criar tabela de categorias de produtos
CREATE TABLE IF NOT EXISTS public.categories (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  description text,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Criar tabela de produtos
CREATE TABLE IF NOT EXISTS public.products (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  description text,
  sku text UNIQUE,
  barcode text UNIQUE,
  category_id uuid REFERENCES public.categories(id),
  price decimal(10,2) NOT NULL DEFAULT 0,
  cost decimal(10,2) DEFAULT 0,
  stock_quantity integer DEFAULT 0,
  min_stock integer DEFAULT 0,
  unit text DEFAULT 'un',
  active boolean DEFAULT true,
  image_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Criar tabela de clientes (customers)
CREATE TABLE IF NOT EXISTS public.customers (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  email text UNIQUE,
  phone text,
  document text UNIQUE, -- CPF/CNPJ
  address jsonb, -- {street, number, city, state, zip_code}
  type text DEFAULT 'individual' CHECK (type IN ('individual', 'company')),
  notes text,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Criar tabela de caixas
CREATE TABLE IF NOT EXISTS public.cash_registers (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  is_open boolean DEFAULT false,
  opened_by uuid REFERENCES public.profiles(id),
  opened_at timestamp with time zone,
  closed_by uuid REFERENCES public.profiles(id),
  closed_at timestamp with time zone,
  initial_amount decimal(10,2) DEFAULT 0,
  current_amount decimal(10,2) DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Criar tabela de vendas
CREATE TABLE IF NOT EXISTS public.sales (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id uuid REFERENCES public.customers(id),
  cash_register_id uuid REFERENCES public.cash_registers(id),
  user_id uuid REFERENCES public.profiles(id),
  total_amount decimal(10,2) NOT NULL,
  discount_amount decimal(10,2) DEFAULT 0,
  payment_method text NOT NULL,
  payment_details jsonb,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Criar tabela de itens de venda
CREATE TABLE IF NOT EXISTS public.sale_items (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  sale_id uuid REFERENCES public.sales(id) ON DELETE CASCADE,
  product_id uuid REFERENCES public.products(id),
  quantity integer NOT NULL,
  unit_price decimal(10,2) NOT NULL,
  total_price decimal(10,2) NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Criar tabela de ordens de serviço
CREATE TABLE IF NOT EXISTS public.service_orders (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id uuid REFERENCES public.customers(id),
  user_id uuid REFERENCES public.profiles(id),
  device_type text NOT NULL,
  device_brand text NOT NULL,
  device_model text NOT NULL,
  serial_number text,
  problem_description text NOT NULL,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
  priority text DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  estimated_cost decimal(10,2),
  final_cost decimal(10,2),
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Criar tabela de movimentações de estoque
CREATE TABLE IF NOT EXISTS public.stock_movements (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id uuid REFERENCES public.products(id),
  user_id uuid REFERENCES public.profiles(id),
  type text NOT NULL CHECK (type IN ('in', 'out', 'adjustment')),
  quantity integer NOT NULL,
  reason text,
  reference_id uuid, -- Pode referenciar sale_id ou service_order_id
  created_at timestamp with time zone DEFAULT now()
);

-- ===================================================
-- 2. CORREÇÃO DE NOMES DE TABELAS
-- ===================================================

-- Migration: Fix table naming inconsistency
-- Date: 2025-08-02
-- Description: Rename customers to clientes for consistency

-- Drop the customers table if it exists (since we'll use clientes)
DROP TABLE IF EXISTS public.customers CASCADE;

-- Create the clientes table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.clientes (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  nome text NOT NULL,
  telefone text,
  cpf_cnpj text,
  email text,
  endereco text,
  tipo text NOT NULL DEFAULT 'Física' CHECK (tipo IN ('Física', 'Jurídica')),
  observacoes text,
  ativo boolean DEFAULT true,
  criado_em timestamp with time zone DEFAULT now(),
  atualizado_em timestamp with time zone DEFAULT now()
);

-- Enable RLS on clientes table
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for clientes table
DROP POLICY IF EXISTS "Users can view all clientes" ON public.clientes;
CREATE POLICY "Users can view all clientes"
ON public.clientes FOR SELECT
USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can insert clientes" ON public.clientes;
CREATE POLICY "Users can insert clientes"
ON public.clientes FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can update clientes" ON public.clientes;
CREATE POLICY "Users can update clientes"
ON public.clientes FOR UPDATE
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can delete clientes" ON public.clientes;
CREATE POLICY "Users can delete clientes"
ON public.clientes FOR DELETE
USING (auth.role() = 'authenticated');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_clientes_nome ON public.clientes(nome);
CREATE INDEX IF NOT EXISTS idx_clientes_telefone ON public.clientes(telefone);
CREATE INDEX IF NOT EXISTS idx_clientes_cpf_cnpj ON public.clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_clientes_email ON public.clientes(email);
CREATE INDEX IF NOT EXISTS idx_clientes_tipo ON public.clientes(tipo);
CREATE INDEX IF NOT EXISTS idx_clientes_ativo ON public.clientes(ativo);

-- ===================================================
-- 3. ORDENS DE SERVIÇO
-- ===================================================

-- Migration: Create ordens_servico table
-- Date: 2025-08-02
-- Description: Create ordens_servico table (Portuguese version) for service orders management

-- Create ordens_servico table if not exists
CREATE TABLE IF NOT EXISTS public.ordens_servico (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  cliente_id uuid REFERENCES public.clientes(id),
  usuario_id uuid REFERENCES auth.users(id),
  numero_os text UNIQUE NOT NULL,
  descricao_problema text NOT NULL,
  descricao_servico text,
  observacoes text,
  valor decimal(10,2) DEFAULT 0,
  status text NOT NULL DEFAULT 'Aberta' CHECK (status IN ('Aberta', 'Em Andamento', 'Pronto', 'Entregue', 'Cancelada')),
  data_entrada timestamp with time zone DEFAULT now(),
  data_previsao timestamp with time zone,
  data_finalizacao timestamp with time zone,
  equipamento text,
  marca text,
  modelo text,
  numero_serie text,
  acessorios text,
  defeitos_encontrados text,
  pecas_utilizadas jsonb,
  tempo_gasto interval,
  criado_em timestamp with time zone DEFAULT now(),
  atualizado_em timestamp with time zone DEFAULT now()
);

-- Enable RLS on ordens_servico table
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for ordens_servico table
DROP POLICY IF EXISTS "Users can view all ordens_servico" ON public.ordens_servico;
CREATE POLICY "Users can view all ordens_servico"
ON public.ordens_servico FOR SELECT
USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can insert ordens_servico" ON public.ordens_servico;
CREATE POLICY "Users can insert ordens_servico"
ON public.ordens_servico FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can update ordens_servico" ON public.ordens_servico;
CREATE POLICY "Users can update ordens_servico"
ON public.ordens_servico FOR UPDATE
USING (auth.role() = 'authenticated')
WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can delete ordens_servico" ON public.ordens_servico;
CREATE POLICY "Users can delete ordens_servico"
ON public.ordens_servico FOR DELETE
USING (auth.role() = 'authenticated');

-- ===================================================
-- 4. DADOS INICIAIS (Seed)
-- ===================================================

-- Inserir categoria padrão se não existir
INSERT INTO public.categories (name, description, active)
VALUES ('Geral', 'Categoria padrão para produtos', true)
ON CONFLICT (name) DO NOTHING;

-- Inserir perfil admin se não existir (ajuste o email conforme necessário)
-- INSERT INTO public.profiles (id, email, name, role, active)
-- VALUES ('admin-uuid-aqui', 'admin@pdv.com', 'Administrador', 'admin', true)
-- ON CONFLICT (id) DO NOTHING;

-- ===================================================
-- 5. CAMPOS DE ENDEREÇO PARA CLIENTES
-- ===================================================

-- Adicionar campos de endereço na tabela clientes
ALTER TABLE public.clientes
ADD COLUMN IF NOT EXISTS endereco_completo text,
ADD COLUMN IF NOT EXISTS bairro text,
ADD COLUMN IF NOT EXISTS cidade text,
ADD COLUMN IF NOT EXISTS estado text,
ADD COLUMN IF NOT EXISTS cep text;

-- ===================================================
-- 6. HISTÓRICO DE CAIXA
-- ===================================================

-- Criar tabela de histórico de caixa
CREATE TABLE IF NOT EXISTS public.historico_caixa (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  caixa_id uuid REFERENCES public.cash_registers(id),
  tipo text NOT NULL CHECK (tipo IN ('abertura', 'fechamento', 'suprimento', 'sangria')),
  valor decimal(10,2) NOT NULL,
  descricao text,
  usuario_id uuid REFERENCES auth.users(id),
  criado_em timestamp with time zone DEFAULT now()
);

-- Enable RLS on historico_caixa table
ALTER TABLE public.historico_caixa ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for historico_caixa table
DROP POLICY IF EXISTS "Users can view all historico_caixa" ON public.historico_caixa;
CREATE POLICY "Users can view all historico_caixa"
ON public.historico_caixa FOR SELECT
USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Users can insert historico_caixa" ON public.historico_caixa;
CREATE POLICY "Users can insert historico_caixa"
ON public.historico_caixa FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

-- ===================================================
-- 7. POLÍTICAS RLS PARA CLIENTES (FINAL)
-- ===================================================

-- Assegurar que RLS está desabilitado para clientes (acesso público)
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;

-- Remover todas as políticas antigas se existirem
DROP POLICY IF EXISTS "Users can view all clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can insert clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can update clientes" ON public.clientes;
DROP POLICY IF EXISTS "Users can delete clientes" ON public.clientes;

-- ===================================================
-- 8. GARANTIA PARA ORDENS DE SERVIÇO
-- ===================================================

-- Adicionar campos de garantia na tabela ordens_servico
ALTER TABLE public.ordens_servico
ADD COLUMN IF NOT EXISTS garantia_meses integer DEFAULT 0,
ADD COLUMN IF NOT EXISTS garantia_descricao text,
ADD COLUMN IF NOT EXISTS data_garantia_fim timestamp with time zone;

-- ===================================================
-- 9. CONFIGURAÇÃO DE EMAIL
-- ===================================================

-- Nota: Configurações de email são feitas no painel do Supabase
-- Esta seção é apenas para referência

-- ===================================================
-- 10. CHECKLIST PARA ORDENS DE SERVIÇO
-- ===================================================

-- Adicionar campo de checklist na tabela ordens_servico
ALTER TABLE public.ordens_servico
ADD COLUMN IF NOT EXISTS checklist jsonb DEFAULT '[]'::jsonb;

-- ===================================================
-- 11. FUNÇÃO DE CAIXA
-- ===================================================

-- Criar função para atualizar caixa automaticamente
CREATE OR REPLACE FUNCTION atualizar_saldo_caixa()
RETURNS TRIGGER AS $$
BEGIN
  -- Se for uma venda, adicionar ao saldo do caixa
  IF TG_OP = 'INSERT' AND TG_TABLE_NAME = 'sales' THEN
    UPDATE public.cash_registers
    SET current_amount = current_amount + NEW.total_amount
    WHERE id = NEW.cash_register_id;
    RETURN NEW;
  END IF;

  -- Se for uma movimentação de caixa, atualizar o saldo
  IF TG_OP = 'INSERT' AND TG_TABLE_NAME = 'historico_caixa' THEN
    IF NEW.tipo = 'suprimento' THEN
      UPDATE public.cash_registers
      SET current_amount = current_amount + NEW.valor
      WHERE id = NEW.caixa_id;
    ELSIF NEW.tipo = 'sangria' THEN
      UPDATE public.cash_registers
      SET current_amount = current_amount - NEW.valor
      WHERE id = NEW.caixa_id;
    END IF;
    RETURN NEW;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Criar triggers para atualizar saldo automaticamente
DROP TRIGGER IF EXISTS trigger_atualizar_saldo_venda ON public.sales;
CREATE TRIGGER trigger_atualizar_saldo_venda
  AFTER INSERT ON public.sales
  FOR EACH ROW
  EXECUTE FUNCTION atualizar_saldo_caixa();

DROP TRIGGER IF EXISTS trigger_atualizar_saldo_caixa ON public.historico_caixa;
CREATE TRIGGER trigger_atualizar_saldo_caixa
  AFTER INSERT ON public.historico_caixa
  FOR EACH ROW
  EXECUTE FUNCTION atualizar_saldo_caixa();

-- ===================================================
-- ✅ MIGRAÇÃO CONCLUÍDA
-- ===================================================
-- Todas as tabelas, políticas e dados foram criados
-- Execute 001_VERIFICATION_POST_MIGRATION.sql para confirmar
-- ===================================================
