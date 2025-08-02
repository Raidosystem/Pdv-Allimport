-- 🔧 SISTEMA DE ORDENS DE SERVIÇO - PDV ALLIMPORT
-- Estrutura para assistência técnica de eletrônicos

-- 1. Criar tabela de ordens de serviço
CREATE TABLE IF NOT EXISTS public.ordens_servico (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    cliente_id UUID REFERENCES public.clientes(id) ON DELETE CASCADE,
    
    -- Informações do aparelho
    tipo TEXT NOT NULL CHECK (tipo IN ('Celular', 'Notebook', 'Console', 'Tablet', 'Outro')),
    marca TEXT NOT NULL,
    modelo TEXT NOT NULL,
    cor TEXT,
    numero_serie TEXT,
    
    -- Checklist técnico
    checklist JSONB DEFAULT '{}',
    observacoes TEXT,
    defeito_relatado TEXT,
    
    -- Datas e status
    data_entrada TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_previsao DATE,
    data_entrega TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'Em análise' CHECK (status IN (
        'Em análise',
        'Aguardando aprovação',
        'Aguardando peças',
        'Em conserto',
        'Pronto',
        'Entregue',
        'Cancelado'
    )),
    
    -- Valores
    valor_orcamento DECIMAL(10,2),
    valor_final DECIMAL(10,2),
    
    -- Controle
    usuario_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Adicionar campos extras na tabela clientes se não existirem
ALTER TABLE public.clientes 
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS endereco TEXT,
ADD COLUMN IF NOT EXISTS cidade TEXT,
ADD COLUMN IF NOT EXISTS cep TEXT;

-- 3. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_ordens_servico_cliente_id ON public.ordens_servico(cliente_id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_status ON public.ordens_servico(status);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_data_entrada ON public.ordens_servico(data_entrada);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_usuario_id ON public.ordens_servico(usuario_id);

-- 4. Habilitar RLS
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;

-- 5. Criar políticas de segurança
CREATE POLICY "Usuários podem ver suas próprias ordens de serviço" ON public.ordens_servico
    FOR SELECT USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem criar ordens de serviço" ON public.ordens_servico
    FOR INSERT WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem atualizar suas próprias ordens de serviço" ON public.ordens_servico
    FOR UPDATE USING (auth.uid() = usuario_id);

-- 6. Função para atualizar timestamp automaticamente
CREATE OR REPLACE FUNCTION update_ordens_servico_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Trigger para updated_at
DROP TRIGGER IF EXISTS update_ordens_servico_updated_at ON public.ordens_servico;
CREATE TRIGGER update_ordens_servico_updated_at
    BEFORE UPDATE ON public.ordens_servico
    FOR EACH ROW
    EXECUTE FUNCTION update_ordens_servico_updated_at();

-- 8. Inserir dados de exemplo
INSERT INTO public.ordens_servico (
    cliente_id,
    tipo,
    marca,
    modelo,
    cor,
    numero_serie,
    checklist,
    observacoes,
    defeito_relatado,
    data_previsao,
    status,
    valor_orcamento,
    usuario_id
) VALUES (
    (SELECT id FROM public.clientes LIMIT 1),
    'Celular',
    'Samsung',
    'Galaxy S21',
    'Preto',
    'SM-G991B123456',
    '{"liga": true, "tela_quebrada": true, "molhado": false, "com_senha": true, "bateria_boa": true, "tampa_presente": true, "acessorios": false}',
    'Cliente relatou que derrubou o aparelho e a tela rachou',
    'Tela trincada, touch funcionando parcialmente',
    CURRENT_DATE + INTERVAL '3 days',
    'Em análise',
    150.00,
    (SELECT auth.uid())
) ON CONFLICT DO NOTHING;

-- 9. Verificações finais
SELECT 
    '✅ ORDENS DE SERVIÇO CONFIGURADAS' as info,
    COUNT(*)::text as total_os
FROM public.ordens_servico;

SELECT 
    '✅ POLÍTICAS RLS ATIVAS' as info,
    COUNT(*)::text as total_policies
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'ordens_servico';

SELECT '🎉 SISTEMA DE OS PRONTO PARA USO!' as resultado;
