-- ========================================
-- FIX: Remover trigger de backup que está causando erro
-- ========================================
-- Problema: Função criar_backup_automatico_diario() não existe
-- Solução: Remover o trigger que chama essa função
-- ========================================

-- 1. Verificar se o trigger existe
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_trigger 
        WHERE tgname = 'trigger_criar_backup_automatico_diario'
    ) THEN
        RAISE NOTICE '✅ Trigger encontrado: trigger_criar_backup_automatico_diario';
    ELSE
        RAISE NOTICE 'ℹ️ Trigger não encontrado';
    END IF;
END $$;

-- 2. Listar todos os triggers da tabela vendas
SELECT 
    tgname AS trigger_name,
    tgrelid::regclass AS table_name,
    proname AS function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE tgrelid = 'vendas'::regclass
ORDER BY tgname;

-- 3. Remover trigger que chama a função inexistente (se existir)
DROP TRIGGER IF EXISTS trigger_criar_backup_automatico_diario ON vendas;
DROP TRIGGER IF EXISTS backup_automatico_trigger ON vendas;
DROP TRIGGER IF EXISTS criar_backup_trigger ON vendas;

-- 4. Remover a função se existir (opcional - caso alguém tenha criado)
DROP FUNCTION IF EXISTS public.criar_backup_automatico_diario() CASCADE;

-- 5. Verificar se há outros triggers problemáticos
DO $$
DECLARE
    trigger_rec RECORD;
BEGIN
    FOR trigger_rec IN 
        SELECT tgname, tgrelid::regclass as table_name
        FROM pg_trigger
        WHERE tgrelid = 'vendas'::regclass
    LOOP
        RAISE NOTICE 'Trigger restante: % na tabela %', trigger_rec.tgname, trigger_rec.table_name;
    END LOOP;
END $$;

-- 6. Confirmar remoção
SELECT 
    'Triggers removidos com sucesso!' AS status,
    COUNT(*) AS triggers_restantes
FROM pg_trigger
WHERE tgrelid = 'vendas'::regclass
  AND tgname LIKE '%backup%';
