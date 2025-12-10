-- =============================================
-- RESTAURAÇÃO URGENTE: FUNÇÕES E PERMISSÕES
-- =============================================
-- Execute este script para restaurar funções e permissões padrão

-- =============================================
-- PASSO 1: CRIAR FUNÇÕES PADRÃO (SE NÃO EXISTEM)
-- =============================================

-- Limpar funções existentes (cuidado!)
-- DELETE FROM public.funcao_permissoes;
-- DELETE FROM public.funcoes;

-- Inserir funções padrão para todas as empresas
DO $$
DECLARE
    v_empresa_id UUID;
    v_admin_id UUID;
    v_gerente_id UUID;
    v_vendedor_id UUID;
    v_tecnico_id UUID;
BEGIN
    -- Para cada empresa
    FOR v_empresa_id IN 
        SELECT DISTINCT id FROM public.empresas
    LOOP
        RAISE NOTICE 'Criando funções para empresa: %', v_empresa_id;
        
        -- 1. ADMIN
        INSERT INTO public.funcoes (empresa_id, nome, descricao, nivel)
        VALUES (v_empresa_id, 'Admin', 'Administrador com acesso total', 1)
        ON CONFLICT DO NOTHING
        RETURNING id INTO v_admin_id;
        
        -- Se já existia, pegar o ID
        IF v_admin_id IS NULL THEN
            SELECT id INTO v_admin_id FROM public.funcoes 
            WHERE empresa_id = v_empresa_id AND nome = 'Admin' LIMIT 1;
        END IF;
        
        -- 2. GERENTE
        INSERT INTO public.funcoes (empresa_id, nome, descricao, nivel)
        VALUES (v_empresa_id, 'Gerente', 'Gerente com permissões administrativas', 2)
        ON CONFLICT DO NOTHING
        RETURNING id INTO v_gerente_id;
        
        IF v_gerente_id IS NULL THEN
            SELECT id INTO v_gerente_id FROM public.funcoes 
            WHERE empresa_id = v_empresa_id AND nome = 'Gerente' LIMIT 1;
        END IF;
        
        -- 3. VENDEDOR
        INSERT INTO public.funcoes (empresa_id, nome, descricao, nivel)
        VALUES (v_empresa_id, 'Vendedor', 'Vendedor com acesso a vendas e clientes', 3)
        ON CONFLICT DO NOTHING
        RETURNING id INTO v_vendedor_id;
        
        IF v_vendedor_id IS NULL THEN
            SELECT id INTO v_vendedor_id FROM public.funcoes 
            WHERE empresa_id = v_empresa_id AND nome = 'Vendedor' LIMIT 1;
        END IF;
        
        -- 4. TÉCNICO
        INSERT INTO public.funcoes (empresa_id, nome, descricao, nivel)
        VALUES (v_empresa_id, 'Técnico', 'Técnico com acesso a ordens de serviço', 4)
        ON CONFLICT DO NOTHING
        RETURNING id INTO v_tecnico_id;
        
        IF v_tecnico_id IS NULL THEN
            SELECT id INTO v_tecnico_id FROM public.funcoes 
            WHERE empresa_id = v_empresa_id AND nome = 'Técnico' LIMIT 1;
        END IF;
        
        -- ==========================================
        -- PERMISSÕES PARA ADMIN (ACESSO TOTAL)
        -- ==========================================
        INSERT INTO public.funcao_permissoes (funcao_id, recurso, acao)
        VALUES 
            -- Dashboard
            (v_admin_id, 'dashboard', 'read'),
            -- Vendas
            (v_admin_id, 'vendas', 'read'),
            (v_admin_id, 'vendas', 'create'),
            (v_admin_id, 'vendas', 'update'),
            (v_admin_id, 'vendas', 'delete'),
            -- Produtos
            (v_admin_id, 'produtos', 'read'),
            (v_admin_id, 'produtos', 'create'),
            (v_admin_id, 'produtos', 'update'),
            (v_admin_id, 'produtos', 'delete'),
            -- Clientes
            (v_admin_id, 'clientes', 'read'),
            (v_admin_id, 'clientes', 'create'),
            (v_admin_id, 'clientes', 'update'),
            (v_admin_id, 'clientes', 'delete'),
            -- Ordens de Serviço
            (v_admin_id, 'ordens_servico', 'read'),
            (v_admin_id, 'ordens_servico', 'create'),
            (v_admin_id, 'ordens_servico', 'update'),
            (v_admin_id, 'ordens_servico', 'delete'),
            -- Caixa
            (v_admin_id, 'caixa', 'read'),
            (v_admin_id, 'caixa', 'create'),
            (v_admin_id, 'caixa', 'update'),
            -- Relatórios
            (v_admin_id, 'relatorios', 'read'),
            -- Administração
            (v_admin_id, 'administracao.usuarios', 'read'),
            (v_admin_id, 'administracao.usuarios', 'create'),
            (v_admin_id, 'administracao.usuarios', 'update'),
            (v_admin_id, 'administracao.usuarios', 'delete'),
            (v_admin_id, 'administracao.funcoes', 'read'),
            (v_admin_id, 'administracao.funcoes', 'update'),
            (v_admin_id, 'administracao.configuracoes', 'read'),
            (v_admin_id, 'administracao.configuracoes', 'update'),
            (v_admin_id, 'administracao.backups', 'read'),
            (v_admin_id, 'administracao.backups', 'create'),
            (v_admin_id, 'administracao.backups', 'delete')
        ON CONFLICT DO NOTHING;
        
        -- ==========================================
        -- PERMISSÕES PARA GERENTE
        -- ==========================================
        INSERT INTO public.funcao_permissoes (funcao_id, recurso, acao)
        VALUES 
            (v_gerente_id, 'dashboard', 'read'),
            (v_gerente_id, 'vendas', 'read'),
            (v_gerente_id, 'vendas', 'create'),
            (v_gerente_id, 'vendas', 'update'),
            (v_gerente_id, 'produtos', 'read'),
            (v_gerente_id, 'produtos', 'create'),
            (v_gerente_id, 'produtos', 'update'),
            (v_gerente_id, 'clientes', 'read'),
            (v_gerente_id, 'clientes', 'create'),
            (v_gerente_id, 'clientes', 'update'),
            (v_gerente_id, 'ordens_servico', 'read'),
            (v_gerente_id, 'ordens_servico', 'create'),
            (v_gerente_id, 'ordens_servico', 'update'),
            (v_gerente_id, 'caixa', 'read'),
            (v_gerente_id, 'caixa', 'create'),
            (v_gerente_id, 'relatorios', 'read')
        ON CONFLICT DO NOTHING;
        
        -- ==========================================
        -- PERMISSÕES PARA VENDEDOR
        -- ==========================================
        INSERT INTO public.funcao_permissoes (funcao_id, recurso, acao)
        VALUES 
            (v_vendedor_id, 'dashboard', 'read'),
            (v_vendedor_id, 'vendas', 'read'),
            (v_vendedor_id, 'vendas', 'create'),
            (v_vendedor_id, 'produtos', 'read'),
            (v_vendedor_id, 'clientes', 'read'),
            (v_vendedor_id, 'clientes', 'create'),
            (v_vendedor_id, 'caixa', 'read')
        ON CONFLICT DO NOTHING;
        
        -- ==========================================
        -- PERMISSÕES PARA TÉCNICO
        -- ==========================================
        INSERT INTO public.funcao_permissoes (funcao_id, recurso, acao)
        VALUES 
            (v_tecnico_id, 'dashboard', 'read'),
            (v_tecnico_id, 'ordens_servico', 'read'),
            (v_tecnico_id, 'ordens_servico', 'update'),
            (v_tecnico_id, 'clientes', 'read')
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE 'Funções e permissões criadas para empresa: %', v_empresa_id;
    END LOOP;
