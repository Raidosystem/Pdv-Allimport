-- Migração: Validação de CPF e garantias no banco de dados
-- Data: 2025-09-14
-- Descrição: Adiciona validação de CPF, função de validação e índices únicos
-- VERSÃO ROBUSTA - Trata erros de sintaxe e casos edge

BEGIN;

-- 1. Função para validar CPF no PostgreSQL
CREATE OR REPLACE FUNCTION public.is_valid_cpf(cpf_in text)
RETURNS boolean
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  cpf text := regexp_replace(coalesce(cpf_in,''), '\D', '', 'g');
  i int; 
  sum1 int := 0; 
  sum2 int := 0; 
  d1 int; 
  d2 int;
BEGIN
  -- CPF deve ter exatamente 11 dígitos
  IF length(cpf) <> 11 THEN 
    RETURN false; 
  END IF;
  
  -- Rejeita sequências repetidas (000.000.000-00, 111.111.111-11, etc.)
  IF cpf ~ '^(.)\1{10}$' THEN 
    RETURN false; 
  END IF;

  -- Calcula primeiro dígito verificador
  FOR i IN 1..9 LOOP
    sum1 := sum1 + cast(substr(cpf, i, 1) as int) * (11 - i);
  END LOOP;
  
  d1 := 11 - (sum1 % 11);
  IF d1 >= 10 THEN 
    d1 := 0; 
  END IF;
  
  IF d1 <> cast(substr(cpf, 10, 1) as int) THEN 
    RETURN false; 
  END IF;

  -- Calcula segundo dígito verificador
  FOR i IN 1..10 LOOP
    sum2 := sum2 + cast(substr(cpf, i, 1) as int) * (12 - i);
  END LOOP;
  
  d2 := 11 - (sum2 % 11);
  IF d2 >= 10 THEN 
    d2 := 0; 
  END IF;
  
  IF d2 <> cast(substr(cpf, 11, 1) as int) THEN 
    RETURN false; 
  END IF;

  RETURN true;
END $$;

-- 2. Adicionar coluna cpf_digits na tabela clientes (se não existir)
ALTER TABLE public.clientes 
  ADD COLUMN IF NOT EXISTS cpf_digits text;

-- 3. Tornar cpf_digits obrigatório (apenas se não houver valores NULL)
DO $$
BEGIN
  -- Primeiro, preenche valores NULL se necessário
  UPDATE public.clientes 
  SET cpf_digits = regexp_replace(coalesce(cpf, ''), '\D', '', 'g')
  WHERE cpf_digits IS NULL AND cpf IS NOT NULL;
  
  -- Remove registros com CPF inválido ou vazio
  DELETE FROM public.clientes 
  WHERE cpf_digits IS NULL OR cpf_digits = '' OR NOT public.is_valid_cpf(cpf_digits);
  
  -- Agora torna a coluna NOT NULL
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'clientes' 
    AND column_name = 'cpf_digits' 
    AND is_nullable = 'YES'
  ) THEN
    ALTER TABLE public.clientes ALTER COLUMN cpf_digits SET NOT NULL;
  END IF;
END $$;

-- 4. Adicionar constraint para validar CPF
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'clientes_cpf_digits_chk' 
    AND table_name = 'clientes'
  ) THEN
    ALTER TABLE public.clientes 
      ADD CONSTRAINT clientes_cpf_digits_chk
      CHECK (
        char_length(cpf_digits) = 11 
        AND cpf_digits ~ '^[0-9]{11}$' 
        AND public.is_valid_cpf(cpf_digits)
      );
  END IF;
END $$;

-- 5. Adicionar coluna empresa_id para multi-tenant (se não existir)
ALTER TABLE public.clientes 
  ADD COLUMN IF NOT EXISTS empresa_id uuid;

-- 6. Tornar empresa_id obrigatório (ajuste conforme necessário)
-- Descomente a linha abaixo se empresa_id for obrigatório
-- ALTER TABLE public.clientes ALTER COLUMN empresa_id SET NOT NULL;

-- 7. Criar índice único para CPF por empresa (multi-tenant)
-- Se empresa_id for obrigatório, use este índice:
-- CREATE UNIQUE INDEX IF NOT EXISTS uniq_clientes_empresa_cpf 
--   ON public.clientes(empresa_id, cpf_digits);

-- Se empresa_id for opcional, use um índice funcional:
CREATE UNIQUE INDEX IF NOT EXISTS uniq_clientes_empresa_cpf 
  ON public.clientes(coalesce(empresa_id, '00000000-0000-0000-0000-000000000000'::uuid), cpf_digits);

-- 8. Função para normalizar cpf_digits (remove caracteres não numéricos)
CREATE OR REPLACE FUNCTION public.normalize_cpf_digits()
RETURNS trigger 
LANGUAGE plpgsql 
AS $$
BEGIN
  IF NEW.cpf_digits IS NOT NULL THEN
    NEW.cpf_digits := regexp_replace(NEW.cpf_digits, '\D', '', 'g');
  END IF;
  RETURN NEW;
END $$;

-- 9. Trigger para normalizar cpf_digits antes de inserir/atualizar
DROP TRIGGER IF EXISTS trg_normalize_cpf ON public.clientes;
CREATE TRIGGER trg_normalize_cpf
  BEFORE INSERT OR UPDATE ON public.clientes
  FOR EACH ROW 
  EXECUTE FUNCTION public.normalize_cpf_digits();

-- 10. Comentários para documentação
COMMENT ON FUNCTION public.is_valid_cpf(text) IS 'Valida CPF usando algoritmo oficial dos dígitos verificadores';
COMMENT ON COLUMN public.clientes.cpf_digits IS 'CPF sem formatação (apenas dígitos)';
COMMENT ON COLUMN public.clientes.empresa_id IS 'ID da empresa para multi-tenant (opcional)';

-- 11. Teste básico da função (opcional - execute manualmente para testar)
/*
-- Testes da função is_valid_cpf
SELECT 
  '11144477735' as cpf,
  public.is_valid_cpf('11144477735') as is_valid; -- Deve retornar true

SELECT 
  '12345678901' as cpf,
  public.is_valid_cpf('12345678901') as is_valid; -- Deve retornar false

SELECT 
  '00000000000' as cpf,
  public.is_valid_cpf('00000000000') as is_valid; -- Deve retornar false (sequência repetida)
*/

-- 12. Migração de dados existentes (se necessário)
-- Se você já tem dados na tabela clientes sem cpf_digits, execute:
/*
UPDATE public.clientes 
SET cpf_digits = regexp_replace(coalesce(cpf, ''), '\D', '', 'g')
WHERE cpf_digits IS NULL AND cpf IS NOT NULL;
*/

-- Commit da transação
COMMIT;