-- =====================================================
-- ✅ VALIDAÇÃO FINAL - APENAS DADOS REAIS
-- =====================================================
-- Verifica se restaram apenas dados legítimos de usuários
-- =====================================================

-- 1️⃣ VALIDAR EMPRESAS (devem ter user_id válido)
SELECT 
  '🏢 EMPRESAS VÁLIDAS' as secao,
  id,
  nome,
  cnpj,
  user_id,
  created_at,
  CASE 
    WHEN user_id IS NOT NULL THEN '✅ Válida'
    ELSE '❌ Suspeita'
  END as status
FROM empresas 
ORDER BY created_at;

-- 2️⃣ VALIDAR INTEGRIDADE REFERENCIAL
SELECT 
  '🔗 INTEGRIDADE REFERENCIAL' as secao,
  'Produtos órfãos' as tipo,
  COUNT(*) as quantidade
FROM produtos 
WHERE empresa_id NOT IN (SELECT id FROM empresas)

UNION ALL

SELECT 
  '🔗 INTEGRIDADE REFERENCIAL' as secao,
  'Clientes órfãos' as tipo,
  COUNT(*) as quantidade
FROM clientes 
WHERE empresa_id NOT IN (SELECT id FROM empresas)

UNION ALL

SELECT 
  '🔗 INTEGRIDADE REFERENCIAL' as secao,
  'Funcionários órfãos' as tipo,
  COUNT(*) as quantidade
FROM funcionarios 
WHERE empresa_id NOT IN (SELECT id FROM empresas)

UNION ALL

SELECT 
  '🔗 INTEGRIDADE REFERENCIAL' as secao,
  'Fornecedores órfãos' as tipo,
  COUNT(*) as quantidade
FROM fornecedores 
WHERE empresa_id NOT IN (SELECT id FROM empresas)

UNION ALL

SELECT 
  '🔗 INTEGRIDADE REFERENCIAL' as secao,
  'Vendas órfãs' as tipo,
  COUNT(*) as quantidade
FROM vendas 
WHERE empresa_id NOT IN (SELECT id FROM empresas);

-- 3️⃣ RESUMO GERAL DO SISTEMA LIMPO
SELECT 
  '📊 RESUMO SISTEMA LIMPO' as secao,
  'Empresas ativas' as item,
  COUNT(*) as total
FROM empresas

UNION ALL

SELECT 
  '📊 RESUMO SISTEMA LIMPO' as secao,
  'Funcionários cadastrados' as item,
  COUNT(*) as total
FROM funcionarios

UNION ALL

SELECT 
  '📊 RESUMO SISTEMA LIMPO' as secao,
  'Produtos no estoque' as item,
  COUNT(*) as total
FROM produtos

UNION ALL

SELECT 
  '📊 RESUMO SISTEMA LIMPO' as secao,
  'Clientes cadastrados' as item,
  COUNT(*) as total
FROM clientes

UNION ALL

SELECT 
  '📊 RESUMO SISTEMA LIMPO' as secao,
  'Fornecedores ativos' as item,
  COUNT(*) as total
FROM fornecedores

UNION ALL

SELECT 
  '📊 RESUMO SISTEMA LIMPO' as secao,
  'Vendas realizadas' as item,
  COUNT(*) as total
FROM vendas

UNION ALL

SELECT 
  '📊 RESUMO SISTEMA LIMPO' as secao,
  'Ordens de serviço' as item,
  COUNT(*) as total
FROM ordens_servico;

-- 4️⃣ DETALHAMENTO POR EMPRESA
SELECT 
  '🏢 DETALHAMENTO POR EMPRESA' as secao,
  e.nome as empresa,
  e.cnpj,
  e.user_id,
  COUNT(DISTINCT f.id) as funcionarios,
  COUNT(DISTINCT p.id) as produtos,
  COUNT(DISTINCT c.id) as clientes,
  COUNT(DISTINCT fo.id) as fornecedores,
  COUNT(DISTINCT v.id) as vendas,
  COUNT(DISTINCT os.id) as ordens_servico
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
LEFT JOIN produtos p ON p.empresa_id = e.id
LEFT JOIN clientes c ON c.empresa_id = e.id
LEFT JOIN fornecedores fo ON fo.empresa_id = e.id
LEFT JOIN vendas v ON v.empresa_id = e.id
LEFT JOIN ordens_servico os ON os.empresa_id = e.id
GROUP BY e.id, e.nome, e.cnpj, e.user_id
ORDER BY e.nome;

-- 5️⃣ VERIFICAR POSSÍVEIS DADOS SUSPEITOS RESTANTES

