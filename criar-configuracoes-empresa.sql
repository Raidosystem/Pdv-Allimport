-- Criar tabela de configurações da empresa se não existir
CREATE TABLE IF NOT EXISTS public.configuracoes_empresa (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    nome_empresa TEXT NOT NULL,
    cnpj TEXT,
    telefone TEXT,
    endereco TEXT,
    cidade TEXT,
    estado TEXT,
    cep TEXT,
    email TEXT,
    logo_url TEXT,
    cor_primaria TEXT DEFAULT '#3B82F6',
    cor_secundaria TEXT DEFAULT '#1E40AF',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE public.configuracoes_empresa ENABLE ROW LEVEL SECURITY;

-- Política para o usuário ver apenas suas configurações
CREATE POLICY "Usuários podem ver suas próprias configurações de empresa" ON public.configuracoes_empresa
    FOR ALL USING (auth.uid() = user_id);

-- Inserir configuração padrão se não existir
INSERT INTO public.configuracoes_empresa (
    user_id, 
    nome_empresa, 
    cnpj, 
    telefone, 
    endereco, 
    cidade, 
    estado, 
    cep, 
    email
) 
SELECT 
    '00000000-0000-0000-0000-000000000000',
    'Allimport',
    '12.345.678/0001-90',
    '(11) 99999-9999',
    'Rua das Empresas, 123',
    'São Paulo',
    'SP',
    '01234-567',
    'contato@allimport.com.br'
WHERE NOT EXISTS (
    SELECT 1 FROM public.configuracoes_empresa 
    WHERE nome_empresa = 'Allimport'
);

-- Verificar se existe usuário vendedor nos funcionários
SELECT * FROM public.funcionarios WHERE cargo = 'vendedor' OR cargo = 'Vendedor' LIMIT 5;
