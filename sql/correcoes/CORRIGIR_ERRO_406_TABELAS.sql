-- =====================================================
-- CORREÇÃO DE ERROS 406 - TABELAS CAIXA E LOJAS_ONLINE
-- =====================================================
-- Este script corrige os erros 406 (Not Acceptable) criando
-- as tabelas necessárias e configurando RLS corretamente
-- Data: 2025-12-20
-- =====================================================

-- =====================================================
-- PARTE 1: TABELA CAIXA
-- =====================================================

-- Criar tabela caixa se não existir
CREATE TABLE IF NOT EXISTS public.caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    valor_inicial DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    valor_final DECIMAL(10,2),
    data_abertura TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    data_fechamento TIMESTAMP WITH TIME ZONE,
    status TEXT CHECK (status IN ('aberto', 'fechado')) DEFAULT 'aberto' NOT NULL,
    diferenca DECIMAL(10,2),
    observacoes TEXT,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Criar tabela de movimentações do caixa se não existir
CREATE TABLE IF NOT EXISTS public.movimentacoes_caixa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    caixa_id UUID REFERENCES public.caixa(id) ON DELETE CASCADE NOT NULL,
    tipo TEXT CHECK (tipo IN ('entrada', 'saida')) NOT NULL,
    descricao TEXT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    usuario_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    venda_id UUID,
    data TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Habilitar RLS nas tabelas de caixa
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa ENABLE ROW LEVEL SECURITY;

-- Remover TODAS as políticas existentes de caixa (inclusive antigas)
DROP POLICY IF EXISTS "Usuários podem ver seus próprios caixas" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem criar caixas" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios caixas" ON public.caixa;
DROP POLICY IF EXISTS "Usuários podem deletar seus próprios caixas" ON public.caixa;
DROP POLICY IF EXISTS "Users can only see their own caixa" ON public.caixa;
DROP POLICY IF EXISTS "caixa_empresa_isolation" ON public.caixa;

-- Criar políticas para tabela caixa
CREATE POLICY "Usuários podem ver seus próprios caixas" ON public.caixa
    FOR SELECT USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem criar caixas" ON public.caixa
    FOR INSERT WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem atualizar seus próprios caixas" ON public.caixa
    FOR UPDATE USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem deletar seus próprios caixas" ON public.caixa
    FOR DELETE USING (auth.uid() = usuario_id);

-- Remover TODAS as políticas existentes de movimentacoes_caixa (inclusive antigas)
DROP POLICY IF EXISTS "Usuários podem ver movimentações dos seus caixas" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "Usuários podem criar movimentações" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "Users can only see their own movimentacoes_caixa" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_delete_policy" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_insert_policy" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_select_policy" ON public.movimentacoes_caixa;
DROP POLICY IF EXISTS "movimentacoes_caixa_update_policy" ON public.movimentacoes_caixa;

-- Criar políticas para tabela movimentacoes_caixa
CREATE POLICY "Usuários podem ver movimentações dos seus caixas" ON public.movimentacoes_caixa
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.caixa 
            WHERE caixa.id = movimentacoes_caixa.caixa_id 
            AND caixa.usuario_id = auth.uid()
        )
    );

CREATE POLICY "Usuários podem criar movimentações" ON public.movimentacoes_caixa
    FOR INSERT WITH CHECK (
        auth.uid() = usuario_id AND
        EXISTS (
            SELECT 1 FROM public.caixa 
            WHERE caixa.id = movimentacoes_caixa.caixa_id 
            AND caixa.usuario_id = auth.uid()
        )
    );

