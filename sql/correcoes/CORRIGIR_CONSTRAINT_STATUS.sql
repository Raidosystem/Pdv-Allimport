-- ============================================
-- CORRIGIR CONSTRAINT STATUS - PERMITIR 'pausado'
-- ============================================
-- Erro: funcionarios_status_check não aceita 'pausado'
-- Solução: Recriar constraint com valores corretos
-- ============================================

-- PASSO 1: Remover constraint antiga (se existir)
ALTER TABLE funcionarios 
DROP CONSTRAINT IF EXISTS funcionarios_status_check;

-- PASSO 2: Adicionar nova constraint com valores corretos
ALTER TABLE funcionarios 
ADD CONSTRAINT funcionarios_status_check 
CHECK (status IN ('ativo', 'pausado', 'inativo'));

-- PASSO 3: Verificar constraint criada
SELECT
    '✅ CONSTRAINT ATUALIZADA' as info,
    conname as constraint_name,
    pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'funcionarios'::regclass
  AND conname = 'funcionarios_status_check';

-- PASSO 4: Testar update com 'pausado' (use um ID real)
/*
-- Substitua pelo ID de um funcionário de teste
UPDATE funcionarios 
SET status = 'pausado' 
WHERE id = 'SEU_ID_AQUI';

-- Verificar
SELECT id, nome, status 
FROM funcionarios 
WHERE id = 'SEU_ID_AQUI';
*/

-- ============================================
-- RESUMO
-- ============================================
-- ✅ Constraint removida
-- ✅ Nova constraint criada: status IN ('ativo', 'pausado', 'inativo')
-- ✅ Agora você pode usar 'pausado' sem erros!
-- ============================================

SELECT '🎉 Constraint corrigida! Agora pode usar status = ''pausado''' as resultado;
