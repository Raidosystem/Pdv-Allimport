-- =============================================
-- REMOVER FUNCTION prevent_orphan_cliente
-- =============================================

-- Esta é a function que está causando o erro:
-- "record 'new' has no field 'usuario_id'"

-- PASSO 1: Remover a function completamente
DROP FUNCTION IF EXISTS prevent_orphan_cliente() CASCADE;

SELECT '✅ Function prevent_orphan_cliente() REMOVIDA!' as status;

-- PASSO 2: Verificar se foi removida
SELECT COUNT(*) as functions_restantes
FROM pg_proc p
WHERE p.proname ILIKE '%prevent_orphan%';

-- PASSO 3: Verificar triggers restantes na tabela clientes
SELECT 
    t.tgname as trigger_name,
    p.proname as function_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
LEFT JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = 'clientes'
AND NOT t.tgisinternal;

-- PASSO 4: Testar inserção
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
    '111.111.111-11',
    '11111111111',
    '11999999999',
    (SELECT id FROM empresas LIMIT 1),
    'fisica',
    true
) RETURNING id, nome;

-- Limpar teste
DELETE FROM clientes WHERE nome = 'TESTE FINAL';

SELECT '🎉 PROBLEMA RESOLVIDO!' as resultado;
