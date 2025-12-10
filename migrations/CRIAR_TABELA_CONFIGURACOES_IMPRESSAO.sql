-- ============================================
-- CRIAR TABELA DE CONFIGURAÇÕES DE IMPRESSÃO
-- ============================================

-- Tabela para armazenar configurações de cabeçalho e rodapé das impressões
CREATE TABLE IF NOT EXISTS public.configuracoes_impressao (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  empresa_id UUID REFERENCES public.empresas(id) ON DELETE CASCADE,
  
  -- Conteúdo customizável
  cabecalho TEXT NOT NULL DEFAULT 'COMPROVANTE DE ENTREGA',
  rodape TEXT NOT NULL DEFAULT 'Obrigado pela preferência! Guarde este documento para validar a garantia.',
  
  -- Metadados
  criado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  atualizado_em TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Garantir apenas uma configuração por usuário
  UNIQUE(user_id)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_configuracoes_impressao_user_id ON public.configuracoes_impressao(user_id);
CREATE INDEX IF NOT EXISTS idx_configuracoes_impressao_empresa_id ON public.configuracoes_impressao(empresa_id);

-- RLS (Row Level Security)
ALTER TABLE public.configuracoes_impressao ENABLE ROW LEVEL SECURITY;

-- Política: Usuários veem apenas suas próprias configurações
DROP POLICY IF EXISTS "Usuários gerenciam suas configurações de impressão" ON public.configuracoes_impressao;
CREATE POLICY "Usuários gerenciam suas configurações de impressão"
ON public.configuracoes_impressao
FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- INSERIR CONFIGURAÇÕES PADRÃO
-- ============================================

-- Inserir configurações padrão para todos os usuários existentes que ainda não têm
INSERT INTO public.configuracoes_impressao (user_id, cabecalho, rodape)
SELECT 
  id,
  'COMPROVANTE DE ENTREGA',
  E'Este documento comprova a entrega do equipamento em perfeito estado de funcionamento.\nEm caso de dúvidas, entre em contato conosco.\n\nObrigado pela preferência!'
FROM auth.users
WHERE NOT EXISTS (
  SELECT 1 FROM public.configuracoes_impressao WHERE user_id = auth.users.id
);

-- ============================================
-- FUNÇÃO PARA AUTO-CRIAR CONFIGURAÇÃO AO CRIAR USUÁRIO
-- ============================================

CREATE OR REPLACE FUNCTION public.criar_configuracao_impressao_padrao()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.configuracoes_impressao (user_id, cabecalho, rodape)
  VALUES (
    NEW.id,
    'COMPROVANTE DE ENTREGA',
    E'Este documento comprova a entrega do equipamento em perfeito estado de funcionamento.\nEm caso de dúvidas, entre em contato conosco.\n\nObrigado pela preferência!'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar configuração automaticamente ao criar novo usuário
DROP TRIGGER IF EXISTS trigger_criar_configuracao_impressao ON auth.users;
CREATE TRIGGER trigger_criar_configuracao_impressao
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.criar_configuracao_impressao_padrao();

-- ============================================
-- VERIFICAR CRIAÇÃO
-- ============================================

-- Ver todas as configurações
SELECT 
  ci.id,
  u.email,
  ci.cabecalho,
  LENGTH(ci.rodape) as tamanho_rodape,
  ci.criado_em
FROM public.configuracoes_impressao ci
JOIN auth.users u ON u.id = ci.user_id
ORDER BY ci.criado_em DESC;

-- Estatísticas
SELECT 
  COUNT(*) as total_configuracoes,
  COUNT(DISTINCT user_id) as usuarios_com_config
FROM public.configuracoes_impressao;

/*
NOTAS:
- O cabeçalho substitui "COMPROVANTE DE ENTREGA" na impressão
- O rodapé substitui o texto padrão no final do documento
- Use \n para quebrar linhas no rodapé
- Cada usuário tem apenas UMA configuração
- Configurações são criadas automaticamente para novos usuários

EXEMPLOS DE USO:

-- Atualizar cabeçalho:
UPDATE public.configuracoes_impressao
SET cabecalho = 'ALLIMPORT ELETRÔNICOS - COMPROVANTE DE ENTREGA',
    atualizado_em = NOW()
WHERE user_id = auth.uid();

-- Atualizar rodapé com informações da empresa:
UPDATE public.configuracoes_impressao
SET rodape = E'ALLIMPORT ELETRÔNICOS\nRua Exemplo, 123 - Centro\nTelefone: (11) 98765-4321\nEmail: contato@allimport.com\n\nObrigado pela preferência!',
    atualizado_em = NOW()
WHERE user_id = auth.uid();

-- Rodapé com múltiplas linhas e informações de garantia:
UPDATE public.configuracoes_impressao
SET rodape = E'CONDIÇÕES DE GARANTIA:\n- Garantia cobre apenas defeitos do serviço executado\n- Não cobre danos por mau uso, quedas ou água\n- Apresente este documento para validar a garantia\n\nATENDIMENTO: Segunda a Sexta, 9h às 18h\nTelefone: (11) 98765-4321\n\nObrigado pela preferência!',
    atualizado_em = NOW()
WHERE user_id = auth.uid();
*/