-- 5.1 - Produtos com códigos suspeitos
SELECT 
  '🔍 PRODUTOS SUSPEITOS RESTANTES' as secao,
  p.nome,
  p.codigo_barras,
  p.preco,
  e.nome as empresa
FROM produtos p
JOIN empresas e ON e.id = p.empresa_id
WHERE p.codigo_barras LIKE '%000%'
   OR p.codigo_barras LIKE '%111%'
   OR p.codigo_barras LIKE '%123%'
   OR p.nome ILIKE '%teste%'
   OR p.nome ILIKE '%produto%'
ORDER BY e.nome, p.nome;

-- 5.2 - Clientes com dados suspeitos
SELECT 
  '🔍 CLIENTES SUSPEITOS RESTANTES' as secao,
  c.nome,
  c.email,
  c.telefone,
  c.cpf_cnpj,
  e.nome as empresa
FROM clientes c
JOIN empresas e ON e.id = c.empresa_id
WHERE c.nome ILIKE '%cliente%'
   OR c.nome ILIKE '%teste%'
   OR c.email LIKE '%example%'
   OR c.telefone LIKE '%1234%'
   OR c.cpf_cnpj LIKE '%000%'
ORDER BY e.nome, c.nome;

-- 5.3 - Funcionários com dados suspeitos
SELECT 
  '🔍 FUNCIONÁRIOS SUSPEITOS RESTANTES' as secao,
  f.nome,
  f.email,
  f.status,
  e.nome as empresa
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id
WHERE f.nome ILIKE '%teste%'
   OR f.nome ILIKE '%admin%'
   OR f.email LIKE '%example%'
   OR f.email LIKE '%teste%'
ORDER BY e.nome, f.nome;

-- 6️⃣ VERIFICAR USUÁRIOS NO SUPABASE AUTH
SELECT 
  '👤 USUÁRIOS SUPABASE AUTH' as secao,
  au.email,
  au.created_at as data_registro,
  au.last_sign_in_at as ultimo_login,
  CASE 
    WHEN e.id IS NOT NULL THEN '✅ Tem empresa'
    ELSE '❌ Sem empresa'
  END as status_empresa
FROM auth.users au
LEFT JOIN empresas e ON e.user_id = au.id
ORDER BY au.created_at;

-- 7️⃣ VERIFICAR ASSINATURAS ATIVAS
SELECT 
  '💳 ASSINATURAS' as secao,
  s.user_id,
  au.email,
  s.status,
  s.expires_at,
  s.created_at,
  CASE 
    WHEN s.expires_at > NOW() THEN '✅ Ativa'
    ELSE '❌ Expirada'
  END as situacao
FROM subscriptions s
JOIN auth.users au ON au.id = s.user_id
ORDER BY s.expires_at DESC;

-- 8️⃣ ANÁLISE DE CONSISTÊNCIA FINAL
SELECT 
  '📈 ANÁLISE DE CONSISTÊNCIA' as secao,
  'Empresas com user_id' as metrica,
  COUNT(*) as valor,
  '100% devem ter user_id válido' as expectativa
FROM empresas 
WHERE user_id IS NOT NULL

UNION ALL

SELECT 
  '📈 ANÁLISE DE CONSISTÊNCIA' as secao,
  'Registros órfãos totais' as metrica,
  (
    SELECT COUNT(*) FROM produtos WHERE empresa_id NOT IN (SELECT id FROM empresas)
  ) + (
    SELECT COUNT(*) FROM clientes WHERE empresa_id NOT IN (SELECT id FROM empresas)
  ) + (
    SELECT COUNT(*) FROM funcionarios WHERE empresa_id NOT IN (SELECT id FROM empresas)
  ) as valor,
  '0 é o ideal' as expectativa

UNION ALL

SELECT 
  '📈 ANÁLISE DE CONSISTÊNCIA' as secao,
  'Empresas com dados' as metrica,
  COUNT(DISTINCT p.empresa_id) as valor,
  'Pelo menos 1 por empresa ativa' as expectativa
FROM produtos p
WHERE p.empresa_id IN (SELECT id FROM empresas);

-- =====================================================
-- 🎯 CRITÉRIOS DE VALIDAÇÃO
-- =====================================================
-- ✅ Todas empresas DEVEM ter user_id válido (UUID)
-- ✅ Zero registros órfãos em qualquer tabela
-- ✅ Nenhum dado com padrões de teste óbvios
-- ✅ Integridade referencial 100% preservada
-- ✅ Apenas dados legítimos de usuários reais
-- =====================================================

-- 🏁 RESULTADO ESPERADO:
-- Sistema 100% limpo com apenas dados reais de usuários
-- Pronto para ambiente de produção profissional