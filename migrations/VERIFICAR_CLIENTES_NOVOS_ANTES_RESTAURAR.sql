-- ============================================
-- VERIFICAR CLIENTES NOVOS (após 01/08/2025)
-- ============================================

-- 1. Verificar se há clientes cadastrados DEPOIS do backup (01/08/2025)
SELECT 
    id,
    nome,
    cpf_cnpj,
    telefone,
    created_at
FROM clientes
WHERE created_at > '2025-08-01T21:17:02.031Z'
ORDER BY created_at DESC;

-- 2. Contar clientes novos
SELECT COUNT(*) as clientes_novos_apos_backup
FROM clientes
WHERE created_at > '2025-08-01T21:17:02.031Z';

-- 3. Se houver clientes novos, SALVE-OS antes de restaurar!
-- Execute este comando se a query acima retornar > 0:
CREATE TABLE IF NOT EXISTS clientes_novos_salvar AS
SELECT * FROM clientes
WHERE created_at > '2025-08-01T21:17:02.031Z';
