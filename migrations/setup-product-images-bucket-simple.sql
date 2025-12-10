-- SCRIPT SIMPLIFICADO PARA CRIAR BUCKET DE IMAGENS
-- Execute este script no SQL Editor do Supabase se o script principal não funcionar

-- 1. Criar o bucket (pode ignorar erro se já existir)
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Verificar se foi criado
SELECT * FROM storage.buckets WHERE id = 'product-images';
