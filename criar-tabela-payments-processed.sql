-- Criar tabela para controle de idempotência dos webhooks
-- Esta tabela evita processamento duplicado de pagamentos

CREATE TABLE IF NOT EXISTS public.payments_processed (
  id BIGSERIAL PRIMARY KEY,
  payment_id TEXT NOT NULL UNIQUE,
  payer_email TEXT,
  processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_payments_processed_payment_id ON public.payments_processed(payment_id);
CREATE INDEX IF NOT EXISTS idx_payments_processed_payer_email ON public.payments_processed(payer_email);
CREATE INDEX IF NOT EXISTS idx_payments_processed_processed_at ON public.payments_processed(processed_at);

-- RLS (Row Level Security)
ALTER TABLE public.payments_processed ENABLE ROW LEVEL SECURITY;

-- Remover políticas existentes se houver
DROP POLICY IF EXISTS "Allow read for authenticated users" ON public.payments_processed;
DROP POLICY IF EXISTS "Allow insert for service role" ON public.payments_processed;

-- Política para permitir leitura apenas para usuários autenticados
CREATE POLICY "Allow read for authenticated users" ON public.payments_processed
  FOR SELECT
  TO authenticated
  USING (true);

-- Política para permitir inserção apenas via service role (webhooks)
CREATE POLICY "Allow insert for service role" ON public.payments_processed
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Comentários para documentação
COMMENT ON TABLE public.payments_processed IS 'Controle de idempotência para webhooks do Mercado Pago';
COMMENT ON COLUMN public.payments_processed.payment_id IS 'ID do pagamento do Mercado Pago (único)';
COMMENT ON COLUMN public.payments_processed.payer_email IS 'Email do pagador para referência';
COMMENT ON COLUMN public.payments_processed.processed_at IS 'Timestamp de quando o webhook foi processado';