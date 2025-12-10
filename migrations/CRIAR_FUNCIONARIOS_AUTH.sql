-- =============================================
-- CRIAR FUNCIONÁRIOS A PARTIR DE USUÁRIOS AUTH
-- =============================================

BEGIN;

-- Ver usuários do auth que não têm funcionário
SELECT 
    '👤 USUÁRIOS SEM FUNCIONÁRIO' as secao;

SELECT 
    au.id as user_id,
    au.email,
    au.created_at,
    f.id as funcionario_id
FROM auth.users au
LEFT JOIN public.funcionarios f ON au.id = f.user_id
WHERE f.id IS NULL
ORDER BY au.created_at;

-- Ver empresas disponíveis
SELECT 
    '🏢 EMPRESAS DISPONÍVEIS' as secao;

SELECT id, nome, created_at FROM public.empresas ORDER BY created_at;

-- =============================================
-- CRIAR FUNCIONÁRIOS PARA USUÁRIOS AUTH
-- =============================================

DO $$
DECLARE
    v_user RECORD;
    v_empresa_id UUID;
    v_funcionario_id UUID;
    v_funcao_admin_id UUID;
BEGIN
    -- Pegar a primeira empresa (Allimport)
    SELECT id INTO v_empresa_id 
    FROM public.empresas 
    ORDER BY created_at ASC 
    LIMIT 1;
    
    RAISE NOTICE '🏢 Empresa selecionada: %', v_empresa_id;
    
    -- Pegar a função Admin da empresa
    SELECT id INTO v_funcao_admin_id
    FROM public.funcoes
    WHERE empresa_id = v_empresa_id
      AND (nome ILIKE '%admin%' OR nivel = 1)
    ORDER BY nivel ASC
    LIMIT 1;
    
    RAISE NOTICE '👑 Função Admin: %', v_funcao_admin_id;
    
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
        
        -- Criar funcionário
        INSERT INTO public.funcionarios (
            user_id,
            empresa_id,
            funcao_id,
            nome,
            email,
            ativo,
            created_at
        ) VALUES (
            v_user.user_id,
            v_empresa_id,
            v_funcao_admin_id,
            COALESCE(SPLIT_PART(v_user.email, '@', 1), 'Usuário'),
            v_user.email,
            true,
            v_user.created_at
        )
        RETURNING id INTO v_funcionario_id;
        
        RAISE NOTICE '✅ Funcionário criado: % (ID: %)', v_user.email, v_funcionario_id;
    END LOOP;
    
    IF NOT FOUND THEN
        RAISE NOTICE '⚠️ Nenhum usuário sem funcionário encontrado';
    END IF;
END $$;

COMMIT;

-- =============================================
-- VERIFICAR RESULTADO
-- =============================================

SELECT 
    '✅ FUNCIONÁRIOS CRIADOS' as secao;

SELECT 
    f.id,
    f.nome,
    f.email,
    f.ativo,
    func.nome as funcao,
    e.nome as empresa,
    f.created_at
FROM public.funcionarios f
LEFT JOIN public.funcoes func ON f.funcao_id = func.id
LEFT JOIN public.empresas e ON f.empresa_id = e.id
ORDER BY f.created_at;

-- Contar funcionários por empresa
SELECT 
    '📊 RESUMO' as secao;

SELECT 
    e.nome as empresa,
    COUNT(f.id) as total_funcionarios,
    COUNT(CASE WHEN f.ativo THEN 1 END) as ativos,
    COUNT(CASE WHEN NOT f.ativo THEN 1 END) as inativos
FROM public.empresas e
LEFT JOIN public.funcionarios f ON e.id = f.empresa_id
GROUP BY e.nome;
