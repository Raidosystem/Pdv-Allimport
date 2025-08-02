# 🔧 SOLUÇÃO: Erro RLS "new row violates row-level security policy"

## 🚨 Problema Identificado
O erro indica que as políticas RLS (Row Level Security) estão bloqueando a inserção de categorias.

## ✅ SOLUÇÃO RÁPIDA

### 1. Acesse o Painel do Supabase
- Vá para: https://supabase.com/dashboard
- Selecione seu projeto
- Clique em "SQL Editor" no menu lateral

### 2. Execute este SQL:

```sql
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

-- 5. Remover políticas antigas (se existirem)
DROP POLICY IF EXISTS "Todos podem visualizar categorias" ON public.categories;
DROP POLICY IF EXISTS "Permitir leitura de categorias para usuários autenticados" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem criar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem editar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem deletar categorias" ON public.categories;

-- 6. Criar políticas corretas
CREATE POLICY "Permitir leitura de categorias para usuários autenticados" 
ON public.categories FOR SELECT 
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

-- 7. Inserir categorias padrão
INSERT INTO public.categories (name, description) VALUES
  ('Eletrônicos', 'Produtos eletrônicos e tecnologia'),
  ('Informática', 'Computadores, periféricos e acessórios'),
  ('Casa e Jardim', 'Produtos para casa e jardim'),
  ('Roupas e Acessórios', 'Vestuário e acessórios pessoais'),
  ('Esportes', 'Equipamentos e acessórios esportivos'),
  ('Livros', 'Livros e material de leitura'),
  ('Saúde e Beleza', 'Produtos de saúde e cosméticos'),
  ('Alimentação', 'Alimentos e bebidas')
ON CONFLICT (name) DO NOTHING;
```

### 3. Verificar se funcionou:

```sql
-- Testar seleção
SELECT * FROM public.categories;

-- Verificar políticas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'categories';

-- Testar inserção (rode este depois de fazer login na aplicação)
INSERT INTO public.categories (name, description) 
VALUES ('Teste Manual', 'Categoria de teste criada via SQL');
```

## 🧪 Teste na Aplicação

Após executar o SQL:

1. Acesse: `http://localhost:5174/test-categorias`
2. Clique em "🔧 Corrigir Políticas RLS"
3. Teste criar uma categoria manualmente

## 📋 Explicação do Problema

- **auth.role() = 'authenticated'** ❌ (método antigo)
- **auth.uid() IS NOT NULL** ✅ (método correto)

A função `auth.uid()` verifica se há um usuário logado, enquanto `auth.role()` pode não funcionar como esperado em algumas configurações.

## 🚀 Resultado Esperado

Após a correção, você deve conseguir:
- ✅ Criar categorias normalmente
- ✅ Ver mensagem de sucesso
- ✅ Categorias aparecendo na lista

Se ainda houver erro, verifique:
1. Se o usuário está realmente logado
2. Se as variáveis de ambiente estão corretas
3. Se a conexão com Supabase está funcionando
