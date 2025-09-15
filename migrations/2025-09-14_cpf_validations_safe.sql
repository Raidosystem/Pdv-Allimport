-- Migração SEGURA: Validação de CPF e garantias no banco de dados
-- Data: 2025-09-14
-- Descrição: Versão segura que verifica existência de tabelas e colunas
-- EXECUTE ESTA VERSÃO SE A ANTERIOR DEU ERRO

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

-- 2. Verificar se tabela clientes existe e criar se necessário
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'clientes'
  ) THEN
    CREATE TABLE public.clientes (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      nome text NOT NULL,
      cpf_digits text,
      email text,
      telefone text,
      endereco text,
      tipo text NOT NULL DEFAULT 'Física',
      empresa_id uuid,
      ativo boolean DEFAULT true,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );
    RAISE NOTICE 'Tabela clientes criada com sucesso';
  ELSE
    RAISE NOTICE 'Tabela clientes já existe';
  END IF;
END $$;

-- 3. Adicionar coluna cpf_digits se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'clientes' 
    AND column_name = 'cpf_digits'
  ) THEN
    ALTER TABLE public.clientes ADD COLUMN cpf_digits text;
    RAISE NOTICE 'Coluna cpf_digits adicionada';
  ELSE
    RAISE NOTICE 'Coluna cpf_digits já existe';
  END IF;
END $$;

-- 4. Adicionar coluna empresa_id se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'clientes' 
    AND column_name = 'empresa_id'
  ) THEN
    ALTER TABLE public.clientes ADD COLUMN empresa_id uuid;
    RAISE NOTICE 'Coluna empresa_id adicionada';
  ELSE
    RAISE NOTICE 'Coluna empresa_id já existe';
  END IF;
END $$;

-- 5. Migrar dados existentes (preencher cpf_digits se houver coluna cpf)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'clientes' 
    AND column_name = 'cpf'
  ) THEN
    UPDATE public.clientes 
    SET cpf_digits = regexp_replace(coalesce(cpf, ''), '\D', '', 'g')
    WHERE cpf_digits IS NULL AND cpf IS NOT NULL;
    RAISE NOTICE 'Dados de CPF migrados da coluna cpf para cpf_digits';
  END IF;
END $$;

-- 6. Tratar registros com CPF inválido (preservando foreign keys)
DO $$
DECLARE
  updated_count int;
  deleted_count int;
BEGIN
  -- Primeiro, tenta corrigir CPFs que podem ser válidos (remove formatação)
  UPDATE public.clientes 
  SET cpf_digits = regexp_replace(coalesce(cpf_digits, ''), '\D', '', 'g')
  WHERE cpf_digits IS NOT NULL 
    AND cpf_digits <> ''
    AND cpf_digits ~ '\D'; -- Contém caracteres não numéricos
    
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE 'Normalizados % registros de CPF (removida formatação)', updated_count;

  -- Desativar registros com CPF inválido que têm ordens de serviço
  UPDATE public.clientes 
  SET ativo = false
  WHERE (cpf_digits IS NULL 
     OR cpf_digits = '' 
     OR length(cpf_digits) <> 11
     OR NOT public.is_valid_cpf(cpf_digits))
    AND EXISTS (
      SELECT 1 FROM ordens_servico os WHERE os.cliente_id = clientes.id
    );
    
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RAISE NOTICE 'Desativados % clientes com CPF inválido (possuem ordens de serviço)', updated_count;

  -- Deletar apenas registros sem ordens de serviço
  DELETE FROM public.clientes 
  WHERE (cpf_digits IS NULL 
     OR cpf_digits = '' 
     OR length(cpf_digits) <> 11
     OR NOT public.is_valid_cpf(cpf_digits))
    AND NOT EXISTS (
      SELECT 1 FROM ordens_servico os WHERE os.cliente_id = clientes.id
    );
     
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RAISE NOTICE 'Removidos % registros com CPF inválido (sem ordens de serviço)', deleted_count;
END $$;

-- 7. Tornar cpf_digits obrigatório (apenas se todos os CPFs forem válidos)
DO $$
DECLARE
  invalid_count int;
  null_count int;
