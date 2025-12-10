-- ========================================
-- 🔧 ADICIONAR COLUNAS FALTANTES EM USER_SETTINGS
-- ========================================

-- Verificar estrutura atual
SELECT 
  '📋 ESTRUTURA ATUAL DA TABELA' as titulo;

SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'user_settings'
ORDER BY ordinal_position;

-- Adicionar colunas se não existirem
DO $$
BEGIN
  -- Adicionar print_settings
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'user_settings' 
    AND column_name = 'print_settings'
  ) THEN
    ALTER TABLE user_settings 
    ADD COLUMN print_settings JSONB DEFAULT '{}'::jsonb;
    RAISE NOTICE '✅ Coluna print_settings adicionada';
  ELSE
    RAISE NOTICE '⚠️ Coluna print_settings já existe';
  END IF;

  -- Adicionar notification_settings
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'user_settings' 
    AND column_name = 'notification_settings'
  ) THEN
    ALTER TABLE user_settings 
    ADD COLUMN notification_settings JSONB DEFAULT '{}'::jsonb;
    RAISE NOTICE '✅ Coluna notification_settings adicionada';
  ELSE
    RAISE NOTICE '⚠️ Coluna notification_settings já existe';
  END IF;
END $$;

-- Agora executar o script completo de correção
-- ==========================================
-- CRIAR FUNÇÃO: buscar_configuracoes_impressao_usuario
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
-- CRIAR CONFIGURAÇÕES PADRÃO
-- ==========================================

-- Atualizar registros existentes que não têm print_settings
UPDATE user_settings
SET print_settings = jsonb_build_object(
  'impressora_padrao', '',
  'largura_papel', '80mm',
  'margem', '2mm',
  'auto_print', false,
  'mostrar_logo', true,
  'mostrar_dados_empresa', true
)
WHERE print_settings IS NULL OR print_settings = '{}'::jsonb;

-- Criar registros para usuários que não têm user_settings
INSERT INTO user_settings (user_id, appearance_settings, print_settings, notification_settings)
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
  ),
  '{}'::jsonb
FROM auth.users au
LEFT JOIN user_settings us ON us.user_id = au.id
WHERE us.id IS NULL
ON CONFLICT (user_id) DO NOTHING;

-- ==========================================
-- VERIFICAÇÃO FINAL
-- ==========================================

SELECT 
  '✅ CORREÇÃO CONCLUÍDA' as status;

-- Estrutura final
SELECT 
  '📋 ESTRUTURA FINAL DA TABELA' as titulo;

SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'user_settings'
ORDER BY ordinal_position;

-- Verificar função criada
SELECT 
  '📋 Função buscar_configuracoes_impressao_usuario:' as info,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ Existe'
    ELSE '❌ Não existe'
  END as status
FROM pg_proc
WHERE proname = 'buscar_configuracoes_impressao_usuario';

-- Mostrar quantidade de registros
SELECT 
  '📊 Registros em user_settings:' as info,
  COUNT(*) as quantidade,
  COUNT(CASE WHEN print_settings IS NOT NULL THEN 1 END) as com_print_settings,
  COUNT(CASE WHEN appearance_settings IS NOT NULL THEN 1 END) as com_appearance_settings
FROM user_settings;

-- Testar função
SELECT 
  '🧪 TESTE DA FUNÇÃO' as titulo;

-- Teste com user_id real (substitua se necessário)
SELECT buscar_configuracoes_impressao_usuario('f7fdf4cf-7101-45ab-86db-5248a7ac58c1') as configuracoes_retornadas;
