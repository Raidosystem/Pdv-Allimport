-- 🔍 DIAGNÓSTICO COMPLETO - Verificar se clientes foram inseridos
-- Execute este script no Supabase SQL Editor

-- =====================================================
-- VERIFICAÇÃO DIRETA NO BANCO
-- =====================================================

-- Contar clientes diretamente
SELECT 'CONTAGEM DIRETA:' as info, COUNT(*) as total FROM public.clientes;

-- Mostrar alguns clientes
SELECT 'ALGUNS CLIENTES:' as info;
SELECT nome, telefone, cidade FROM public.clientes LIMIT 5;

-- Verificar estrutura da tabela
SELECT 'ESTRUTURA DA TABELA:' as info;
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'clientes' AND table_schema = 'public';

-- Verificar RLS (Row Level Security)
SELECT 'STATUS RLS:' as info;
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'clientes';

-- Verificar políticas RLS
SELECT 'POLÍTICAS RLS:' as info;
SELECT policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'clientes';

-- Se não aparecer nada, RLS pode estar bloqueando
SELECT 'TESTE SEM RLS:' as info;
SET row_security = off;
SELECT COUNT(*) as total_sem_rls FROM public.clientes;
SELECT nome, telefone FROM public.clientes LIMIT 3;
