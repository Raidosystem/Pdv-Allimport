-- Verificar estrutura da tabela empresas
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'empresas'
ORDER BY ordinal_position;

-- Verificar dados atuais
SELECT * FROM public.empresas LIMIT 5;
