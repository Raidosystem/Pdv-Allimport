-- Migração para adicionar campos de endereço detalhados na tabela clientes
-- Data: 2025-08-02

-- Adicionar novos campos de endereço
ALTER TABLE clientes 
ADD COLUMN IF NOT EXISTS rua TEXT,
ADD COLUMN IF NOT EXISTS numero TEXT,
ADD COLUMN IF NOT EXISTS bairro TEXT,
ADD COLUMN IF NOT EXISTS cidade TEXT,
ADD COLUMN IF NOT EXISTS cep TEXT;

-- Comentários das colunas
COMMENT ON COLUMN clientes.rua IS 'Rua ou avenida do endereço';
COMMENT ON COLUMN clientes.numero IS 'Número do endereço';
COMMENT ON COLUMN clientes.bairro IS 'Bairro do endereço';
COMMENT ON COLUMN clientes.cidade IS 'Cidade do endereço';
COMMENT ON COLUMN clientes.cep IS 'CEP do endereço (formato: 00000-000)';

-- Índices para melhorar performance de busca
CREATE INDEX IF NOT EXISTS idx_clientes_cidade ON clientes(cidade);
CREATE INDEX IF NOT EXISTS idx_clientes_cep ON clientes(cep);

-- Função para concatenar endereço automaticamente (trigger)
CREATE OR REPLACE FUNCTION atualizar_endereco_completo()
RETURNS TRIGGER AS $$
BEGIN
    -- Concatena os campos de endereço em endereco
    NEW.endereco := CONCAT_WS(', ', 
        NULLIF(NEW.rua, ''),
        NULLIF(NEW.numero, ''),
        NULLIF(NEW.bairro, ''),
        NULLIF(NEW.cidade, ''),
        NULLIF(NEW.cep, '')
    );
    
    -- Se todos os campos estão vazios, deixa endereco como NULL
    IF NEW.endereco = '' THEN
        NEW.endereco := NULL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar endereço automaticamente
DROP TRIGGER IF EXISTS trigger_atualizar_endereco ON clientes;
CREATE TRIGGER trigger_atualizar_endereco
    BEFORE INSERT OR UPDATE ON clientes
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_endereco_completo();

-- Atualizar registros existentes (opcional - descomente se necessário)
-- UPDATE clientes SET endereco = endereco WHERE endereco IS NOT NULL;

COMMENT ON FUNCTION atualizar_endereco_completo() IS 'Concatena automaticamente os campos de endereço na coluna endereco';
COMMENT ON TRIGGER trigger_atualizar_endereco ON clientes IS 'Trigger para atualizar o campo endereco automaticamente';
