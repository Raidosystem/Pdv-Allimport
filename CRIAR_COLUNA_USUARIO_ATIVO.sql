-- 🔧 CRIAR COLUNA usuario_ativo na tabela funcionarios

-- ✅ Passo 1: Adicionar a coluna
ALTER TABLE funcionarios 
ADD COLUMN IF NOT EXISTS usuario_ativo BOOLEAN DEFAULT TRUE;

-- ✅ Passo 2: Adicionar outras colunas necessárias
ALTER TABLE funcionarios 
ADD COLUMN IF NOT EXISTS senha_definida BOOLEAN DEFAULT FALSE;

ALTER TABLE funcionarios 
ADD COLUMN IF NOT EXISTS primeiro_acesso BOOLEAN DEFAULT TRUE;

ALTER TABLE funcionarios 
ADD COLUMN IF NOT EXISTS foto_perfil TEXT;

-- ✅ Passo 3: Atualizar TODOS os funcionários existentes
UPDATE funcionarios
SET usuario_ativo = TRUE,
    senha_definida = TRUE,
    primeiro_acesso = FALSE
WHERE usuario_ativo IS NULL;

-- ✅ Passo 4: Verificar se as colunas foram criadas
SELECT 
  '✅ COLUNAS CRIADAS' as status,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcionarios'
  AND column_name IN ('usuario_ativo', 'senha_definida', 'primeiro_acesso', 'foto_perfil')
ORDER BY column_name;

-- ✅ Passo 5: Verificar Maria Silva agora
SELECT 
  '✅ MARIA SILVA AGORA' as status,
  id,
  nome,
  email,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  status
FROM funcionarios
WHERE id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa';

-- ✅ Passo 6: Testar a função listar_usuarios_ativos
SELECT 
  '✅ FUNÇÃO AGORA FUNCIONA' as status,
  id,
  nome,
  email,
  tipo_admin,
  usuario_ativo
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- ✅ Passo 7: Ver todos os funcionários
SELECT 
  '✅ TODOS OS FUNCIONÁRIOS' as status,
  nome,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  primeiro_acesso
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY tipo_admin, nome;
