-- ============================================
-- CRIAR BUCKET PARA LOGOS DAS EMPRESAS
-- Execute no SQL Editor do Supabase
-- ============================================

-- Criar o bucket para armazenar logos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'empresa-assets',
  'empresa-assets',
  true,
  2097152, -- 2MB em bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- VERIFICAÇÃO
-- ============================================
SELECT 
  id, 
  name, 
  public, 
  file_size_limit,
  allowed_mime_types
FROM storage.buckets 
WHERE id = 'empresa-assets';

-- Deve retornar:
-- id: empresa-assets
-- name: empresa-assets
-- public: true
-- file_size_limit: 2097152
-- allowed_mime_types: {image/jpeg,image/jpg,image/png,image/gif,image/webp}
