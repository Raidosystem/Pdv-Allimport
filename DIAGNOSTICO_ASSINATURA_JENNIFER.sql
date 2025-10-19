-- 🔍 DIAGNOSTICAR PROBLEMA DE ASSINATURA NO LOGIN LOCAL

-- ====================================
-- 1. VERIFICAR DADOS DO FUNCIONÁRIO JENNIFER
-- ====================================
SELECT 
  '👤 JENNIFER' as info,
  f.id as funcionario_id,
  f.nome,
  f.email as funcionario_email,
  f.empresa_id,
  e.email as empresa_email,
  e.tipo_conta,
  e.data_fim_teste,
  CASE 
    WHEN e.tipo_conta = 'assinatura_ativa' THEN 'ACESSO TOTAL'
    WHEN e.tipo_conta = 'teste_ativo' AND e.data_fim_teste > NOW() THEN 'EM TESTE'
    WHEN e.tipo_conta = 'teste_expirado' THEN 'TESTE EXPIRADO'
    ELSE 'SEM ACESSO'
  END as status_acesso
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id
WHERE f.nome = 'Jennifer Sousa';

-- ====================================
-- 2. VERIFICAR EMPRESA DA JENNIFER
-- ====================================
SELECT 
  '🏢 EMPRESA' as info,
  id,
  nome,
  email,
  tipo_conta,
  data_cadastro,
  data_fim_teste,
  CASE 
    WHEN tipo_conta = 'assinatura_ativa' THEN '✅ TEM ACESSO'
    WHEN tipo_conta = 'teste_ativo' AND data_fim_teste > NOW() THEN '⏳ EM TESTE'
    WHEN tipo_conta = 'teste_expirado' THEN '❌ TESTE EXPIRADO'
    WHEN tipo_conta = 'super_admin' THEN '🔑 SUPER ADMIN'
    ELSE '❓ INDEFINIDO'
  END as status
FROM empresas
WHERE id = (SELECT empresa_id FROM funcionarios WHERE nome = 'Jennifer Sousa' LIMIT 1);

-- ====================================
-- 3. TESTAR VALIDAÇÃO DE SENHA JENNIFER
-- ====================================
SELECT 
  '🧪 VALIDAÇÃO JENNIFER' as teste,
  *
FROM validar_senha_local(
  (SELECT id FROM funcionarios WHERE nome = 'Jennifer Sousa' LIMIT 1),
  '123456'
);

-- ====================================
-- 4. RESUMO DO PROBLEMA
-- ====================================
SELECT 
  '📝 PROBLEMA' as info,
  'Login local de Jennifer retorna empresa_id correto?' as pergunta_1,
  'SubscriptionGuard usa empresa_id ou user.email?' as pergunta_2,
  'Jennifer.empresa_id tem tipo_conta = assinatura_ativa?' as pergunta_3;
