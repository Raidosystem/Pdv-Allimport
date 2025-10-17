-- Verificar estrutura da tabela funcao_permissoes
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'funcao_permissoes'
ORDER BY ordinal_position;

-- Verificar estrutura da tabela audit_logs
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'audit_logs'
ORDER BY ordinal_position;

-- Ver algumas linhas de exemplo de funcao_permissoes
SELECT * FROM funcao_permissoes LIMIT 3;
