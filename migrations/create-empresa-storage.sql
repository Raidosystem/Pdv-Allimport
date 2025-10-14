-- ========================================
-- CRIAR BUCKET DE STORAGE PARA LOGOS
-- ========================================
-- Execute este SQL no Supabase SQL Editor

-- Criar bucket público para assets da empresa
INSERT INTO storage.buckets (id, name, public)
VALUES ('empresa-assets', 'empresa-assets', true)
ON CONFLICT (id) DO NOTHING;

-- Política: Usuários autenticados podem fazer upload
CREATE POLICY "Usuários podem fazer upload de logos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'empresa-assets' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Política: Todos podem visualizar (bucket público)
CREATE POLICY "Logos são públicas"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'empresa-assets');

-- Política: Usuários podem atualizar seus próprios arquivos
CREATE POLICY "Usuários podem atualizar seus logos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'empresa-assets'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Política: Usuários podem deletar seus próprios arquivos
CREATE POLICY "Usuários podem deletar seus logos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'empresa-assets'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- ✅ Bucket criado com sucesso!
-- Agora os usuários podem fazer upload de logos
