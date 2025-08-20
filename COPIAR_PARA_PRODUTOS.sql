-- 🚀 SOLUÇÃO FINAL: COPIAR PRODUTOS ALLIMPORT PARA TABELA 'produtos'

-- O PDV busca na tabela 'produtos' (português) mas inserimos em 'products' (inglês)
-- Vamos copiar os dados da AllImport para a tabela correta!

-- 1. VERIFICAR ESTRUTURA DA TABELA 'produtos'
SELECT 'ESTRUTURA DA TABELA PRODUTOS:' as info;
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'produtos' 
ORDER BY ordinal_position;

-- 2. VERIFICAR DADOS ATUAIS EM 'produtos'
SELECT 'DADOS ATUAIS EM PRODUTOS:' as info;
SELECT nome FROM produtos LIMIT 10;

-- 3. COPIAR PRODUTOS ALLIMPORT DE 'products' PARA 'produtos'
-- AJUSTAR OS NOMES DAS COLUNAS CONFORME A ESTRUTURA

INSERT INTO produtos (id, nome, descricao, preco, estoque, ativo)
SELECT 
    id,
    name as nome,
    description as descricao, 
    price as preco,
    stock_quantity as estoque,
    active as ativo
FROM products 
WHERE name LIKE 'ALLIMPORT%';

-- 4. VERIFICAR SE OS DADOS FORAM COPIADOS
SELECT 'PRODUTOS ALLIMPORT COPIADOS:' as resultado;
SELECT COUNT(*) as total FROM produtos WHERE nome LIKE 'ALLIMPORT%';

-- 5. LISTAR PRODUTOS ALLIMPORT NA TABELA 'produtos'
SELECT 'PRODUTOS ALLIMPORT EM PRODUTOS:' as info;
SELECT nome, preco FROM produtos WHERE nome LIKE 'ALLIMPORT%' ORDER BY nome;

-- ✅ AGORA OS PRODUTOS DEVEM APARECER NO PDV!
-- O PDV vai buscar na tabela 'produtos' e encontrar os dados da AllImport!
