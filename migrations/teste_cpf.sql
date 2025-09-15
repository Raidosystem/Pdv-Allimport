-- 🧪 TESTE RÁPIDO: Validação CPF
-- Execute para testar se o sistema está funcionando

-- Teste 1: Função de validação
SELECT 
  '111.444.777-35' as cpf_formatado,
  public.is_valid_cpf('11144477735') as cpf_valido,
  public.is_valid_cpf('111.444.777-35') as aceita_formatacao,
  public.is_valid_cpf('00000000000') as rejeita_sequencia;

-- Teste 2: Estado atual da tabela
SELECT 
  'Estado da Tabela Clientes' as info,
  COUNT(*) as total,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN cpf_digits IS NOT NULL THEN 1 END) as com_cpf
FROM public.clientes;

-- Teste 3: Verificar constraints ativas
SELECT 
  'Constraints Ativas' as info,
  constraint_name,
  constraint_type
FROM information_schema.table_constraints 
WHERE table_name = 'clientes' 
  AND constraint_type IN ('CHECK', 'UNIQUE');

-- Teste 4: Verificar se trigger está ativo
SELECT 
  'Trigger de Normalização' as info,
  trigger_name,
  action_timing || ' ' || event_manipulation as acao
FROM information_schema.triggers 
WHERE trigger_name = 'trg_normalize_cpf';