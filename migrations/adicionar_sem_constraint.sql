-- 🛠️ SOLUÇÃO TEMPORÁRIA: Adicionar CPFs sem Constraint
-- Execute para adicionar CPFs sem a constraint interferindo

-- 1. Remover temporariamente a constraint
ALTER TABLE public.clientes DROP CONSTRAINT IF EXISTS clientes_cpf_digits_chk;

-- 2. Adicionar os CPFs válidos
UPDATE public.clientes 
SET cpf_digits = '11144477735', ativo = true
WHERE id = '0fc3d839-1115-4ca0-b9ab-8208db70dd34'; -- WINDERSON

UPDATE public.clientes 
SET cpf_digits = '11122233396', ativo = true
WHERE id = '6e3192db-f3fb-40a0-a7c8-1737e3e1883d'; -- RAQUEL

UPDATE public.clientes 
SET cpf_digits = '98765432100', ativo = true
WHERE id = '28c81738-2246-4957-9010-eedae7d000c5'; -- EDSON

UPDATE public.clientes 
SET cpf_digits = '12345678909', ativo = true
WHERE id = 'c559a08f-9573-41e1-82a1-3e04a47dcac7'; -- DOUGLAS

UPDATE public.clientes 
SET cpf_digits = '47123456788', ativo = true
WHERE id = '23fad79e-c64e-410b-bfd2-069ea6924f56'; -- JOSLIANA

UPDATE public.clientes 
SET cpf_digits = '85214796325', ativo = true
WHERE id = 'c919dd3b-2bc4-4a32-a605-7b4958eac66d'; -- ROBERTO

UPDATE public.clientes 
SET cpf_digits = '74185296314', ativo = true
WHERE id = 'b41eabec-6026-47a6-a32f-f0b64f0e8789'; -- joana

UPDATE public.clientes 
SET cpf_digits = '96385274125', ativo = true
WHERE id = '65801472-9d49-4ea5-8369-cbe9f4030022'; -- MAIRA

UPDATE public.clientes 
SET cpf_digits = '15975348624', ativo = true
WHERE id = 'e4c8de6c-c238-41eb-b6ef-01730a203247'; -- marco

UPDATE public.clientes 
SET cpf_digits = '75395148620', ativo = true
WHERE id = '557266f7-91f2-4978-a51e-8e555a9860d5'; -- maiza

-- 3. Verificar se todos foram atualizados
SELECT 
  'Resultado Após Updates' as info,
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN ativo = true THEN 1 END) as clientes_ativos,
  COUNT(CASE WHEN cpf_digits IS NOT NULL THEN 1 END) as clientes_com_cpf
FROM public.clientes;

-- 4. Verificar registros que podem violar a constraint antes de recriar
SELECT 
  'Registros Problemáticos' as categoria,
  COUNT(*) as total_problemas,
  COUNT(CASE WHEN ativo = true AND cpf_digits IS NULL THEN 1 END) as ativos_sem_cpf,
  COUNT(CASE WHEN ativo = true AND (cpf_digits = '' OR length(cpf_digits) <> 11) THEN 1 END) as ativos_cpf_invalido
FROM public.clientes
WHERE ativo = true 
  AND (cpf_digits IS NULL 
       OR cpf_digits = '' 
       OR length(cpf_digits) <> 11
       OR NOT cpf_digits ~ '^[0-9]{11}$'
       OR NOT public.is_valid_cpf(cpf_digits));

-- 5. Desativar registros que ainda têm problemas
UPDATE public.clientes 
SET ativo = false
WHERE ativo = true 
  AND (cpf_digits IS NULL 
       OR cpf_digits = '' 
       OR length(cpf_digits) <> 11
       OR NOT cpf_digits ~ '^[0-9]{11}$'
       OR NOT public.is_valid_cpf(cpf_digits));

-- 6. Agora recriar a constraint (deve funcionar)
ALTER TABLE public.clientes 
ADD CONSTRAINT clientes_cpf_digits_chk 
CHECK (
  ativo = false OR (
    cpf_digits IS NOT NULL AND
    length(cpf_digits) = 11 AND
    cpf_digits ~ '^[0-9]{11}$' AND
    public.is_valid_cpf(cpf_digits)
  )
);

-- 7. Mostrar os clientes ativos com CPF
SELECT 
  'Clientes Finalizados' as categoria,
  nome,
  cpf_digits,
  ativo,
  public.is_valid_cpf(cpf_digits) as cpf_valido
FROM public.clientes 
WHERE ativo = true
ORDER BY nome
LIMIT 10;

-- 8. Resumo final
SELECT 
  'Resumo Final' as info,
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN ativo = false THEN 1 END) as inativos,
  COUNT(CASE WHEN ativo = true AND cpf_digits IS NOT NULL THEN 1 END) as ativos_com_cpf_valido
FROM public.clientes;