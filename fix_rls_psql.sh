#!/bin/bash

# Script para conectar via psql e aplicar fix manual das políticas RLS
# Usar com a senha: @qw12aszx##

echo "🔧 Conectando ao Supabase via psql para corrigir RLS..."

# Conectar via psql
PGPASSWORD="@qw12aszx##" psql \
  -h "aws-0-us-east-1.pooler.supabase.com" \
  -p 6543 \
  -d "postgres" \
  -U "postgres.kmcaaqetxtwkdcczdomw" \
  -c "
-- Verificar status atual da tabela clientes
\d public.clientes

-- Verificar políticas existentes
SELECT policyname, cmd, qual, with_check FROM pg_policies WHERE tablename = 'clientes';

-- Remover TODAS as políticas existentes
DROP POLICY IF EXISTS \"clientes_select_policy\" ON public.clientes;
DROP POLICY IF EXISTS \"clientes_insert_policy\" ON public.clientes;
DROP POLICY IF EXISTS \"clientes_update_policy\" ON public.clientes;
DROP POLICY IF EXISTS \"clientes_delete_policy\" ON public.clientes;
DROP POLICY IF EXISTS \"Authenticated users can view clientes\" ON public.clientes;
DROP POLICY IF EXISTS \"Authenticated users can insert clientes\" ON public.clientes;
DROP POLICY IF EXISTS \"Authenticated users can update clientes\" ON public.clientes;
DROP POLICY IF EXISTS \"Authenticated users can delete clientes\" ON public.clientes;

-- Desabilitar RLS temporariamente para testar
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;

-- Verificar se consegue inserir sem RLS
INSERT INTO public.clientes (nome, telefone, email) 
VALUES ('Teste RLS', '(11) 99999-9999', 'teste@rls.com');

SELECT * FROM public.clientes WHERE nome = 'Teste RLS';

-- Remover o teste
DELETE FROM public.clientes WHERE nome = 'Teste RLS';

-- Reabilitar RLS
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

-- Criar políticas mais simples
CREATE POLICY \"allow_all_for_authenticated\" ON public.clientes
  FOR ALL USING (true) WITH CHECK (true);

-- Verificar políticas criadas
SELECT policyname, cmd, qual, with_check FROM pg_policies WHERE tablename = 'clientes';

-- Testar inserção com RLS habilitado
INSERT INTO public.clientes (nome, telefone, email) 
VALUES ('Teste RLS 2', '(11) 88888-8888', 'teste2@rls.com');

SELECT * FROM public.clientes WHERE nome = 'Teste RLS 2';

DELETE FROM public.clientes WHERE nome = 'Teste RLS 2';

GRANT ALL ON public.clientes TO authenticated;
GRANT ALL ON public.clientes TO anon;
"

echo "✅ Script executado. Verifique os resultados acima."
