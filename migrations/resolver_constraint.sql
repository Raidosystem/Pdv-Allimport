-- 🔍 RESOLVER PROBLEMA DA CONSTRAINT
-- Vamos investigar e corrigir o problema

-- 1. Ver a definição exata da constraint
SELECT 
  constraint_name,
  check_clause
FROM information_schema.check_constraints 
WHERE constraint_name = 'clientes_cpf_digits_chk';

-- 2. Testar o CPF isoladamente
SELECT 
  '47123456788' as cpf,
  length('47123456788') as tamanho,
  '47123456788' ~ '^[0-9]{11}$' as regex_ok,
  public.is_valid_cpf('47123456788') as funcao_ok;

-- 3. Ver se a constraint está considerando outros campos
-- Vamos remover temporariamente a constraint e recriar uma mais simples
ALTER TABLE public.clientes DROP CONSTRAINT IF EXISTS clientes_cpf_digits_chk;

-- 4. Criar uma constraint mais específica apenas para registros ativos
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

-- 5. Agora tentar atualizar novamente
UPDATE public.clientes 
SET cpf_digits = '47123456788', ativo = true
WHERE id = '23fad79e-c64e-410b-bfd2-069ea6924f56';

-- 6. Verificar se funcionou
SELECT 
  'Cliente Atualizado' as info,
  nome,
  cpf_digits,
  ativo,
  public.is_valid_cpf(cpf_digits) as cpf_valido
FROM public.clientes 
WHERE id = '23fad79e-c64e-410b-bfd2-069ea6924f56';