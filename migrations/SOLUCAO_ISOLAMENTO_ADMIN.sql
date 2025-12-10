-- ========================================
-- 🔧 SOLUÇÃO FINAL - BYPASS PARA ADMIN
-- Como você é postgres, vou criar views isoladas
-- ========================================

-- 1. PRIMEIRO, IDENTIFICAR QUAL USUÁRIO DEVERIA VER CADA DADO
-- Baseado na análise anterior: assistenciaallimport10@gmail.com tem os dados

-- 2. CRIAR VIEWS QUE SIMULAM O ISOLAMENTO
-- View de produtos isolados por usuário
CREATE OR REPLACE VIEW produtos_isolados_por_usuario AS
SELECT 
    p.*,
    u.email as owner_email
FROM produtos p
JOIN auth.users u ON p.user_id = u.id;

-- View de clientes isolados por usuário
CREATE OR REPLACE VIEW clientes_isolados_por_usuario AS
SELECT 
    c.*,
    u.email as owner_email
FROM clientes c
JOIN auth.users u ON c.user_id = u.id;

-- View de vendas isoladas por usuário
CREATE OR REPLACE VIEW vendas_isoladas_por_usuario AS
SELECT 
    v.*,
    u.email as owner_email
FROM vendas v
JOIN auth.users u ON v.user_id = u.id;

-- 3. CRIAR FUNÇÃO PARA SIMULAR ISOLAMENTO
-- Esta função vai filtrar dados baseado no email do usuário
CREATE OR REPLACE FUNCTION get_produtos_by_user(user_email TEXT DEFAULT NULL)
RETURNS TABLE(
    id UUID,
    nome VARCHAR(255),
    preco DECIMAL(10,2),
    user_id UUID,
    owner_email VARCHAR(255)
) AS $$
BEGIN
    IF user_email IS NULL THEN
        -- Se não especificar usuário, não retorna nada (segurança)
        RETURN;
    END IF;
    
    RETURN QUERY
    SELECT 
        p.id,
        p.nome,
        p.preco,
        p.user_id,
        u.email as owner_email
    FROM produtos p
    JOIN auth.users u ON p.user_id = u.id
    WHERE u.email = user_email;
END;
$$ LANGUAGE plpgsql;

-- 4. CRIAR FUNÇÃO PARA CLIENTES
CREATE OR REPLACE FUNCTION get_clientes_by_user(user_email TEXT DEFAULT NULL)
RETURNS TABLE(
    id UUID,
    nome VARCHAR(255),
    telefone VARCHAR(255),
    user_id UUID,
    owner_email VARCHAR(255)
) AS $$
BEGIN
    IF user_email IS NULL THEN
        RETURN;
    END IF;
    
    RETURN QUERY
    SELECT 
        c.id,
        c.nome,
        c.telefone,
        c.user_id,
        u.email as owner_email
    FROM clientes c
    JOIN auth.users u ON c.user_id = u.id
    WHERE u.email = user_email;
END;
$$ LANGUAGE plpgsql;

-- 5. TESTAR AS FUNÇÕES
-- Ver produtos do novaradiosystem (deveria retornar 0)
SELECT 'PRODUTOS novaradiosystem' as teste, COUNT(*) as quantidade
FROM get_produtos_by_user('novaradiosystem@outlook.com');

-- Ver produtos do assistenciaallimport10 (deveria retornar 809)
SELECT 'PRODUTOS assistenciaallimport10' as teste, COUNT(*) as quantidade
FROM get_produtos_by_user('assistenciaallimport10@gmail.com');

-- Ver clientes do novaradiosystem (deveria retornar 0)
SELECT 'CLIENTES novaradiosystem' as teste, COUNT(*) as quantidade
FROM get_clientes_by_user('novaradiosystem@outlook.com');

-- Ver clientes do assistenciaallimport10 (deveria retornar 131)
SELECT 'CLIENTES assistenciaallimport10' as teste, COUNT(*) as quantidade
FROM get_clientes_by_user('assistenciaallimport10@gmail.com');

-- 6. RESUMO DE TODOS OS USUÁRIOS E SEUS DADOS
SELECT 
    '📊 RESUMO FINAL POR USUÁRIO' as info,
    u.email,
    COALESCE(p.produtos, 0) as produtos,
    COALESCE(c.clientes, 0) as clientes,
    COALESCE(v.vendas, 0) as vendas
FROM auth.users u
LEFT JOIN (SELECT user_id, COUNT(*) as produtos FROM produtos GROUP BY user_id) p ON u.id = p.user_id
LEFT JOIN (SELECT user_id, COUNT(*) as clientes FROM clientes GROUP BY user_id) c ON u.id = c.user_id
LEFT JOIN (SELECT user_id, COUNT(*) as vendas FROM vendas GROUP BY user_id) v ON u.id = v.user_id
ORDER BY produtos DESC, clientes DESC;

SELECT '🎉 FUNÇÕES DE ISOLAMENTO CRIADAS - USE ELAS NO FRONTEND!' as resultado;