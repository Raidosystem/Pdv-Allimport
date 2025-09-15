-- 🧪 TESTE FINAL: Validação do Sistema CPF
-- Execute para confirmar que tudo está funcionando para usar o CpfInput

-- 1. Verificar função de validação
SELECT 
  'Teste de Validação CPF' as categoria,
  'CPF Válido' as teste,
  '111.444.777-35' as cpf_entrada,
  public.is_valid_cpf('11144477735') as resultado_esperado_true;

SELECT 
  'Teste de Validação CPF' as categoria,
  'CPF Inválido' as teste,
  '123.456.789-01' as cpf_entrada,
  public.is_valid_cpf('12345678901') as resultado_esperado_false;

-- 2. Testar duplicidade (simular o que o CpfInput fará)
SELECT 
  'Teste de Duplicidade' as categoria,
  COUNT(*) as clientes_com_este_cpf,
  CASE 
    WHEN COUNT(*) > 0 THEN 'CPF já existe'
    ELSE 'CPF disponível'
  END as status
FROM public.clientes 
WHERE cpf_digits = '11144477735' 
  AND ativo = true;

-- 3. Estado atual para usar no frontend
SELECT 
  'Estado para Frontend' as info,
  COUNT(CASE WHEN ativo = true THEN 1 END) as clientes_ativos,
  COUNT(CASE WHEN ativo = true AND cpf_digits IS NOT NULL THEN 1 END) as clientes_com_cpf,
  CASE 
    WHEN COUNT(CASE WHEN ativo = true THEN 1 END) > 0 THEN 'PRONTO PARA TESTE'
    ELSE 'EXECUTE adicionar_cpfs_exemplo.sql PRIMEIRO'
  END as status_sistema
FROM public.clientes;

-- 4. Exemplo de consulta que o CpfInput fará
-- Esta é a consulta que será executada pelo componente CpfInput
/*
SELECT COUNT(*) 
FROM public.clientes 
WHERE cpf_digits = ? 
  AND ativo = true 
  AND (empresa_id = ? OR ? IS NULL);
*/

-- 5. Testar inserção de novo cliente (simular formulário)
-- Remova o comentário para testar
/*
INSERT INTO public.clientes (nome, cpf_digits, email) 
VALUES ('Cliente Teste', '85296374185', 'teste@email.com');
*/

-- 6. Verificar se constraints estão funcionando
SELECT 
  'Constraints Ativas' as categoria,
  constraint_name,
  constraint_type
FROM information_schema.table_constraints 
WHERE table_name = 'clientes' 
  AND constraint_type IN ('CHECK', 'UNIQUE')
  AND constraint_name LIKE '%cpf%';