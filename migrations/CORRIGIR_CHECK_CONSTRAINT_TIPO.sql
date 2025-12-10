-- =============================================
-- CORRIGIR CHECK CONSTRAINT DO TIPO
-- =============================================

-- PASSO 1: Ver qual é o constraint atual
SELECT 
    con.conname as constraint_name,
    pg_get_constraintdef(con.oid) as definition
FROM pg_constraint con
JOIN pg_class rel ON rel.oid = con.conrelid
WHERE rel.relname = 'clientes'
AND con.contype = 'c'
AND con.conname ILIKE '%tipo%';

-- PASSO 2: Remover o constraint problemático
ALTER TABLE clientes DROP CONSTRAINT IF EXISTS clientes_tipo_check;

SELECT '✅ Constraint clientes_tipo_check REMOVIDO!' as status;

-- PASSO 3: Criar novo constraint correto
ALTER TABLE clientes 
ADD CONSTRAINT clientes_tipo_check 
CHECK (tipo IN ('fisica', 'juridica'));

SELECT '✅ Novo constraint criado com valores corretos!' as status;

-- PASSO 4: Testar inserção novamente
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

SELECT '🎉 AGORA SIM - FUNCIONANDO!' as resultado;
