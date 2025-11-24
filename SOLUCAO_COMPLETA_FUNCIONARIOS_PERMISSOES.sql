-- =============================================
-- SOLUÇÃO COMPLETA: FUNCIONÁRIOS E PERMISSÕES
-- =============================================
-- Este script resolve TODOS os problemas de uma vez

BEGIN;

-- =============================================
-- PASSO 1: CRIAR FUNCIONÁRIOS A PARTIR DE AUTH
-- =============================================

DO $$
DECLARE
    v_user RECORD;
    v_empresa_id UUID;
    v_funcionario_id UUID;
    v_funcao_admin_id UUID;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE '🚀 INICIANDO CRIAÇÃO DE FUNCIONÁRIOS';
    RAISE NOTICE '========================================';
    
    -- Pegar a primeira empresa (Allimport)
    SELECT id INTO v_empresa_id 
    FROM public.empresas 
    ORDER BY created_at ASC 
    LIMIT 1;
    
    RAISE NOTICE '🏢 Empresa selecionada: %', v_empresa_id;
    
    -- Pegar a função Admin da empresa (menor nível = mais permissões)
    SELECT id INTO v_funcao_admin_id
    FROM public.funcoes
    WHERE empresa_id = v_empresa_id
    ORDER BY nivel ASC
    LIMIT 1;
    
    RAISE NOTICE '👑 Função padrão: %', v_funcao_admin_id;
    
    -- Para cada usuário sem funcionário
    FOR v_user IN 
        SELECT 
            au.id as user_id,
            au.email,
            au.created_at
        FROM auth.users au
        LEFT JOIN public.funcionarios f ON au.id = f.user_id
        WHERE f.id IS NULL
        ORDER BY au.created_at
    LOOP
        RAISE NOTICE '➕ Criando funcionário para: %', v_user.email;
        
        -- Criar funcionário (somente se não existir)
        INSERT INTO public.funcionarios (
            user_id,
            empresa_id,
            funcao_id,
            nome,
            email,
            ativo,
            status,
            created_at
        ) VALUES (
            v_user.user_id,
            v_empresa_id,
            v_funcao_admin_id,
            COALESCE(SPLIT_PART(v_user.email, '@', 1), 'Usuário'),
            v_user.email,
            true,
            'ativo',
            v_user.created_at
        )
        RETURNING id INTO v_funcionario_id;
        
        RAISE NOTICE '✅ Funcionário criado: % (ID: %)', v_user.email, v_funcionario_id;
    END LOOP;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ CRIAÇÃO DE FUNCIONÁRIOS CONCLUÍDA';
    RAISE NOTICE '========================================';
END $$;

-- =============================================
-- PASSO 2: GARANTIR QUE TODAS AS FUNÇÕES TÊM PERMISSÕES
-- =============================================

