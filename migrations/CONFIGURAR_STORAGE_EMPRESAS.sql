-- 💾 CONFIGURAÇÃO DO STORAGE PARA LOGOS DAS EMPRESAS
-- Execute este script no SQL Editor do Supabase

-- =====================================
-- CRIAR BUCKET PARA LOGOS
-- =====================================

-- Inserir bucket 'empresas' se não existir
INSERT INTO storage.buckets (id, name, public) 
VALUES ('empresas', 'empresas', true)
ON CONFLICT (id) DO NOTHING;

-- =====================================
-- POLÍTICAS DE STORAGE
-- =====================================

-- Remover políticas existentes primeiro
DROP POLICY IF EXISTS "Users can upload own company logo" ON storage.objects;
DROP POLICY IF EXISTS "Public can view logos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own company logo" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own company logo" ON storage.objects;

-- Política para permitir que usuários façam upload de suas próprias logos
CREATE POLICY "Users can upload own company logo" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'empresas' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Política para visualização pública das logos
CREATE POLICY "Public can view logos" ON storage.objects
FOR SELECT USING (bucket_id = 'empresas');

-- Política para usuários atualizarem suas próprias logos
CREATE POLICY "Users can update own company logo" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'empresas' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Política para usuários deletarem suas próprias logos
CREATE POLICY "Users can delete own company logo" ON storage.objects
FOR DELETE USING (
  bucket_id = 'empresas' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- =====================================
-- VERIFICAÇÃO
-- =====================================

-- Verificar se o bucket foi criado
SELECT 
  id, 
  name, 
  public,
  created_at,
  CASE 
    WHEN id = 'empresas' THEN '✅ Bucket criado com sucesso'
    ELSE '❌ Bucket não encontrado'
  END as status
FROM storage.buckets 
WHERE id = 'empresas';

-- Verificar políticas de storage
SELECT 
  policyname,
  cmd,
  CASE 
    WHEN policyname IS NOT NULL THEN '✅ Política ativa'
    ELSE '❌ Política não encontrada'
  END as status
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects'
AND policyname LIKE '%logo%' OR policyname LIKE '%empresas%';

-- ✅ STORAGE CONFIGURADO!
SELECT '🏢 Storage para logos das empresas configurado com sucesso!' as resultado;
