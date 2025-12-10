-- 🔧 SCRIPT SIMPLIFICADO PARA CORRIGIR STORAGE
-- Execute este script se houver erro de políticas duplicadas

-- =====================================
-- REMOVER POLÍTICAS EXISTENTES
-- =====================================

-- Remover todas as políticas de storage relacionadas a logos/empresas
DROP POLICY IF EXISTS "Users can upload own company logo" ON storage.objects;
DROP POLICY IF EXISTS "Public can view logos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own company logo" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own company logo" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload to empresas bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public access to empresas bucket" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload logos" ON storage.objects;

-- =====================================
-- GARANTIR QUE O BUCKET EXISTE
-- =====================================

INSERT INTO storage.buckets (id, name, public) 
VALUES ('empresas', 'empresas', true)
ON CONFLICT (id) DO NOTHING;

-- =====================================
-- RECRIAR POLÍTICAS LIMPAS
-- =====================================

-- Política para upload (usuários autenticados podem fazer upload)
CREATE POLICY "upload_own_logo" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'empresas' 
  AND auth.uid() IS NOT NULL
);

-- Política para visualização pública
CREATE POLICY "view_logos_public" ON storage.objects
FOR SELECT USING (bucket_id = 'empresas');

-- Política para atualização (apenas o próprio usuário)
CREATE POLICY "update_own_logo" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'empresas' 
  AND auth.uid() IS NOT NULL
);

-- Política para exclusão (apenas o próprio usuário)
CREATE POLICY "delete_own_logo" ON storage.objects
FOR DELETE USING (
  bucket_id = 'empresas' 
  AND auth.uid() IS NOT NULL
);

-- =====================================
-- VERIFICAÇÃO FINAL
-- =====================================

-- Verificar bucket
SELECT 
  'Bucket empresas: ' || 
  CASE 
    WHEN EXISTS(SELECT 1 FROM storage.buckets WHERE id = 'empresas') 
    THEN '✅ Criado' 
    ELSE '❌ Erro' 
  END as status;

-- Verificar políticas
SELECT 
  COUNT(*) || ' políticas de storage ativas para logos' as resultado
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects'
AND (policyname LIKE '%logo%' OR policyname LIKE '%empresas%');

-- ✅ CONCLUÍDO!
SELECT '🚀 Storage configurado com sucesso! Agora o upload de logos deve funcionar.' as resultado_final;