BEGIN
  -- Primeiro, conta quantos registros têm cpf_digits NULL
  SELECT COUNT(*) INTO null_count
  FROM public.clientes 
  WHERE cpf_digits IS NULL;

  IF null_count > 0 THEN
    RAISE NOTICE 'Encontrados % registros com cpf_digits NULL. Tentando corrigir...', null_count;
    
    -- Tenta preencher de outras colunas se existirem
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'clientes' AND column_name = 'cpf'
    ) THEN
      UPDATE public.clientes 
      SET cpf_digits = regexp_replace(coalesce(cpf, ''), '\D', '', 'g')
      WHERE cpf_digits IS NULL AND cpf IS NOT NULL AND cpf <> '';
      
      GET DIAGNOSTICS invalid_count = ROW_COUNT;
      RAISE NOTICE 'Preenchidos % registros de cpf_digits a partir da coluna cpf', invalid_count;
    END IF;
    
    -- Remove ou desativa registros que ainda têm NULL
    UPDATE public.clientes 
    SET ativo = false
    WHERE cpf_digits IS NULL 
      AND EXISTS (
        SELECT 1 FROM ordens_servico os WHERE os.cliente_id = clientes.id
      );
      
    GET DIAGNOSTICS invalid_count = ROW_COUNT;
    RAISE NOTICE 'Desativados % clientes com CPF NULL (possuem ordens de serviço)', invalid_count;
    
    DELETE FROM public.clientes 
    WHERE cpf_digits IS NULL 
      AND NOT EXISTS (
        SELECT 1 FROM ordens_servico os WHERE os.cliente_id = clientes.id
      );
      
    GET DIAGNOSTICS invalid_count = ROW_COUNT;
    RAISE NOTICE 'Removidos % clientes com CPF NULL (sem ordens de serviço)', invalid_count;
  END IF;

  -- Agora conta registros ativos com CPF inválido (incluindo NULL restantes)
  SELECT COUNT(*) INTO invalid_count
  FROM public.clientes 
  WHERE ativo = true 
    AND (cpf_digits IS NULL 
         OR cpf_digits = '' 
         OR length(cpf_digits) <> 11
         OR NOT public.is_valid_cpf(cpf_digits));

  IF invalid_count > 0 THEN
    RAISE NOTICE 'AVISO: % clientes ativos ainda têm CPF inválido/NULL. NOT NULL não será aplicado.', invalid_count;
    RAISE NOTICE 'Corrija os CPFs manualmente e execute: ALTER TABLE clientes ALTER COLUMN cpf_digits SET NOT NULL;';
  ELSE
    -- Verifica se ainda há algum NULL restante
    SELECT COUNT(*) INTO null_count FROM public.clientes WHERE cpf_digits IS NULL;
    
    IF null_count > 0 THEN
      RAISE NOTICE 'AVISO: % registros ainda têm cpf_digits NULL (inativos). NOT NULL não será aplicado.', null_count;
    ELSE
      IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'clientes' 
        AND column_name = 'cpf_digits' 
        AND is_nullable = 'YES'
      ) THEN
        ALTER TABLE public.clientes ALTER COLUMN cpf_digits SET NOT NULL;
        RAISE NOTICE 'Coluna cpf_digits agora é obrigatória';
      ELSE
        RAISE NOTICE 'Coluna cpf_digits já é obrigatória';
      END IF;
    END IF;
  END IF;
END $$;

-- 8. Adicionar constraint de validação (apenas para registros ativos)
DO $$
DECLARE
  invalid_count int;
  null_count int;
