-- 🔧 SQL SIMPLIFICADO PARA CORRIGIR ERRO RLS DE CATEGORIAS
-- Execute este SQL no painel do Supabase (SQL Editor) linha por linha
-- ERRO 42501 DETECTADO: Política RLS está bloqueando inserções

-- PASSO 1: Criar tabela (se não existir)
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- PASSO 2: TEMPORARIAMENTE DESABILITAR RLS (para resolver o problema)
ALTER TABLE public.categories DISABLE ROW LEVEL SECURITY;

-- PASSO 3: Remover TODAS as políticas antigas
DROP POLICY IF EXISTS "Todos podem visualizar categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir leitura de categorias para usuários autenticados" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem criar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem editar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem deletar categorias" ON public.categories;

-- PASSO 4: Inserir algumas categorias de teste ANTES de habilitar RLS
INSERT INTO public.categories (name, description) VALUES ('Eletrônicos', 'Produtos eletrônicos e tecnologia');
INSERT INTO public.categories (name, description) VALUES ('Informática', 'Computadores, periféricos e acessórios');
INSERT INTO public.categories (name, description) VALUES ('Casa e Jardim', 'Produtos para casa e jardim');

-- PASSO 5: Agora HABILITAR RLS novamente
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- PASSO 6: Criar políticas MAIS PERMISSIVAS
CREATE POLICY "Permitir leitura de categorias" 
ON public.categories 
FOR SELECT 
USING (true);

CREATE POLICY "Permitir inserção de categorias" 
ON public.categories 
FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Permitir edição de categorias" 
ON public.categories 
FOR UPDATE 
USING (true);

CREATE POLICY "Permitir exclusão de categorias" 
ON public.categories 
FOR DELETE 
USING (true);

-- PASSO 7: Verificar se as políticas foram criadas
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename = 'categories';

-- PASSO 8: Testar inserção manual (deve funcionar agora)
INSERT INTO public.categories (name, description) VALUES ('Teste Manual', 'Categoria de teste');

-- PASSO 9: Verificar dados
SELECT * FROM public.categories;

-- PASSO 10: (OPCIONAL) Se quiser políticas mais restritivas depois dos testes
-- Descomente estas linhas APENAS se estiver funcionando perfeitamente:

-- DROP POLICY "Permitir inserção de categorias" ON public.categories;
-- CREATE POLICY "Usuários autenticados podem criar categorias" 
-- ON public.categories 
-- FOR INSERT 
-- TO authenticated
-- WITH CHECK (auth.uid() IS NOT NULL);
