-- 🔍 VERIFICAR CONSTRAINT DE EMAIL

-- Ver todas as constraints da tabela funcionarios
SELECT
  conname as constraint_name,
  pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'funcionarios'::regclass
ORDER BY conname;

-- Ver funcionários com email NULL
SELECT 
  '📊 Funcionários com email NULL' as status,
  empresa_id,
  COUNT(*) as total
FROM funcionarios
WHERE email IS NULL
GROUP BY empresa_id
ORDER BY total DESC;

-- Ver duplicatas potenciais
SELECT 
  '⚠️ Duplicatas (empresa_id + email)' as status,
  empresa_id,
  email,
  COUNT(*) as duplicatas
FROM funcionarios
WHERE email IS NOT NULL
GROUP BY empresa_id, email
HAVING COUNT(*) > 1;
