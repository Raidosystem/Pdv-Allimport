-- ============================================
-- ATUALIZAR TABELA EMPRESAS COM CAMPOS DE ENDEREÇO SEPARADOS
-- ============================================

-- Adicionar colunas de endereço separadas
ALTER TABLE empresas
  ADD COLUMN IF NOT EXISTS logradouro TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS numero TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS complemento TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS bairro TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS estado TEXT DEFAULT '',
  ADD COLUMN IF NOT EXISTS uf TEXT DEFAULT '';

-- Renomear coluna logo para logo_url (padronizar nomenclatura)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'empresas' AND column_name = 'logo'
  ) THEN
    ALTER TABLE empresas RENAME COLUMN logo TO logo_url;
  END IF;
END $$;

-- Comentários nas colunas para documentação
COMMENT ON COLUMN empresas.logradouro IS 'Rua, Avenida, etc.';
COMMENT ON COLUMN empresas.numero IS 'Número do endereço';
COMMENT ON COLUMN empresas.complemento IS 'Apartamento, Sala, Bloco, etc.';
COMMENT ON COLUMN empresas.bairro IS 'Bairro';
COMMENT ON COLUMN empresas.cidade IS 'Cidade';
COMMENT ON COLUMN empresas.estado IS 'Cidade - UF (ex: São Paulo - SP)';
COMMENT ON COLUMN empresas.uf IS 'Sigla do estado (SP, RJ, MG, etc.)';
COMMENT ON COLUMN empresas.cep IS 'CEP no formato 00000-000';

-- Atualizar timestamp de modificação
CREATE OR REPLACE FUNCTION update_empresas_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recriar trigger se já existir
DROP TRIGGER IF EXISTS trigger_update_empresas_timestamp ON empresas;
CREATE TRIGGER trigger_update_empresas_timestamp
  BEFORE UPDATE ON empresas
  FOR EACH ROW
  EXECUTE FUNCTION update_empresas_updated_at();

-- Verificar estrutura atualizada
SELECT 
  column_name,
  data_type,
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'empresas'
ORDER BY ordinal_position;
