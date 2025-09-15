-- 🔍 TESTE DIRETO: Simular a busca que o sistema faz
-- Substitua '12345678901' pelo CPF que você está testando

-- Teste 1: Busca exata na coluna cpf_digits
SELECT 'Busca em cpf_digits' as teste, nome, cpf_digits, cpf_cnpj
FROM public.clientes 
WHERE cpf_digits ILIKE '%12345678901%'
  AND ativo = true;

-- Teste 2: Busca na coluna cpf_cnpj  
SELECT 'Busca em cpf_cnpj' as teste, nome, cpf_digits, cpf_cnpj
FROM public.clientes 
WHERE cpf_cnpj ILIKE '%12345678901%'
  AND ativo = true;

-- Teste 3: Busca em nome (para verificar se a busca funciona)
SELECT 'Busca em nome' as teste, nome, cpf_digits, cpf_cnpj
FROM public.clientes 
WHERE nome ILIKE '%João%'  -- Substitua por um nome que você sabe que existe
  AND ativo = true;

-- Teste 4: Query OR completa (como nosso sistema faz)
SELECT 'Query OR completa' as teste, nome, cpf_digits, cpf_cnpj
FROM public.clientes 
WHERE (
  nome ILIKE '%12345678901%'
  OR telefone ILIKE '%12345678901%'
  OR cpf_cnpj ILIKE '%12345678901%'
  OR endereco ILIKE '%12345678901%'
  OR cpf_digits ILIKE '%12345678901%'
)
AND ativo = true;