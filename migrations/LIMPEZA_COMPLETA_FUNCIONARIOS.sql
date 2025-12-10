-- 🗑️ LIMPEZA COMPLETA: Excluir FUNCIONÁRIOS e ÓRFÃOS

-- ⚠️ ATENÇÃO: Este script vai:
-- 1. Excluir os 9 funcionários ÓRFÃOS (sem empresa)
-- 2. Excluir TODOS os funcionários normais (mantém só admin_empresa)

-- ====================================
-- PASSO 1: VER O QUE VAI SER EXCLUÍDO
-- ====================================

-- Funcionários ÓRFÃOS (sem empresa válida)
SELECT 
  '🗑️ ÓRFÃOS A EXCLUIR' as tipo,
  f.id,
  f.nome,
  f.email,
  f.tipo_admin,
  'SEM EMPRESA VÁLIDA' as motivo
FROM funcionarios f
WHERE NOT EXISTS (
  SELECT 1 FROM empresas e WHERE e.id = f.empresa_id
)
ORDER BY f.nome;

-- Funcionários NORMAIS (com empresa, mas não são admin)
SELECT 
  '🗑️ FUNCIONÁRIOS A EXCLUIR' as tipo,
  f.id,
  f.nome,
  f.email,
  e.nome as empresa,
  'NÃO É ADMIN' as motivo
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id
WHERE f.tipo_admin != 'admin_empresa'
ORDER BY e.nome, f.nome;

-- Total a excluir
SELECT 
  '📊 TOTAL A EXCLUIR' as resumo,
  COUNT(CASE WHEN NOT EXISTS (SELECT 1 FROM empresas e WHERE e.id = f.empresa_id) THEN 1 END) as orfaos,
  COUNT(CASE WHEN f.tipo_admin != 'admin_empresa' AND EXISTS (SELECT 1 FROM empresas e WHERE e.id = f.empresa_id) THEN 1 END) as funcionarios,
  COUNT(CASE WHEN f.tipo_admin != 'admin_empresa' OR NOT EXISTS (SELECT 1 FROM empresas e WHERE e.id = f.empresa_id) THEN 1 END) as total
FROM funcionarios f;

-- ====================================
-- PASSO 2: EXCLUIR LOGINS (FK primeiro)
-- ====================================

-- Excluir logins de ÓRFÃOS
DELETE FROM login_funcionarios
WHERE funcionario_id IN (
  SELECT f.id FROM funcionarios f
  WHERE NOT EXISTS (
    SELECT 1 FROM empresas e WHERE e.id = f.empresa_id
  )
);

-- Excluir logins de FUNCIONÁRIOS normais
DELETE FROM login_funcionarios
WHERE funcionario_id IN (
  SELECT f.id FROM funcionarios f
  WHERE f.tipo_admin != 'admin_empresa'
  AND EXISTS (
    SELECT 1 FROM empresas e WHERE e.id = f.empresa_id
  )
);

-- ====================================
-- PASSO 3: EXCLUIR FUNCIONÁRIOS
-- ====================================

-- Excluir ÓRFÃOS
DELETE FROM funcionarios
WHERE NOT EXISTS (
  SELECT 1 FROM empresas e WHERE e.id = empresa_id
);

-- Excluir FUNCIONÁRIOS normais
DELETE FROM funcionarios
WHERE tipo_admin != 'admin_empresa';

-- ====================================
-- PASSO 4: VERIFICAR RESULTADO
-- ====================================

SELECT 
  '✅ LIMPEZA CONCLUÍDA' as status,
  COUNT(*) as total_restante,
  COUNT(CASE WHEN tipo_admin = 'admin_empresa' THEN 1 END) as admins_mantidos,
  COUNT(CASE WHEN tipo_admin != 'admin_empresa' THEN 1 END) as funcionarios_restantes
FROM funcionarios;

-- Ver o que sobrou
SELECT 
  '👔 EMPRESAS E ADMINS RESTANTES' as tipo,
  e.nome as empresa,
  e.cnpj,
  f.nome as admin,
  f.email as email_admin
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id AND f.tipo_admin = 'admin_empresa'
ORDER BY e.nome;

-- Verificar órfãos (deve ser 0)
SELECT 
  '✅ ÓRFÃOS RESTANTES' as verificacao,
  COUNT(*) as deve_ser_zero
FROM funcionarios f
WHERE NOT EXISTS (
  SELECT 1 FROM empresas e WHERE e.id = f.empresa_id
);
