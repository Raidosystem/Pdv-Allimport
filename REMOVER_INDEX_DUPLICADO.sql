-- 🎯 REMOVER ÍNDICE DUPLICADO QUE BLOQUEIA NULL

-- ⚠️ PROBLEMA:
-- Temos 2 índices UNIQUE para (empresa_id, email):
-- 1. idx_funcionarios_empresa_email_unique (ANTIGO - sem WHERE)
-- 2. funcionarios_empresa_id_email_unique (NOVO - com WHERE email IS NOT NULL)
-- O antigo está causando o erro de duplicate key!

-- ✅ SOLUÇÃO: Remover o índice antigo

-- 1. Remover o índice antigo (sem WHERE clause)
DROP INDEX IF EXISTS idx_funcionarios_empresa_email_unique;

-- 2. Verificar que só sobrou o índice correto
SELECT 
  '✅ Índices restantes' as status,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'funcionarios'
AND indexname LIKE '%email%'
ORDER BY indexname;

-- 3. Testar: Deveria mostrar apenas 2 índices agora:
-- - idx_funcionarios_email (busca simples)
-- - funcionarios_empresa_id_email_unique (UNIQUE com WHERE email IS NOT NULL)

-- 4. Confirmar que funcionários com NULL podem ser criados
SELECT 
  '📊 TESTE: Funcionários sem email por empresa' as teste,
  empresa_id,
  COUNT(*) as total_sem_email
FROM funcionarios
WHERE email IS NULL
GROUP BY empresa_id
ORDER BY total_sem_email DESC
LIMIT 10;

-- 5. Resultado esperado
SELECT 
  '✅ PRONTO!' as status,
  'Agora pode criar quantos funcionários sem email quiser' as resultado,
  'O único UNIQUE restante só valida quando email IS NOT NULL' as explicacao;
