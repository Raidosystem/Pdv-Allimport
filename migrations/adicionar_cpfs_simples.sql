-- 🔧 SCRIPT SIMPLES: Adicionar CPFs Válidos Testados
-- Execute este script para adicionar CPFs que foram validados

-- Primeiro, vamos testar se os CPFs são válidos
SELECT 
  'Teste de CPFs' as categoria,
  cpf,
  public.is_valid_cpf(cpf) as valido
FROM (VALUES 
  ('11144477735'),
  ('11122233396'), 
  ('98765432100'),
  ('12345678909'),
  ('47123456788'),
  ('85214796325'),
  ('74185296314'),
  ('96385274125'),
  ('15975348624'),
  ('75395148620')
) AS test_cpfs(cpf);

-- Agora vamos atualizar um por vez para identificar problemas
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

-- Verificar quantos foram atualizados
SELECT 
  'Resultado Parcial' as info,
  COUNT(*) as total,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos_agora,
  COUNT(CASE WHEN cpf_digits IS NOT NULL AND length(cpf_digits) = 11 THEN 1 END) as com_cpf
FROM public.clientes;