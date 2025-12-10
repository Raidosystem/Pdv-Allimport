-- ============================================
-- TESTE DIRETO - BUSCA DE CLIENTES
-- ============================================
-- Este script simula exatamente o que o frontend está tentando fazer

-- 1. Ver quantos clientes você tem na sua empresa
SELECT 
    '👥 MEUS CLIENTES' as tipo,
    COUNT(*) as total
FROM clientes
WHERE empresa_id = get_user_empresa_id();

-- 2. Listar os 10 primeiros clientes (como o frontend faz)
SELECT 
    '📋 LISTA DE CLIENTES' as tipo,
    id,
    nome,
    telefone,
    cpf_cnpj,
    empresa_id
FROM clientes
WHERE empresa_id = get_user_empresa_id()
ORDER BY criado_em DESC
LIMIT 10;

-- 3. Testar busca por nome (como quando você digita na busca)
SELECT 
    '🔍 BUSCA POR NOME' as tipo,
    id,
    nome,
    telefone
FROM clientes
WHERE empresa_id = get_user_empresa_id()
AND (
    nome ILIKE '%a%' OR  -- Buscar clientes com letra 'a'
    telefone ILIKE '%1%'  -- ou telefone com '1'
)
LIMIT 5;

-- 4. Ver se a função get_user_empresa_id está funcionando
SELECT 
    '🏢 MINHA EMPRESA' as tipo,
    get_user_empresa_id() as empresa_id,
    (SELECT nome FROM empresas WHERE id = get_user_empresa_id()) as nome_empresa;
