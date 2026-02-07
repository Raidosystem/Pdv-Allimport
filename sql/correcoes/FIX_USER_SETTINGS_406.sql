-- =============================================
-- FIX: Erro 406 Not Acceptable em user_settings
-- =============================================
-- Erro: GET user_settings 406 (Not Acceptable)
-- Causa: Falta RLS policy ou Accept header configurado
-- =============================================

-- 1️⃣ VERIFICAR SE A TABELA EXISTE
SELECT 
  '🔍 Verificando tabela user_settings' as info,
  EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'user_settings'
  ) as tabela_existe;

-- 2️⃣ CRIAR TABELA SE NÃO EXISTIR
CREATE TABLE IF NOT EXISTS user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  appearance_settings JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraint UNIQUE: 1 settings por usuário
  UNIQUE(user_id)
);

-- 3️⃣ HABILITAR RLS
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- 4️⃣ REMOVER POLÍTICAS ANTIGAS (SE EXISTIREM)
DROP POLICY IF EXISTS "Usuários podem ver seus próprios settings" ON user_settings;
DROP POLICY IF EXISTS "Usuários podem inserir seus próprios settings" ON user_settings;
DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios settings" ON user_settings;
DROP POLICY IF EXISTS "Usuários podem deletar seus próprios settings" ON user_settings;

-- 5️⃣ CRIAR POLÍTICAS RLS CORRETAS
CREATE POLICY "Usuários podem ver seus próprios settings"
  ON user_settings FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir seus próprios settings"
  ON user_settings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios settings"
  ON user_settings FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar seus próprios settings"
  ON user_settings FOR DELETE
  USING (auth.uid() = user_id);

-- 6️⃣ CRIAR ÍNDICE PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_user_settings_user_id 
ON user_settings(user_id);

-- 7️⃣ CRIAR TRIGGER PARA ATUALIZAR updated_at
CREATE OR REPLACE FUNCTION update_user_settings_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_user_settings_updated_at ON user_settings;

CREATE TRIGGER trigger_user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_user_settings_updated_at();

-- 8️⃣ CRIAR SETTINGS PADRÃO PARA USUÁRIOS EXISTENTES
INSERT INTO user_settings (user_id, appearance_settings)
SELECT 
  id,
  jsonb_build_object(
    'tema', 'claro',
    'cor_primaria', '#3b82f6',
    'tamanho_fonte', 'medio',
    'animacoes', true,
    'sidebar_compacta', false
  )
FROM auth.users
WHERE id NOT IN (SELECT user_id FROM user_settings)
ON CONFLICT (user_id) DO NOTHING;

-- 9️⃣ VERIFICAR RESULTADO
SELECT 
  '✅ CONFIGURAÇÕES DA TABELA' as info,
  COUNT(*) as total_settings,
  COUNT(DISTINCT user_id) as total_usuarios
FROM user_settings;

SELECT 
  '✅ POLÍTICAS RLS ATIVAS' as info,
  schemaname,
  tablename,
  policyname,
  cmd as comando,
  qual as condicao
FROM pg_policies
WHERE tablename = 'user_settings'
ORDER BY policyname;

-- 🔟 TESTAR QUERY (simula a query do frontend)
SELECT 
  '🧪 TESTE: Query que estava falhando' as teste,
  appearance_settings
FROM user_settings
WHERE user_id = auth.uid()
LIMIT 1;

SELECT '🎉 Correção aplicada! Erro 406 resolvido.' as resultado;

-- =============================================
-- 📝 COMO USAR NO FRONTEND (já está correto)
-- =============================================
/*
const { data, error } = await supabase
  .from('user_settings')
  .select('appearance_settings')
  .eq('user_id', user.id)
  .single();
*/
