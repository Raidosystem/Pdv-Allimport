-- =====================================================
-- CORRIGIR RLS ORDENS DE SERVIÇO
-- Permitir que cada usuário veja APENAS suas próprias ordens
-- =====================================================

-- 1. Verificar RLS atual
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'ordens_servico';

-- 2. REMOVER políticas antigas que podem estar bloqueando
DROP POLICY IF EXISTS "Usuários podem ver próprias ordens" ON ordens_servico;
DROP POLICY IF EXISTS "Isolamento por empresa - SELECT" ON ordens_servico;
DROP POLICY IF EXISTS "Users can view own service orders" ON ordens_servico;
DROP POLICY IF EXISTS "enable_read_ordens" ON ordens_servico;

-- 3. CRIAR política correta: usuário vê ordens da SUA empresa
CREATE POLICY "Usuários veem ordens da própria empresa"
ON ordens_servico
FOR SELECT
USING (
  -- Usuário vê ordens onde empresa_id = seu user_id
  empresa_id = auth.uid()
  OR
  -- OU onde user_id = seu user_id (ordens antigas)
  user_id = auth.uid()
);

-- 4. CRIAR política de INSERT
CREATE POLICY "Usuários criam ordens na própria empresa"
ON ordens_servico
FOR INSERT
WITH CHECK (
  empresa_id = auth.uid()
  OR
  user_id = auth.uid()
);

-- 5. CRIAR política de UPDATE
CREATE POLICY "Usuários atualizam ordens da própria empresa"
ON ordens_servico
FOR UPDATE
USING (
  empresa_id = auth.uid()
  OR
  user_id = auth.uid()
)
WITH CHECK (
  empresa_id = auth.uid()
  OR
  user_id = auth.uid()
);

-- 6. CRIAR política de DELETE
CREATE POLICY "Usuários deletam ordens da própria empresa"
ON ordens_servico
FOR DELETE
USING (
  empresa_id = auth.uid()
  OR
  user_id = auth.uid()
);

-- 7. Garantir que RLS está ATIVO
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- 8. TESTAR: Ver quantas ordens o usuário atual consegue acessar
SELECT 
  COUNT(*) as ordens_visiveis,
  string_agg(DISTINCT status, ', ') as status_encontrados
FROM ordens_servico;

-- 9. VERIFICAR políticas criadas
SELECT 
  policyname,
  cmd,
  qual as usando,
  with_check as com_check
FROM pg_policies
WHERE tablename = 'ordens_servico'
ORDER BY cmd;
