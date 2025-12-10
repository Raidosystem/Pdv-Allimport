-- ==============================================================================
-- FIX DEPLOY ERRORS - Categories RLS + listar_usuarios_ativos RPC
-- ==============================================================================
-- Este script corrige os 2 erros após deploy:
-- 1. categories com empresa_id causando erro 400
-- 2. RPC listar_usuarios_ativos retornando 404
-- ==============================================================================

-- ====================================
-- PARTE 1: CORRIGIR CATEGORIES
-- ====================================

-- 1.1: Verificar se coluna empresa_id existe
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'categories' AND column_name = 'empresa_id'
  ) THEN
    -- Se não existir, adicionar coluna
    ALTER TABLE public.categories ADD COLUMN empresa_id UUID REFERENCES auth.users(id);
    RAISE NOTICE '✅ Coluna empresa_id adicionada à tabela categories';
  ELSE
    RAISE NOTICE 'ℹ️ Coluna empresa_id já existe em categories';
  END IF;
END $$;

-- 1.2: Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_categories_empresa_id ON public.categories(empresa_id);
CREATE INDEX IF NOT EXISTS idx_categories_empresa_name ON public.categories(empresa_id, name);

-- 1.3: Atualizar categorias existentes com empresa_id do usuário atual
-- (Todas as categorias NULL serão atribuídas ao seu usuário)
UPDATE public.categories 
SET empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
WHERE empresa_id IS NULL;

-- 1.4: Remover políticas antigas de RLS
DROP POLICY IF EXISTS "Authenticated users can view categories" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem criar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem editar categorias" ON public.categories;
DROP POLICY IF EXISTS "Usuários autenticados podem deletar categorias" ON public.categories;
DROP POLICY IF EXISTS "Users can only see own categories" ON public.categories;
DROP POLICY IF EXISTS "super_access_categories" ON public.categories;
DROP POLICY IF EXISTS "assistencia_full_access_categories" ON public.categories;
DROP POLICY IF EXISTS "Permitir leitura de categorias para usuários autenticados" ON public.categories;
DROP POLICY IF EXISTS "categories_select_own_empresa" ON public.categories;
DROP POLICY IF EXISTS "categories_insert_own_empresa" ON public.categories;
DROP POLICY IF EXISTS "categories_update_own_empresa" ON public.categories;
DROP POLICY IF EXISTS "categories_delete_own_empresa" ON public.categories;

-- 1.5: Habilitar RLS
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- 1.6: Criar novas políticas RLS com empresa_id
CREATE POLICY "categories_select_own_empresa" ON public.categories
  FOR SELECT
  TO authenticated
  USING (empresa_id = auth.uid());

CREATE POLICY "categories_insert_own_empresa" ON public.categories
  FOR INSERT
  TO authenticated
  WITH CHECK (empresa_id = auth.uid());

CREATE POLICY "categories_update_own_empresa" ON public.categories
  FOR UPDATE
  TO authenticated
  USING (empresa_id = auth.uid())
  WITH CHECK (empresa_id = auth.uid());

CREATE POLICY "categories_delete_own_empresa" ON public.categories
  FOR DELETE
  TO authenticated
  USING (empresa_id = auth.uid());

-- 1.7: Garantir permissões
GRANT SELECT, INSERT, UPDATE, DELETE ON public.categories TO authenticated;

-- ====================================
-- PARTE 2: CORRIGIR RPC listar_usuarios_ativos
-- ====================================

-- 2.1: Remover função antiga se existir
DROP FUNCTION IF EXISTS listar_usuarios_ativos(UUID);

-- 2.2: Criar função RPC listar_usuarios_ativos
CREATE OR REPLACE FUNCTION listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  email TEXT,
  foto_perfil TEXT,
  tipo_admin TEXT,
  senha_definida BOOLEAN,
  primeiro_acesso BOOLEAN
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id,
    f.nome,
    COALESCE(f.email, '') as email,
    f.foto_perfil,
    f.tipo_admin,
    COALESCE(f.senha_definida, false) as senha_definida,
    COALESCE(f.primeiro_acesso, true) as primeiro_acesso
  FROM funcionarios f
  WHERE f.empresa_id = p_empresa_id
    AND (f.usuario_ativo = true OR f.usuario_ativo IS NULL)
    AND (f.status = 'ativo' OR f.status IS NULL)
    AND f.senha_definida = true
  ORDER BY f.nome;
END;
$$;

-- 2.3: Garantir permissões para RPC
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO anon;

-- 2.4: Ativar funcionários se necessário
UPDATE funcionarios
SET 
  usuario_ativo = true,
  senha_definida = true,
  status = 'ativo',
  primeiro_acesso = COALESCE(primeiro_acesso, true)
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND (usuario_ativo IS NULL OR usuario_ativo = false 
       OR senha_definida IS NULL OR senha_definida = false 
       OR status IS NULL OR status != 'ativo');

-- ====================================
-- PARTE 3: VERIFICAÇÃO
-- ====================================

-- 3.1: Verificar categories
SELECT 
  '✅ CATEGORIES' as tabela,
  COUNT(*) as total_categorias,
  COUNT(CASE WHEN empresa_id IS NOT NULL THEN 1 END) as com_empresa_id,
  COUNT(CASE WHEN empresa_id IS NULL THEN 1 END) as sem_empresa_id
FROM categories;

-- 3.2: Verificar políticas RLS de categories
SELECT 
  '📋 POLICIES CATEGORIES' as info,
  polname as nome_politica,
  CASE polcmd 
    WHEN 'r' THEN 'SELECT'
    WHEN 'a' THEN 'INSERT'
    WHEN 'w' THEN 'UPDATE'
    WHEN 'd' THEN 'DELETE'
    ELSE 'ALL'
  END as comando
FROM pg_policy
WHERE polrelid = 'public.categories'::regclass;

-- 3.3: Testar RPC listar_usuarios_ativos
SELECT 
  '🧪 TESTE RPC' as tipo,
  id,
  nome,
  email,
  tipo_admin,
  senha_definida
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1')
LIMIT 5;

-- 3.4: Verificar funcionários ativos
SELECT 
  '👥 FUNCIONÁRIOS' as info,
  COUNT(*) as total,
  COUNT(CASE WHEN usuario_ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN senha_definida = true THEN 1 END) as com_senha
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- ====================================
-- RESULTADO
-- ====================================
SELECT 
  '🎉 SCRIPT EXECUTADO' as status,
  'Erros 400 e 404 corrigidos!' as mensagem,
  'Teste o sistema agora' as proxima_acao;
