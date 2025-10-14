-- ========================================
-- CRIAR TABELA USER_SETTINGS
-- ========================================
-- Execute este SQL no Supabase SQL Editor

-- Criar tabela de configurações de usuário
CREATE TABLE IF NOT EXISTS public.user_settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  appearance_settings JSONB DEFAULT '{
    "tema": "claro",
    "cor_primaria": "#3B82F6",
    "cor_secundaria": "#10B981",
    "tamanho_fonte": "medio",
    "animacoes": true,
    "sidebar_compacta": false
  }'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Criar índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON public.user_settings(user_id);

-- Adicionar comentários
COMMENT ON TABLE public.user_settings IS 'Configurações personalizadas de cada usuário';
COMMENT ON COLUMN public.user_settings.appearance_settings IS 'Configurações de aparência e interface (tema, cores, fonte, animações, etc)';

-- Habilitar Row Level Security
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

-- Políticas RLS: Usuários só podem ver/editar suas próprias configurações
CREATE POLICY "Usuários podem ver suas próprias configurações"
  ON public.user_settings
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir suas próprias configurações"
  ON public.user_settings
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar suas próprias configurações"
  ON public.user_settings
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar suas próprias configurações"
  ON public.user_settings
  FOR DELETE
  USING (auth.uid() = user_id);

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_user_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar updated_at
DROP TRIGGER IF EXISTS trigger_update_user_settings_updated_at ON public.user_settings;
CREATE TRIGGER trigger_update_user_settings_updated_at
  BEFORE UPDATE ON public.user_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_user_settings_updated_at();

-- ✅ Tabela criada com sucesso!
-- Agora os usuários podem salvar suas configurações personalizadas
