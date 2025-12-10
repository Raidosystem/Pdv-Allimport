-- ============================================
-- SOLUÇÃO COMPLETA - TODAS AS TABELAS E BUCKET
-- Execute TUDO de uma vez no SQL Editor
-- ============================================

-- 1. CRIAR/ATUALIZAR TABELA EMPRESAS
-- ============================================
CREATE TABLE IF NOT EXISTS empresas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL DEFAULT '',
  razao_social TEXT DEFAULT '',
  cnpj TEXT DEFAULT '',
  telefone TEXT DEFAULT '',
  email TEXT DEFAULT '',
  site TEXT DEFAULT '',
  endereco TEXT DEFAULT '',
  cidade TEXT DEFAULT '',
  cep TEXT DEFAULT '',
  logo TEXT DEFAULT '',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- 2. CRIAR/ATUALIZAR TABELA SUBSCRIPTIONS
-- ============================================
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'trial',
  plan_type TEXT DEFAULT 'free',
  trial_start_date TIMESTAMP WITH TIME ZONE,
  trial_end_date TIMESTAMP WITH TIME ZONE,
  subscription_start_date TIMESTAMP WITH TIME ZONE,
  subscription_end_date TIMESTAMP WITH TIME ZONE,
  payment_method TEXT,
  last_payment_date TIMESTAMP WITH TIME ZONE,
  next_payment_date TIMESTAMP WITH TIME ZONE,
  amount DECIMAL(10, 2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- 3. DESABILITAR RLS (TEMPORARIAMENTE) PARA PERMITIR ACESSO
-- ============================================
ALTER TABLE empresas DISABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions DISABLE ROW LEVEL SECURITY;

-- 4. CRIAR BUCKET SE NÃO EXISTIR
-- ============================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'empresa-assets',
  'empresa-assets',
  true,
  2097152,
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 2097152,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];

-- 5. CRIAR POLÍTICAS PERMISSIVAS PARA O BUCKET
-- ============================================
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;

CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'empresa-assets');

CREATE POLICY "Allow public read"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'empresa-assets');

CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'empresa-assets');

CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'empresa-assets');

-- ============================================
-- VERIFICAÇÃO FINAL
-- ============================================
SELECT 'Tabelas e bucket criados com sucesso!' as status;

SELECT 'EMPRESAS:' as tabela, * FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'empresas';

SELECT 'SUBSCRIPTIONS:' as tabela, * FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'subscriptions';

SELECT 'BUCKET:' as tabela, * FROM storage.buckets WHERE id = 'empresa-assets';
