-- 🔍 PROCURAR JENNIFER SOUSA

-- ====================================
-- 1. BUSCAR POR NOME (TODAS EMPRESAS)
-- ====================================
SELECT 
  '🔍 BUSCA POR NOME' as info,
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  tipo_admin,
  status,
  empresa_id,
  funcao_id,
  created_at
FROM funcionarios
WHERE nome ILIKE '%Jennifer%' OR nome ILIKE '%Sousa%'
ORDER BY created_at DESC;

-- ====================================
-- 2. VER PÁGINA ActivateUsersPage - ONDE CRIA FUNCIONÁRIO
-- ====================================
-- Verificar se há erro no código de criação
SELECT 
  '📋 ESTRUTURA TABELA' as info,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcionarios'
  AND column_name IN ('nome', 'empresa_id', 'funcao_id', 'usuario_ativo', 'senha_definida', 'tipo_admin', 'status')
ORDER BY ordinal_position;

-- ====================================
-- 3. VERIFICAR RLS DA TABELA FUNCIONARIOS
-- ====================================
SELECT 
  '🔒 RLS FUNCIONARIOS' as info,
  policyname,
  cmd as operacao,
  qual as tipo
FROM pg_policies
WHERE tablename = 'funcionarios'
ORDER BY cmd, policyname;

-- ====================================
-- 4. TESTAR INSERÇÃO MANUAL
-- ====================================
-- Vamos criar Jennifer manualmente para testar
INSERT INTO funcionarios (
  empresa_id,
  nome,
  email,
  tipo_admin,
  funcao_id,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  status
)
VALUES (
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Jennifer Sousa',
  NULL,  -- Sem email
  'funcionario',  -- Não é admin
  (SELECT id FROM funcoes WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00' AND nome = 'Vendedor' LIMIT 1),
  true,
  true,
  true,
  'ativo'
)
RETURNING 
  id,
  nome,
  funcao_id,
  usuario_ativo,
  senha_definida,
  'CRIADO MANUALMENTE' as status;

-- ====================================
-- 5. CRIAR LOGIN PARA JENNIFER
-- ====================================
INSERT INTO login_funcionarios (funcionario_id, usuario, senha, ativo)
SELECT 
  f.id,
  'jennifer',
  crypt('123456', gen_salt('bf')),
  true
FROM funcionarios f
WHERE f.nome = 'Jennifer Sousa'
  AND NOT EXISTS (
    SELECT 1 FROM login_funcionarios lf WHERE lf.funcionario_id = f.id
  )
RETURNING funcionario_id, usuario, 'LOGIN CRIADO (senha: 123456)' as info;

-- ====================================
-- 6. TESTAR RPC COM JENNIFER
-- ====================================
SELECT 
  '🧪 RPC APÓS CRIAR JENNIFER' as teste,
  *
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00');

-- ====================================
-- 7. VERIFICAR TODOS FUNCIONÁRIOS AGORA
-- ====================================
SELECT 
  '✅ FUNCIONÁRIOS FINAIS' as info,
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  tipo_admin,
  funcao_id
FROM funcionarios
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
ORDER BY created_at DESC;
