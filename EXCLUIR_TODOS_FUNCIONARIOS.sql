-- 🗑️ EXCLUIR TODOS OS FUNCIONÁRIOS (NÃO ADMIN)

-- ⚠️ ATENÇÃO: Este script vai EXCLUIR permanentemente TODOS os funcionários
-- Mantém apenas os admin_empresa (donos do sistema)

-- ====================================
-- 1. BACKUP: Ver o que vai ser excluído
-- ====================================
SELECT 
  '⚠️ ESTES FUNCIONÁRIOS SERÃO EXCLUÍDOS' as aviso,
  f.id,
  f.nome,
  f.email,
  e.nome as empresa,
  func.nome as funcao
FROM funcionarios f
JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE f.tipo_admin != 'admin_empresa'
ORDER BY e.nome, f.nome;

-- ====================================
-- 2. CONTAGEM: Quantos serão excluídos?
-- ====================================
SELECT 
  '📊 TOTAL A EXCLUIR' as info,
  COUNT(*) as total_funcionarios
FROM funcionarios
WHERE tipo_admin != 'admin_empresa';

-- ====================================
-- 3. EXCLUIR LOGINS DOS FUNCIONÁRIOS (primeiro, por FK)
-- ====================================
DELETE FROM login_funcionarios
WHERE funcionario_id IN (
  SELECT id FROM funcionarios 
  WHERE tipo_admin != 'admin_empresa'
);

-- ====================================
-- 4. EXCLUIR FUNCIONÁRIOS
-- ====================================
DELETE FROM funcionarios
WHERE tipo_admin != 'admin_empresa';

-- ====================================
-- 5. VERIFICAR RESULTADO
-- ====================================
SELECT 
  '✅ LIMPEZA CONCLUÍDA' as status,
  COUNT(CASE WHEN tipo_admin = 'admin_empresa' THEN 1 END) as admins_mantidos,
  COUNT(CASE WHEN tipo_admin != 'admin_empresa' THEN 1 END) as funcionarios_restantes
FROM funcionarios;

-- ====================================
-- 6. VER EMPRESAS E SEUS ADMINS
-- ====================================
SELECT 
  '👔 EMPRESAS RESTANTES' as tipo,
  e.nome as empresa,
  e.tipo_conta,
  f.nome as admin,
  f.email
FROM empresas e
JOIN funcionarios f ON f.empresa_id = e.id AND f.tipo_admin = 'admin_empresa'
ORDER BY e.tipo_conta, e.nome;

-- ====================================
-- 7. RESETAR SEQUENCE (opcional - para começar IDs do zero)
-- ====================================
-- Descomente se quiser resetar os IDs:
-- SELECT setval('funcionarios_id_seq', (SELECT MAX(id) FROM funcionarios));
-- SELECT setval('login_funcionarios_id_seq', 1, false);
