-- =====================================================
-- 🔍 ANÁLISE E LIMPEZA ESPECÍFICA - DADOS SUSPEITOS
-- =====================================================
-- Identifica e remove dados que claramente são de teste
-- =====================================================

-- 1️⃣ IDENTIFICAR PADRÕES SUSPEITOS

-- 1.1 - Empresas com padrões de teste
SELECT 
  'EMPRESAS_SUSPEITAS' as tipo,
  id,
  nome,
  cnpj,
  user_id,
  created_at
FROM empresas 
WHERE nome ILIKE '%loja%'
   OR nome ILIKE '%padaria%'
   OR nome ILIKE '%farmácia%'
   OR nome ILIKE '%mercado%'
   OR nome ILIKE '%oficina%'
   OR nome ILIKE '%pet%'
   OR nome = 'Allimport'
   OR cnpj = '12.345.678/0001-90'
   OR cnpj LIKE '%000%'
   OR user_id IS NULL
ORDER BY created_at;

-- 1.2 - Produtos com códigos de barras suspeitos
SELECT 
  'PRODUTOS_SUSPEITOS' as tipo,
  id,
  nome,
  codigo_barras,
  preco,
  empresa_id
FROM produtos 
WHERE codigo_barras LIKE '%12345%'
   OR codigo_barras LIKE '%000%'
   OR codigo_barras = '7891234567890'
   OR preco = 10.00
   OR preco = 5.00
   OR nome ILIKE '%produto%'
   OR nome ILIKE '%item%'
   OR nome ILIKE '%teste%'
ORDER BY empresa_id, id;

-- 1.3 - Clientes com dados genéricos
SELECT 
  'CLIENTES_SUSPEITOS' as tipo,
  id,
  nome,
  email,
  telefone,
  cpf_cnpj,
  empresa_id
FROM clientes 
WHERE nome ILIKE '%cliente%'
   OR nome ILIKE '%joão%'
   OR nome ILIKE '%maria%'
   OR email ILIKE '%example%'
   OR email ILIKE '%teste%'
   OR telefone LIKE '%1234%'
   OR telefone LIKE '%0000%'
   OR cpf_cnpj LIKE '%000%'
   OR cpf_cnpj LIKE '%111%'
   OR cpf_cnpj LIKE '%123%'
ORDER BY empresa_id, id;

-- 1.4 - Funcionários com dados de teste
SELECT 
  'FUNCIONARIOS_SUSPEITOS' as tipo,
  id,
  nome,
  email,
  funcao_id,
  empresa_id,
  status
FROM funcionarios 
WHERE nome ILIKE '%funcionário%'
   OR nome ILIKE '%usuário%'
   OR nome ILIKE '%admin%'
   OR nome ILIKE '%teste%'
   OR email ILIKE '%exemplo%'
   OR email ILIKE '%teste%'
   OR email ILIKE '%admin%'
ORDER BY empresa_id, id;

-- 2️⃣ LIMPEZA ESPECÍFICA E SEGURA

-- 2.1 - Remover empresas claramente de teste (SEM user_id)
DELETE FROM funcionarios WHERE empresa_id IN (
  SELECT id FROM empresas WHERE user_id IS NULL
);

DELETE FROM produtos WHERE empresa_id IN (
  SELECT id FROM empresas WHERE user_id IS NULL
);

DELETE FROM clientes WHERE empresa_id IN (
  SELECT id FROM empresas WHERE user_id IS NULL
);

DELETE FROM fornecedores WHERE empresa_id IN (
  SELECT id FROM empresas WHERE user_id IS NULL
);

DELETE FROM vendas WHERE empresa_id IN (
  SELECT id FROM empresas WHERE user_id IS NULL
);

DELETE FROM ordens_servico WHERE empresa_id IN (
  SELECT id FROM empresas WHERE user_id IS NULL
);

DELETE FROM caixa WHERE empresa_id IN (
  SELECT id FROM empresas WHERE user_id IS NULL
);

DELETE FROM empresas WHERE user_id IS NULL;

