-- ============================================
-- LIMPAR TODAS AS POLÍTICAS DO BUCKET empresa-assets
-- Execute este SQL para remover políticas duplicadas
-- ============================================

-- Remover todas as políticas do bucket empresa-assets
DROP POLICY IF EXISTS "Allow authenticated deletes" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read" ON storage.objects;
DROP POLICY IF EXISTS "empresa_assets_delete" ON storage.objects;
DROP POLICY IF EXISTS "empresa_assets_insert" ON storage.objects;
DROP POLICY IF EXISTS "empresa_assets_select" ON storage.objects;
DROP POLICY IF EXISTS "empresa_assets_update" ON storage.objects;
DROP POLICY IF EXISTS "Leitura pública de logos" ON storage.objects;
DROP POLICY IF EXISTS "Permitir atualizar próprias logos" ON storage.objects;
DROP POLICY IF EXISTS "Permitir deletar próprias logos" ON storage.objects;
DROP POLICY IF EXISTS "Permitir upload de logos para usuários autenticados" ON storage.objects;

-- Criar UMA ÚNICA política permissiva e simples
CREATE POLICY "empresa_assets_acesso_total"
ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'empresa-assets')
WITH CHECK (bucket_id = 'empresa-assets');

-- Verificar resultado
SELECT 
  policyname,
  cmd as operacao,
  CASE 
    WHEN roles::text LIKE '%public%' THEN '🌐 Público'
    WHEN roles::text LIKE '%authenticated%' THEN '🔐 Autenticado'
    ELSE roles::text
  END as quem_pode
FROM pg_policies 
WHERE tablename = 'objects' 
  AND schemaname = 'storage'
  AND policyname LIKE '%empresa%'
ORDER BY policyname;

SELECT '✅ Políticas limpas! Agora só existe uma política simples e permissiva.' as resultado;
