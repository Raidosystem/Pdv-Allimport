-- =============================================
-- ADICIONAR COLUNAS DE ENDEREÇO SEPARADAS
-- =============================================

-- Adicionar colunas de endereço detalhado
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS rua TEXT;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS numero TEXT;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS cidade TEXT;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS estado TEXT;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS cep TEXT;

SELECT '✅ Colunas de endereço adicionadas!' as status;

-- Verificar estrutura
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'clientes'
AND column_name IN ('endereco', 'rua', 'numero', 'cidade', 'estado', 'cep')
ORDER BY ordinal_position;

-- Ver cliente exemplo
SELECT 
    nome,
    endereco,
    rua,
    numero,
    cidade,
    estado,
    cep
FROM clientes
LIMIT 3;
