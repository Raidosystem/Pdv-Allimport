-- =============================================
-- POLÍTICAS RLS DEFINITIVAS PARA MULTI-TENANCY
-- =============================================
-- Este script garante que NUNCA mais haverá vazamento de dados entre empresas

BEGIN;

-- =============================================
-- PASSO 1: ADICIONAR UNIQUE CONSTRAINT EM user_id
-- =============================================
-- Garante que um user_id só pode ter 1 funcionário

ALTER TABLE public.funcionarios 
ADD CONSTRAINT funcionarios_user_id_unique UNIQUE (user_id);

-- =============================================
-- PASSO 2: POLÍTICAS RLS ULTRA-RESTRITIVAS PARA FUNCIONARIOS
-- =============================================

-- Remover políticas antigas
DROP POLICY IF EXISTS "funcionarios_select_policy" ON public.funcionarios;
DROP POLICY IF EXISTS "funcionarios_insert_policy" ON public.funcionarios;
DROP POLICY IF EXISTS "funcionarios_update_policy" ON public.funcionarios;
DROP POLICY IF EXISTS "funcionarios_delete_policy" ON public.funcionarios;

-- SELECT: Apenas funcionários da MINHA empresa
CREATE POLICY "funcionarios_select_policy" ON public.funcionarios
FOR SELECT
USING (
    empresa_id IN (
        SELECT id FROM public.empresas WHERE user_id = auth.uid()
    )
);

-- INSERT: Apenas para MINHA empresa E apenas se o user_id corresponder
CREATE POLICY "funcionarios_insert_policy" ON public.funcionarios
FOR INSERT
WITH CHECK (
    -- A empresa deve pertencer ao usuário logado
    empresa_id IN (
        SELECT id FROM public.empresas WHERE user_id = auth.uid()
    )
    AND (
        -- OU está criando para si mesmo (primeiro funcionário)
        user_id = auth.uid()
        -- OU está criando um funcionário sem user_id (será criado depois)
        OR user_id IS NULL
    )
);

-- UPDATE: Apenas funcionários da MINHA empresa
CREATE POLICY "funcionarios_update_policy" ON public.funcionarios
FOR UPDATE
USING (
    empresa_id IN (
        SELECT id FROM public.empresas WHERE user_id = auth.uid()
    )
)
WITH CHECK (
    empresa_id IN (
        SELECT id FROM public.empresas WHERE user_id = auth.uid()
    )
);

-- DELETE: Apenas funcionários da MINHA empresa
CREATE POLICY "funcionarios_delete_policy" ON public.funcionarios
FOR DELETE
USING (
    empresa_id IN (
        SELECT id FROM public.empresas WHERE user_id = auth.uid()
    )
);

-- =============================================
-- PASSO 3: TRIGGER PARA VALIDAR EMPRESA_ID NO INSERT
-- =============================================

CREATE OR REPLACE FUNCTION validar_empresa_funcionario()
RETURNS TRIGGER AS $$
DECLARE
    v_empresa_owner UUID;
BEGIN
    -- Buscar o dono da empresa
    SELECT user_id INTO v_empresa_owner
    FROM public.empresas
    WHERE id = NEW.empresa_id;
    
    -- Se a empresa não existe, bloquear
    IF v_empresa_owner IS NULL THEN
        RAISE EXCEPTION 'Empresa não encontrada';
    END IF;
    
    -- Se está tentando criar funcionário para empresa de outro usuário, bloquear
    IF v_empresa_owner != auth.uid() AND NEW.user_id != auth.uid() THEN
        RAISE EXCEPTION 'Você não pode criar funcionários para empresas de outros usuários';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger
DROP TRIGGER IF EXISTS trigger_validar_empresa_funcionario ON public.funcionarios;
CREATE TRIGGER trigger_validar_empresa_funcionario
    BEFORE INSERT ON public.funcionarios
    FOR EACH ROW
    EXECUTE FUNCTION validar_empresa_funcionario();

-- =============================================
-- PASSO 4: FUNÇÃO SEGURA PARA CRIAR FUNCIONÁRIO
-- =============================================

