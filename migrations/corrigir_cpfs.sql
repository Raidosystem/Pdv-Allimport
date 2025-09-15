-- 🔧 CORREÇÃO: Reativar clientes e corrigir CPFs
-- Execute este script para corrigir os clientes desativados

-- 1. Primeiro, vamos ver o estado atual dos CPFs
SELECT 
  'Análise dos CPFs' as info,
  COUNT(*) as total,
  COUNT(CASE WHEN cpf_digits IS NULL THEN 1 END) as nulos,
  COUNT(CASE WHEN cpf_digits = '' THEN 1 END) as vazios,
  COUNT(CASE WHEN length(cpf_digits) > 0 AND length(cpf_digits) <> 11 THEN 1 END) as tamanho_errado,
  COUNT(CASE WHEN length(cpf_digits) = 11 AND NOT cpf_digits ~ '^[0-9]+$' THEN 1 END) as nao_numerico
FROM public.clientes;

-- 2. Verificar se existe coluna 'cpf' original
SELECT 
  'Colunas CPF' as info,
  column_name,
  data_type
FROM information_schema.columns 
WHERE table_name = 'clientes' 
  AND column_name LIKE '%cpf%';

-- 3. Se houver coluna 'cpf', vamos migrar os dados
DO $$
DECLARE
  migrated_count int;
BEGIN
  -- Verifica se coluna cpf existe
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'clientes' AND column_name = 'cpf'
  ) THEN
    -- Migra dados da coluna cpf para cpf_digits
    UPDATE public.clientes 
    SET cpf_digits = regexp_replace(coalesce(cpf, ''), '\D', '', 'g')
    WHERE cpf IS NOT NULL 
      AND cpf <> ''
      AND (cpf_digits IS NULL OR cpf_digits = '');
      
    GET DIAGNOSTICS migrated_count = ROW_COUNT;
    RAISE NOTICE 'Migrados % registros da coluna cpf', migrated_count;
    
  ELSE
    RAISE NOTICE 'Coluna cpf não encontrada. Você precisará inserir CPFs manualmente.';
  END IF;
END $$;

-- 4. Reativar clientes que agora têm CPF válido
DO $$
DECLARE
  reactivated_count int;
BEGIN
  UPDATE public.clientes 
  SET ativo = true
  WHERE ativo = false
    AND cpf_digits IS NOT NULL
    AND cpf_digits <> ''
    AND length(cpf_digits) = 11
    AND cpf_digits ~ '^[0-9]+$'
    AND public.is_valid_cpf(cpf_digits);
    
  GET DIAGNOSTICS reactivated_count = ROW_COUNT;
  RAISE NOTICE 'Reativados % clientes com CPF válido', reactivated_count;
END $$;

-- 5. Verificar resultado final
SELECT 
  'Resultado Final' as info,
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN cpf_digits IS NOT NULL AND cpf_digits <> '' THEN 1 END) as com_cpf,
  COUNT(CASE WHEN cpf_digits IS NULL OR cpf_digits = '' THEN 1 END) as sem_cpf,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN ativo = false THEN 1 END) as inativos
FROM public.clientes;

-- 6. Mostrar clientes que ainda precisam de CPF
SELECT 
  'Clientes que precisam de CPF' as info,
  id,
  nome,
  cpf_digits,
  ativo
FROM public.clientes 
WHERE ativo = false
  AND (cpf_digits IS NULL OR cpf_digits = '' OR NOT public.is_valid_cpf(cpf_digits))
LIMIT 10;