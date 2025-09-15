-- ✅ VERIFICAÇÃO PÓS-MIGRAÇÃO: Sistema de Validação CPF
-- Execute estas consultas para confirmar que tudo foi aplicado corretamente

-- 1. Verificar se a função de validação foi criada
SELECT 
  routine_name,
  routine_type,
  data_type
FROM information_schema.routines 
WHERE routine_name = 'is_valid_cpf';

-- 2. Verificar se as colunas foram adicionadas
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'clientes' 
  AND column_name IN ('cpf_digits', 'empresa_id');

-- 3. Verificar se a constraint foi criada
SELECT 
  constraint_name,
  constraint_type
FROM information_schema.table_constraints 
WHERE table_name = 'clientes' 
  AND constraint_name = 'clientes_cpf_digits_chk';

-- 4. Verificar se o índice único foi criado
SELECT 
  indexname,
  indexdef
FROM pg_indexes 
WHERE tablename = 'clientes' 
  AND indexname = 'uniq_clientes_empresa_cpf';

-- 5. Verificar se o trigger foi criado
SELECT 
  trigger_name,
  event_manipulation,
  action_timing
FROM information_schema.triggers 
WHERE trigger_name = 'trg_normalize_cpf';

-- 6. Testar a função de validação CPF
SELECT 
  'CPF Válido' as teste,
  public.is_valid_cpf('11144477735') as resultado; -- Deve retornar true

SELECT 
  'CPF Inválido' as teste,
  public.is_valid_cpf('12345678901') as resultado; -- Deve retornar false

SELECT 
  'Sequência Repetida' as teste,
  public.is_valid_cpf('00000000000') as resultado; -- Deve retornar false

-- 7. Verificar estado dos dados na tabela clientes
SELECT 
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN cpf_digits IS NOT NULL THEN 1 END) as com_cpf,
  COUNT(CASE WHEN cpf_digits IS NULL THEN 1 END) as sem_cpf,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN ativo = false THEN 1 END) as inativos
FROM public.clientes;

-- 8. Verificar CPFs inválidos restantes (se houver)
SELECT 
  id,
  nome,
  cpf_digits,
  ativo,
  CASE 
    WHEN cpf_digits IS NULL THEN 'NULL'
    WHEN cpf_digits = '' THEN 'VAZIO'
    WHEN length(cpf_digits) <> 11 THEN 'TAMANHO_INVÁLIDO'
    WHEN NOT public.is_valid_cpf(cpf_digits) THEN 'CPF_INVÁLIDO'
    ELSE 'OK'
  END as status_cpf
FROM public.clientes 
WHERE ativo = true 
  AND (cpf_digits IS NULL 
       OR cpf_digits = '' 
       OR length(cpf_digits) <> 11
       OR NOT public.is_valid_cpf(cpf_digits))
LIMIT 5;

-- 9. Testar inserção com CPF válido (deve funcionar)
-- INSERT INTO public.clientes (nome, cpf_digits) VALUES ('Teste CPF', '11144477735');

-- 10. Testar inserção com CPF inválido (deve falhar se constraint estiver ativa)
-- INSERT INTO public.clientes (nome, cpf_digits) VALUES ('Teste Inválido', '12345678901');