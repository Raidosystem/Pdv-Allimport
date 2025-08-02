-- 🧹 LIMPEZA COMPLETA: Remover todas as políticas e triggers
-- Execute este script ANTES dos outros

-- 1. Desabilitar RLS em todas as tabelas
ALTER TABLE public.caixa DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa DISABLE ROW LEVEL SECURITY;

-- Se clientes existir, desabilitar também
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'clientes' AND table_schema = 'public') THEN
        ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- 2. Remover TODAS as políticas existentes (sem exceção)
DO $$
DECLARE
    pol_record RECORD;
BEGIN
    -- Buscar e remover todas as políticas das tabelas de interesse
    FOR pol_record IN 
        SELECT schemaname, tablename, policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename IN ('caixa', 'movimentacoes_caixa', 'clientes', 'cash_registers')
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
                      pol_record.policyname, 
                      pol_record.schemaname, 
                      pol_record.tablename);
    END LOOP;
END $$;

-- 3. Remover todos os triggers das tabelas
DROP TRIGGER IF EXISTS update_caixa_updated_at ON public.caixa;
DROP TRIGGER IF EXISTS update_cash_registers_updated_at ON public.caixa;

-- 4. Verificar se as tabelas existem
SELECT 
    'TABELAS EXISTENTES:' as info,
    table_name
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('caixa', 'movimentacoes_caixa', 'clientes', 'cash_registers')
ORDER BY table_name;

-- 5. Verificar colunas atuais
SELECT 
    'ESTRUTURA ATUAL:' as info,
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
AND table_name IN ('caixa', 'movimentacoes_caixa')
AND column_name LIKE '%user%'
ORDER BY table_name, column_name;

-- 6. Verificar se ainda há políticas
SELECT 
    'POLÍTICAS RESTANTES:' as info,
    COUNT(*)::text as total
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN ('caixa', 'movimentacoes_caixa', 'clientes');

SELECT '🧹 LIMPEZA CONCLUÍDA! Agora execute RENOMEAR_SIMPLES.sql novamente.' as resultado;
