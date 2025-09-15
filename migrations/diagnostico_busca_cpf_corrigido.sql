-- 🔍 DIAGNÓSTICO: Verificar busca de clientes
-- Execute para entender como a busca está configurada

-- 1. Verificar todas as colunas CPF na tabela clientes
SELECT 
  'Colunas CPF Disponíveis' as info,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'clientes' 
  AND (column_name LIKE '%cpf%' OR column_name LIKE '%documento%');

-- 2. Ver dados reais dos clientes ativos
SELECT 
  'Dados dos Clientes' as categoria,
  nome,
  cpf_cnpj,      -- Coluna original (pode ser NULL)
  cpf_digits,    -- Nova coluna com números
  CASE 
    WHEN cpf_cnpj IS NOT NULL THEN cpf_cnpj
    WHEN cpf_digits IS NOT NULL THEN 
      CONCAT(
        SUBSTR(cpf_digits, 1, 3), '.',
        SUBSTR(cpf_digits, 4, 3), '.',
        SUBSTR(cpf_digits, 7, 3), '-',
        SUBSTR(cpf_digits, 10, 2)
      )
    ELSE 'SEM CPF'
  END as cpf_formatado,
  ativo
FROM public.clientes 
WHERE ativo = true
ORDER BY nome
LIMIT 10;

-- 3. Testar diferentes formatos de busca CPF
-- Teste 1: Busca por cpf_digits (apenas números)
SELECT 
  'Busca por cpf_digits' as tipo_busca,
  nome,
  cpf_digits
FROM public.clientes 
WHERE cpf_digits = '11144477735'  -- Só números
  AND ativo = true;

-- Teste 2: Busca por cpf formatado (se existir)
SELECT 
  'Busca por cpf formatado' as tipo_busca,
  nome,
  cpf_cnpj,
  cpf_digits
FROM public.clientes 
WHERE cpf_cnpj = '111.444.777-35'  -- Com formatação
  AND ativo = true;

-- Teste 3: Busca usando LIKE em cpf_digits
SELECT 
  'Busca LIKE cpf_digits' as tipo_busca,
  nome,
  cpf_digits
FROM public.clientes 
WHERE cpf_digits LIKE '%11144477735%'
  AND ativo = true;

-- 4. Consulta ideal para busca (função que remove formatação)
SELECT 
  'Busca Universal' as tipo_busca,
  nome,
  cpf_cnpj,
  cpf_digits,
  CASE 
    WHEN cpf_digits IS NOT NULL THEN 
      CONCAT(
        SUBSTR(cpf_digits, 1, 3), '.',
        SUBSTR(cpf_digits, 4, 3), '.',
        SUBSTR(cpf_digits, 7, 3), '-',
        SUBSTR(cpf_digits, 10, 2)
      )
    ELSE cpf_cnpj
  END as cpf_para_exibir
FROM public.clientes 
WHERE (
  cpf_digits = regexp_replace('111.444.777-35', '\D', '', 'g')  -- Remove formatação e compara
  OR cpf_cnpj = '111.444.777-35'  -- Ou compara direto se estiver formatado
)
AND ativo = true;