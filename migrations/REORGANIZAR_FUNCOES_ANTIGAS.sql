-- =============================================
-- REORGANIZAR FUNÇÕES - MANTER FUNÇÕES ANTIGAS
-- =============================================
-- Remove funções duplicadas e mantém as originais com suas permissões

BEGIN;

-- =============================================
-- PASSO 1: IDENTIFICAR FUNÇÕES DUPLICADAS
-- =============================================

SELECT 
    '🔍 ANÁLISE DE FUNÇÕES DUPLICADAS' as secao;

SELECT 
    e.nome as empresa,
    f.nome as funcao,
    f.id,
    f.nivel,
    f.created_at,
    COUNT(fp.permissao_id) as total_permissoes
FROM public.funcoes f
INNER JOIN public.empresas e ON f.empresa_id = e.id
LEFT JOIN public.funcao_permissoes fp ON f.id = fp.funcao_id
GROUP BY e.nome, f.id, f.nome, f.nivel, f.created_at
ORDER BY e.nome, f.created_at;

-- =============================================
-- PASSO 2: REMOVER FUNÇÕES NOVAS (DUPLICADAS)
-- =============================================
-- Remove as funções criadas recentemente (Admin, Gerente, Vendedor, Técnico novos)

DO $$
DECLARE
    v_empresa_id UUID;
    v_funcoes_para_remover UUID[];
BEGIN
    FOR v_empresa_id IN 
        SELECT DISTINCT id FROM public.empresas
    LOOP
        RAISE NOTICE '🔄 Processando empresa: %', v_empresa_id;
        
        -- Identificar funções duplicadas (as mais recentes com nomes padrão)
        SELECT ARRAY_AGG(id) INTO v_funcoes_para_remover
        FROM (
            SELECT id, nome, created_at,
                   ROW_NUMBER() OVER (PARTITION BY empresa_id, nome ORDER BY created_at DESC) as rn
            FROM public.funcoes
            WHERE empresa_id = v_empresa_id
              AND nome IN ('Admin', 'Gerente', 'Vendedor', 'Técnico')
        ) duplicadas
        WHERE rn > 1;
        
        -- Remover permissões das funções duplicadas
        IF v_funcoes_para_remover IS NOT NULL THEN
            DELETE FROM public.funcao_permissoes
            WHERE funcao_id = ANY(v_funcoes_para_remover);
            
            -- Remover as funções duplicadas
            DELETE FROM public.funcoes
            WHERE id = ANY(v_funcoes_para_remover);
            
            RAISE NOTICE '✅ Removidas % funções duplicadas', array_length(v_funcoes_para_remover, 1);
        END IF;
    END LOOP;
END $$;

-- =============================================
-- PASSO 3: GARANTIR PERMISSÕES NAS FUNÇÕES ANTIGAS
-- =============================================

DO $$
DECLARE
    v_funcao RECORD;
    v_permissoes_adicionadas INTEGER;
