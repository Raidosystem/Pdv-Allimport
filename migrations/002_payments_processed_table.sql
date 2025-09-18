-- Tabela para controle de idempotência de pagamentos processados
-- Evita reprocessamento de webhooks duplicados do MercadoPago

CREATE TABLE IF NOT EXISTS payments_processed (
  id SERIAL PRIMARY KEY,
  mp_payment_id TEXT NOT NULL UNIQUE,
  user_email TEXT NOT NULL,
  status TEXT NOT NULL,
  amount DECIMAL(10,2),
  payment_method TEXT,
  processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  webhook_data JSONB,
  
  -- Índices para performance
  CONSTRAINT idx_mp_payment_id UNIQUE (mp_payment_id)
);

-- Índices para consultas rápidas
CREATE INDEX IF NOT EXISTS idx_payments_processed_user_email ON payments_processed(user_email);
CREATE INDEX IF NOT EXISTS idx_payments_processed_status ON payments_processed(status);
CREATE INDEX IF NOT EXISTS idx_payments_processed_processed_at ON payments_processed(processed_at);

-- RLS Policies
ALTER TABLE payments_processed ENABLE ROW LEVEL SECURITY;

-- Política para visualização (apenas próprios pagamentos)
CREATE POLICY "Users can view own payments" ON payments_processed
  FOR SELECT USING (user_email = (SELECT email FROM auth.users WHERE id = auth.uid()));

-- Política para webhook (SERVICE_ROLE_KEY pode inserir)
CREATE POLICY "Service role can insert payments" ON payments_processed
  FOR INSERT WITH CHECK (true);

-- Política para SERVICE_ROLE_KEY ler todos os pagamentos (para verificação de idempotência)
CREATE POLICY "Service role can read all payments" ON payments_processed
  FOR SELECT TO service_role USING (true);

-- Comentários para documentação
COMMENT ON TABLE payments_processed IS 'Controle de idempotência para webhooks do MercadoPago';
COMMENT ON COLUMN payments_processed.mp_payment_id IS 'ID único do pagamento no MercadoPago';
COMMENT ON COLUMN payments_processed.user_email IS 'Email do usuário que fez o pagamento';
COMMENT ON COLUMN payments_processed.webhook_data IS 'Dados completos do webhook para auditoria';