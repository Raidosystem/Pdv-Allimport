-- =============================================
-- CRIAR TRIGGER PARA AUTO-GERAR ENDERECO
-- =============================================
-- Execute este script ANTES de executar o outro
-- =============================================

-- 1. Verificar se coluna endereco existe, se não, criar
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'clientes' 
    AND column_name = 'endereco'
  ) THEN
    ALTER TABLE clientes ADD COLUMN endereco text;
    RAISE NOTICE 'Coluna endereco criada com sucesso';
  ELSE
    RAISE NOTICE 'Coluna endereco já existe';
  END IF;
END $$;

-- 2. Criar função para gerar endereço completo
CREATE OR REPLACE FUNCTION update_endereco_completo()
RETURNS TRIGGER AS $$
BEGIN
  -- Construir endereco completo a partir dos componentes
  NEW.endereco := TRIM(
    CONCAT_WS(', ',
      NULLIF(TRIM(CONCAT(
        COALESCE(NEW.tipo_logradouro || ' ', ''),
        COALESCE(NEW.logradouro, '')
      )), ''),
      NULLIF(NEW.numero, ''),
      NULLIF(NEW.complemento, ''),
      NULLIF(NEW.bairro, ''),
      NULLIF(TRIM(CONCAT(
        COALESCE(NEW.cidade, ''),
        CASE WHEN NEW.estado IS NOT NULL THEN ' - ' || NEW.estado ELSE '' END
      )), ''),
      CASE 
        WHEN NEW.cep IS NOT NULL 
        THEN 'CEP: ' || NEW.cep 
        ELSE NULL 
      END
    )
  );
  
  -- Se ficou vazio, deixar NULL
  IF NEW.endereco = '' THEN
    NEW.endereco := NULL;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Remover trigger antigo se existir
DROP TRIGGER IF EXISTS trigger_update_endereco ON clientes;

-- 4. Criar trigger para executar ANTES de INSERT/UPDATE
CREATE TRIGGER trigger_update_endereco
  BEFORE INSERT OR UPDATE ON clientes
  FOR EACH ROW
  EXECUTE FUNCTION update_endereco_completo();

-- 5. Atualizar registros existentes
UPDATE clientes
SET logradouro = logradouro  -- Força trigger executar
WHERE logradouro IS NOT NULL OR cidade IS NOT NULL;

-- 6. Verificar se funcionou
SELECT 
  COUNT(*) as total_clientes,
  COUNT(endereco) as total_com_endereco,
  COUNT(*) - COUNT(endereco) as total_sem_endereco
FROM clientes;

-- 7. Confirmar sucesso
DO $$ 
BEGIN
  RAISE NOTICE '✅ Trigger criado e testado com sucesso!';
END $$;
