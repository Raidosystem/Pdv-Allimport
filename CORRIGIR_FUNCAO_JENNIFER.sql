-- ========================================
-- CORRIGIR FUNÇÃO DA JENNIFER
-- ========================================
-- Problema: Jennifer está com função de TÉCNICO mas deveria ser VENDEDOR
-- Causa: Script APLICAR_TEMPLATES_FUNCIONARIOS.sql aplicou template errado

-- ========================================
-- 1️⃣ DIAGNÓSTICO: Verificar situação atual
-- ========================================
SELECT 
  f.nome,
  f.email,
  f.tipo_admin,
  func.nome as funcao_atual,
  func.id as funcao_id,
  f.id as funcionario_id
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE f.email LIKE '%jennifer%' OR f.email LIKE '%sousajenifer%';

-- Resultado esperado:
-- Jennifer | sousajenifer895@gmail.com | funcionario | Técnico (ERRADO!)

-- ========================================
-- 2️⃣ VERIFICAR FUNÇÕES DISPONÍVEIS
-- ========================================
SELECT 
  id,
  nome,
  descricao,
  empresa_id
FROM funcoes
WHERE nome IN ('Vendedor', 'Técnico', 'Vendedora')
ORDER BY nome;

-- ========================================
-- 3️⃣ CORREÇÃO: Atribuir função VENDEDOR
-- ========================================
-- ⚠️ IMPORTANTE: Substitua os UUIDs pelos valores reais do diagnóstico acima

UPDATE funcionarios
SET 
  funcao_id = (
    SELECT id 
    FROM funcoes 
    WHERE nome IN ('Vendedor', 'Vendedora')
    AND empresa_id = (SELECT empresa_id FROM funcionarios WHERE email LIKE '%jennifer%' LIMIT 1)
    LIMIT 1
  )
WHERE email LIKE '%jennifer%' OR email LIKE '%sousajenifer%';

-- ========================================
-- 4️⃣ VERIFICAÇÃO: Confirmar correção
-- ========================================
SELECT 
  f.nome,
  f.email,
  f.tipo_admin,
  func.nome as funcao_atualizada,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE f.email LIKE '%jennifer%' OR f.email LIKE '%sousajenifer%'
GROUP BY f.id, f.nome, f.email, f.tipo_admin, func.nome;

-- Resultado esperado:
-- Jennifer | sousajenifer895@gmail.com | funcionario | Vendedor | 14 permissões (aprox)

-- ========================================
-- 5️⃣ LISTAR PERMISSÕES DA JENNIFER APÓS CORREÇÃO
-- ========================================
SELECT 
  f.nome as funcionario,
  func.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcionarios f
JOIN funcoes func ON func.id = f.funcao_id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email LIKE '%jennifer%' OR f.email LIKE '%sousajenifer%'
ORDER BY p.recurso, p.acao;

-- ✅ Permissões esperadas para VENDEDOR:
-- vendas:read, vendas:create, vendas:update
-- clientes:read, clientes:create, clientes:update
-- produtos:read
-- caixa:read
-- relatorios:read

-- ❌ NÃO deve ter:
-- ordens_servico:* (isso é de TÉCNICO)
-- configuracoes:* (isso é de ADMIN)
-- produtos:delete (isso é de GERENTE/ADMIN)

-- ========================================
-- 📋 DOCUMENTAÇÃO
-- ========================================
-- FUNÇÕES PADRÃO DO SISTEMA:
-- 
-- 🔴 ADMIN           → Acesso total (tipo_admin = 'admin_empresa')
-- 🟣 GERENTE         → Gerenciar, mas não configurar sistema
-- 🔵 VENDEDOR        → Vendas, clientes, produtos (read), caixa (read)
-- 🟢 TÉCNICO         → Ordens de Serviço + vendas básicas
-- 🟡 CAIXA           → Caixa + vendas básicas
--
-- ⚠️ REGRA CRÍTICA:
-- - funcao_id define as permissões do funcionário
-- - tipo_admin define se é admin (apenas para donos)
-- - NUNCA alterar tipo_admin de funcionário para 'admin_empresa'
--   (isso dá acesso total!)
