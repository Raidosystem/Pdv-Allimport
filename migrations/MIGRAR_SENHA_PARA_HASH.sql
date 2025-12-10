-- =====================================================
-- MIGRAÇÃO: Coluna senha -> senha_hash (criptografada)
-- =====================================================
-- 🎯 Objetivo: Migrar de senha em texto plano para hash criptografado
-- 📅 Data: 2025-12-07
-- ⚠️ IMPORTANTE: Execute este SQL no Supabase SQL Editor

-- =====================================================
-- 1. VERIFICAR ESTRUTURA ATUAL
-- =====================================================
SELECT 
    column_name, 
    data_type, 
    column_default
FROM information_schema.columns
WHERE table_name = 'login_funcionarios'
AND column_name IN ('senha', 'senha_hash')
ORDER BY column_name;

-- =====================================================
-- 2. ADICIONAR COLUNA senha_hash (se não existir)
-- =====================================================
-- A coluna senha_hash será a nova coluna criptografada
ALTER TABLE login_funcionarios 
ADD COLUMN IF NOT EXISTS senha_hash TEXT;

COMMENT ON COLUMN login_funcionarios.senha_hash IS 
'Senha criptografada usando bcrypt (crypt + gen_salt)';

-- =====================================================
-- 3. MIGRAR DADOS: senha -> senha_hash
-- =====================================================
-- ⚠️ Migrar senhas existentes de texto plano para hash
-- ⚠️ Isso permite que senhas antigas continuem funcionando
UPDATE login_funcionarios
SET senha_hash = crypt(senha, gen_salt('bf'))
WHERE senha_hash IS NULL 
  AND senha IS NOT NULL 
  AND senha != '';

-- Verificar quantas senhas foram migradas
SELECT 
    COUNT(*) FILTER (WHERE senha_hash IS NOT NULL) as com_hash,
    COUNT(*) FILTER (WHERE senha_hash IS NULL) as sem_hash,
    COUNT(*) as total
FROM login_funcionarios;

-- =====================================================
-- 4. TORNAR senha_hash NOT NULL (após migração)
-- =====================================================
-- ⚠️ Só execute isso DEPOIS de verificar que todas as senhas foram migradas
-- ALTER TABLE login_funcionarios 
-- ALTER COLUMN senha_hash SET NOT NULL;

-- =====================================================
-- 5. REMOVER COLUNA senha ANTIGA (CUIDADO!)
-- =====================================================
-- ⚠️ NÃO EXECUTE AINDA! Mantenha a coluna 'senha' por enquanto para rollback
-- ⚠️ Só remova depois de testar em produção por alguns dias
-- ALTER TABLE login_funcionarios 
-- DROP COLUMN IF EXISTS senha;

-- =====================================================
-- 6. CRIAR ÍNDICE para performance
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_login_funcionarios_senha_hash 
ON login_funcionarios(senha_hash);

-- =====================================================
-- 7. VERIFICAR ESTRUTURA FINAL
-- =====================================================
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'login_funcionarios'
AND column_name IN ('senha', 'senha_hash', 'precisa_trocar_senha')
ORDER BY column_name;

-- Resultado esperado:
-- column_name           | data_type | is_nullable | column_default
-- precisa_trocar_senha  | boolean   | YES         | false
-- senha                 | text      | NO          | NULL          (mantida temporariamente)
-- senha_hash            | text      | YES         | NULL          (será NOT NULL depois)

-- =====================================================
-- 8. TESTAR LOGIN COM SENHA HASH
-- =====================================================
-- Testar se a autenticação funciona com senha_hash:
-- SELECT * FROM autenticar_funcionario_local('usuario_teste', 'senha123');
-- ✅ Deve retornar o funcionário se senha estiver correta

-- =====================================================
-- 📋 CHECKLIST DE EXECUÇÃO
-- =====================================================
-- ✅ 1. Executar passos 1-3 (verificar + adicionar + migrar)
-- ✅ 2. Verificar quantas senhas foram migradas (passo 3)
-- ✅ 3. Testar login de alguns funcionários (passo 8)
-- ⏸️ 4. Aguardar alguns dias em produção
-- ⏸️ 5. Executar passo 4 (tornar NOT NULL)
-- ⏸️ 6. Aguardar mais alguns dias
-- ⏸️ 7. Executar passo 5 (remover coluna antiga)

-- =====================================================
-- 🔧 ROLLBACK (em caso de problema)
-- =====================================================
-- Se algo der errado, reverter:
-- ALTER TABLE login_funcionarios DROP COLUMN IF EXISTS senha_hash;
-- (a coluna 'senha' original será mantida)
