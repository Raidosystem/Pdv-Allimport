-- ⚡ EXECUTE EXATAMENTE ESTE CÓDIGO NO SUPABASE
-- Copie e cole tudo de uma vez no SQL Editor

INSERT INTO storage.buckets (id, name, public) VALUES ('empresas', 'empresas', true) ON CONFLICT (id) DO NOTHING;

CREATE POLICY "empresas_policy" ON storage.objects FOR ALL USING (bucket_id = 'empresas') WITH CHECK (bucket_id = 'empresas');

SELECT 'PRONTO! Agora o upload vai funcionar' as status;
