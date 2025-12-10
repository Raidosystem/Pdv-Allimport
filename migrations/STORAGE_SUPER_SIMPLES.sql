-- 🚀 SCRIPT SUPER SIMPLES - CONFIGURAR STORAGE
-- Execute este script se o anterior deu erro

-- Criar bucket empresas
INSERT INTO storage.buckets (id, name, public) 
VALUES ('empresas', 'empresas', true)
ON CONFLICT (id) DO NOTHING;

-- Remover qualquer política antiga
DROP POLICY IF EXISTS "Users can upload own company logo" ON storage.objects;
DROP POLICY IF EXISTS "Public can view logos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own company logo" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own company logo" ON storage.objects;
DROP POLICY IF EXISTS "allow_uploads_empresas" ON storage.objects;

-- Criar uma política simples que permite tudo para usuários logados
CREATE POLICY "empresas_all_operations" ON storage.objects
FOR ALL 
USING (bucket_id = 'empresas' AND auth.uid() IS NOT NULL)
WITH CHECK (bucket_id = 'empresas' AND auth.uid() IS NOT NULL);

-- Verificar se funcionou
SELECT 'Storage configurado com sucesso!' as resultado;