-- Índices para performance do caixa
CREATE INDEX IF NOT EXISTS idx_caixa_usuario_id ON public.caixa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_caixa_status ON public.caixa(status);
CREATE INDEX IF NOT EXISTS idx_caixa_data_abertura ON public.caixa(data_abertura);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa_id ON public.movimentacoes_caixa(caixa_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_usuario_id ON public.movimentacoes_caixa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_data ON public.movimentacoes_caixa(data);

-- =====================================================
-- PARTE 2: TABELA LOJAS_ONLINE
-- =====================================================

-- Criar tabela lojas_online se não existir
CREATE TABLE IF NOT EXISTS public.lojas_online (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  empresa_id UUID NOT NULL, -- Removido REFERENCES por enquanto
  slug TEXT UNIQUE, -- URL amigável (ex: minhaloja)
  nome TEXT NOT NULL, -- Nome da loja
  ativa BOOLEAN DEFAULT false,
  whatsapp TEXT,
  logo_url TEXT,
  cor_primaria TEXT DEFAULT '#3B82F6',
  cor_secundaria TEXT DEFAULT '#10B981',
  descricao TEXT,
  
  -- Configurações
  mostrar_preco BOOLEAN DEFAULT true,
  mostrar_estoque BOOLEAN DEFAULT false,
  permitir_carrinho BOOLEAN DEFAULT true,
  calcular_frete BOOLEAN DEFAULT false,
  permitir_retirada BOOLEAN DEFAULT true,
  
  -- Meta tags
  meta_title TEXT,
  meta_description TEXT,
  meta_keywords TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);TODAS as políticas existentes de lojas_online (inclusive antigas)
DROP POLICY IF EXISTS "Leitura pública de lojas ativas" ON public.lojas_online;
DROP POLICY IF EXISTS "Empresas podem ver suas lojas" ON public.lojas_online;
DROP POLICY IF EXISTS "Empresas podem criar lojas" ON public.lojas_online;
DROP POLICY IF EXISTS "Empresas podem atualizar suas lojas" ON public.lojas_online;
DROP POLICY IF EXISTS "Empresas podem deletar suas lojas" ON public.lojas_online;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.lojas_online;
DROP POLICY IF EXISTS "Users can view their own stores" ON public.lojas_online;
DROP POLICY IF EXISTS "Acesso público a lojas ativas" ON public.lojas_online;
DROP POLICY IF EXISTS "public_read_lojas_ativa ON public.lojas_online;
DROP POLICY IF EXISTS "Empresas podem criar lojas" ON public.lojas_online;
DROP POLICY IF EXISTS "Empresas podem atualizar suas lojas" ON public.lojas_online;
DROP POLICY IF EXISTS "Empresas podem deletar suas lojas" ON public.lojas_online;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.lojas_online;
DROP POLICY IF EXISTS "Users can view their own stores" ON public.lojas_online;

-- Criar políticas simples para lojas_online
-- Leitura pública de lojas ativas
CREATE POLICY "Leitura pública de lojas ativas"
  ON public.lojas_online FOR SELECT
  USING (ativa = true);

-- Donos podem ver suas lojas (ativas ou não)
CREATE POLICY "Empresas podem ver suas lojas"
  ON public.lojas_online FOR SELECT
  USING (empresa_id = auth.uid());

-- Inserção por empresa
CREATE POLICY "Empresas podem criar lojas"
  ON public.lojas_online FOR INSERT
  WITH CHECK (empresa_id = auth.uid());

-- Atualização por empresa
CREATE POLICY "Empresas podem atualizar suas lojas"
  ON public.lojas_online FOR UPDATE
  USING (empresa_id = auth.uid());

-- Deleção por empresa
CREATE POLICY "Empresas podem deletar suas lojas"
  ON public.lojas_online FOR DELETE
  USING (empresa_id = auth.uid());

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_lojas_online_empresa_id ON public.lojas_online(empresa_id);
CREATE INDEX IF NOT EXISTS idx_lojas_online_slug ON public.lojas_online(slug);
CREATE INDEX IF NOT EXISTS idx_lojas_online_ativa ON public.lojas_online(ativa);

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se as tabelas foram criadas
DO $$
BEGIN
  RAISE NOTICE '✅ Verificando tabelas...';
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'caixa') THEN
    RAISE NOTICE '✅ Tabela caixa existe';
  ELSE
    RAISE WARNING '❌ Tabela caixa NÃO existe';
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movimentacoes_caixa') THEN
    RAISE NOTICE '✅ Tabela movimentacoes_caixa existe';
  ELSE
    RAISE WARNING '❌ Tabela movimentacoes_caixa NÃO existe';
  END IF;
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'lojas_online') THEN
    RAISE NOTICE '✅ Tabela lojas_online existe';
  ELSE
    RAISE WARNING '❌ Tabela lojas_online NÃO existe';
  END IF;
END $$;

-- Verificar RLS
SELECT 
  schemaname, 
  tablename, 
  rowsecurity as "RLS Habilitado"
FROM pg_tables 
WHERE tablename IN ('caixa', 'movimentacoes_caixa', 'lojas_online')
  AND schemaname = 'public';

-- Verificar políticas
SELECT 
  tablename,
  policyname,
  cmd as "Operação",
  CASE 
    WHEN permissive = 'PERMISSIVE' THEN 'Permissiva'
    ELSE 'Restritiva'
  END as "Tipo"
FROM pg_policies
WHERE tablename IN ('caixa', 'movimentacoes_caixa', 'lojas_online')
ORDER BY tablename, policyname;
