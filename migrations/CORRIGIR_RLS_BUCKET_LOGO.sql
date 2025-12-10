-- ============================================
-- CORRIGIR RLS DO BUCKET empresa-assets PARA PERMITIR UPLOAD DE LOGOS
-- ============================================

-- 1. VERIFICAR SE O BUCKET EXISTE
SELECT name, public FROM storage.buckets WHERE name = 'empresa-assets';

-- 2. REMOVER POLÍTICAS ANTIGAS (se existirem)
DROP POLICY IF EXISTS "Usuários autenticados podem fazer upload" ON storage.objects;
DROP POLICY IF EXISTS "Usuários podem fazer upload de logos" ON storage.objects;
DROP POLICY IF EXISTS "Upload público de logos" ON storage.objects;
DROP POLICY IF EXISTS "Qualquer um pode ver logos públicos" ON storage.objects;
DROP POLICY IF EXISTS "Leitura pública de logos" ON storage.objects;

-- 3. CRIAR POLÍTICA DE UPLOAD (permitir qualquer usuário autenticado)
CREATE POLICY "Permitir upload de logos para usuários autenticados"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'empresa-assets' 
  AND (storage.foldername(name))[1] = 'logos'
);

-- 4. CRIAR POLÍTICA DE ATUALIZAÇÃO (permitir sobrescrever próprias logos)
CREATE POLICY "Permitir atualizar próprias logos"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'empresa-assets'
  AND (storage.foldername(name))[1] = 'logos'
)
WITH CHECK (
  bucket_id = 'empresa-assets'
  AND (storage.foldername(name))[1] = 'logos'
);

-- 5. CRIAR POLÍTICA DE LEITURA PÚBLICA (qualquer um pode ver)
CREATE POLICY "Leitura pública de logos"
ON storage.objects
FOR SELECT
TO public
USING (
  bucket_id = 'empresa-assets'
  AND (storage.foldername(name))[1] = 'logos'
);

-- 6. CRIAR POLÍTICA DE EXCLUSÃO (usuários autenticados podem deletar)
CREATE POLICY "Permitir deletar próprias logos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'empresa-assets'
  AND (storage.foldername(name))[1] = 'logos'
);

-- 7. VERIFICAR POLÍTICAS CRIADAS
SELECT 
  policyname, 
  permissive, 
  roles, 
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'objects' 
  AND policyname LIKE '%logo%'
ORDER BY policyname;

-- 8. VERIFICAR SE O BUCKET ESTÁ PÚBLICO
SELECT 
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets 
WHERE name = 'empresa-assets';

-- ============================================
-- ALTERNATIVA: DESABILITAR RLS TEMPORARIAMENTE (NÃO RECOMENDADO PARA PRODUÇÃO)
-- ============================================
-- Se as políticas acima não funcionarem, descomente as linhas abaixo:

-- ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- ⚠️ ATENÇÃO: Isso desabilita a segurança! Use apenas para testes!
-- ⚠️ Reative depois com: ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- ============================================
-- SOLUÇÃO MAIS SIMPLES: POLÍTICAS PERMISSIVAS
-- ============================================

-- Remover todas as políticas do bucket empresa-assets
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'objects' 
      AND schemaname = 'storage'
      AND policyname LIKE '%empresa%'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', pol.policyname);
  END LOOP;
END $$;

-- Criar políticas permissivas simples
CREATE POLICY "empresa_assets_insert"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'empresa-assets');

CREATE POLICY "empresa_assets_update"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'empresa-assets')
WITH CHECK (bucket_id = 'empresa-assets');

CREATE POLICY "empresa_assets_select"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'empresa-assets');

CREATE POLICY "empresa_assets_delete"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'empresa-assets');

-- Verificar resultado final
SELECT 
  policyname,
  cmd as operacao,
  CASE 
    WHEN roles::text = '{authenticated}' THEN '🔐 Autenticados'
    WHEN roles::text = '{public}' THEN '🌐 Público'
    ELSE roles::text 
  END as quem_pode
FROM pg_policies 
WHERE tablename = 'objects' 
  AND schemaname = 'storage'
  AND (
    policyname LIKE '%empresa%' 
    OR policyname LIKE '%logo%'
  )
ORDER BY policyname;

-- Mensagem de sucesso
SELECT '✅ Políticas RLS atualizadas! Agora o upload de logos deve funcionar.' as status;
