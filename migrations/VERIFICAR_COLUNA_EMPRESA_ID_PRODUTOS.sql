-- Verificar estrutura da tabela produtos
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'produtos'
ORDER BY ordinal_position;

-- Se não tiver empresa_id, adicionar:
-- ALTER TABLE produtos ADD COLUMN empresa_id UUID REFERENCES auth.users(id);
