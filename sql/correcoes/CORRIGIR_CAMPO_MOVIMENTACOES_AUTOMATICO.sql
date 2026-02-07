-- 🔧 CORREÇÃO DEFINITIVA: Garantir que movimentacoes_caixa use usuario_id
-- Este script detecta qual campo existe e corrige automaticamente

-- ============================================================================
-- PASSO 1: Descobrir qual campo existe (usuario_id ou user_id)
-- ============================================================================

DO $$
DECLARE
    tem_usuario_id BOOLEAN;
    tem_user_id BOOLEAN;
BEGIN
    -- Verificar se existe usuario_id
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'movimentacoes_caixa' 
          AND column_name = 'usuario_id'
    ) INTO tem_usuario_id;
    
    -- Verificar se existe user_id
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
          AND table_name = 'movimentacoes_caixa' 
          AND column_name = 'user_id'
    ) INTO tem_user_id;
    
    -- Mostrar resultado
    RAISE NOTICE '=================================================';
    RAISE NOTICE '🔍 DIAGNÓSTICO DA TABELA movimentacoes_caixa';
    RAISE NOTICE '=================================================';
    
    IF tem_usuario_id THEN
        RAISE NOTICE '✅ Campo usuario_id EXISTE';
    ELSE
        RAISE NOTICE '❌ Campo usuario_id NÃO EXISTE';
    END IF;
    
    IF tem_user_id THEN
        RAISE NOTICE '✅ Campo user_id EXISTE';
    ELSE
        RAISE NOTICE '❌ Campo user_id NÃO EXISTE';
    END IF;
    
    RAISE NOTICE '=================================================';
    
    -- CENÁRIO 1: Existe user_id mas não existe usuario_id (precisa renomear)
    IF tem_user_id AND NOT tem_usuario_id THEN
        RAISE NOTICE '🔧 AÇÃO: Renomeando user_id → usuario_id...';
        
        -- Desabilitar RLS temporariamente
        ALTER TABLE public.movimentacoes_caixa DISABLE ROW LEVEL SECURITY;
        
        -- Renomear coluna
        ALTER TABLE public.movimentacoes_caixa RENAME COLUMN user_id TO usuario_id;
        
        -- Reabilitar RLS
        ALTER TABLE public.movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
        
        RAISE NOTICE '✅ Coluna renomeada com sucesso!';
    
    -- CENÁRIO 2: Existe usuario_id (correto!)
    ELSIF tem_usuario_id THEN
        RAISE NOTICE '✅ Estrutura já está correta! Campo usuario_id existe.';
        
        -- Verificar se existe user_id duplicado
        IF tem_user_id THEN
            RAISE NOTICE '⚠️ AVISO: Campos user_id E usuario_id existem (duplicados!)';
            RAISE NOTICE '🔧 Removendo campo user_id duplicado...';
            
            ALTER TABLE public.movimentacoes_caixa DROP COLUMN IF EXISTS user_id CASCADE;
            
            RAISE NOTICE '✅ Campo user_id removido.';
        END IF;
    
    -- CENÁRIO 3: Nenhum campo existe (erro crítico!)
    ELSE
        RAISE EXCEPTION '❌ ERRO CRÍTICO: Nenhum dos campos (usuario_id ou user_id) existe na tabela!';
    END IF;
    
    RAISE NOTICE '=================================================';
END $$;

-- ============================================================================
-- PASSO 2: Recriar políticas RLS com usuario_id
-- ============================================================================

-- Remover TODAS as políticas antigas
DROP POLICY IF EXISTS "Usuários podem ver movimentações dos seus caixas" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "Usuários podem criar movimentações" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "Users can only see their own movimentacoes_caixa" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_delete_policy" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_insert_policy" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_select_policy" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_update_policy" ON public.movimentacoes_caixa;

-- Garantir que RLS está habilitado
ALTER TABLE public.movimentacoes_caixa ENABLE ROW LEVEL SECURITY;

-- Criar política de SELECT
CREATE POLICY "Usuários podem ver movimentações dos seus caixas" 
ON public.movimentacoes_caixa
FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM public.caixa 
        WHERE caixa.id = movimentacoes_caixa.caixa_id 
        AND caixa.usuario_id = auth.uid()
    )
);

-- Criar política de INSERT
CREATE POLICY "Usuários podem criar movimentações" 
ON public.movimentacoes_caixa
FOR INSERT 
WITH CHECK (
    auth.uid() = usuario_id AND
    EXISTS (
        SELECT 1 FROM public.caixa 
        WHERE caixa.id = movimentacoes_caixa.caixa_id 
        AND caixa.usuario_id = auth.uid()
    )
);

-- ============================================================================
-- PASSO 3: Verificar correção
-- ============================================================================

-- Mostrar estrutura final
SELECT 
    '✅ Estrutura final da tabela movimentacoes_caixa:' as resultado;

SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'movimentacoes_caixa'
ORDER BY ordinal_position;

-- Mostrar políticas ativas
SELECT 
    '✅ Políticas RLS ativas:' as resultado;

SELECT 
    policyname,
    cmd
FROM pg_policies
WHERE tablename = 'movimentacoes_caixa';

SELECT 
    '=================================================',
    '✅ CORREÇÃO CONCLUÍDA COM SUCESSO!',
    '=================================================';