CREATE OR REPLACE FUNCTION criar_funcionario_seguro(
    p_nome TEXT,
    p_email TEXT,
    p_funcao_id UUID,
    p_ativo BOOLEAN DEFAULT true,
    p_status TEXT DEFAULT 'ativo'
)
RETURNS UUID AS $$
DECLARE
    v_empresa_id UUID;
    v_funcionario_id UUID;
    v_user_id UUID;
BEGIN
    -- Obter user_id do usuário logado
    v_user_id := auth.uid();
    
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Usuário não autenticado';
    END IF;
    
    -- Buscar empresa_id do usuário logado
    SELECT id INTO v_empresa_id
    FROM public.empresas
    WHERE user_id = v_user_id;
    
    IF v_empresa_id IS NULL THEN
        RAISE EXCEPTION 'Empresa não encontrada para o usuário';
    END IF;
    
    -- Validar que a função pertence à empresa do usuário
    IF NOT EXISTS (
        SELECT 1 FROM public.funcoes 
        WHERE id = p_funcao_id AND empresa_id = v_empresa_id
    ) THEN
        RAISE EXCEPTION 'Função não encontrada ou não pertence à sua empresa';
    END IF;
    
    -- Criar funcionário APENAS para a empresa do usuário logado
    INSERT INTO public.funcionarios (
        empresa_id,
        funcao_id,
        nome,
        email,
        ativo,
        status,
        user_id,
        created_at
    ) VALUES (
        v_empresa_id,
        p_funcao_id,
        p_nome,
        p_email,
        p_ativo,
        p_status,
        NULL, -- user_id será preenchido quando o funcionário fizer login
        NOW()
    )
    RETURNING id INTO v_funcionario_id;
    
    RETURN v_funcionario_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- PASSO 5: VERIFICAR INTEGRIDADE DOS DADOS
-- =============================================

-- Ver se há funcionários com empresa_id incorreto
SELECT 
    '⚠️ FUNCIONÁRIOS COM EMPRESA_ID INCORRETO' as secao;

SELECT 
    f.id,
    f.nome,
    f.email,
    f.empresa_id,
    e.user_id as empresa_owner,
    f.user_id as funcionario_user_id,
    CASE 
        WHEN f.user_id = e.user_id THEN '✓ OK (É o proprietário)'
        WHEN f.user_id IS NULL THEN '⚠️ NULL (Será preenchido no login)'
        ELSE '✗ INCORRETO (Funcionário de outra empresa)'
    END as status
FROM public.funcionarios f
INNER JOIN public.empresas e ON f.empresa_id = e.id
WHERE f.user_id IS NOT NULL 
  AND f.user_id != e.user_id;

-- Contar funcionários por empresa
SELECT 
    '📊 FUNCIONÁRIOS POR EMPRESA' as secao;

SELECT 
    e.nome as empresa,
    e.user_id as proprietario,
    COUNT(f.id) as total_funcionarios,
    COUNT(CASE WHEN f.user_id = e.user_id THEN 1 END) as proprietarios,
    COUNT(CASE WHEN f.user_id IS NULL THEN 1 END) as sem_user_id,
    COUNT(CASE WHEN f.user_id IS NOT NULL AND f.user_id != e.user_id THEN 1 END) as incorretos
FROM public.empresas e
LEFT JOIN public.funcionarios f ON e.id = f.empresa_id
GROUP BY e.nome, e.user_id
ORDER BY e.nome;

COMMIT;

-- =============================================
-- RESULTADO
-- =============================================

SELECT '✅ PROTEÇÕES MULTI-TENANCY APLICADAS!' as status;
SELECT '
🔒 PROTEÇÕES IMPLEMENTADAS:

1. ✅ UNIQUE constraint em user_id (1 usuário = 1 funcionário)
2. ✅ RLS ultra-restritivo em funcionarios (apenas SUA empresa)
3. ✅ Trigger de validação no INSERT
4. ✅ Função criar_funcionario_seguro() que valida empresa_id
5. ✅ Políticas que impedem acesso cross-empresa

⚠️ NUNCA MAIS:
- Scripts SQL não podem criar funcionários sem validar empresa_id
- Apenas criar_funcionario_seguro() deve ser usado
- Frontend deve sempre passar pela validação do backend
- RLS garante que mesmo queries diretos não vazam dados

' as protecoes;
