-- =============================================
-- RESTAURAÇÃO URGENTE: FUNÇÕES E PERMISSÕES
-- =============================================
-- Este script cria funções e associa permissões existentes

BEGIN;

-- =============================================
-- PASSO 1: CRIAR FUNÇÕES PADRÃO
-- =============================================

DO $$
DECLARE
    v_empresa_id UUID;
    v_admin_id UUID;
    v_gerente_id UUID;
    v_vendedor_id UUID;
    v_tecnico_id UUID;
    v_permissao_id UUID;
BEGIN
    -- Para cada empresa
    FOR v_empresa_id IN 
        SELECT DISTINCT id FROM public.empresas
    LOOP
        RAISE NOTICE '🔄 Processando empresa: %', v_empresa_id;
        
        -- ==========================================
        -- CRIAR FUNÇÕES
        -- ==========================================
        
        -- 1. ADMIN
        INSERT INTO public.funcoes (empresa_id, nome, descricao, nivel)
        VALUES (v_empresa_id, 'Admin', 'Administrador com acesso total ao sistema', 1)
        ON CONFLICT DO NOTHING
        RETURNING id INTO v_admin_id;
        
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
        VALUES (v_empresa_id, 'Técnico', 'Técnico especializado em ordens de serviço', 4)
        ON CONFLICT DO NOTHING
        RETURNING id INTO v_tecnico_id;
        
        IF v_tecnico_id IS NULL THEN
            SELECT id INTO v_tecnico_id FROM public.funcoes 
            WHERE empresa_id = v_empresa_id AND nome = 'Técnico' LIMIT 1;
        END IF;
        
        RAISE NOTICE '✅ Funções criadas: Admin (%), Gerente (%), Vendedor (%), Técnico (%)', 
            v_admin_id, v_gerente_id, v_vendedor_id, v_tecnico_id;
        
        -- ==========================================
        -- PERMISSÕES PARA ADMIN (ACESSO TOTAL)
        -- ==========================================
        RAISE NOTICE '🔑 Atribuindo permissões para ADMIN...';
        
        -- Admin tem TODAS as permissões
        INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
        SELECT v_empresa_id, v_admin_id, p.id
        FROM public.permissoes p
        ON CONFLICT DO NOTHING;
        
        -- ==========================================
        -- PERMISSÕES PARA GERENTE
        -- ==========================================
        RAISE NOTICE '🔑 Atribuindo permissões para GERENTE...';
        
        -- Gerente: vendas, produtos, clientes, ordens, caixa, relatórios
        INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
        SELECT v_empresa_id, v_gerente_id, p.id
        FROM public.permissoes p
        WHERE p.recurso IN (
            'vendas', 'produtos', 'clientes', 'ordens', 'caixa',
            'estoque', 'categorias', 'historico', 'charts', 'metrics',
            'overview', 'financeiro', 'descontos', 'cupom', 'precos'
        )
        ON CONFLICT DO NOTHING;
        
        -- ==========================================
        -- PERMISSÕES PARA VENDEDOR
        -- ==========================================
        RAISE NOTICE '🔑 Atribuindo permissões para VENDEDOR...';
        
        -- Vendedor: vendas, produtos (read), clientes, caixa (read)
        INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
        SELECT v_empresa_id, v_vendedor_id, p.id
        FROM public.permissoes p
        WHERE p.recurso IN ('vendas', 'clientes', 'cupom', 'descontos', 'overview')
           OR (p.recurso = 'produtos' AND p.acao = 'read')
           OR (p.recurso = 'caixa' AND p.acao = 'read')
           OR (p.recurso = 'estoque' AND p.acao = 'read')
           OR (p.recurso = 'categorias' AND p.acao = 'read')
        ON CONFLICT DO NOTHING;
        
        -- ==========================================
        -- PERMISSÕES PARA TÉCNICO
        -- ==========================================
        RAISE NOTICE '🔑 Atribuindo permissões para TÉCNICO...';
        
        -- Técnico: ordens de serviço, clientes (read)
        INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
        SELECT v_empresa_id, v_tecnico_id, p.id
        FROM public.permissoes p
        WHERE p.recurso = 'ordens'
           OR (p.recurso = 'clientes' AND p.acao = 'read')
           OR (p.recurso = 'historico' AND p.acao = 'read')
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE '✅ Permissões atribuídas para empresa: %', v_empresa_id;
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

COMMIT;

-- =============================================
-- PASSO 3: VERIFICAR RESULTADO
-- =============================================

-- Ver funções criadas com contagem de permissões
SELECT 
    '📊 FUNÇÕES CRIADAS' as secao;

SELECT 
    e.nome as empresa,
    f.nome as funcao,
    f.descricao,
    f.nivel,
    COUNT(DISTINCT fp.permissao_id) as total_permissoes
FROM public.funcoes f
INNER JOIN public.empresas e ON f.empresa_id = e.id
LEFT JOIN public.funcao_permissoes fp ON f.id = fp.funcao_id
GROUP BY e.nome, f.id, f.nome, f.descricao, f.nivel
ORDER BY e.nome, f.nivel;

-- Ver funcionários e suas funções
SELECT 
    '👥 FUNCIONÁRIOS E SUAS FUNÇÕES' as secao;

SELECT 
    f.nome as funcionario,
    f.email,
    func.nome as funcao,
    func.nivel,
    e.nome as empresa,
    f.ativo
FROM public.funcionarios f
LEFT JOIN public.funcoes func ON f.funcao_id = func.id
LEFT JOIN public.empresas e ON f.empresa_id = e.id
ORDER BY e.nome, func.nivel, f.nome;

-- Ver algumas permissões por função
SELECT 
    '🔑 PERMISSÕES POR FUNÇÃO (AMOSTRA)' as secao;

SELECT 
    e.nome as empresa,
    func.nome as funcao,
    p.recurso,
    p.acao,
    p.descricao
FROM public.funcoes func
INNER JOIN public.empresas e ON func.empresa_id = e.id
INNER JOIN public.funcao_permissoes fp ON func.id = fp.funcao_id
INNER JOIN public.permissoes p ON fp.permissao_id = p.id
WHERE p.recurso IN ('vendas', 'produtos', 'clientes', 'ordens', 'usuarios')
ORDER BY e.nome, func.nivel, p.recurso, p.acao
LIMIT 50;

-- Resumo final
SELECT 
    '✅ RESTAURAÇÃO CONCLUÍDA!' as status;

SELECT 
    'Empresas: ' || COUNT(DISTINCT e.id) ||
    ' | Funções: ' || COUNT(DISTINCT f.id) ||
    ' | Associações: ' || COUNT(fp.id) ||
    ' | Funcionários: ' || COUNT(DISTINCT func.id) as resumo
FROM public.empresas e
LEFT JOIN public.funcoes f ON e.id = f.empresa_id
LEFT JOIN public.funcao_permissoes fp ON f.id = fp.funcao_id
LEFT JOIN public.funcionarios func ON func.funcao_id = f.id;
