-- =============================================
-- DIAGNÓSTICO URGENTE: FUNÇÕES E PERMISSÕES SUMIRAM
-- =============================================

-- 1. VERIFICAR ESTRUTURA DA TABELA FUNCIONARIOS
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'funcionarios'
ORDER BY ordinal_position;

-- 2. VERIFICAR SE EXISTEM FUNCIONÁRIOS
SELECT 
    COUNT(*) as total_funcionarios,
    COUNT(CASE WHEN funcao_id IS NOT NULL THEN 1 END) as com_funcao,
    COUNT(CASE WHEN funcao_id IS NULL THEN 1 END) as sem_funcao
FROM public.funcionarios;

-- 3. LISTAR FUNCIONÁRIOS E SUAS FUNÇÕES
SELECT 
    f.id,
    f.nome,
    f.email,
    f.funcao_id,
    func.nome as nome_funcao,
    f.ativo,
    f.empresa_id
FROM public.funcionarios f
LEFT JOIN public.funcoes func ON f.funcao_id = func.id
ORDER BY f.created_at DESC
LIMIT 20;

-- 4. VERIFICAR SE A TABELA FUNCOES EXISTE E TEM DADOS
SELECT 
    COUNT(*) as total_funcoes
FROM public.funcoes;

-- 5. LISTAR TODAS AS FUNÇÕES
SELECT 
    id,
    nome,
    descricao,
    nivel,
    empresa_id,
    created_at
FROM public.funcoes
ORDER BY nivel, nome;

-- 6. VERIFICAR ESTRUTURA DA TABELA FUNCAO_PERMISSOES
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'funcao_permissoes'
ORDER BY ordinal_position;

-- 7. VERIFICAR SE EXISTEM PERMISSÕES
SELECT 
    COUNT(*) as total_permissoes
FROM public.funcao_permissoes;

-- 8. LISTAR PERMISSÕES (SEM ASSUMIR ESTRUTURA)
SELECT *
FROM public.funcao_permissoes
LIMIT 20;

-- 9. VERIFICAR USUÁRIOS AUTH
SELECT 
    u.id,
    u.email,
    u.created_at,
    u.last_sign_in_at,
    EXISTS(SELECT 1 FROM public.funcionarios WHERE email = u.email) as tem_funcionario
FROM auth.users u
ORDER BY u.created_at DESC
LIMIT 10;

-- 10. VERIFICAR RLS DAS TABELAS
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_ativo
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('funcionarios', 'funcoes', 'funcao_permissoes')
ORDER BY tablename;

-- 11. VERIFICAR POLÍTICAS RLS
SELECT 
    tablename,
    policyname,
    permissive,
    cmd,
    qual
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('funcionarios', 'funcoes', 'funcao_permissoes')
ORDER BY tablename, policyname;

-- =============================================
-- RESULTADO ESPERADO:
-- =============================================
-- Se funcionários existem mas funcao_id está NULL:
--   → Problema: Dados foram perdidos ou não associados
--   → Solução: Restaurar funções e associações

-- Se tabela funcoes está vazia:
--   → Problema: Funções foram deletadas
--   → Solução: Recriar funções padrão

-- Se RLS está bloqueando acesso:
--   → Problema: Políticas muito restritivas
--   → Solução: Ajustar RLS
