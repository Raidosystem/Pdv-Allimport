-- Criar tabela contas_pagar
CREATE TABLE IF NOT EXISTS contas_pagar (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fornecedor TEXT NOT NULL,
  descricao TEXT NOT NULL,
  valor NUMERIC(10, 2) NOT NULL,
  data_vencimento DATE NOT NULL,
  data_pagamento DATE,
  status TEXT NOT NULL CHECK (status IN ('pendente', 'pago', 'vencido', 'cancelado')),
  categoria TEXT NOT NULL,
  observacoes TEXT,
  boleto_url TEXT,
  boleto_codigo_barras TEXT,
  boleto_linha_digitavel TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para otimização
CREATE INDEX idx_contas_pagar_user_id ON contas_pagar(user_id);
CREATE INDEX idx_contas_pagar_status ON contas_pagar(status);
CREATE INDEX idx_contas_pagar_data_vencimento ON contas_pagar(data_vencimento);
CREATE INDEX idx_contas_pagar_fornecedor ON contas_pagar(fornecedor);

-- RLS (Row Level Security)
ALTER TABLE contas_pagar ENABLE ROW LEVEL SECURITY;

-- Policy: Usuários só veem suas próprias contas
CREATE POLICY "Usuários veem apenas suas contas"
  ON contas_pagar
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Usuários podem inserir suas próprias contas
CREATE POLICY "Usuários podem inserir suas contas"
  ON contas_pagar
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Usuários podem atualizar suas próprias contas
CREATE POLICY "Usuários podem atualizar suas contas"
  ON contas_pagar
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: Usuários podem deletar suas próprias contas
CREATE POLICY "Usuários podem deletar suas contas"
  ON contas_pagar
  FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_contas_pagar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER contas_pagar_updated_at
  BEFORE UPDATE ON contas_pagar
  FOR EACH ROW
  EXECUTE FUNCTION update_contas_pagar_updated_at();

-- Criar bucket de storage para boletos (se não existir)
INSERT INTO storage.buckets (id, name, public)
VALUES ('boletos', 'boletos', true)
ON CONFLICT (id) DO NOTHING;

-- RLS para storage de boletos
CREATE POLICY "Usuários podem fazer upload de boletos"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'boletos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Usuários podem ver seus boletos"
  ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'boletos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Usuários podem deletar seus boletos"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'boletos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Comentários
COMMENT ON TABLE contas_pagar IS 'Tabela para gerenciar contas a pagar e boletos';
COMMENT ON COLUMN contas_pagar.fornecedor IS 'Nome do fornecedor/credor';
COMMENT ON COLUMN contas_pagar.status IS 'Status: pendente, pago, vencido, cancelado';
COMMENT ON COLUMN contas_pagar.boleto_url IS 'URL do boleto em PDF no Storage';
COMMENT ON COLUMN contas_pagar.boleto_codigo_barras IS 'Código de barras do boleto';
COMMENT ON COLUMN contas_pagar.boleto_linha_digitavel IS 'Linha digitável do boleto';
