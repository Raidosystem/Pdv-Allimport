-- ============================================
-- CORRIGIR RLS PARA ORDENS_SERVICO
-- ============================================
-- Problema: Página mostra 0 ordens (RLS bloqueando SELECT)
-- Solução: Criar política SELECT permissiva
-- ============================================

-- 1. Verificar políticas atuais de ordens_servico
SELECT 
  policyname,
  cmd,
  qual,
  permissive
FROM pg_policies
WHERE tablename = 'ordens_servico'
ORDER BY policyname;

-- 2. Verificar se RLS está habilitado
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'ordens_servico';

-- 3. Remover políticas antigas restritivas (se existirem)
DROP POLICY IF EXISTS "ordens_servico_select_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_read_policy" ON ordens_servico;
DROP POLICY IF EXISTS "Users can read their own orders" ON ordens_servico;

-- 4. Criar política SELECT permissiva para usuários autenticados
CREATE POLICY "ordens_servico_select_autenticados"
ON ordens_servico
FOR SELECT
TO authenticated
USING (
  -- Permite ler ordens do próprio usuário
  usuario_id = auth.uid()
  OR
  user_id = auth.uid()
  OR
  -- Permite ler ordens da mesma empresa
  usuario_id IN (
    SELECT id FROM auth.users 
    WHERE raw_user_meta_data->>'empresa_id' = 
          (SELECT raw_user_meta_data->>'empresa_id' FROM auth.users WHERE id = auth.uid())
  )
  OR
  user_id IN (
    SELECT id FROM auth.users 
    WHERE raw_user_meta_data->>'empresa_id' = 
          (SELECT raw_user_meta_data->>'empresa_id' FROM auth.users WHERE id = auth.uid())
  )
);

-- 5. Habilitar RLS (se não estiver)
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- 6. Testar SELECT direto (deve retornar 160 ordens)
SELECT COUNT(*) as total_ordens FROM ordens_servico;

-- 7. Testar com JOIN (deve retornar 160 com nomes de clientes)
SELECT 
  COUNT(*) as total_com_join
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id;

-- 8. Testar primeiras 5 ordens com nomes
SELECT 
  os.numero_os,
  os.modelo,
  c.nome as cliente_nome
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
ORDER BY os.data_entrada DESC
LIMIT 5;

-- 9. Verificar políticas criadas
SELECT 
  tablename,
  policyname,
  cmd,
  permissive
FROM pg_policies
WHERE tablename IN ('ordens_servico', 'clientes')
ORDER BY tablename, policyname;

-- ============================================
-- RESULTADO ESPERADO:
-- ✅ Query 6: 160 ordens visíveis
-- ✅ Query 7: 160 ordens com JOIN
-- ✅ Query 8: 5 ordens com nomes reais
-- ✅ Após isso, React carregará 160 ordens com nomes!
-- ============================================