END $$;

-- =============================================
-- PASSO 2: ASSOCIAR FUNCIONÁRIOS ÀS FUNÇÕES
-- =============================================

-- Atribuir função Admin ao primeiro usuário de cada empresa
UPDATE public.funcionarios f
SET funcao_id = (
    SELECT id FROM public.funcoes 
    WHERE empresa_id = f.empresa_id 
    AND nome = 'Admin' 
    LIMIT 1
)
WHERE f.funcao_id IS NULL
AND f.id IN (
    SELECT id FROM (
        SELECT DISTINCT ON (empresa_id) id, empresa_id
        FROM public.funcionarios
        ORDER BY empresa_id, created_at ASC
    ) AS first_users
);

-- Atribuir função Vendedor aos demais funcionários sem função
UPDATE public.funcionarios f
SET funcao_id = (
    SELECT id FROM public.funcoes 
    WHERE empresa_id = f.empresa_id 
    AND nome = 'Vendedor' 
    LIMIT 1
)
WHERE f.funcao_id IS NULL;

-- =============================================
-- PASSO 3: VERIFICAR RESULTADO
-- =============================================

-- Ver funções criadas
SELECT 
    e.nome as empresa,
    f.nome as funcao,
    f.descricao,
    f.nivel,
    COUNT(fp.id) as total_permissoes
FROM public.funcoes f
INNER JOIN public.empresas e ON f.empresa_id = e.id
LEFT JOIN public.funcao_permissoes fp ON f.id = fp.funcao_id
GROUP BY e.nome, f.id, f.nome, f.descricao, f.nivel
ORDER BY e.nome, f.nivel;

-- Ver funcionários e suas funções
SELECT 
    f.nome as funcionario,
    f.email,
    func.nome as funcao,
    e.nome as empresa,
    f.ativo
FROM public.funcionarios f
LEFT JOIN public.funcoes func ON f.funcao_id = func.id
LEFT JOIN public.empresas e ON f.empresa_id = e.id
ORDER BY e.nome, f.nome;

-- Ver permissões por função
SELECT 
    func.nome as funcao,
    fp.recurso,
    fp.acao
FROM public.funcoes func
INNER JOIN public.funcao_permissoes fp ON func.id = fp.funcao_id
ORDER BY func.nivel, fp.recurso, fp.acao;

-- =============================================
-- RESULTADO ESPERADO
-- =============================================
SELECT '✅ FUNÇÕES E PERMISSÕES RESTAURADAS COM SUCESSO!' as status;

-- Resumo
SELECT 
    'Funções criadas: ' || COUNT(DISTINCT f.id) || 
    ' | Permissões: ' || COUNT(fp.id) ||
    ' | Funcionários associados: ' || COUNT(DISTINCT func.id) as resumo
FROM public.funcoes f
LEFT JOIN public.funcao_permissoes fp ON f.id = fp.funcao_id
LEFT JOIN public.funcionarios func ON func.funcao_id = f.id;
