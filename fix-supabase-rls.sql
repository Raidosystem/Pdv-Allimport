-- Fix Supabase RLS for PDV Allimport
-- Este script corrige as políticas de Row Level Security

-- Habilitar RLS e criar políticas para produtos
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

-- Política para permitir SELECT na tabela produtos para usuários anônimos (desenvolvimento)
CREATE POLICY "Allow public read access to produtos" ON produtos
  FOR SELECT USING (true);

-- Política para permitir INSERT na tabela produtos para usuários autenticados
CREATE POLICY "Allow authenticated insert to produtos" ON produtos
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Política para permitir UPDATE na tabela produtos para usuários autenticados
CREATE POLICY "Allow authenticated update to produtos" ON produtos
  FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Habilitar RLS e criar políticas para categorias
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;

-- Política para permitir SELECT na tabela categorias
CREATE POLICY "Allow public read access to categorias" ON categorias
  FOR SELECT USING (true);

-- Habilitar RLS e criar políticas para clientes
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;

-- Política para permitir SELECT na tabela clientes
CREATE POLICY "Allow public read access to clientes" ON clientes
  FOR SELECT USING (true);

-- Política para permitir INSERT na tabela clientes para usuários autenticados
CREATE POLICY "Allow authenticated insert to clientes" ON clientes
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Política para permitir UPDATE na tabela clientes para usuários autenticados
CREATE POLICY "Allow authenticated update to clientes" ON clientes
  FOR UPDATE USING (auth.uid() IS NOT NULL);

-- Commit das mudanças
COMMIT;