BEGIN
    -- Para cada função existente, garantir que tenha permissões adequadas
    FOR v_funcao IN 
        SELECT 
            f.id,
            f.empresa_id,
            f.nome,
            f.nivel,
            COUNT(fp.permissao_id) as total_permissoes_atuais
        FROM public.funcoes f
        LEFT JOIN public.funcao_permissoes fp ON f.id = fp.funcao_id
        GROUP BY f.id, f.empresa_id, f.nome, f.nivel
    LOOP
        RAISE NOTICE '🔑 Verificando permissões para: % (nivel %, permissões atuais: %)', 
            v_funcao.nome, v_funcao.nivel, v_funcao.total_permissoes_atuais;
        
        -- Se não tem permissões, adicionar baseado no nome/nível
        IF v_funcao.total_permissoes_atuais = 0 THEN
            
            -- ADMINISTRADOR / ADMIN (nível mais alto ou nome específico)
            IF v_funcao.nome ILIKE '%admin%' OR v_funcao.nivel = 1 THEN
                INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
                SELECT v_funcao.empresa_id, v_funcao.id, p.id
                FROM public.permissoes p
                ON CONFLICT DO NOTHING;
                
                GET DIAGNOSTICS v_permissoes_adicionadas = ROW_COUNT;
                RAISE NOTICE '✅ Admin: % permissões adicionadas', v_permissoes_adicionadas;
            
            -- GERENTE
            ELSIF v_funcao.nome ILIKE '%gerente%' OR v_funcao.nivel = 2 THEN
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
            
            -- VENDEDOR
            ELSIF v_funcao.nome ILIKE '%vendedor%' OR v_funcao.nivel = 3 THEN
                INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
                SELECT v_funcao.empresa_id, v_funcao.id, p.id
                FROM public.permissoes p
                WHERE p.recurso IN ('vendas', 'clientes', 'cupom', 'descontos', 'overview', 'print')
                   OR (p.recurso = 'produtos' AND p.acao = 'read')
                   OR (p.recurso = 'caixa' AND p.acao = 'read')
                   OR (p.recurso = 'estoque' AND p.acao = 'read')
                   OR (p.recurso = 'categorias' AND p.acao = 'read')
                ON CONFLICT DO NOTHING;
                
                GET DIAGNOSTICS v_permissoes_adicionadas = ROW_COUNT;
                RAISE NOTICE '✅ Vendedor: % permissões adicionadas', v_permissoes_adicionadas;
            
            -- TÉCNICO
            ELSIF v_funcao.nome ILIKE '%técnico%' OR v_funcao.nome ILIKE '%tecnico%' OR v_funcao.nivel = 4 THEN
                INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
                SELECT v_funcao.empresa_id, v_funcao.id, p.id
                FROM public.permissoes p
                WHERE p.recurso = 'ordens'
                   OR (p.recurso = 'clientes' AND p.acao = 'read')
                   OR (p.recurso = 'historico' AND p.acao = 'read')
                   OR p.recurso = 'print'
                ON CONFLICT DO NOTHING;
                
                GET DIAGNOSTICS v_permissoes_adicionadas = ROW_COUNT;
                RAISE NOTICE '✅ Técnico: % permissões adicionadas', v_permissoes_adicionadas;
            
            -- OPERADOR DE CAIXA
            ELSIF v_funcao.nome ILIKE '%caixa%' OR v_funcao.nome ILIKE '%operador%' THEN
                INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
                SELECT v_funcao.empresa_id, v_funcao.id, p.id
                FROM public.permissoes p
                WHERE p.recurso IN ('vendas', 'caixa', 'clientes', 'produtos', 'overview', 'print', 'cupom', 'descontos')
                   OR (p.recurso = 'estoque' AND p.acao = 'read')
                ON CONFLICT DO NOTHING;
                
                GET DIAGNOSTICS v_permissoes_adicionadas = ROW_COUNT;
                RAISE NOTICE '✅ Operador de Caixa: % permissões adicionadas', v_permissoes_adicionadas;
            
            -- OUTRAS FUNÇÕES (permissões básicas)
            ELSE
                INSERT INTO public.funcao_permissoes (empresa_id, funcao_id, permissao_id)
                SELECT v_funcao.empresa_id, v_funcao.id, p.id
                FROM public.permissoes p
                WHERE p.recurso IN ('overview')
                   OR (p.recurso IN ('vendas', 'produtos', 'clientes') AND p.acao = 'read')
                ON CONFLICT DO NOTHING;
                
                GET DIAGNOSTICS v_permissoes_adicionadas = ROW_COUNT;
                RAISE NOTICE '⚠️ Função desconhecida "%": % permissões básicas adicionadas', 
                    v_funcao.nome, v_permissoes_adicionadas;
            END IF;
        END IF;
    END LOOP;
END $$;

-- =============================================
-- PASSO 4: ASSOCIAR FUNCIONÁRIOS ÀS FUNÇÕES
-- =============================================

-- Associar funcionários à função de nível mais baixo disponível (mais permissões)
-- Prioriza Admin/Administrador para o primeiro usuário
UPDATE public.funcionarios f
SET funcao_id = (
    SELECT func.id 
    FROM public.funcoes func
    WHERE func.empresa_id = f.empresa_id
    ORDER BY func.nivel ASC, func.created_at ASC
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

-- Demais funcionários: Vendedor ou Operador de Caixa
UPDATE public.funcionarios f
SET funcao_id = (
    SELECT func.id 
    FROM public.funcoes func
    WHERE func.empresa_id = f.empresa_id
      AND (func.nome ILIKE '%vendedor%' OR func.nome ILIKE '%caixa%')
    ORDER BY func.nivel ASC
    LIMIT 1
)
WHERE f.funcao_id IS NULL;

-- Se ainda houver funcionários sem função, atribuir qualquer função disponível
UPDATE public.funcionarios f
SET funcao_id = (
    SELECT func.id 
    FROM public.funcoes func
    WHERE func.empresa_id = f.empresa_id
    ORDER BY func.nivel DESC
    LIMIT 1
)
WHERE f.funcao_id IS NULL;

COMMIT;

-- =============================================
-- PASSO 5: VERIFICAR RESULTADO FINAL
-- =============================================

SELECT 
    '📊 FUNÇÕES FINAIS POR EMPRESA' as secao;

SELECT 
    e.nome as empresa,
    f.nome as funcao,
    f.nivel,
    f.descricao,
    COUNT(DISTINCT fp.permissao_id) as total_permissoes,
    COUNT(DISTINCT func.id) as total_usuarios
FROM public.funcoes f
INNER JOIN public.empresas e ON f.empresa_id = e.id
LEFT JOIN public.funcao_permissoes fp ON f.id = fp.funcao_id
LEFT JOIN public.funcionarios func ON func.funcao_id = f.id
GROUP BY e.nome, f.id, f.nome, f.nivel, f.descricao
ORDER BY e.nome, f.nivel;

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

SELECT 
    '✅ REORGANIZAÇÃO CONCLUÍDA!' as status;

SELECT 
    'Empresas: ' || COUNT(DISTINCT e.id) ||
    ' | Funções únicas: ' || COUNT(DISTINCT f.id) ||
    ' | Total permissões: ' || COUNT(fp.id) ||
    ' | Funcionários associados: ' || COUNT(DISTINCT func.id) as resumo
FROM public.empresas e
LEFT JOIN public.funcoes f ON e.id = f.empresa_id
LEFT JOIN public.funcao_permissoes fp ON f.id = fp.funcao_id
LEFT JOIN public.funcionarios func ON func.funcao_id = f.id;
