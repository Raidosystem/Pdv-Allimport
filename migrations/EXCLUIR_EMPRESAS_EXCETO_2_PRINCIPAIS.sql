-- 🗑️ EXCLUIR TODAS AS EMPRESAS EXCETO AS 2 PRINCIPAIS

-- ⚠️ ATENÇÃO: Este script vai MANTER apenas:
-- 1. cece118d-e040-471a-873f-db7d5c104089 (novaradiosystem@outlook.com) - SUPER ADMIN
-- 2. f1726fcf-d23b-4cca-8079-39314ae56e00 (assistenciaallimport10@gmail.com) - CLIENTE PAGO

-- ====================================
-- PASSO 1: PREVIEW - VER O QUE SERÁ MANTIDO
-- ====================================
SELECT 
  '✅ ESTAS EMPRESAS SERÃO MANTIDAS' as acao,
  id,
  nome,
  email,
  cnpj,
  tipo_conta,
  is_super_admin
FROM empresas
WHERE id IN (
  'cece118d-e040-471a-873f-db7d5c104089',
  'f1726fcf-d23b-4cca-8079-39314ae56e00'
)
ORDER BY is_super_admin DESC NULLS LAST;

-- ====================================
-- PASSO 2: PREVIEW - VER O QUE SERÁ EXCLUÍDO
-- ====================================
SELECT 
  '🗑️ ESTAS EMPRESAS SERÃO EXCLUÍDAS' as acao,
  e.id,
  e.nome,
  e.email,
  e.cnpj,
  e.tipo_conta,
  COUNT(f.id) as total_funcionarios,
  COUNT(CASE WHEN f.tipo_admin = 'admin_empresa' THEN 1 END) as admins
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
WHERE e.id NOT IN (
  'cece118d-e040-471a-873f-db7d5c104089',
  'f1726fcf-d23b-4cca-8079-39314ae56e00'
)
GROUP BY e.id, e.nome, e.email, e.cnpj, e.tipo_conta
ORDER BY e.nome;

-- Total a excluir
SELECT 
  '📊 RESUMO DA EXCLUSÃO' as info,
  COUNT(*) as total_empresas_a_excluir,
  SUM(funcionarios_count) as total_funcionarios_a_excluir
FROM (
  SELECT 
    e.id,
    COUNT(f.id) as funcionarios_count
  FROM empresas e
  LEFT JOIN funcionarios f ON f.empresa_id = e.id
  WHERE e.id NOT IN (
    'cece118d-e040-471a-873f-db7d5c104089',
    'f1726fcf-d23b-4cca-8079-39314ae56e00'
  )
  GROUP BY e.id
) subquery;

-- ====================================
-- ⚠️ CONFIRME ACIMA ANTES DE CONTINUAR! ⚠️
-- ====================================
-- Se estiver tudo correto, execute as linhas abaixo:
-- ====================================

-- PASSO 3: EXCLUIR FUNCIONÁRIOS DAS EMPRESAS QUE SERÃO REMOVIDAS
DELETE FROM funcionarios
WHERE empresa_id NOT IN (
  'cece118d-e040-471a-873f-db7d5c104089',
  'f1726fcf-d23b-4cca-8079-39314ae56e00'
);

-- PASSO 4: EXCLUIR FUNÇÕES DAS EMPRESAS QUE SERÃO REMOVIDAS
DELETE FROM funcoes
WHERE empresa_id NOT IN (
  'cece118d-e040-471a-873f-db7d5c104089',
  'f1726fcf-d23b-4cca-8079-39314ae56e00'
);

-- PASSO 5: EXCLUIR PERMISSÕES DAS EMPRESAS QUE SERÃO REMOVIDAS
DELETE FROM funcao_permissoes
WHERE empresa_id NOT IN (
  'cece118d-e040-471a-873f-db7d5c104089',
  'f1726fcf-d23b-4cca-8079-39314ae56e00'
);

-- PASSO 6: EXCLUIR AS EMPRESAS (MENOS AS 2 PRINCIPAIS)
DELETE FROM empresas
WHERE id NOT IN (
  'cece118d-e040-471a-873f-db7d5c104089',
  'f1726fcf-d23b-4cca-8079-39314ae56e00'
);

-- ====================================
-- PASSO 7: VERIFICAR RESULTADO FINAL
-- ====================================
SELECT 
  '✅ EXCLUSÃO CONCLUÍDA' as status,
  COUNT(*) as total_empresas_restantes
FROM empresas;

-- Ver empresas restantes (deve ser 2)
SELECT 
  '📋 EMPRESAS RESTANTES' as titulo,
  CASE 
    WHEN e.is_super_admin = true THEN '🔐 SUPER ADMIN'
    WHEN e.tipo_conta = 'assinatura_ativa' THEN '💰 CLIENTE PAGO'
    ELSE '❓ OUTRO'
  END as tipo,
  e.id,
  e.nome,
  e.email,
  e.cnpj,
  e.tipo_conta,
  COUNT(f.id) as funcionarios
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
GROUP BY e.id, e.is_super_admin, e.tipo_conta, e.nome, e.email, e.cnpj
ORDER BY e.is_super_admin DESC NULLS LAST;

-- Verificar se não há mais duplicatas
SELECT 
  '✅ VERIFICAÇÃO FINAL' as titulo,
  'Empresas duplicadas' as item,
  COUNT(*) as deve_ser_zero
FROM (
  SELECT nome, COUNT(*) as qtd
  FROM empresas
  GROUP BY nome
  HAVING COUNT(*) > 1
) duplicatas;