DO $$
DECLARE
    v_funcao RECORD;
    v_total_permissoes INTEGER;
    v_permissoes_adicionadas INTEGER;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE '🔑 VERIFICANDO PERMISSÕES DAS FUNÇÕES';
    RAISE NOTICE '========================================';
    
    FOR v_funcao IN 
        SELECT 
            f.id,
            f.empresa_id,
            f.nome,
            f.nivel,
            COUNT(fp.permissao_id) as permissoes_atuais
        FROM public.funcoes f
        LEFT JOIN public.funcao_permissoes fp ON f.id = fp.funcao_id
        GROUP BY f.id, f.empresa_id, f.nome, f.nivel
    LOOP
        RAISE NOTICE '📋 Função: % (nivel %, permissões atuais: %)', 
            v_funcao.nome, v_funcao.nivel, v_funcao.permissoes_atuais;
        
        -- Se não tem permissões, adicionar baseado no tipo
        IF v_funcao.permissoes_atuais = 0 THEN
            
            -- ADMIN / ADMINISTRADOR (nível 1)
            IF v_funcao.nome ILIKE '%admin%' OR v_funcao.nivel = 1 THEN
                INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
                SELECT v_funcao.empresa_id, v_funcao.id, p.id
                FROM public.permissoes p
                ON CONFLICT DO NOTHING;
                
                GET DIAGNOSTICS v_permissoes_adicionadas = ROW_COUNT;
                RAISE NOTICE '✅ Admin: % permissões adicionadas', v_permissoes_adicionadas;
            
            -- OPERADOR DE CAIXA
            ELSIF v_funcao.nome ILIKE '%caixa%' OR v_funcao.nome ILIKE '%operador%' THEN
                INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
                SELECT v_funcao.empresa_id, v_funcao.id, p.id
                FROM public.permissoes p
                WHERE p.recurso IN ('vendas', 'caixa', 'clientes', 'produtos', 'overview', 'print', 'cupom', 'descontos', 'categorias')
                   OR (p.recurso = 'estoque' AND p.acao = 'read')
                ON CONFLICT DO NOTHING;
                
                GET DIAGNOSTICS v_permissoes_adicionadas = ROW_COUNT;
                RAISE NOTICE '✅ Operador de Caixa: % permissões adicionadas', v_permissoes_adicionadas;
            
            -- VENDEDOR (nível 2)
            ELSIF v_funcao.nome ILIKE '%vendedor%' OR v_funcao.nivel = 2 THEN
                INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
                SELECT v_funcao.empresa_id, v_funcao.id, p.id
                FROM public.permissoes p
                WHERE p.recurso IN ('vendas', 'clientes', 'cupom', 'descontos', 'overview', 'print')
                   OR (p.recurso IN ('produtos', 'caixa', 'estoque', 'categorias') AND p.acao = 'read')
                ON CONFLICT DO NOTHING;
                
                GET DIAGNOSTICS v_permissoes_adicionadas = ROW_COUNT;
                RAISE NOTICE '✅ Vendedor: % permissões adicionadas', v_permissoes_adicionadas;
            
            -- TÉCNICO (nível 2)
            ELSIF v_funcao.nome ILIKE '%técnico%' OR v_funcao.nome ILIKE '%tecnico%' THEN
                INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
                SELECT v_funcao.empresa_id, v_funcao.id, p.id
                FROM public.permissoes p
                WHERE p.recurso IN ('ordens', 'print')
                   OR (p.recurso IN ('clientes', 'historico') AND p.acao = 'read')
                ON CONFLICT DO NOTHING;
                
                GET DIAGNOSTICS v_permissoes_adicionadas = ROW_COUNT;
                RAISE NOTICE '✅ Técnico: % permissões adicionadas', v_permissoes_adicionadas;
            
            -- GERENTE (nível 3)
            ELSIF v_funcao.nome ILIKE '%gerente%' OR v_funcao.nivel = 3 THEN
                INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
                SELECT v_funcao.empresa_id, v_funcao.id, p.id
                FROM public.permissoes p
                WHERE p.recurso IN (
                    'vendas', 'produtos', 'clientes', 'ordens', 'caixa',
                    'estoque', 'categorias', 'historico', 'charts', 'metrics',
                    'overview', 'financeiro', 'descontos', 'cupom', 'precos',
                    'print', 'impressao', 'export'
                )
                ON CONFLICT DO NOTHING;
                
                GET DIAGNOSTICS v_permissoes_adicionadas = ROW_COUNT;
                RAISE NOTICE '✅ Gerente: % permissões adicionadas', v_permissoes_adicionadas;
            
            -- OUTRAS FUNÇÕES (permissões básicas)
            ELSE
                INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
                SELECT v_funcao.empresa_id, v_funcao.id, p.id
                FROM public.permissoes p
                WHERE p.recurso = 'overview'
                   OR (p.recurso IN ('vendas', 'produtos', 'clientes') AND p.acao = 'read')
                ON CONFLICT DO NOTHING;
                
                GET DIAGNOSTICS v_permissoes_adicionadas = ROW_COUNT;
                RAISE NOTICE '⚠️ Função "%": % permissões básicas adicionadas', 
                    v_funcao.nome, v_permissoes_adicionadas;
            END IF;
        ELSE
            RAISE NOTICE '✓ Função já tem permissões';
        END IF;
    END LOOP;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ PERMISSÕES DAS FUNÇÕES VERIFICADAS';
    RAISE NOTICE '========================================';
END $$;

COMMIT;

-- =============================================
-- VERIFICAÇÃO FINAL
-- =============================================

SELECT '======================================' as linha;
SELECT '📊 RESULTADO FINAL' as titulo;
SELECT '======================================' as linha;

-- Funcionários criados
SELECT 
    '👥 FUNCIONÁRIOS' as secao,
    COUNT(*) as total,
    COUNT(CASE WHEN ativo THEN 1 END) as ativos,
    COUNT(CASE WHEN funcao_id IS NOT NULL THEN 1 END) as com_funcao
FROM public.funcionarios;

-- Funções e suas permissões
SELECT 
    '🔑 FUNÇÕES E PERMISSÕES' as secao,
    e.nome as empresa,
    f.nome as funcao,
    f.nivel,
    COUNT(DISTINCT fp.permissao_id) as total_permissoes,
    COUNT(DISTINCT func.id) as total_funcionarios
FROM public.funcoes f
INNER JOIN public.empresas e ON f.empresa_id = e.id
LEFT JOIN public.funcao_permissoes fp ON f.id = fp.funcao_id
LEFT JOIN public.funcionarios func ON func.funcao_id = f.id
GROUP BY e.nome, f.id, f.nome, f.nivel
ORDER BY e.nome, f.nivel;

-- Funcionários e suas funções
SELECT 
    '👤 FUNCIONÁRIOS DETALHADOS' as secao,
    f.nome as funcionario,
    f.email,
    func.nome as funcao,
    e.nome as empresa,
    f.ativo
FROM public.funcionarios f
LEFT JOIN public.funcoes func ON f.funcao_id = func.id
LEFT JOIN public.empresas e ON f.empresa_id = e.id
ORDER BY e.nome, f.nome;

SELECT '======================================' as linha;
SELECT '✅ SOLUÇÃO COMPLETA APLICADA!' as status;
SELECT '======================================' as linha;
