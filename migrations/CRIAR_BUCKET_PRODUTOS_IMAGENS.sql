-- ==========================================
-- CRIAR BUCKET PARA IMAGENS DE PRODUTOS
-- ==========================================

-- 1. Criar bucket público para imagens de produtos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'produtos-imagens',
  'produtos-imagens',
  true,
  2097152, -- 2MB em bytes
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO NOTHING;

-- 2. Configurar políticas de acesso
-- Permitir usuários autenticados fazerem upload
CREATE POLICY "Usuários podem fazer upload de imagens"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'produtos-imagens'
  AND auth.uid() IS NOT NULL
);

-- Permitir todos verem as imagens (público)
CREATE POLICY "Imagens são públicas"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'produtos-imagens');

-- Permitir usuários autenticados atualizarem suas imagens
CREATE POLICY "Usuários podem atualizar imagens"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'produtos-imagens'
  AND auth.uid() IS NOT NULL
);

-- Permitir usuários autenticados deletarem suas imagens
CREATE POLICY "Usuários podem deletar imagens"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'produtos-imagens'
  AND auth.uid() IS NOT NULL
);

-- ==========================================
-- CONFIRMAÇÃO
-- ==========================================

SELECT 
  '✅ Bucket produtos-imagens criado com sucesso!' as status,
  'Usuários podem fazer upload de imagens para produtos' as mensagem;

-- ==========================================
-- INSTRUÇÕES
-- ==========================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ BUCKET DE IMAGENS CRIADO COM SUCESSO!';
  RAISE NOTICE '';
  RAISE NOTICE '📁 Nome do bucket: produtos-imagens';
  RAISE NOTICE '🔓 Acesso: Público (imagens visíveis para todos)';
  RAISE NOTICE '📏 Limite de tamanho: 2MB por arquivo';
  RAISE NOTICE '🖼️  Formatos permitidos: JPEG, PNG, WEBP, GIF';
  RAISE NOTICE '';
  RAISE NOTICE '💡 As imagens dos produtos aparecerão automaticamente no catálogo online!';
  RAISE NOTICE '';
END $$;
