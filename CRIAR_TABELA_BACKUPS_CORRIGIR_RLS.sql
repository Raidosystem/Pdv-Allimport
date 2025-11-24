-- =====================================================
-- CRIAR TABELA DE BACKUPS E CONFIGURAR RLS
-- =====================================================
-- Criado: 2025-11-24
-- Objetivo: Corrigir erro 403 ao acessar backups
-- =====================================================

-- 1. Adicionar coluna user_id na tabela empresas se não existir
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'empresas' 
    AND column_name = 'user_id'
  ) THEN
    ALTER TABLE public.empresas 
    ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    
    RAISE NOTICE '✅ Coluna user_id adicionada na tabela empresas';
  ELSE
    RAISE NOTICE 'ℹ️ Coluna user_id já existe na tabela empresas';
  END IF;
END $$;

-- 2. Criar tabela de backups se não existir
CREATE TABLE IF NOT EXISTS public.backups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  empresa_id UUID NOT NULL REFERENCES public.empresas(id) ON DELETE CASCADE,
  
  -- Dados do backup
  data JSONB NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN ('manual', 'automatico', 'sistema')),
  descricao TEXT,
  
  -- Metadados
  tamanho_bytes BIGINT,
  status TEXT NOT NULL DEFAULT 'concluido' CHECK (status IN ('concluido', 'falhou', 'processando')),
  
  -- Estatísticas do backup
  total_clientes INTEGER DEFAULT 0,
  total_produtos INTEGER DEFAULT 0,
  total_vendas INTEGER DEFAULT 0,
  total_ordens INTEGER DEFAULT 0,
  total_caixas INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- 3. Popular user_id nas empresas existentes (primeiro usuário de auth.users)
DO $$ 
DECLARE
  v_primeiro_user_id UUID;
  v_empresas_atualizadas INTEGER;
BEGIN
  -- Buscar primeiro usuário
  SELECT id INTO v_primeiro_user_id
  FROM auth.users
  ORDER BY created_at ASC
  LIMIT 1;
  
  IF v_primeiro_user_id IS NOT NULL THEN
    -- Atualizar empresas sem user_id
    UPDATE public.empresas
    SET user_id = v_primeiro_user_id
    WHERE user_id IS NULL;
    
    GET DIAGNOSTICS v_empresas_atualizadas = ROW_COUNT;
    
    RAISE NOTICE '✅ % empresa(s) vinculada(s) ao primeiro usuário', v_empresas_atualizadas;
  ELSE
    RAISE NOTICE '⚠️ Nenhum usuário encontrado em auth.users';
  END IF;
END $$;

-- 4. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_backups_user_id ON public.backups(user_id);
CREATE INDEX IF NOT EXISTS idx_backups_empresa_id ON public.backups(empresa_id);
CREATE INDEX IF NOT EXISTS idx_backups_created_at ON public.backups(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_backups_tipo ON public.backups(tipo);
CREATE INDEX IF NOT EXISTS idx_backups_status ON public.backups(status);

-- 5. Adicionar coluna backup_config na tabela empresas se não existir
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'empresas' 
    AND column_name = 'backup_config'
  ) THEN
    ALTER TABLE public.empresas 
    ADD COLUMN backup_config JSONB DEFAULT jsonb_build_object(
      'auto_backup_enabled', true,
      'backup_frequency_hours', 24,
      'retention_days', 30,
      'include_vendas', true,
      'include_produtos', true,
      'include_clientes', true,
      'include_ordens', true,
      'include_caixas', true
    );
    
    RAISE NOTICE '✅ Coluna backup_config adicionada com configurações padrão';
  ELSE
    RAISE NOTICE 'ℹ️ Coluna backup_config já existe';
  END IF;
END $$;

-- 6. Habilitar RLS na tabela backups
ALTER TABLE public.backups ENABLE ROW LEVEL SECURITY;

-- 7. Remover políticas antigas se existirem
DROP POLICY IF EXISTS "backups_select_policy" ON public.backups;
DROP POLICY IF EXISTS "backups_insert_policy" ON public.backups;
DROP POLICY IF EXISTS "backups_update_policy" ON public.backups;
DROP POLICY IF EXISTS "backups_delete_policy" ON public.backups;

-- 8. Criar políticas RLS permissivas para backups
-- Usuários autenticados podem ver backups da sua empresa
CREATE POLICY "backups_select_policy" ON public.backups
  FOR SELECT
  TO authenticated
  USING (
    empresa_id IN (
      SELECT id FROM public.empresas 
      WHERE user_id = auth.uid()
    )
    OR user_id = auth.uid()
  );

