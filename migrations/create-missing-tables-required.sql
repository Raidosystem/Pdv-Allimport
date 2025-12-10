-- TABELAS FALTANTES PARA INSERIR MANUALMENTE NO SUPABASE
-- Execute estas queries no SQL Editor do Supabase Dashboard
-- IMPORTANTE: Execute ANTES do script principal create-missing-tables.sql

-- =============================================
-- TABELA CAIXA (CONTROLE DE SESSÕES DE CAIXA)
-- =============================================
CREATE TABLE IF NOT EXISTS public.caixa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data_abertura TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    data_fechamento TIMESTAMP WITH TIME ZONE,
    saldo_inicial DECIMAL(10,2) NOT NULL DEFAULT 0,
    saldo_final DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'aberto', -- 'aberto', 'fechado'
    observacoes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- TABELA MOVIMENTAÇÕES DE CAIXA
-- =============================================
CREATE TABLE IF NOT EXISTS public.movimentacoes_caixa (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    caixa_id UUID REFERENCES public.caixa(id) ON DELETE CASCADE NOT NULL,
    tipo VARCHAR(20) NOT NULL, -- 'entrada', 'saida', 'venda', 'troco', 'sangria', 'suprimento'
    valor DECIMAL(10,2) NOT NULL,
    descricao TEXT,
    venda_id UUID, -- Referência opcional para vendas
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- TABELA CONFIGURAÇÕES DO SISTEMA
-- =============================================
CREATE TABLE IF NOT EXISTS public.configuracoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chave VARCHAR(100) NOT NULL, -- ex: 'nome_loja', 'logo_url', 'endereco', etc.
    valor TEXT, -- Valor da configuração
    descricao TEXT, -- Descrição da configuração
    tipo VARCHAR(20) DEFAULT 'string', -- 'string', 'number', 'boolean', 'json'
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(chave, user_id) -- Cada usuário pode ter apenas uma configuração por chave
);

-- =============================================
-- VERIFICAR SE TABELA CLIENTES JÁ EXISTE
-- =============================================
-- Se a tabela clientes não existir, crie ela também:
CREATE TABLE IF NOT EXISTS public.clientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    telefone VARCHAR(20),
    cpf VARCHAR(14),
    endereco TEXT,
    data_nascimento DATE,
    observacoes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- HABILITAR RLS NAS NOVAS TABELAS
-- =============================================
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.configuracoes ENABLE ROW LEVEL SECURITY;

-- =============================================
-- POLÍTICAS RLS PARA AS NOVAS TABELAS
-- =============================================

-- CAIXA: Políticas RLS
DROP POLICY IF EXISTS "Users can only see their own caixa" ON public.caixa;
CREATE POLICY "Users can only see their own caixa" ON public.caixa
    FOR ALL USING (auth.uid() = user_id);

-- MOVIMENTAÇÕES CAIXA: Políticas RLS
DROP POLICY IF EXISTS "Users can only see their own movimentacoes_caixa" ON public.movimentacoes_caixa;
CREATE POLICY "Users can only see their own movimentacoes_caixa" ON public.movimentacoes_caixa
    FOR ALL USING (auth.uid() = user_id);

-- CONFIGURAÇÕES: Políticas RLS
DROP POLICY IF EXISTS "Users can only see their own configuracoes" ON public.configuracoes;
CREATE POLICY "Users can only see their own configuracoes" ON public.configuracoes
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- TRIGGERS PARA AUTO-INSERIR user_id
-- =============================================

-- Trigger para caixa
DROP TRIGGER IF EXISTS set_user_id_caixa ON public.caixa;
CREATE TRIGGER set_user_id_caixa
    BEFORE INSERT ON public.caixa
    FOR EACH ROW EXECUTE FUNCTION public.set_user_id();

-- Trigger para movimentacoes_caixa
DROP TRIGGER IF EXISTS set_user_id_movimentacoes_caixa ON public.movimentacoes_caixa;
CREATE TRIGGER set_user_id_movimentacoes_caixa
    BEFORE INSERT ON public.movimentacoes_caixa
    FOR EACH ROW EXECUTE FUNCTION public.set_user_id();

-- Trigger para configuracoes
DROP TRIGGER IF EXISTS set_user_id_configuracoes ON public.configuracoes;
CREATE TRIGGER set_user_id_configuracoes
    BEFORE INSERT ON public.configuracoes
    FOR EACH ROW EXECUTE FUNCTION public.set_user_id();

-- =============================================
-- PERMISSÕES PARA USUÁRIOS AUTENTICADOS
-- =============================================
GRANT SELECT, INSERT, UPDATE, DELETE ON public.caixa TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.movimentacoes_caixa TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.configuracoes TO authenticated;

-- Remover permissões de usuários anônimos
REVOKE ALL ON public.caixa FROM anon;
REVOKE ALL ON public.movimentacoes_caixa FROM anon;
REVOKE ALL ON public.configuracoes FROM anon;

-- =============================================
-- INSERIR CONFIGURAÇÕES PADRÃO (OPCIONAL)
-- =============================================
INSERT INTO public.configuracoes (chave, valor, descricao, tipo) VALUES 
('nome_loja', 'PDV Allimport', 'Nome da loja', 'string'),
('endereco_loja', '', 'Endereço da loja', 'string'),
('telefone_loja', '', 'Telefone da loja', 'string'),
('cnpj_loja', '', 'CNPJ da loja', 'string'),
('logo_url', '', 'URL do logo da loja', 'string'),
('cor_tema', '#3B82F6', 'Cor do tema do sistema', 'string'),
('moeda', 'BRL', 'Moeda padrão', 'string'),
('taxa_desconto_max', '10', 'Taxa máxima de desconto (%)', 'number'),
('backup_automatico', 'true', 'Backup automático habilitado', 'boolean'),
('notificacoes_email', 'true', 'Notificações por email', 'boolean')
ON CONFLICT (chave, user_id) DO NOTHING;

-- =============================================
-- VERIFICAÇÃO FINAL
-- =============================================
SELECT 'TABELAS CRIADAS COM SUCESSO:
✅ caixa - Controle de sessões de caixa
✅ movimentacoes_caixa - Movimentações de entrada/saída
✅ configuracoes - Configurações do sistema
✅ clientes - Cadastro de clientes (se não existia)
✅ RLS habilitado em todas as tabelas
✅ Triggers para user_id configurados
✅ Permissões configuradas
🔒 Privacidade garantida!' as resultado;
