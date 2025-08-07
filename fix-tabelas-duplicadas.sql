-- Script para remover tabelas duplicadas de caixa
-- Execute com conexão admin do Supabase

-- 1. Verificar dependências antes de remover
SELECT 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND ccu.table_name = 'cash_registers';

-- 2. Remover tabela cash_registers duplicada
DROP TABLE IF EXISTS public.cash_registers CASCADE;

-- 3. Verificar se tabela sales faz referência incorreta
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'sales' 
  AND column_name LIKE '%cash_register%';

-- 4. Se existe, corrigir referência da tabela sales
-- ALTER TABLE public.sales DROP COLUMN IF EXISTS cash_register_id;
-- ALTER TABLE public.sales ADD COLUMN caixa_id UUID REFERENCES public.caixa(id);

-- 5. Verificar limpeza
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name LIKE '%cash%' 
  OR table_name LIKE '%caixa%';

-- 6. Confirmar estrutura final
SELECT 
  t.table_name,
  COUNT(c.column_name) as total_colunas
FROM information_schema.tables t
LEFT JOIN information_schema.columns c ON t.table_name = c.table_name
WHERE t.table_schema = 'public' 
  AND t.table_name IN ('caixa', 'movimentacoes_caixa')
GROUP BY t.table_name
ORDER BY t.table_name;