-- Usuários autenticados podem criar backups
CREATE POLICY "backups_insert_policy" ON public.backups
  FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    AND empresa_id IN (
      SELECT id FROM public.empresas 
      WHERE user_id = auth.uid()
    )
  );

-- Usuários podem atualizar seus próprios backups
CREATE POLICY "backups_update_policy" ON public.backups
  FOR UPDATE
  TO authenticated
  USING (
    user_id = auth.uid()
    OR empresa_id IN (
      SELECT id FROM public.empresas 
      WHERE user_id = auth.uid()
    )
  )
  WITH CHECK (
    user_id = auth.uid()
    OR empresa_id IN (
      SELECT id FROM public.empresas 
      WHERE user_id = auth.uid()
    )
  );

-- Usuários podem deletar seus próprios backups
CREATE POLICY "backups_delete_policy" ON public.backups
  FOR DELETE
  TO authenticated
  USING (
    user_id = auth.uid()
    OR empresa_id IN (
      SELECT id FROM public.empresas 
      WHERE user_id = auth.uid()
    )
  );

-- 9. Criar trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_backups_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_backups_updated_at ON public.backups;

CREATE TRIGGER trigger_update_backups_updated_at
  BEFORE UPDATE ON public.backups
  FOR EACH ROW
  EXECUTE FUNCTION update_backups_updated_at();

-- 10. Criar função para popular empresa_id automaticamente
CREATE OR REPLACE FUNCTION auto_set_backup_empresa_id()
RETURNS TRIGGER AS $$
DECLARE
  v_empresa_id UUID;
BEGIN
  -- Se empresa_id já está definido, não fazer nada
  IF NEW.empresa_id IS NOT NULL THEN
    RETURN NEW;
  END IF;

  -- Buscar empresa_id do usuário
  SELECT id INTO v_empresa_id
  FROM public.empresas
  WHERE user_id = NEW.user_id
  LIMIT 1;

  -- Se encontrou, atribuir
  IF v_empresa_id IS NOT NULL THEN
    NEW.empresa_id = v_empresa_id;
  ELSE
    -- Se não encontrou, criar empresa automaticamente
    INSERT INTO public.empresas (user_id, nome, created_at, updated_at)
    VALUES (NEW.user_id, 'Minha Empresa', NOW(), NOW())
    RETURNING id INTO v_empresa_id;
    
    NEW.empresa_id = v_empresa_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_auto_set_backup_empresa_id ON public.backups;

CREATE TRIGGER trigger_auto_set_backup_empresa_id
  BEFORE INSERT ON public.backups
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_backup_empresa_id();

-- 11. Atualizar configurações padrão para empresas existentes sem backup_config
UPDATE public.empresas
SET backup_config = jsonb_build_object(
  'auto_backup_enabled', true,
  'backup_frequency_hours', 24,
  'retention_days', 30,
  'include_vendas', true,
  'include_produtos', true,
  'include_clientes', true,
  'include_ordens', true,
  'include_caixas', true
)
WHERE backup_config IS NULL;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

DO $$
DECLARE
  v_backups_count INTEGER;
  v_empresas_com_config INTEGER;
BEGIN
  -- Contar backups existentes
  SELECT COUNT(*) INTO v_backups_count FROM public.backups;
  
  -- Contar empresas com configuração
  SELECT COUNT(*) INTO v_empresas_com_config 
  FROM public.empresas 
  WHERE backup_config IS NOT NULL;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ SISTEMA DE BACKUPS CONFIGURADO';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Tabela backups: ✅ Criada e configurada';
  RAISE NOTICE 'RLS habilitado: ✅ Sim';
  RAISE NOTICE 'Políticas criadas: ✅ 4 políticas (SELECT, INSERT, UPDATE, DELETE)';
  RAISE NOTICE 'Backups existentes: % backup(s)', v_backups_count;
  RAISE NOTICE 'Empresas configuradas: % empresa(s)', v_empresas_com_config;
  RAISE NOTICE '';
  RAISE NOTICE '🎯 PRÓXIMOS PASSOS:';
  RAISE NOTICE '1. Teste criar um backup manual';
  RAISE NOTICE '2. Verifique se o histórico de backups aparece';
  RAISE NOTICE '3. Teste download e upload de backup';
  RAISE NOTICE '========================================';
END $$;