BEGIN
  -- Conta registros ativos com CPF inválido ou NULL
  SELECT COUNT(*) INTO invalid_count
  FROM public.clientes 
  WHERE ativo = true 
    AND (cpf_digits IS NULL 
         OR cpf_digits = '' 
         OR length(cpf_digits) <> 11
         OR NOT public.is_valid_cpf(cpf_digits));

  -- Conta registros com NULL (incluindo inativos)
  SELECT COUNT(*) INTO null_count FROM public.clientes WHERE cpf_digits IS NULL;

  IF invalid_count > 0 OR null_count > 0 THEN
    RAISE NOTICE 'AVISO: % clientes ativos têm CPF inválido, % registros têm NULL. Constraint não será aplicada.', invalid_count, null_count;
    RAISE NOTICE 'Corrija os CPFs e execute: ALTER TABLE clientes ADD CONSTRAINT clientes_cpf_digits_chk CHECK (...);';
  ELSE
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.table_constraints 
      WHERE constraint_name = 'clientes_cpf_digits_chk' 
      AND table_name = 'clientes'
    ) THEN
      ALTER TABLE public.clientes 
        ADD CONSTRAINT clientes_cpf_digits_chk
        CHECK (
          ativo = false OR (
            cpf_digits IS NOT NULL AND
            char_length(cpf_digits) = 11 
            AND cpf_digits ~ '^[0-9]{11}$' 
            AND public.is_valid_cpf(cpf_digits)
          )
        );
      RAISE NOTICE 'Constraint de validação CPF adicionada (apenas para ativos)';
    ELSE
      RAISE NOTICE 'Constraint de validação CPF já existe';
    END IF;
  END IF;
END $$;

-- 9. Criar índice único para CPF por empresa (apenas registros ativos com CPF válido)
DO $$
DECLARE
  null_count int;
BEGIN
  -- Verifica se há registros ativos com cpf_digits NULL
  SELECT COUNT(*) INTO null_count 
  FROM public.clientes 
  WHERE ativo = true AND cpf_digits IS NULL;

  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE indexname = 'uniq_clientes_empresa_cpf'
  ) THEN
    CREATE UNIQUE INDEX uniq_clientes_empresa_cpf 
      ON public.clientes(coalesce(empresa_id, '00000000-0000-0000-0000-000000000000'::uuid), cpf_digits)
      WHERE ativo = true AND cpf_digits IS NOT NULL;
    RAISE NOTICE 'Índice único CPF/empresa criado (apenas para ativos com CPF válido)';
    
    IF null_count > 0 THEN
      RAISE NOTICE 'AVISO: % clientes ativos têm cpf_digits NULL e não estão no índice único', null_count;
    END IF;
  ELSE
    RAISE NOTICE 'Índice único CPF/empresa já existe';
  END IF;
END $$;

-- 10. Função para normalizar cpf_digits
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

-- 11. Trigger para normalizar cpf_digits
DO $$
BEGIN
  DROP TRIGGER IF EXISTS trg_normalize_cpf ON public.clientes;
  CREATE TRIGGER trg_normalize_cpf
    BEFORE INSERT OR UPDATE ON public.clientes
    FOR EACH ROW 
    EXECUTE FUNCTION public.normalize_cpf_digits();
  RAISE NOTICE 'Trigger de normalização CPF criado';
END $$;

-- 12. Comentários para documentação
COMMENT ON FUNCTION public.is_valid_cpf(text) IS 'Valida CPF usando algoritmo oficial dos dígitos verificadores';
COMMENT ON COLUMN public.clientes.cpf_digits IS 'CPF sem formatação (apenas dígitos)';
COMMENT ON COLUMN public.clientes.empresa_id IS 'ID da empresa para multi-tenant (opcional)';

-- 13. Teste básico da função
DO $$
BEGIN
  -- Teste CPF válido
  IF NOT public.is_valid_cpf('11144477735') THEN
    RAISE EXCEPTION 'Erro: CPF válido não foi reconhecido';
  END IF;
  
  -- Teste CPF inválido
  IF public.is_valid_cpf('12345678901') THEN
    RAISE EXCEPTION 'Erro: CPF inválido foi aceito';
  END IF;
  
  -- Teste sequência repetida
  IF public.is_valid_cpf('00000000000') THEN
    RAISE EXCEPTION 'Erro: Sequência repetida foi aceita';
  END IF;
  
  RAISE NOTICE 'Todos os testes de validação CPF passaram ✓';
END $$;

-- 14. Finalização
DO $$
BEGIN
  RAISE NOTICE '🎉 Migração de validação CPF concluída com sucesso!';
END $$;

COMMIT;