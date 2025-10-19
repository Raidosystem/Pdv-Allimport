-- 🎯 SOLUÇÃO: Permitir múltiplos NULL na constraint

-- ⚠️ PROBLEMA ATUAL:
-- A constraint 'funcionarios_empresa_id_email_key' impede:
-- - Criar múltiplos funcionários com email = NULL para a mesma empresa
-- - Mas precisamos criar funcionários SEM email!

-- ✅ SOLUÇÃO:
-- Dropar a constraint antiga e criar uma nova que:
-- - Permite UNIQUE apenas quando email NÃO é NULL
-- - Permite múltiplos NULL (PostgreSQL permite por padrão em UNIQUE)

-- 1. Dropar constraint antiga
ALTER TABLE funcionarios 
DROP CONSTRAINT IF EXISTS funcionarios_empresa_id_email_key;

-- 2. Criar constraint parcial (só valida quando email não é NULL)
CREATE UNIQUE INDEX funcionarios_empresa_id_email_unique
ON funcionarios (empresa_id, email)
WHERE email IS NOT NULL;

-- 3. Verificar resultado
SELECT 
  '✅ Constraint atualizada' as status,
  'Agora pode criar funcionários sem email' as resultado;

-- 4. Testar: Ver quantos funcionários sem email existem
SELECT 
  '📊 Funcionários SEM email' as tipo,
  empresa_id,
  COUNT(*) as total
FROM funcionarios
WHERE email IS NULL
GROUP BY empresa_id
ORDER BY total DESC
LIMIT 10;

-- 5. Ver constraint nova
SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'funcionarios'
AND indexname LIKE '%email%';
