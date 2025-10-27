-- =========================================
-- REMOVER DUPLICATAS DE FUNÇÕES E PERMISSÕES
-- =========================================

-- ⚠️ IMPORTANTE: Execute este script SOMENTE após verificar as duplicatas
-- com o script VERIFICAR_DUPLICATAS_FUNCOES.sql

-- BACKUP ANTES DE EXECUTAR:
-- Faça backup das tabelas: funcoes, permissoes, funcao_permissoes

BEGIN;

-- ====================
-- PASSO 1: REMOVER DUPLICATAS DE PERMISSÕES
-- ====================

-- 1.1. Criar tabela temporária com as permissões únicas (mantém a mais antiga)
CREATE TEMP TABLE permissoes_unicas AS
SELECT DISTINCT ON (recurso, acao)
  id,
  recurso,
  acao,
  descricao,
  categoria
FROM permissoes
ORDER BY recurso, acao, created_at ASC;

-- 1.2. Atualizar funcao_permissoes para apontar para as permissões únicas
UPDATE funcao_permissoes fp
SET permissao_id = pu.id
FROM permissoes_unicas pu
WHERE EXISTS (
  SELECT 1 FROM permissoes p
  WHERE p.id = fp.permissao_id
  AND p.recurso = pu.recurso
  AND p.acao = pu.acao
)
AND fp.permissao_id != pu.id;

-- 1.3. Remover permissões duplicadas (mantém apenas as da tabela temp)
DELETE FROM permissoes
WHERE id NOT IN (SELECT id FROM permissoes_unicas);

-- ====================
-- PASSO 2: REMOVER DUPLICATAS DE FUNÇÕES
-- ====================

-- 2.1. Criar tabela temporária com as funções únicas (mantém a mais antiga)
CREATE TEMP TABLE funcoes_unicas AS
SELECT DISTINCT ON (empresa_id, nome)
  id,
  empresa_id,
  nome,
  descricao
FROM funcoes
ORDER BY empresa_id, nome, created_at ASC;

-- 2.2. Atualizar funcao_permissoes para apontar para as funções únicas
UPDATE funcao_permissoes fp
SET funcao_id = fu.id
FROM funcoes_unicas fu
WHERE EXISTS (
  SELECT 1 FROM funcoes f
  WHERE f.id = fp.funcao_id
  AND f.empresa_id = fu.empresa_id
  AND f.nome = fu.nome
)
AND fp.funcao_id != fu.id;

-- 2.3. Atualizar funcionarios para apontar para as funções únicas
UPDATE funcionarios func
SET funcao_id = fu.id
FROM funcoes_unicas fu
WHERE EXISTS (
  SELECT 1 FROM funcoes f
  WHERE f.id = func.funcao_id
  AND f.empresa_id = fu.empresa_id
  AND f.nome = fu.nome
)
AND func.funcao_id != fu.id;

-- 2.4. Remover funções duplicadas (mantém apenas as da tabela temp)
DELETE FROM funcoes
WHERE id NOT IN (SELECT id FROM funcoes_unicas);

-- ====================
-- PASSO 3: REMOVER DUPLICATAS EM FUNCAO_PERMISSOES
-- ====================

-- 3.1. Remover linhas duplicadas na tabela de vínculo
DELETE FROM funcao_permissoes
WHERE id NOT IN (
  SELECT MIN(id)
  FROM funcao_permissoes
  GROUP BY empresa_id, funcao_id, permissao_id
);

-- ====================
-- PASSO 4: VERIFICAR RESULTADO
-- ====================

-- Verificar se ainda existem duplicatas de permissões
SELECT 
  'Duplicatas de Permissões Restantes' as verificacao,
  COUNT(*) as quantidade
FROM (
  SELECT recurso, acao, COUNT(*) as cnt
  FROM permissoes
  GROUP BY recurso, acao
  HAVING COUNT(*) > 1
) sub;

-- Verificar se ainda existem duplicatas de funções
SELECT 
  'Duplicatas de Funções Restantes' as verificacao,
  COUNT(*) as quantidade
FROM (
  SELECT empresa_id, nome, COUNT(*) as cnt
  FROM funcoes
  GROUP BY empresa_id, nome
  HAVING COUNT(*) > 1
) sub;

-- Verificar se ainda existem duplicatas em funcao_permissoes
SELECT 
  'Duplicatas de Vínculos Restantes' as verificacao,
  COUNT(*) as quantidade
FROM (
  SELECT empresa_id, funcao_id, permissao_id, COUNT(*) as cnt
  FROM funcao_permissoes
  GROUP BY empresa_id, funcao_id, permissao_id
  HAVING COUNT(*) > 1
) sub;

-- Se tudo estiver OK (todas as verificações = 0), faça COMMIT
-- Caso contrário, faça ROLLBACK

-- COMMIT; -- Descomente esta linha para confirmar as mudanças
-- ROLLBACK; -- Use esta linha se algo estiver errado
