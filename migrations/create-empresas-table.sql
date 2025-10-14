-- Criar tabela empresas para armazenar dados da empresa
CREATE TABLE IF NOT EXISTS empresas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  razao_social TEXT,
  cnpj TEXT,
  telefone TEXT,
  email TEXT,
  site TEXT,
  endereco TEXT,
  cidade TEXT,
  cep TEXT,
  logo TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Habilitar RLS
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;

-- Política: Usuários podem ver apenas seus próprios dados
CREATE POLICY "Usuários podem ver suas empresas"
  ON empresas FOR SELECT
  USING (auth.uid() = user_id);

-- Política: Usuários podem inserir seus próprios dados
CREATE POLICY "Usuários podem criar suas empresas"
  ON empresas FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política: Usuários podem atualizar seus próprios dados
CREATE POLICY "Usuários podem atualizar suas empresas"
  ON empresas FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Política: Usuários podem deletar seus próprios dados
CREATE POLICY "Usuários podem deletar suas empresas"
  ON empresas FOR DELETE
  USING (auth.uid() = user_id);

-- Índice para melhor performance
CREATE INDEX IF NOT EXISTS idx_empresas_user_id ON empresas(user_id);

-- Comentários
COMMENT ON TABLE empresas IS 'Dados das empresas dos usuários';
COMMENT ON COLUMN empresas.user_id IS 'ID do usuário proprietário';
COMMENT ON COLUMN empresas.nome IS 'Nome fantasia da empresa';
COMMENT ON COLUMN empresas.razao_social IS 'Razão social da empresa';
COMMENT ON COLUMN empresas.cnpj IS 'CNPJ da empresa';
