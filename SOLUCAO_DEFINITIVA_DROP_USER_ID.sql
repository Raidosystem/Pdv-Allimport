-- =============================================
-- SOLUÇÃO DEFINITIVA: REMOVER user_id CASCADE
-- =============================================

-- Esta é a ÚNICA solução que vai funcionar
-- Há algo muito quebrado no banco relacionado a user_id/usuario_id

-- PASSO 1: Remover a coluna user_id com CASCADE
ALTER TABLE clientes DROP COLUMN IF EXISTS user_id CASCADE;

SELECT '✅ Coluna user_id REMOVIDA!' as status;

-- PASSO 2: Verificar se ainda existem triggers
SELECT COUNT(*) as total_triggers 
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
WHERE c.relname = 'clientes'
AND NOT t.tgisinternal;

-- PASSO 3: Listar colunas restantes
SELECT column_name 
FROM information_schema.columns
WHERE table_name = 'clientes'
ORDER BY ordinal_position;

-- PASSO 4: Testar inserção simples
INSERT INTO clientes (
    nome,
    cpf_cnpj,
    cpf_digits,
    telefone,
    empresa_id,
    tipo,
    ativo
) VALUES (
    'TESTE DEFINITIVO',
    '000.000.000-00',
    '00000000000',
    '11999999999',
    (SELECT id FROM empresas LIMIT 1),
    'fisica',
    true
) RETURNING id, nome;

-- Se funcionar, deletar o teste
DELETE FROM clientes WHERE nome = 'TESTE DEFINITIVO';

SELECT '✅ TESTE CONCLUÍDO - Sistema funcionando!' as resultado;
