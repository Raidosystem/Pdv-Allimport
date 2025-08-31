-- 🔍 VERIFICAR ESTRUTURA DA TABELA CLIENTES
-- Execute este script no Supabase SQL Editor para descobrir os campos reais

-- =====================================================
-- VERIFICAR ESTRUTURA DA TABELA
-- =====================================================

SELECT 'ESTRUTURA DA TABELA CLIENTES:' as info;

SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'clientes'
ORDER BY ordinal_position;

-- Contar registros atuais
SELECT 'REGISTROS ATUAIS:' as info, COUNT(*) as total FROM public.clientes;

-- Mostrar se existe algum registro para ver a estrutura
SELECT 'EXEMPLO DE ESTRUTURA (se houver dados):' as info;
SELECT * FROM public.clientes LIMIT 1;
