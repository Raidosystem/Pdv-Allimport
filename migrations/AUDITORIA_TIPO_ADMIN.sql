-- ========================================
-- AUDITORIA E CORREÇÃO DE TIPO_ADMIN
-- ========================================
-- Garantir que apenas o dono da empresa tenha tipo_admin='admin_empresa'
-- Todos os outros funcionários devem ter tipo_admin='funcionario'

-- 1️⃣ LISTAR TODOS OS FUNCIONÁRIOS E SEUS TIPOS
SELECT 
  '📊 AUDITORIA DE TIPOS DE ADMIN' as etapa,
  f.id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.empresa_id,
  e.email as email_empresa,
  CASE 
    WHEN f.empresa_id = f.user_id THEN '✅ É o dono da empresa'
    WHEN f.tipo_admin = 'admin_empresa' AND f.empresa_id != f.user_id THEN '❌ FUNCIONÁRIO com admin_empresa (ERRO)'
    WHEN f.tipo_admin = 'funcionario' AND f.empresa_id != f.user_id THEN '✅ Funcionário normal (correto)'
    WHEN f.tipo_admin = 'super_admin' THEN '👑 Super Admin (apenas novaradiosystem)'
    ELSE '⚠️ Situação desconhecida'
  END as validacao,
  func.nome as funcao
FROM funcionarios f
LEFT JOIN auth.users e ON e.id = f.empresa_id
LEFT JOIN funcoes func ON func.id = f.funcao_id
ORDER BY 
  CASE f.tipo_admin
    WHEN 'super_admin' THEN 1
    WHEN 'admin_empresa' THEN 2
    WHEN 'funcionario' THEN 3
    ELSE 4
  END,
  f.nome;

-- 2️⃣ IDENTIFICAR FUNCIONÁRIOS COM TIPO ERRADO
SELECT 
  '🚨 FUNCIONÁRIOS COM TIPO_ADMIN INCORRETO' as etapa,
  f.id,
  f.nome,
  f.email,
  f.tipo_admin as tipo_atual,
  'funcionario' as tipo_correto,
  f.empresa_id,
  f.user_id,
  e.email as dono_empresa
FROM funcionarios f
LEFT JOIN auth.users e ON e.id = f.empresa_id
WHERE f.tipo_admin = 'admin_empresa' -- Tem tipo admin_empresa
  AND f.empresa_id != f.user_id -- MAS não é o dono (empresa_id diferente de user_id)
  AND f.email NOT IN ('novaradiosystem@outlook.com'); -- E não é o super admin

-- 3️⃣ CORRIGIR FUNCIONÁRIOS COM TIPO ERRADO
-- Todos os funcionários (não donos) devem ser tipo_admin='funcionario'
UPDATE funcionarios
SET 
  tipo_admin = 'funcionario',
  updated_at = now()
WHERE tipo_admin = 'admin_empresa' -- Atualmente marcado como admin
  AND empresa_id != user_id -- MAS não é o dono da empresa
  AND email NOT IN ('novaradiosystem@outlook.com'); -- E não é o super admin

-- 4️⃣ GARANTIR QUE DONOS DE EMPRESA SEJAM ADMIN_EMPRESA
UPDATE funcionarios
SET 
  tipo_admin = 'admin_empresa',
  updated_at = now()
WHERE empresa_id = user_id -- É o dono (user_id = empresa_id)
  AND tipo_admin != 'super_admin' -- Não é super admin
  AND tipo_admin != 'admin_empresa'; -- E ainda não está marcado corretamente

-- 5️⃣ VERIFICAR CRISTIANO (assistenciaallimport10@gmail.com)
SELECT 
  '👤 VALIDAÇÃO DO CRISTIANO' as etapa,
  f.id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.empresa_id,
  f.user_id,
  CASE 
    WHEN f.tipo_admin = 'admin_empresa' THEN '✅ Tipo correto (admin_empresa)'
    ELSE '❌ ERRO: Deveria ser admin_empresa, está como ' || f.tipo_admin
  END as validacao,
  CASE 
    WHEN f.empresa_id = f.user_id THEN '✅ É o dono (empresa_id = user_id)'
    ELSE '❌ ERRO: empresa_id != user_id'
  END as validacao_dono
FROM funcionarios f
WHERE f.email ILIKE '%assistenciaallimport10%'
   OR f.user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com');

-- 6️⃣ VERIFICAR JENNIFER (deve ser funcionário comum)
SELECT 
  '👤 VALIDAÇÃO DA JENNIFER' as etapa,
  f.id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.funcao_id,
  func.nome as funcao,
  f.empresa_id,
  f.user_id,
  CASE 
    WHEN f.tipo_admin = 'funcionario' THEN '✅ Tipo correto (funcionario)'
    ELSE '❌ ERRO: Deveria ser funcionario, está como ' || f.tipo_admin
  END as validacao_tipo,
  CASE 
    WHEN func.nome ILIKE '%vendedor%' THEN '✅ Função correta (Vendedor)'
    ELSE '⚠️ Função: ' || COALESCE(func.nome, 'SEM FUNÇÃO')
  END as validacao_funcao,
  CASE 
    WHEN f.empresa_id != f.user_id THEN '✅ Não é dono (empresa_id != user_id)'
    ELSE '❌ ERRO: Está marcado como dono'
  END as validacao_dono
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE f.email = 'jennifer_sousa@temp.local'
   OR LOWER(f.nome) LIKE '%jennifer%sousa%';

-- 7️⃣ RESULTADO FINAL - TODOS OS FUNCIONÁRIOS
SELECT 
  '✅ RESULTADO FINAL' as etapa,
  f.nome,
  f.email,
  f.tipo_admin,
  func.nome as funcao,
  CASE 
    WHEN f.tipo_admin = 'super_admin' THEN '👑 Super Admin (sistema)'
    WHEN f.tipo_admin = 'admin_empresa' AND f.empresa_id = f.user_id THEN '🏢 Admin Empresa (dono)'
    WHEN f.tipo_admin = 'funcionario' THEN '👤 Funcionário'
    ELSE '❌ CONFIGURAÇÃO INVÁLIDA'
  END as categoria,
  (SELECT COUNT(*) 
   FROM funcao_permissoes fp 
   WHERE fp.funcao_id = f.funcao_id
  ) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
ORDER BY 
  CASE f.tipo_admin
    WHEN 'super_admin' THEN 1
    WHEN 'admin_empresa' THEN 2
    WHEN 'funcionario' THEN 3
  END,
  f.nome;

-- ========================================
-- REGRAS DO SISTEMA
-- ========================================
/*
TIPOS DE ADMIN:
1. super_admin = Desenvolvedor do sistema (novaradiosystem@outlook.com)
   - Acesso total a TUDO
   - Pode ver dados de todas as empresas

2. admin_empresa = Dono da empresa (quem comprou o sistema)
   - Acesso total aos dados da SUA empresa
   - Pode criar/editar funcionários
   - Pode configurar o sistema
   - IDENTIFICADO POR: empresa_id = user_id

3. funcionario = Funcionário da empresa
   - Acesso limitado conforme função (Vendedor, Caixa, etc)
   - NÃO pode acessar administração
   - IDENTIFICADO POR: empresa_id != user_id

VALIDAÇÃO:
- Se funcionário tem tipo_admin='admin_empresa' MAS empresa_id != user_id → ERRO
- Jennifer deve ser tipo_admin='funcionario' com função 'Vendedor'
- Cristiano deve ser tipo_admin='admin_empresa' com empresa_id = user_id
*/
