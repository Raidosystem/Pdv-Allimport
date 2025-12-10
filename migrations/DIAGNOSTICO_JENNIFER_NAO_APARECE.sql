-- 🔍 DIAGNÓSTICO COMPLETO - POR QUE JENNIFER NÃO APARECE?

-- ====================================
-- 1. JENNIFER EXISTE NA TABELA funcionarios?
-- ====================================
SELECT 
  '👤 JENNIFER NA TABELA funcionarios' as teste,
  id,
  nome,
  empresa_id,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  created_at
FROM funcionarios
WHERE nome = 'Jennifer Sousa'
ORDER BY created_at DESC;

-- ====================================
-- 2. JENNIFER TEM LOGIN NA TABELA login_funcionarios?
-- ====================================
SELECT 
  '🔑 JENNIFER NA TABELA login_funcionarios' as teste,
  id,
  funcionario_id,
  usuario,
  ativo,
  LENGTH(senha) as tamanho_senha,
  created_at
FROM login_funcionarios
WHERE funcionario_id IN (SELECT id FROM funcionarios WHERE nome = 'Jennifer Sousa')
ORDER BY created_at DESC;

-- ====================================
-- 3. O QUE A RPC listar_usuarios_ativos RETORNA?
-- ====================================
SELECT 
  '📋 RPC listar_usuarios_ativos' as teste,
  *
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00');

-- ====================================
-- 4. VERIFICAR A DEFINIÇÃO DA RPC
-- ====================================
SELECT 
  '🔧 DEFINIÇÃO DA RPC' as teste,
  pg_get_functiondef(oid) as definicao
FROM pg_proc
WHERE proname = 'listar_usuarios_ativos';

-- ====================================
-- 5. VERIFICAR FILTROS DA RPC
-- ====================================
-- Buscar TODOS os funcionários da empresa (sem filtros)
SELECT 
  '👥 TODOS OS FUNCIONÁRIOS (SEM FILTRO)' as teste,
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  tipo_admin
FROM funcionarios
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
ORDER BY nome;

-- ====================================
-- 6. COMPARAR JENNIFER COM CRISTIANO
-- ====================================
SELECT 
  '🔍 COMPARAÇÃO JENNIFER vs CRISTIANO' as teste,
  nome,
  usuario_ativo as ativo,
  senha_definida as tem_senha,
  primeiro_acesso,
  tipo_admin,
  CASE 
    WHEN usuario_ativo = true AND senha_definida = true THEN '✅ DEVERIA APARECER'
    ELSE '❌ NÃO APARECE (falta critério)'
  END as analise
FROM funcionarios
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
ORDER BY nome;
