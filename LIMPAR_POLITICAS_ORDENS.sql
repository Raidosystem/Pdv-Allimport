-- =====================================================
-- LIMPAR POLÍTICAS DUPLICADAS - MANTER APENAS AS CORRETAS
-- =====================================================

-- 1. REMOVER as políticas ANTIGAS (que usam get_user_empresa_id)
DROP POLICY IF EXISTS "ordens_servico_empresa_isolation" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_delete_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_insert_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_select_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_update_policy" ON ordens_servico;

-- 2. VERIFICAR que sobraram apenas as políticas corretas
SELECT 
  policyname,
  cmd,
  qual as condicao_using
FROM pg_policies
WHERE tablename = 'ordens_servico'
ORDER BY cmd;

-- 3. TESTAR: Ver quantas ordens o usuário consegue acessar agora
SELECT 
  COUNT(*) as total_ordens,
  COUNT(DISTINCT status) as tipos_status,
  string_agg(DISTINCT status, ', ') as status_encontrados
FROM ordens_servico;

-- 4. Ver detalhes das primeiras 5 ordens
SELECT 
  id,
  created_at,
  status,
  equipamento,
  empresa_id
FROM ordens_servico
ORDER BY created_at DESC
LIMIT 5;