-- 2.2 - Remover produtos com códigos de barras de teste
DELETE FROM produtos 
WHERE codigo_barras IN (
  '7891234567890',
  '1234567890123',
  '0000000000000',
  '1111111111111'
)
OR codigo_barras LIKE '%00000%'
OR codigo_barras LIKE '%11111%'
OR codigo_barras LIKE '%12345%';

-- 2.3 - Remover clientes com dados obviamente falsos
DELETE FROM clientes 
WHERE cpf_cnpj IN (
  '000.000.000-00',
  '111.111.111-11',
  '123.456.789-00',
  '12345678901'
)
OR telefone IN (
  '(11) 99999-9999',
  '(11) 12345-6789',
  '11999999999',
  '11123456789'
)
OR email LIKE '%@example.com'
OR email LIKE '%@teste.com';

-- 2.4 - Remover fornecedores com CNPJ de teste
DELETE FROM fornecedores 
WHERE cnpj IN (
  '00.000.000/0000-00',
  '11.111.111/1111-11',
  '12.345.678/0001-90'
)
OR telefone IN (
  '(11) 99999-9999',
  '(11) 12345-6789'
)
OR email LIKE '%@example.com'
OR email LIKE '%@teste.com';

-- 3️⃣ LIMPEZA DE VENDAS E ORDENS DE SERVIÇO COM VALORES SUSPEITOS

-- 3.1 - Vendas com valores redondos suspeitos (provavelmente teste)
DELETE FROM vendas 
WHERE total IN (100.00, 50.00, 10.00, 5.00, 1.00)
  AND created_at < NOW() - INTERVAL '7 days';

-- 3.2 - Ordens de serviço com valores padrão
DELETE FROM ordens_servico 
WHERE valor_servico IN (100.00, 50.00, 10.00)
  AND defeito_relatado ILIKE '%teste%'
  OR cliente_nome ILIKE '%cliente%';

-- 4️⃣ VERIFICAÇÃO FINAL DOS DADOS LIMPOS

SELECT 
  'VERIFICACAO_FINAL' as operacao,
  'Empresas com user_id válido' as descricao,
  COUNT(*) as quantidade
FROM empresas 
WHERE user_id IS NOT NULL

UNION ALL

SELECT 
  'VERIFICACAO_FINAL' as operacao,
  'Produtos restantes' as descricao,
  COUNT(*) as quantidade
FROM produtos

UNION ALL

SELECT 
  'VERIFICACAO_FINAL' as operacao,
  'Clientes restantes' as descricao,
  COUNT(*) as quantidade
FROM clientes

UNION ALL

SELECT 
  'VERIFICACAO_FINAL' as operacao,
  'Funcionários restantes' as descricao,
  COUNT(*) as quantidade
FROM funcionarios

UNION ALL

SELECT 
  'VERIFICACAO_FINAL' as operacao,
  'Fornecedores restantes' as descricao,
  COUNT(*) as quantidade
FROM fornecedores;

-- 5️⃣ VERIFICAR DADOS POR EMPRESA
SELECT 
  e.nome as empresa,
  e.user_id,
  COUNT(DISTINCT f.id) as funcionarios,
  COUNT(DISTINCT p.id) as produtos,
  COUNT(DISTINCT c.id) as clientes,
  COUNT(DISTINCT fo.id) as fornecedores,
  COUNT(DISTINCT v.id) as vendas
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
LEFT JOIN produtos p ON p.empresa_id = e.id
LEFT JOIN clientes c ON c.empresa_id = e.id
LEFT JOIN fornecedores fo ON fo.empresa_id = e.id
LEFT JOIN vendas v ON v.empresa_id = e.id
GROUP BY e.id, e.nome, e.user_id
ORDER BY e.nome;

-- =====================================================
-- 🎯 RESULTADO ESPERADO APÓS LIMPEZA
-- =====================================================
-- ✅ Apenas empresas com user_id real (UUID válido)
-- ✅ Produtos sem códigos de barras de teste
-- ✅ Clientes sem CPF/email/telefone genéricos
-- ✅ Fornecedores sem CNPJ/dados de teste
-- ✅ Vendas sem valores suspeitos de teste
-- ✅ Sistema limpo e profissional
-- =====================================================