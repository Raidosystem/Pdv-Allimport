-- 🔧 SQL PARA CORRIGIR ERRO RLS DE CATEGORIAS
-- Execute este SQL no painel do Supabase (SQL Editor)

-- 1. Verificar se a tabela existe
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'categories';

-- 2. Criar tabela se não existir
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. Criar índice para busca por nome
CREATE INDEX IF NOT EXISTS idx_categories_name ON public.categories(name);

-- 4. Habilitar RLS
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- 5. Remover TODAS as políticas antigas (IMPORTANTE!)
DROP POLICY IF EXISTS "Todos podem visualizar categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir leitura de categorias para usuários autenticados" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem criar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem editar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem deletar categorias" ON public.categories;

-- 6. Criar políticas CORRETAS com TO authenticated
CREATE POLICY "Permitir leitura de categorias para usuários autenticados" 
ON public.categories 
FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Usuários autenticados podem criar categorias" 
ON public.categories 
FOR INSERT 
TO authenticated
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Usuários autenticados podem editar categorias" 
ON public.categories 
FOR UPDATE 
TO authenticated
USING (auth.uid() IS NOT NULL);

CREATE POLICY "Usuários autenticados podem deletar categorias" 
ON public.categories 
FOR DELETE 
TO authenticated
USING (auth.uid() IS NOT NULL);

-- 7. Inserir categorias padrão (método simples e seguro)
INSERT INTO public.categories (name, description) 
SELECT 'Eletrônicos', 'Produtos eletrônicos e tecnologia'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Eletrônicos');

INSERT INTO public.categories (name, description) 
SELECT 'Informática', 'Computadores, periféricos e acessórios'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Informática');

INSERT INTO public.categories (name, description) 
SELECT 'Casa e Jardim', 'Produtos para casa e jardim'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Casa e Jardim');

INSERT INTO public.categories (name, description) 
SELECT 'Roupas e Acessórios', 'Vestuário e acessórios pessoais'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Roupas e Acessórios');

INSERT INTO public.categories (name, description) 
SELECT 'Esportes', 'Equipamentos e acessórios esportivos'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Esportes');

INSERT INTO public.categories (name, description) 
SELECT 'Livros', 'Livros e material de leitura'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Livros');

INSERT INTO public.categories (name, description) 
SELECT 'Saúde e Beleza', 'Produtos de saúde e cosméticos'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Saúde e Beleza');

INSERT INTO public.categories (name, description) 
SELECT 'Alimentação', 'Alimentos e bebidas'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Alimentação');

-- 8. Verificar se as políticas foram criadas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'categories';

-- 9. Testar seleção
SELECT * FROM public.categories LIMIT 5;
