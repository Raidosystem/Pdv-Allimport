-- ===================================================
-- 🚀 MIGRAÇÃO RÁPIDA - PDV ALLIMPORT
-- ===================================================
-- Script simplificado e robusto para resolver problemas imediatos
-- Execute este script no Supabase SQL Editor
-- Data: 28/08/2025
-- Versão: 1.0.1 (Corrigida)
-- ===================================================

-- 1. CRIAR/ATUALIZAR TABELAS ESSENCIAIS
-- ===================================================

-- Tabela de produtos (se não existir)
CREATE TABLE IF NOT EXISTS public.produtos (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  nome text NOT NULL,
  descricao text,
  sku text,
  codigo_barras text,
  preco decimal(10,2) NOT NULL DEFAULT 0,
  estoque_atual integer DEFAULT 0,
  estoque_minimo integer DEFAULT 0,
  unidade text DEFAULT 'un',
  ativo boolean DEFAULT true,
  criado_em timestamp with time zone DEFAULT now(),
  atualizado_em timestamp with time zone DEFAULT now()
);

-- Adicionar coluna ativo se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'produtos'
    AND column_name = 'ativo'
  ) THEN
    ALTER TABLE public.produtos ADD COLUMN ativo boolean DEFAULT true;
  END IF;
END $$;

-- Tabela de clientes (se não existir)
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

-- Adicionar coluna ativo se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'clientes'
    AND column_name = 'ativo'
  ) THEN
    ALTER TABLE public.clientes ADD COLUMN ativo boolean DEFAULT true;
  END IF;
END $$;

-- Tabela de categorias (se não existir)
CREATE TABLE IF NOT EXISTS public.categorias (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  nome text NOT NULL UNIQUE,
  descricao text,
  ativo boolean DEFAULT true,
  criado_em timestamp with time zone DEFAULT now(),
  atualizado_em timestamp with time zone DEFAULT now()
);

-- Adicionar coluna ativo se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = 'categorias'
    AND column_name = 'ativo'
  ) THEN
    ALTER TABLE public.categorias ADD COLUMN ativo boolean DEFAULT true;
  END IF;
END $$;

-- Adicionar constraint UNIQUE para nome se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_schema = 'public'
    AND table_name = 'categorias'
    AND constraint_name = 'categorias_nome_key'
  ) THEN
    ALTER TABLE public.categorias ADD CONSTRAINT categorias_nome_key UNIQUE (nome);
  END IF;
END $$;

-- 2. CONFIGURAR PERMISSÕES (RLS)
-- ===================================================

-- Desabilitar RLS para acesso público temporário (só se a tabela existir)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'produtos') THEN
    ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'clientes') THEN
    ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'categorias') THEN
    ALTER TABLE public.categorias DISABLE ROW LEVEL SECURITY;
  END IF;
END $$;

-- 3. CRIAR ÍNDICES PARA PERFORMANCE (SOMENTE SE COLUNAS EXISTIREM)
-- ===================================================

-- Índices para produtos
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'produtos' AND column_name = 'nome') THEN
    CREATE INDEX IF NOT EXISTS idx_produtos_nome ON public.produtos(nome);
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'produtos' AND column_name = 'codigo_barras') THEN
    CREATE INDEX IF NOT EXISTS idx_produtos_codigo_barras ON public.produtos(codigo_barras);
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'produtos' AND column_name = 'ativo') THEN
    CREATE INDEX IF NOT EXISTS idx_produtos_ativo ON public.produtos(ativo);
  END IF;
END $$;

-- Índices para clientes
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'clientes' AND column_name = 'nome') THEN
    CREATE INDEX IF NOT EXISTS idx_clientes_nome ON public.clientes(nome);
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'clientes' AND column_name = 'telefone') THEN
    CREATE INDEX IF NOT EXISTS idx_clientes_telefone ON public.clientes(telefone);
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'clientes' AND column_name = 'ativo') THEN
    CREATE INDEX IF NOT EXISTS idx_clientes_ativo ON public.clientes(ativo);
  END IF;
END $$;

-- Índices para categorias
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'categorias' AND column_name = 'nome') THEN
    CREATE INDEX IF NOT EXISTS idx_categorias_nome ON public.categorias(nome);
  END IF;
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'categorias' AND column_name = 'ativo') THEN
    CREATE INDEX IF NOT EXISTS idx_categorias_ativo ON public.categorias(ativo);
  END IF;
END $$;

-- 4. INSERIR DADOS DE TESTE (OPCIONAL)
-- ===================================================

-- Inserir categoria padrão (só se a tabela existir)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'categorias') THEN
    INSERT INTO public.categorias (nome, descricao, ativo)
    VALUES ('Geral', 'Categoria padrão', true)
    ON CONFLICT (nome) DO NOTHING;
  END IF;
END $$;

-- ===================================================
-- ✅ MIGRAÇÃO ROBUSTA CONCLUÍDA
-- ===================================================
-- Execute a verificação para confirmar:
-- SELECT
--   (SELECT COUNT(*) FROM public.produtos) as produtos,
--   (SELECT COUNT(*) FROM public.clientes) as clientes,
--   (SELECT COUNT(*) FROM public.categorias) as categorias;
-- ===================================================

-- 📋 PRÓXIMOS PASSOS:
-- 1. Execute o script de diagnóstico: sql/debug/000_DIAGNOSTICO_PRE_MIGRACAO.sql
-- 2. Verifique os resultados da migração com a query SELECT acima
-- 3. Se necessário, execute scripts adicionais da pasta sql/migrations/
