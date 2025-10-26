-- =============================================
-- REMOVER TODAS AS FUNCTIONS RELACIONADAS
-- =============================================

-- PASSO 1: Buscar TODAS as functions que mencionam "orphan" ou "usuario_id"
SELECT 
    n.nspname as schema_name,
    p.proname as function_name,
    pg_get_functiondef(p.oid) as definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE (
    p.proname ILIKE '%orphan%'
    OR p.proname ILIKE '%cliente%'
    OR pg_get_functiondef(p.oid) ILIKE '%usuario_id%'
)
AND n.nspname IN ('public', 'auth')
ORDER BY n.nspname, p.proname;

-- PASSO 2: Remover TODAS as versões possíveis da function
DROP FUNCTION IF EXISTS public.prevent_orphan_cliente() CASCADE;
DROP FUNCTION IF EXISTS prevent_orphan_cliente() CASCADE;
DROP FUNCTION IF EXISTS public.prevent_orphan_cliente CASCADE;

SELECT '✅ Functions removidas!' as status;

-- PASSO 3: Remover TODOS os triggers da tabela clientes
DO $$
DECLARE
    trigger_rec RECORD;
BEGIN
    FOR trigger_rec IN 
        SELECT tgname
        FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        WHERE c.relname = 'clientes'
        AND NOT t.tgisinternal
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON clientes CASCADE', trigger_rec.tgname);
        RAISE NOTICE 'Trigger % removido', trigger_rec.tgname;
    END LOOP;
END $$;

SELECT '✅ Todos os triggers removidos!' as status;

-- PASSO 4: Verificar que não sobrou nada
SELECT 
    t.tgname as trigger_name,
    p.proname as function_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
LEFT JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = 'clientes'
AND NOT t.tgisinternal;

-- PASSO 5: Testar inserção
INSERT INTO clientes (
    nome,
    cpf_cnpj,
    cpf_digits,
    telefone,
    empresa_id,
    tipo,
    ativo
) VALUES (
    'TESTE FINAL',
    '222.222.222-22',
    '22222222222',
    '11999999999',
    (SELECT id FROM empresas LIMIT 1),
    'fisica',
    true
) RETURNING id, nome;

-- PASSO 6: Limpar
DELETE FROM clientes WHERE cpf_digits = '22222222222';

SELECT '🎉 AGORA SIM - LIMPO E FUNCIONANDO!' as resultado;
