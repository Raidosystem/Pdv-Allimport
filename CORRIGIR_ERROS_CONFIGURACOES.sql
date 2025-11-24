-- ========================================
-- 🔧 CORRIGIR ERROS DE CONFIGURAÇÕES
-- ========================================
-- Erro 1: 404 - buscar_configuracoes_impressao_usuario não existe
-- Erro 2: 406 - user_settings.appearance_settings não aceita
-- ========================================

-- ==========================================
-- 1️⃣ CRIAR TABELA USER_SETTINGS (se não existir)
-- ==========================================

CREATE TABLE IF NOT EXISTS user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  appearance_settings JSONB DEFAULT '{"theme": "light", "primaryColor": "#3B82F6"}'::jsonb,
  print_settings JSONB DEFAULT '{}'::jsonb,
  notification_settings JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON user_settings(user_id);

-- RLS
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- Políticas RLS
DROP POLICY IF EXISTS "Usuários podem ver suas próprias configurações" ON user_settings;
DROP POLICY IF EXISTS "Usuários podem inserir suas próprias configurações" ON user_settings;
DROP POLICY IF EXISTS "Usuários podem atualizar suas próprias configurações" ON user_settings;

CREATE POLICY "Usuários podem ver suas próprias configurações"
ON user_settings FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Usuários podem inserir suas próprias configurações"
ON user_settings FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Usuários podem atualizar suas próprias configurações"
ON user_settings FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ==========================================
-- 2️⃣ CRIAR FUNÇÃO: buscar_configuracoes_impressao_usuario
-- ==========================================

CREATE OR REPLACE FUNCTION buscar_configuracoes_impressao_usuario(p_user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_settings JSONB;
BEGIN
  -- Buscar configurações existentes
  SELECT print_settings INTO v_settings
  FROM user_settings
  WHERE user_id = p_user_id;

  -- Se não existir, criar registro padrão
  IF v_settings IS NULL THEN
    INSERT INTO user_settings (user_id, print_settings)
    VALUES (
      p_user_id,
      jsonb_build_object(
        'impressora_padrao', '',
        'largura_papel', '80mm',
        'margem', '2mm',
        'auto_print', false,
        'mostrar_logo', true,
        'mostrar_dados_empresa', true
      )
    )
    ON CONFLICT (user_id) DO UPDATE
    SET print_settings = EXCLUDED.print_settings
    RETURNING print_settings INTO v_settings;
  END IF;

  RETURN COALESCE(v_settings, '{}'::jsonb);
END;
$$;

-- ==========================================
-- 3️⃣ CRIAR CONFIGURAÇÕES PADRÃO PARA USUÁRIOS EXISTENTES
-- ==========================================

INSERT INTO user_settings (user_id, appearance_settings, print_settings)
SELECT 
  au.id,
  '{"theme": "light", "primaryColor": "#3B82F6"}'::jsonb,
  jsonb_build_object(
    'impressora_padrao', '',
    'largura_papel', '80mm',
    'margem', '2mm',
    'auto_print', false,
    'mostrar_logo', true,
    'mostrar_dados_empresa', true
  )
FROM auth.users au
LEFT JOIN user_settings us ON us.user_id = au.id
WHERE us.id IS NULL
ON CONFLICT (user_id) DO NOTHING;

-- ==========================================
-- 4️⃣ VERIFICAÇÃO FINAL
-- ==========================================

SELECT 
  '✅ CORREÇÃO CONCLUÍDA' as status;

-- Verificar função criada
SELECT 
  '📋 Função buscar_configuracoes_impressao_usuario:' as info,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ Existe'
    ELSE '❌ Não existe'
  END as status
FROM pg_proc
WHERE proname = 'buscar_configuracoes_impressao_usuario';

-- Verificar tabela criada
SELECT 
  '📋 Tabela user_settings:' as info,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ Existe'
    ELSE '❌ Não existe'
  END as status
FROM information_schema.tables
WHERE table_name = 'user_settings';

-- Mostrar quantidade de registros
SELECT 
  '📊 Registros em user_settings:' as info,
  COUNT(*) as quantidade
FROM user_settings;

-- Testar função (substitua pelo user_id real)
SELECT 
  '🧪 Teste da função:' as titulo;

-- Exemplo: SELECT buscar_configuracoes_impressao_usuario('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');
