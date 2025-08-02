-- 🚀 SOLUÇÃO RÁPIDA: REMOVER RLS COMPLETAMENTE (MAIS SIMPLES)
-- Execute no Supabase SQL Editor

-- PASSO 1: Desabilitar RLS completamente
ALTER TABLE public.categories DISABLE ROW LEVEL SECURITY;

-- PASSO 2: Remover todas as políticas
DROP POLICY IF EXISTS "Todos podem visualizar categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir leitura de categorias para usuários autenticados" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem criar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem editar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem deletar categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir leitura de categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir inserção de categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir edição de categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir exclusão de categorias" ON public.categories;

-- PASSO 3: Testar inserção (deve funcionar agora)
INSERT INTO public.categories (name, description) VALUES ('Teste Funcionando', 'RLS desabilitado');

-- PASSO 4: Verificar
SELECT * FROM public.categories;

-- NOTA: Sem RLS, qualquer pessoa pode acessar a tabela
-- Para projetos simples isso é aceitável
-- Para projetos em produção, você pode reativar RLS depois que estiver funcionando
