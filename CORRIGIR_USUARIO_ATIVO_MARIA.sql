-- 🔍 VERIFICAR coluna usuario_ativo

-- ✅ Passo 1: A coluna existe?
SELECT 
  '1️⃣ COLUNA EXISTE?' as verificacao,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcionarios'
  AND column_name = 'usuario_ativo';

-- ✅ Passo 2: Valor da Maria Silva
SELECT 
  '2️⃣ VALOR DA MARIA' as verificacao,
  id,
  nome,
  usuario_ativo,
  status,
  tipo_admin
FROM funcionarios
WHERE id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ Passo 3: Todos os funcionários e seus valores
SELECT 
  '3️⃣ TODOS OS FUNCIONÁRIOS' as verificacao,
  nome,
  tipo_admin,
  usuario_ativo,
  status
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY created_at DESC;

-- 🔧 SOLUÇÃO: Atualizar Maria Silva para usuario_ativo = TRUE
UPDATE funcionarios
SET usuario_ativo = TRUE
WHERE id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ Passo 4: Verificar após UPDATE
SELECT 
  '4️⃣ DEPOIS DO UPDATE' as verificacao,
  id,
  nome,
  usuario_ativo,
  status
FROM funcionarios
WHERE id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ Passo 5: Testar função novamente
SELECT 
  '5️⃣ TESTE DA FUNÇÃO AGORA' as verificacao,
  id,
  nome,
  email,
  tipo_admin
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');
