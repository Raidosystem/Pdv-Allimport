-- 🔍 DIAGNÓSTICO SIMPLES - Verificar clientes inseridos
-- Execute este script no Supabase SQL Editor

-- =====================================================
-- VERIFICAÇÕES BÁSICAS
-- =====================================================

-- 1. Contar clientes diretamente
SELECT 'TOTAL DE CLIENTES:' as info, COUNT(*) as total FROM public.clientes;

-- 2. Mostrar primeiros 5 clientes
SELECT 'PRIMEIROS 5 CLIENTES:' as info;
SELECT nome, telefone, cidade, estado FROM public.clientes LIMIT 5;

-- 3. Verificar se tabela tem dados
SELECT 'VERIFICAÇÃO BÁSICA:' as info;
SELECT 
  CASE 
    WHEN COUNT(*) > 0 THEN 'CLIENTES ENCONTRADOS ✅'
    ELSE 'TABELA VAZIA ❌'
  END as status
FROM public.clientes;

-- 4. Buscar clientes específicos do backup
SELECT 'CLIENTES DO BACKUP:' as info;
SELECT nome, telefone FROM public.clientes 
WHERE nome IN ('ANTONIO CLAUDIO FIGUEIRA', 'EDVANIA DA SILVA', 'SAULO DE TARSO')
LIMIT 5;

-- 5. Contar por cidade (estatística do backup)
SELECT 'CLIENTES POR CIDADE:' as info;
SELECT cidade, COUNT(*) as total 
FROM public.clientes 
WHERE cidade IS NOT NULL AND cidade != ''
GROUP BY cidade 
ORDER BY total DESC 
LIMIT 5;

-- 6. Verificar user_id específico
SELECT 'CLIENTES DO USER ALL IMPORT:' as info;
SELECT COUNT(*) as total 
FROM public.clientes 
WHERE user_id = '28e56a69-90df-4852-b663-9b02f4358c6f';

SELECT 'DIAGNÓSTICO CONCLUÍDO! ✅' as resultado;
