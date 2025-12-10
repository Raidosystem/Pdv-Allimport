-- 🔍 DIAGNOSTICAR PROBLEMA DE FOREIGN KEY

-- Ver qual empresa_id o código está tentando usar
SELECT 
  '🔍 AUTH.UID() ATUAL' as info,
  auth.uid() as user_id_logado;

-- Ver se esse ID existe na tabela empresas
SELECT 
  '📋 EMPRESAS EXISTENTES' as info,
  id,
  nome,
  email,
  tipo_conta
FROM empresas
ORDER BY nome;

-- Ver se auth.uid() tem match em empresas
SELECT 
  '✅ MATCH?' as info,
  CASE 
    WHEN EXISTS (SELECT 1 FROM empresas WHERE id = auth.uid()) 
    THEN 'SIM - ID existe em empresas'
    ELSE '❌ NÃO - ID não existe em empresas!'
  END as resultado,
  auth.uid() as seu_user_id;

-- Ver funcionarios com esse auth.uid()
SELECT 
  '👤 FUNCIONÁRIO?' as info,
  f.id as funcionario_id,
  f.nome,
  f.empresa_id,
  f.tipo_admin
FROM funcionarios f
WHERE f.id = auth.uid();
