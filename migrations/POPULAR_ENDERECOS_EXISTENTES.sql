-- =============================================
-- POPULAR ENDEREÇOS DOS CLIENTES EXISTENTES
-- =============================================
-- Execute este script para gerar endereços dos 141 clientes
-- =============================================

-- Atualizar TODOS os clientes forçando o trigger executar
UPDATE clientes
SET 
  logradouro = COALESCE(logradouro, ''),
  numero = COALESCE(numero, ''),
  bairro = COALESCE(bairro, ''),
  cidade = COALESCE(cidade, ''),
  estado = COALESCE(estado, ''),
  cep = COALESCE(cep, ''),
  tipo_logradouro = COALESCE(tipo_logradouro, '')
WHERE id IS NOT NULL;

-- Verificar resultado
SELECT 
  COUNT(*) as total_clientes,
  COUNT(endereco) as total_com_endereco,
  COUNT(CASE WHEN endereco IS NOT NULL AND endereco != '' THEN 1 END) as total_endereco_preenchido,
  COUNT(*) - COUNT(endereco) as total_sem_endereco
FROM clientes;

-- Mostrar exemplos de endereços gerados
SELECT 
  id,
  nome,
  logradouro,
  numero,
  cidade,
  estado,
  endereco
FROM clientes
WHERE endereco IS NOT NULL AND endereco != ''
LIMIT 10;
