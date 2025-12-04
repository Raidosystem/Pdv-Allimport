-- ========================================
-- REMOVER TODOS OS TRIGGERS DE BACKUP
-- ========================================

-- 1. Listar TODOS os triggers da tabela vendas
SELECT 
    tgname AS trigger_name,
    tgrelid::regclass AS table_name,
    proname AS function_name,
    pg_get_triggerdef(t.oid) AS trigger_definition
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE tgrelid = 'vendas'::regclass
  AND tgname NOT LIKE 'RI_%'  -- Excluir triggers internos do PostgreSQL
ORDER BY tgname;

-- 2. Remover TODOS os triggers que contenham 'backup' no nome
DO $$
DECLARE
    trigger_rec RECORD;
BEGIN
    FOR trigger_rec IN 
        SELECT tgname
        FROM pg_trigger
        WHERE tgrelid = 'vendas'::regclass
          AND LOWER(tgname) LIKE '%backup%'
    LOOP
        RAISE NOTICE '🗑️ Removendo trigger: %', trigger_rec.tgname;
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON vendas', trigger_rec.tgname);
    END LOOP;
END $$;

-- 3. Tentar remover triggers específicos conhecidos
DROP TRIGGER IF EXISTS trigger_backup_automatico ON vendas;
DROP TRIGGER IF EXISTS backup_diario_trigger ON vendas;
DROP TRIGGER IF EXISTS auto_backup_trigger ON vendas;
DROP TRIGGER IF EXISTS trigger_backup ON vendas;

-- 4. Verificar resultado final
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ Todos os triggers de backup foram removidos!'
        ELSE '⚠️ Ainda restam ' || COUNT(*) || ' trigger(s) de backup'
    END AS status,
    COALESCE(STRING_AGG(tgname, ', '), 'Nenhum') AS triggers_restantes
FROM pg_trigger
WHERE tgrelid = 'vendas'::regclass
  AND LOWER(tgname) LIKE '%backup%';

-- 5. Listar triggers finais (todos, exceto internos)
SELECT 
    tgname AS trigger_name,
    proname AS function_name
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE tgrelid = 'vendas'::regclass
  AND tgname NOT LIKE 'RI_%'
ORDER BY tgname;
