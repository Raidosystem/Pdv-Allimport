-- 🔍 DIAGNÓSTICO SIMPLES: Ver todos os clientes com CPF
SELECT 
  id,
  nome,
  cpf_cnpj,
  cpf_digits,
  ativo,
  criado_em
FROM public.clientes 
WHERE ativo = true
  AND (cpf_cnpj IS NOT NULL OR cpf_digits IS NOT NULL)
ORDER BY criado_em DESC
LIMIT 20;