-- =============================================
-- CRIAR TABELA FORNECEDORES
-- =============================================

-- 1. Criar tabela fornecedores
CREATE TABLE IF NOT EXISTS fornecedores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome TEXT NOT NULL,
    cnpj TEXT,
    telefone TEXT,
    email TEXT,
    endereco TEXT,
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_fornecedores_nome ON fornecedores(nome);
CREATE INDEX IF NOT EXISTS idx_fornecedores_ativo ON fornecedores(ativo);

-- 3. Habilitar RLS (Row Level Security)
ALTER TABLE fornecedores ENABLE ROW LEVEL SECURITY;

-- 4. Criar política para permitir SELECT para todos usuários autenticados
CREATE POLICY "Permitir SELECT fornecedores" ON fornecedores
    FOR SELECT
    USING (true);

-- 5. Criar política para permitir INSERT para usuários autenticados
CREATE POLICY "Permitir INSERT fornecedores" ON fornecedores
    FOR INSERT
    WITH CHECK (true);

-- 6. Criar política para permitir UPDATE para usuários autenticados
CREATE POLICY "Permitir UPDATE fornecedores" ON fornecedores
    FOR UPDATE
    USING (true);

-- 7. Criar política para permitir DELETE para usuários autenticados
CREATE POLICY "Permitir DELETE fornecedores" ON fornecedores
    FOR DELETE
    USING (true);

SELECT '✅ Tabela fornecedores criada com sucesso!' as status;

-- 8. Verificar estrutura da tabela
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'fornecedores'
ORDER BY ordinal_position;
