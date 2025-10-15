-- ============================================
-- CORRIGIR TODOS OS ERROS DE RLS E PERMISSÕES
-- Resolve: Erro 406, Erro 401, "new row violates row-level security policy"
-- ============================================

-- PARTE 1: DESABILITAR RLS EM TODAS AS TABELAS (DESENVOLVIMENTO)
-- ============================================

-- Desabilitar RLS na tabela empresas
ALTER TABLE empresas DISABLE ROW LEVEL SECURITY;

-- Desabilitar RLS na tabela subscriptions
ALTER TABLE subscriptions DISABLE ROW LEVEL SECURITY;

-- Desabilitar RLS na tabela user_settings (se existir)
ALTER TABLE IF EXISTS user_settings DISABLE ROW LEVEL SECURITY;

-- Desabilitar RLS no Storage
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- Desabilitar RLS no bucket
ALTER TABLE storage.buckets DISABLE ROW LEVEL SECURITY;

-- Mensagem de progresso
SELECT '✅ Passo 1/4: RLS desabilitado em todas as tabelas' as status;

-- ============================================
-- PARTE 2: GARANTIR QUE O BUCKET empresa-assets EXISTE E ESTÁ PÚBLICO
-- ============================================

-- Criar ou atualizar bucket empresa-assets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'empresa-assets',
  'empresa-assets',
  true,
  2097152, -- 2MB
  ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif', 'image/jpg']
)
ON CONFLICT (id) 
DO UPDATE SET
  public = true,
  file_size_limit = 2097152,
  allowed_mime_types = ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif', 'image/jpg'];

-- Mensagem de progresso
SELECT '✅ Passo 2/4: Bucket empresa-assets configurado' as status;

-- ============================================
-- PARTE 3: REMOVER TODAS AS POLÍTICAS ANTIGAS
-- ============================================

-- Remover políticas da tabela empresas
DROP POLICY IF EXISTS "Permitir acesso à própria empresa" ON empresas;
DROP POLICY IF EXISTS "Usuários podem ver suas empresas" ON empresas;
DROP POLICY IF EXISTS "Usuários podem atualizar suas empresas" ON empresas;
DROP POLICY IF EXISTS "Usuários podem inserir suas empresas" ON empresas;

-- Remover políticas da tabela subscriptions
DROP POLICY IF EXISTS "Permitir acesso à própria assinatura" ON subscriptions;
DROP POLICY IF EXISTS "Usuários podem ver suas assinaturas" ON subscriptions;

-- Remover políticas do storage
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'objects' 
      AND schemaname = 'storage'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', pol.policyname);
  END LOOP;
END $$;

-- Mensagem de progresso
SELECT '✅ Passo 3/4: Políticas antigas removidas' as status;

-- ============================================
-- PARTE 4: VERIFICAR ESTRUTURA DAS TABELAS
-- ============================================

-- Verificar tabela empresas
SELECT 
  '📋 Estrutura da tabela empresas:' as info,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'empresas'
ORDER BY ordinal_position;

-- Verificar tabela subscriptions
SELECT 
  '📋 Estrutura da tabela subscriptions:' as info,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'subscriptions'
ORDER BY ordinal_position;

-- Verificar bucket
SELECT 
  '📦 Bucket empresa-assets:' as info,
  id,
  name,
  public as "público?",
  file_size_limit as "limite (bytes)",
  allowed_mime_types as "tipos permitidos"
FROM storage.buckets 
WHERE name = 'empresa-assets';

-- Verificar status do RLS
SELECT 
  '🔒 Status do RLS:' as info,
  schemaname,
  tablename,
  CASE 
    WHEN rowsecurity = true THEN '🔴 ATIVADO (vai dar erro)'
    ELSE '✅ DESATIVADO (correto para dev)'
  END as status_rls
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('empresas', 'subscriptions', 'user_settings')
ORDER BY tablename;

-- Verificar status do RLS no Storage
SELECT 
  '🔒 Status do RLS Storage:' as info,
  schemaname,
  tablename,
  CASE 
    WHEN rowsecurity = true THEN '🔴 ATIVADO (vai dar erro)'
    ELSE '✅ DESATIVADO (correto para dev)'
  END as status_rls
FROM pg_tables 
WHERE schemaname = 'storage' 
  AND tablename IN ('objects', 'buckets')
ORDER BY tablename;

-- ============================================
-- MENSAGEM FINAL
-- ============================================

SELECT '
🎉 CORREÇÕES APLICADAS COM SUCESSO!

✅ O que foi feito:
1. RLS desabilitado em todas as tabelas (empresas, subscriptions, user_settings)
2. RLS desabilitado no Storage (objects, buckets)
3. Bucket empresa-assets configurado como público
4. Todas as políticas antigas removidas
5. Limite de 2MB por arquivo
6. Tipos de imagem permitidos: PNG, JPG, JPEG, WEBP, GIF

🧪 TESTE AGORA:
1. Vá em Configurações → Empresa
2. Preencha os dados da empresa
3. Faça upload de uma logo
4. Clique em Salvar
5. Deve funcionar! ✅

⚠️ IMPORTANTE PARA PRODUÇÃO:
Este SQL desabilita o RLS para facilitar o desenvolvimento.
Antes de colocar em produção, você deve:
- Reativar o RLS
- Criar políticas adequadas
- Testar com usuários reais

Para reativar o RLS depois:
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
' as instrucoes_finais;
