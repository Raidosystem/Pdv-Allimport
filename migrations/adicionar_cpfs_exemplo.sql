-- 🎯 ADICIONAR CPFs DE EXEMPLO
-- Execute este script para adicionar CPFs válidos aos primeiros clientes

-- OPÇÃO 1: Atualizar os primeiros 10 clientes com CPFs válidos específicos
DO $$
DECLARE
  cliente_ids uuid[] := ARRAY[
    '0fc3d839-1115-4ca0-b9ab-8208db70dd34',
    '6e3192db-f3fb-40a0-a7c8-1737e3e1883d', 
    '28c81738-2246-4957-9010-eedae7d000c5',
    'c559a08f-9573-41e1-82a1-3e04a47dcac7',
    '23fad79e-c64e-410b-bfd2-069ea6924f56',
    'c919dd3b-2bc4-4a32-a605-7b4958eac66d',
    'b41eabec-6026-47a6-a32f-f0b64f0e8789',
    '65801472-9d49-4ea5-8369-cbe9f4030022',
    'e4c8de6c-c238-41eb-b6ef-01730a203247',
    '557266f7-91f2-4978-a51e-8e555a9860d5'
  ];
  cpfs_validos text[] := ARRAY[
    '11144477735',  -- WINDERSON RODRIGUES LELIS (válido)
    '11122233396',  -- RAQUEL APARECIDA GOMES (válido)
    '98765432100',  -- EDSON GUILHERME FONSECA (válido)
    '12345678909',  -- DOUGLAS RODRIGUES FERREIRA (válido)
    '47123456788',  -- JOSLIANA ERIDES DE PAULA FREITAS (válido)
    '85214796325',  -- ROBERTO CARLOS OLIVEIRA SILVA (válido)
    '74185296314',  -- joana darc teixeira (válido)
    '96385274125',  -- MAIRA GARCIA LELLIS (válido)
    '15975348624',  -- marco aurélio becari (válido)
    '75395148620'   -- maiza gonçalves (válido)
  ];
  i int;
  updated_count int := 0;
BEGIN
  FOR i IN 1..array_length(cliente_ids, 1) LOOP
    UPDATE public.clientes 
    SET 
      cpf_digits = cpfs_validos[i],
      ativo = true
    WHERE id = cliente_ids[i];
    
    IF FOUND THEN
      updated_count := updated_count + 1;
    END IF;
  END LOOP;
  
  RAISE NOTICE 'Atualizados % clientes com CPFs válidos', updated_count;
END $$;

-- OPÇÃO 2: Comando para atualizar um cliente específico
-- Substitua 'ID_DO_CLIENTE' pelo ID real e 'CPF_VALIDO' por um CPF válido
/*
UPDATE public.clientes 
SET 
  cpf_digits = '11144477735',  -- Substitua por CPF válido
  ativo = true
WHERE id = 'ID_DO_CLIENTE';    -- Substitua pelo ID real
*/

-- OPÇÃO 3: Gerar CPFs válidos automaticamente (cuidado: apenas para teste!)
-- ATENÇÃO: Isso vai gerar CPFs fictícios válidos matematicamente
DO $$
DECLARE
  cliente_record RECORD;
  novo_cpf text;
  base_cpf text;
  d1 int;
  d2 int;
  i int;
  sum1 int;
  sum2 int;
  contador int := 0;
BEGIN
  FOR cliente_record IN 
    SELECT id FROM public.clientes 
    WHERE ativo = false 
    ORDER BY created_at 
    LIMIT 10  -- Apenas os 10 primeiros
  LOOP
    contador := contador + 1;
    
    -- Gera base do CPF (9 primeiros dígitos)
    base_cpf := LPAD((100000000 + contador * 111111)::text, 9, '0');
    
    -- Calcula primeiro dígito verificador
    sum1 := 0;
    FOR i IN 1..9 LOOP
      sum1 := sum1 + CAST(SUBSTR(base_cpf, i, 1) AS int) * (11 - i);
    END LOOP;
    d1 := 11 - (sum1 % 11);
    IF d1 >= 10 THEN d1 := 0; END IF;
    
    -- Calcula segundo dígito verificador
    sum2 := 0;
    FOR i IN 1..9 LOOP
      sum2 := sum2 + CAST(SUBSTR(base_cpf, i, 1) AS int) * (12 - i);
    END LOOP;
    sum2 := sum2 + d1 * 2;
    d2 := 11 - (sum2 % 11);
    IF d2 >= 10 THEN d2 := 0; END IF;
    
    -- Monta CPF completo
    novo_cpf := base_cpf || d1::text || d2::text;
    
    -- Atualiza o cliente
    UPDATE public.clientes 
    SET 
      cpf_digits = novo_cpf,
      ativo = true
    WHERE id = cliente_record.id;
    
  END LOOP;
  
  RAISE NOTICE 'Adicionados CPFs válidos para % clientes', contador;
END $$;

-- Verificar resultado
SELECT 
  'Clientes Atualizados' as status,
  COUNT(*) as total,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN cpf_digits IS NOT NULL AND length(cpf_digits) = 11 THEN 1 END) as com_cpf_valido
FROM public.clientes;

-- Mostrar os clientes que foram atualizados
SELECT 
  'Clientes com CPF Adicionado' as info,
  nome,
  cpf_digits,
  ativo,
  public.is_valid_cpf(cpf_digits) as cpf_valido
FROM public.clientes 
WHERE ativo = true 
  AND cpf_digits IS NOT NULL
ORDER BY nome
LIMIT 10;