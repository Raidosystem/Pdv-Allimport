-- ============================================
-- CORRIGIR POLÍTICAS RLS DO BUCKET
-- Execute no SQL Editor do Supabase
-- ============================================

-- Opção 1: DESABILITAR RLS (mais simples)
-- Como o bucket já é público, podemos desabilitar RLS
UPDATE storage.buckets 
SET public = true, 
    file_size_limit = 2097152,
    allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
WHERE id = 'empresa-assets';

-- ============================================
-- Opção 2: SE PREFERIR MANTER RLS
-- Execute estas políticas para permitir acesso
-- ============================================

-- Remover políticas antigas se existirem
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;

-- Política para permitir qualquer usuário autenticado fazer upload
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'empresa-assets');

-- Política para permitir visualização pública
CREATE POLICY "Allow public read"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'empresa-assets');

-- Política para permitir usuários autenticados atualizarem
CREATE POLICY "Allow authenticated updates"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'empresa-assets')
WITH CHECK (bucket_id = 'empresa-assets');

-- Política para permitir usuários autenticados deletarem
CREATE POLICY "Allow authenticated deletes"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'empresa-assets');

-- ============================================
-- VERIFICAÇÃO
-- ============================================
SELECT * FROM storage.buckets WHERE id = 'empresa-assets';
