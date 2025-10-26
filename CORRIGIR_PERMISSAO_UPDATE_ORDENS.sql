-- ========================================
-- CORREÇÃO: Permissão para UPDATE em ordens_servico
-- ========================================
-- Problema: Política RLS está tentando acessar tabela users sem permissão
-- Solução: Recriar política usando apenas auth.uid() e empresa_id
-- ========================================

-- 1. Remover política problemática
DROP POLICY IF EXISTS "Users can only update own ordens_servico" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_update_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_update_own" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_policy_update" ON ordens_servico;
DROP POLICY IF EXISTS "Users can update ordens_servico" ON ordens_servico;

-- 2. Criar nova política simplificada
CREATE POLICY "ordens_servico_update_simple" 
ON ordens_servico
FOR UPDATE
USING (
  -- Permitir update para o dono da empresa OU para o usuário que criou
  empresa_id = auth.uid() 
  OR 
  usuario_id = auth.uid()
)
WITH CHECK (
  -- Mesmo check para garantir que não modifique para outra empresa
  empresa_id = auth.uid() 
  OR 
  usuario_id = auth.uid()
);

-- 3. Verificar se RLS está ativado
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- 4. Garantir que admin empresa tenha permissão total
-- (apenas confirmação, não cria nova política)
COMMENT ON POLICY "ordens_servico_update_simple" ON ordens_servico IS 
'Permite UPDATE para o dono da empresa (empresa_id = auth.uid()) ou criador da ordem (usuario_id = auth.uid())';

-- ========================================
-- VERIFICAÇÃO
-- ========================================
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'ordens_servico' AND cmd = 'UPDATE';
