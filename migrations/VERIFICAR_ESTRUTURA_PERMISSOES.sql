-- =============================================
-- VERIFICAR ESTRUTURA DA TABELA permissoes
-- =============================================

-- Ver estrutura completa da tabela permissoes
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'permissoes'
ORDER BY ordinal_position;

-- Ver todas as permissões existentes
SELECT * FROM public.permissoes ORDER BY recurso, acao;

-- Contar permissões por recurso
SELECT 
    recurso,
    COUNT(*) as total_acoes
FROM public.permissoes
GROUP BY recurso
ORDER BY recurso;
