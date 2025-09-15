-- 🔍 TESTE: Buscar clientes por diferentes formatos de CPF
-- Substitua os CPFs pelos valores reais que você está testando

-- Ver a estrutura das colunas CPF
SELECT 
  'Estrutura das Colunas' as info,
  column_name,
  data_type,
  character_maximum_length
FROM information_schema.columns 
WHERE table_name = 'clientes' 
  AND column_name IN ('cpf_cnpj', 'cpf_digits');

-- Ver todos os clientes com qualquer tipo de CPF
SELECT 
  'Todos os Clientes com CPF' as categoria,
  id,
  nome,
  cpf_cnpj,
  cpf_digits,
  LENGTH(cpf_cnpj) as len_cpf_cnpj,
  LENGTH(cpf_digits) as len_cpf_digits,
  ativo
FROM public.clientes 
WHERE (cpf_cnpj IS NOT NULL AND cpf_cnpj != '') 
   OR (cpf_digits IS NOT NULL AND cpf_digits != '')
ORDER BY criado_em DESC
LIMIT 10;

-- Teste com diferentes padrões de busca
-- Substitua '12345678901' pelo CPF que você está buscando
SELECT 
  'Busca Teste 1: CPF Digits' as tipo,
  nome,
  cpf_digits,
  cpf_cnpj
FROM public.clientes 
WHERE cpf_digits LIKE '%12345678901%'
  AND ativo = true;

-- Teste 2: CPF formatado na coluna cpf_cnpj
SELECT 
  'Busca Teste 2: CPF Formatado' as tipo,
  nome,
  cpf_digits,
  cpf_cnpj
FROM public.clientes 
WHERE cpf_cnpj LIKE '%123.456.789-01%'
  AND ativo = true;

-- Teste 3: Busca universal (como nossa função deveria funcionar)
SELECT 
  'Busca Teste 3: Universal' as tipo,
  nome,
  cpf_digits,
  cpf_cnpj
FROM public.clientes 
WHERE (
  cpf_digits LIKE '%12345678901%'
  OR cpf_cnpj LIKE '%12345678901%'
  OR cpf_cnpj LIKE '%123.456.789-01%'
  OR REPLACE(REPLACE(REPLACE(cpf_cnpj, '.', ''), '-', ''), ' ', '') LIKE '%12345678901%'
)
AND ativo = true;