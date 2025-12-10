-- 🔍 VERIFICAR STATUS DOS FUNCIONÁRIOS

-- 1. Ver todos os funcionários com seus status
SELECT 
  id,
  nome,
  email,
  status,
  empresa_id,
  user_id,
  tipo_admin,
  funcao_id
FROM funcionarios
ORDER BY created_at DESC;

-- 2. Atualizar status para 'ativo' se estiver diferente
UPDATE funcionarios 
SET status = 'ativo' 
WHERE status IS NULL OR status != 'ativo';

-- 3. Confirmar atualização
SELECT 
  id,
  nome,
  status,
  tipo_admin
FROM funcionarios
ORDER BY nome;

-- 4. Testar novamente a query que estava falhando
SELECT id FROM funcionarios 
WHERE empresa_id = auth.uid() 
AND status = 'ativo' 
LIMIT 1;
