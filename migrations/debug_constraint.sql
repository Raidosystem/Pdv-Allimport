-- 🔍 DIAGNÓSTICO: Verificar Constraint CPF
-- Execute para entender por que a constraint está falhando

-- 1. Verificar a constraint atual
SELECT 
  'Constraint Atual' as info,
  constraint_name,
  check_clause
FROM information_schema.check_constraints 
WHERE constraint_name = 'clientes_cpf_digits_chk';

-- 2. Testar CPFs individualmente na função
SELECT 
  'Teste Individual' as categoria,
  cpf,
  length(cpf) as tamanho,
  cpf ~ '^[0-9]+$' as apenas_numeros,
  public.is_valid_cpf(cpf) as funcao_valida
FROM (VALUES 
  ('47123456788'),
  ('98712345680'),
  ('11144477735')
) AS test_cpfs(cpf);

-- 3. Verificar se o cliente específico tem algum campo que pode estar causando problema
SELECT 
  'Cliente Problema' as info,
  id,
  nome,
  cpf_digits,
  ativo,
  tipo
FROM public.clientes 
WHERE id = '23fad79e-c64e-410b-bfd2-069ea6924f56';

-- 4. Testar inserção simples para debugar
-- Vamos criar um cliente temporário para teste
INSERT INTO public.clientes (nome, cpf_digits, tipo, ativo) 
VALUES ('TESTE CPF', '47123456788', 'Física', true);

-- Se funcionou, remove o teste
DELETE FROM public.clientes WHERE nome = 'TESTE CPF';

-- 5. Tentar atualizar apenas o CPF sem alterar ativo
UPDATE public.clientes 
SET cpf_digits = '47123456788'
WHERE id = '23fad79e-c64e-410b-bfd2-069ea6924f56';

-- Depois ativar separadamente
UPDATE public.clientes 
SET ativo = true
WHERE id = '23fad79e-c64e-410b-bfd2-069ea6924f56';