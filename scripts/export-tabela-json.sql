-- Execute no Supabase SQL Editor para exportar tabela como JSON
-- Substitua 'empresas' pela tabela que deseja exportar

SELECT json_agg(row_to_json(t)) 
FROM empresas t;

-- Para múltiplas tabelas:
SELECT 'empresas' as tabela, json_agg(row_to_json(t)) as dados FROM empresas t
UNION ALL
SELECT 'produtos', json_agg(row_to_json(t)) FROM produtos t
UNION ALL
SELECT 'clientes', json_agg(row_to_json(t)) FROM clientes t;
