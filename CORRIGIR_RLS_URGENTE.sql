-- =====================================================
-- 🔒 CORREÇÃO URGENTE: REATIVAR RLS EM TODAS AS TABELAS
-- =====================================================
-- Execute este SQL no Supabase SQL Editor
-- =====================================================

-- PASSO 1: REATIVAR RLS EM TABELAS CRÍTICAS
-- =====================================================

ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fornecedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.configuracoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.funcionarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.login_funcionarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.funcoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.funcao_permissoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.backups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

-- PASSO 2: VERIFICAR STATUS
-- =====================================================

SELECT 
    tablename,
    CASE 
        WHEN rowsecurity THEN '✅ RLS Ativo'
        ELSE '🚨 RLS Desabilitado'
    END AS status
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN (
        'clientes', 'produtos', 'vendas', 'vendas_itens', 'itens_venda',
        'caixa', 'movimentacoes_caixa', 'ordens_servico', 'fornecedores',
        'categorias', 'configuracoes', 'empresas', 'funcionarios',
        'login_funcionarios', 'user_approvals', 'funcoes', 'permissoes',
        'funcao_permissoes', 'backups', 'subscriptions', 'contas_pagar',
        'contas_receber', 'user_settings'
    )
ORDER BY tablename;

-- PASSO 3: VERIFICAR SE POLÍTICAS EXISTEM
-- =====================================================

SELECT 
    tablename,
    COUNT(*) AS num_policies
FROM pg_policies
WHERE schemaname = 'public'
    AND tablename IN (
        'clientes', 'produtos', 'vendas', 'caixa', 
        'ordens_servico', 'fornecedores'
    )
GROUP BY tablename
ORDER BY tablename;

-- PASSO 4: SE POLÍTICAS FALTAREM, CRIAR (MODELO)
-- =====================================================
-- Usar get_current_user_id() para suportar funcionários

-- Exemplo para tabela sem políticas:
-- CREATE POLICY "users_own_data" ON <tabela>
--   FOR ALL USING (user_id = get_current_user_id());

-- =====================================================
-- ✅ APÓS EXECUTAR, RODAR VERIFICAR_RLS_ATUAL.sql
-- =====================================================
