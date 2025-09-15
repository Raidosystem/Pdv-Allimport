-- 🧪 TESTE RÁPIDO: Verificar se existem clientes com cpf_digits
SELECT 
  COUNT(*) as total_clientes,
  COUNT(cpf_cnpj) as tem_cpf_cnpj,
  COUNT(cpf_digits) as tem_cpf_digits
FROM public.clientes 
WHERE ativo = true;

-- Ver alguns exemplos de dados
SELECT 
  nome,
  cpf_cnpj,
  cpf_digits,
  LENGTH(cpf_digits) as len_digits
FROM public.clientes 
WHERE ativo = true
  AND (cpf_cnpj IS NOT NULL OR cpf_digits IS NOT NULL)
LIMIT 5;