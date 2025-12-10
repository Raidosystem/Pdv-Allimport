-- ============================================
-- CORRIGIR RLS PARA PERMITIR JOIN EM CLIENTES
-- ============================================
-- Problema: Supabase retorna clientes: null no JOIN
-- Causa: RLS bloqueando SELECT na tabela clientes
-- Solução: Adicionar política SELECT permissiva
-- ============================================

-- 1. Verificar políticas atuais
SELECT 
  policyname,
  cmd,
  qual,
  with_check,
  permissive
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY policyname;

-- 2. Remover políticas antigas restritivas (se existirem)
DROP POLICY IF EXISTS "clientes_select_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_read_policy" ON clientes;
DROP POLICY IF EXISTS "Users can read their own clients" ON clientes;
DROP POLICY IF EXISTS "Usuarios podem ver apenas seus clientes" ON clientes;

-- 3. Criar política SELECT permissiva para usuários autenticados
CREATE POLICY "clientes_select_autenticados"
ON clientes
FOR SELECT
TO authenticated
USING (
  -- Permite ler clientes da própria empresa
  user_id = auth.uid()
  OR
  -- Permite ler clientes da mesma empresa
  user_id IN (
    SELECT id FROM auth.users 
    WHERE raw_user_meta_data->>'empresa_id' = 
          (SELECT raw_user_meta_data->>'empresa_id' FROM auth.users WHERE id = auth.uid())
  )
);

-- 4. Verificar se RLS está habilitado
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'clientes';

-- 5. Se não estiver habilitado, habilitar
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;

-- 6. Testar SELECT direto (deve funcionar)
SELECT COUNT(*) as total_clientes FROM clientes;

-- 7. Testar JOIN (deve retornar nomes agora)
SELECT 
  os.numero_os,
  os.cliente_id,
  c.id as cliente_id_encontrado,
  c.nome as nome_cliente
FROM ordens_servico os
LEFT JOIN clientes c ON os.cliente_id = c.id
WHERE os.numero_os IN ('OS-2025-06-17-001', 'OS-2025-06-17-002')
ORDER BY os.numero_os;

-- 8. Verificar política criada
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY policyname;

-- ============================================
-- RESULTADO ESPERADO:
-- ✅ Política criada: clientes_select_autenticados
-- ✅ JOIN retorna: EDVANIA DA SILVA para OS-2025-06-17-001 e 002
-- ✅ React receberá: order.clientes = { nome: "EDVANIA DA SILVA", ... }
-- ============================================
