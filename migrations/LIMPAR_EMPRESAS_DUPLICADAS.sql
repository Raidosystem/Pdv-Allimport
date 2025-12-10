-- 🗑️ LIMPAR EMPRESAS DUPLICADAS E SEM ADMIN

-- ⚠️ ATENÇÃO: Este script vai:
-- 1. Manter apenas empresas com admin ativo
-- 2. Excluir empresas duplicadas sem admin
-- 3. Excluir empresas de teste sem funcionários

-- ====================================
-- PASSO 1: VER O QUE SERÁ EXCLUÍDO
-- ====================================

-- Empresas SEM admin (serão excluídas)
SELECT 
  '🗑️ EMPRESAS SEM ADMIN (EXCLUIR)' as acao,
  e.id,
  e.nome,
  e.email,
  e.cnpj,
  e.tipo_conta
FROM empresas e
WHERE NOT EXISTS (
  SELECT 1 FROM funcionarios f
  WHERE f.empresa_id = e.id
  AND f.tipo_admin = 'admin_empresa'
)
ORDER BY e.nome;

-- Total a excluir
SELECT 
  '📊 TOTAL A EXCLUIR' as info,
  COUNT(*) as empresas_sem_admin
FROM empresas e
WHERE NOT EXISTS (
  SELECT 1 FROM funcionarios f
  WHERE f.empresa_id = e.id
  AND f.tipo_admin = 'admin_empresa'
);

-- ====================================
-- PASSO 2: EXCLUIR EMPRESAS SEM ADMIN
-- ====================================

-- Excluir funcionários órfãos dessas empresas (se houver)
DELETE FROM funcionarios
WHERE empresa_id IN (
  SELECT e.id FROM empresas e
  WHERE NOT EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.empresa_id = e.id
    AND f.tipo_admin = 'admin_empresa'
  )
);

-- Excluir funções dessas empresas (se houver)
DELETE FROM funcoes
WHERE empresa_id IN (
  SELECT e.id FROM empresas e
  WHERE NOT EXISTS (
    SELECT 1 FROM funcionarios f
    WHERE f.empresa_id = e.id
    AND f.tipo_admin = 'admin_empresa'
  )
);

-- Excluir as empresas sem admin
DELETE FROM empresas
WHERE NOT EXISTS (
  SELECT 1 FROM funcionarios f
  WHERE f.empresa_id = empresas.id
  AND f.tipo_admin = 'admin_empresa'
);

-- ====================================
-- PASSO 3: VERIFICAR RESULTADO
-- ====================================

SELECT 
  '✅ LIMPEZA CONCLUÍDA' as status,
  COUNT(*) as total_empresas_restantes,
  COUNT(CASE WHEN tipo_conta = 'assinatura_ativa' THEN 1 END) as clientes_pagos,
  COUNT(CASE WHEN tipo_conta = 'teste_ativo' THEN 1 END) as em_teste
FROM empresas;

-- Ver empresas restantes
SELECT 
  '📋 EMPRESAS RESTANTES' as titulo,
  e.nome,
  e.email,
  e.tipo_conta,
  COUNT(f.id) as total_funcionarios,
  COUNT(CASE WHEN f.tipo_admin = 'admin_empresa' THEN 1 END) as admins
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
GROUP BY e.id, e.nome, e.email, e.tipo_conta
ORDER BY e.tipo_conta, e.nome;

-- ====================================
-- PASSO 4: VERIFICAR DUPLICATAS (deve ser 0)
-- ====================================

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
