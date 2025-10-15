-- ============================================
-- SQL SIMPLIFICADO - APENAS TABELAS PÚBLICAS
-- (Não mexe em storage.objects que precisa de owner)
-- ============================================

-- 1. DESABILITAR RLS NAS TABELAS PÚBLICAS
ALTER TABLE empresas DISABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions DISABLE ROW LEVEL SECURITY;

-- 2. REMOVER POLÍTICAS (se existirem)
DROP POLICY IF EXISTS "Permitir acesso à própria empresa" ON empresas;
DROP POLICY IF EXISTS "Usuários podem ver suas empresas" ON empresas;
DROP POLICY IF EXISTS "Usuários podem atualizar suas empresas" ON empresas;
DROP POLICY IF EXISTS "Usuários podem inserir suas empresas" ON empresas;
DROP POLICY IF EXISTS "Permitir acesso à própria assinatura" ON subscriptions;
DROP POLICY IF EXISTS "Usuários podem ver suas assinaturas" ON subscriptions;

-- 3. GARANTIR QUE O BUCKET EXISTE E É PÚBLICO
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'empresa-assets',
  'empresa-assets',
  true,
  2097152,
  ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif', 'image/jpg']
)
ON CONFLICT (id) 
DO UPDATE SET
  public = true,
  file_size_limit = 2097152,
  allowed_mime_types = ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif', 'image/jpg'];

-- 4. VERIFICAR RESULTADO
SELECT 
  '📋 Status das Tabelas:' as secao,
  tablename,
  CASE 
    WHEN rowsecurity = true THEN '🔴 RLS ATIVADO (vai dar erro)'
    ELSE '✅ RLS DESATIVADO (correto)'
  END as status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('empresas', 'subscriptions')
ORDER BY tablename;

-- 5. VERIFICAR BUCKET
SELECT 
  '📦 Bucket empresa-assets:' as secao,
  id,
  name,
  CASE 
    WHEN public = true THEN '✅ PÚBLICO (correto)'
    ELSE '🔴 PRIVADO (vai dar erro)'
  END as status,
  file_size_limit as "limite_bytes",
  allowed_mime_types as "tipos_permitidos"
FROM storage.buckets 
WHERE name = 'empresa-assets';

-- MENSAGEM FINAL
SELECT '
✅ SQL EXECUTADO!

⚠️ IMPORTANTE: 
Para desabilitar RLS no Storage, você PRECISA fazer pela interface:

1. Vá em Storage → empresa-assets → Settings
2. Na seção "Policies", DELETE todas as políticas
3. Ou crie uma política permissiva (veja SOLUCAO_INTERFACE_SUPABASE.md)

Depois desse SQL + configuração do Storage, recarregue a página e teste!
' as proximos_passos;
