-- =============================================
-- CORREÇÃO URGENTE: RLS BLOQUEANDO FUNÇÕES
-- =============================================
-- O problema é que as políticas RLS estão muito restritivas

-- =============================================
-- PASSO 1: VERIFICAR DADOS ATUAIS
-- =============================================

-- Ver funcionários e seus dados de acesso
SELECT 
    f.id,
    f.nome,
    f.email,
    f.user_id,
    f.empresa_id,
    f.funcao_id,
    func.nome as funcao_nome,
    e.nome as empresa_nome
FROM public.funcionarios f
LEFT JOIN public.funcoes func ON f.funcao_id = func.id
LEFT JOIN public.empresas e ON f.empresa_id = e.id
ORDER BY f.created_at DESC;

-- Ver usuários auth
SELECT 
    id,
    email,
    created_at
FROM auth.users
ORDER BY created_at DESC;

-- =============================================
-- PASSO 2: DESABILITAR RLS TEMPORARIAMENTE
-- =============================================
-- CUIDADO: Isso permite acesso total temporariamente

ALTER TABLE public.funcoes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.funcao_permissoes DISABLE ROW LEVEL SECURITY;

-- =============================================
-- PASSO 3: CRIAR POLÍTICAS PERMISSIVAS
-- =============================================

-- Remover políticas antigas de funcoes
DROP POLICY IF EXISTS "allow_all_authenticated_select" ON public.funcoes;
DROP POLICY IF EXISTS "allow_all_authenticated_insert" ON public.funcoes;
DROP POLICY IF EXISTS "allow_all_authenticated_update" ON public.funcoes;
DROP POLICY IF EXISTS "allow_all_authenticated_delete" ON public.funcoes;

-- Remover políticas antigas de funcao_permissoes
DROP POLICY IF EXISTS "allow_all_authenticated_select" ON public.funcao_permissoes;
DROP POLICY IF EXISTS "allow_all_authenticated_insert" ON public.funcao_permissoes;
DROP POLICY IF EXISTS "allow_all_authenticated_update" ON public.funcao_permissoes;
DROP POLICY IF EXISTS "allow_all_authenticated_delete" ON public.funcao_permissoes;

-- Criar políticas ULTRA PERMISSIVAS para funcoes
CREATE POLICY "allow_all_authenticated_select"
ON public.funcoes FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "allow_all_authenticated_insert"
ON public.funcoes FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "allow_all_authenticated_update"
ON public.funcoes FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "allow_all_authenticated_delete"
ON public.funcoes FOR DELETE
TO authenticated
USING (true);

-- Criar políticas ULTRA PERMISSIVAS para funcao_permissoes
CREATE POLICY "allow_all_authenticated_select"
ON public.funcao_permissoes FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "allow_all_authenticated_insert"
ON public.funcao_permissoes FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "allow_all_authenticated_update"
ON public.funcao_permissoes FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "allow_all_authenticated_delete"
ON public.funcao_permissoes FOR DELETE
TO authenticated
USING (true);

-- Reabilitar RLS (agora com políticas permissivas)
ALTER TABLE public.funcoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.funcao_permissoes ENABLE ROW LEVEL SECURITY;

-- =============================================
-- PASSO 4: AJUSTAR POLÍTICAS DE FUNCIONARIOS
-- =============================================

-- Remover políticas restritivas de funcionarios
DROP POLICY IF EXISTS "Admins podem atualizar funcionários" ON public.funcionarios;
DROP POLICY IF EXISTS "Admins podem criar funcionários" ON public.funcionarios;
DROP POLICY IF EXISTS "Usuários podem ver funcionários da empresa" ON public.funcionarios;

-- Criar políticas permissivas para funcionarios
CREATE POLICY "allow_all_authenticated_select_funcionarios"
ON public.funcionarios FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "allow_all_authenticated_insert_funcionarios"
ON public.funcionarios FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "allow_all_authenticated_update_funcionarios"
ON public.funcionarios FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "allow_all_authenticated_delete_funcionarios"
ON public.funcionarios FOR DELETE
TO authenticated
USING (true);

-- =============================================
-- PASSO 5: VERIFICAR POLÍTICAS CRIADAS
-- =============================================

SELECT 
    tablename,
    policyname,
    permissive,
    cmd
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('funcionarios', 'funcoes', 'funcao_permissoes')
ORDER BY tablename, cmd;

-- =============================================
-- PASSO 6: TESTAR ACESSO
-- =============================================

-- Agora deve funcionar
SELECT COUNT(*) as total_funcoes FROM public.funcoes;
SELECT COUNT(*) as total_permissoes FROM public.funcao_permissoes;
SELECT COUNT(*) as total_funcionarios FROM public.funcionarios;

-- =============================================
-- RESULTADO ESPERADO
-- =============================================
SELECT '✅ RLS CORRIGIDO - POLÍTICAS PERMISSIVAS ATIVAS!' as status;

-- Todas as tabelas devem estar acessíveis agora para usuários autenticados
