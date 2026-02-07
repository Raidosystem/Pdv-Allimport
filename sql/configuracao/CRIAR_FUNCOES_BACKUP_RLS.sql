-- 🔓 FUNÇÃO SQL PARA BACKUP - Bypassa RLS
-- Execute este SQL no Supabase Dashboard para permitir backups

-- Função para listar todas as empresas (SECURITY DEFINER bypassa RLS)
CREATE OR REPLACE FUNCTION backup_listar_empresas()
RETURNS TABLE (
  id UUID,
  user_id UUID,
  nome TEXT,
  razao_social TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER  -- Bypassa RLS
AS $$
BEGIN
  RETURN QUERY
  SELECT e.id, e.user_id, e.nome, e.razao_social
  FROM empresas e;
END;
$$;

-- Função para listar dados de uma tabela por user_id
CREATE OR REPLACE FUNCTION backup_tabela_por_user(
  tabela_nome TEXT,
  filtro_user_id UUID
)
RETURNS SETOF JSONB
LANGUAGE plpgsql
SECURITY DEFINER  -- Bypassa RLS
AS $$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT to_jsonb(t.*) FROM %I t WHERE user_id = $1',
    tabela_nome
  ) USING filtro_user_id;
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION backup_listar_empresas() TO service_role;
GRANT EXECUTE ON FUNCTION backup_tabela_por_user(TEXT, UUID) TO service_role;

-- Verificar funções criadas
SELECT 'backup_listar_empresas' as funcao, prosecdef as security_definer
FROM pg_proc WHERE proname = 'backup_listar_empresas';

SELECT 'backup_tabela_por_user' as funcao, prosecdef as security_definer
FROM pg_proc WHERE proname = 'backup_tabela_por_user';

-- ✅ Agora o script Python pode chamar essas funções via RPC
