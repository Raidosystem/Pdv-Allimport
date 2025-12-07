-- =============================================
-- Adicionar coluna precisa_trocar_senha
-- Para forçar troca de senha no primeiro acesso
-- ou após reset pelo admin
-- =============================================

-- 1. Adicionar coluna na tabela login_funcionarios
ALTER TABLE login_funcionarios 
ADD COLUMN IF NOT EXISTS precisa_trocar_senha BOOLEAN DEFAULT false;

-- 2. Comentário na coluna
COMMENT ON COLUMN login_funcionarios.precisa_trocar_senha IS 
'Flag que indica se o funcionário precisa trocar a senha no próximo login (primeira senha ou após reset do admin)';

-- 3. Atualizar funcionários existentes para não precisar trocar
-- (apenas novos funcionários ou após reset precisarão)
UPDATE login_funcionarios 
SET precisa_trocar_senha = false 
WHERE precisa_trocar_senha IS NULL;

-- 4. Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_login_funcionarios_precisa_trocar 
ON login_funcionarios(precisa_trocar_senha) 
WHERE precisa_trocar_senha = true;

-- 5. Verificar estrutura
SELECT 
    column_name, 
    data_type, 
    column_default, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'login_funcionarios'
AND column_name = 'precisa_trocar_senha';

-- Deve retornar:
-- column_name           | data_type | column_default | is_nullable
-- precisa_trocar_senha  | boolean   | false          | YES
