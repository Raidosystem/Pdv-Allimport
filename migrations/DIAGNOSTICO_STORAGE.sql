-- 🔍 SCRIPT PARA VERIFICAR STATUS DO STORAGE
-- Execute este script para diagnosticar o problema

-- Verificar se o bucket 'empresas' existe
SELECT 
  'Verificando bucket empresas...' as etapa,
  CASE 
    WHEN EXISTS(SELECT 1 FROM storage.buckets WHERE id = 'empresas') 
    THEN '✅ Bucket empresas existe'
    ELSE '❌ Bucket empresas NÃO existe'
  END as status;

-- Listar todos os buckets para ver o que existe
SELECT 
  'Buckets disponíveis:' as info,
  id as bucket_id,
  name as bucket_name,
  public as is_public
FROM storage.buckets
ORDER BY created_at;

-- Verificar políticas do storage
SELECT 
  'Políticas de storage:' as info,
  policyname as policy_name,
  cmd as policy_type
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects'
ORDER BY policyname;

-- Se o bucket não existe, criar agora
INSERT INTO storage.buckets (id, name, public) 
VALUES ('empresas', 'empresas', true)
ON CONFLICT (id) DO NOTHING;

-- Criar política simples se não existe
DO $$
BEGIN
    -- Tentar criar a política, ignorar se já existe
    PERFORM 1 FROM pg_policies 
    WHERE schemaname = 'storage' 
    AND tablename = 'objects' 
    AND policyname = 'empresas_policy';
    
    IF NOT FOUND THEN
        EXECUTE 'CREATE POLICY empresas_policy ON storage.objects FOR ALL USING (bucket_id = ''empresas'') WITH CHECK (bucket_id = ''empresas'')';
    END IF;
END
$$;

-- Verificação final
SELECT 
  'Status final:' as resultado,
  CASE 
    WHEN EXISTS(SELECT 1 FROM storage.buckets WHERE id = 'empresas') 
    THEN '✅ Storage empresas pronto para uso'
    ELSE '❌ Problema ainda persiste'
  END as status;
