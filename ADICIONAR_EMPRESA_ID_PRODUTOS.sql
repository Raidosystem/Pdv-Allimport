-- ✅ Adicionar coluna empresa_id na tabela produtos
-- Executar isso no Supabase SQL Editor

-- 1. Adicionar a coluna
ALTER TABLE produtos 
ADD COLUMN empresa_id UUID REFERENCES auth.users(id);

-- 2. Atualizar todos os produtos existentes com o usuario_id (assumindo que todos pertencem ao mesmo usuário por enquanto)
-- IMPORTANTE: Substitua o UUID abaixo pelo seu user_id
-- UPDATE produtos SET empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' WHERE empresa_id IS NULL;

-- 3. Fazer a coluna NOT NULL após preenchimento
-- ALTER TABLE produtos ALTER COLUMN empresa_id SET NOT NULL;

-- 4. Criar índice para melhor performance
-- CREATE INDEX idx_produtos_empresa_id ON produtos(empresa_id);

-- ✅ Resultado esperado:
-- A tabela produtos agora terá a coluna empresa_id
-- Todos os produtos existentes terão o empresa_id associado
-- Isolamento de dados por usuário será possível
