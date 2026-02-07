-- 🔧 CORRIGIR RLS DA TABELA CONTAS_PAGAR
-- Problema: Funcionários não conseguem inserir/atualizar contas a pagar
-- Solução: Usar get_current_user_id() que considera funcionários

-- 1. Remover TODAS as políticas antigas (incluindo as novas se já existirem)
DROP POLICY IF EXISTS "Usuários veem apenas suas contas" ON contas_pagar;
DROP POLICY IF EXISTS "Usuários podem inserir suas contas" ON contas_pagar;
DROP POLICY IF EXISTS "Usuários podem atualizar suas contas" ON contas_pagar;
DROP POLICY IF EXISTS "Usuários podem deletar suas contas" ON contas_pagar;
DROP POLICY IF EXISTS "users_select_own_contas_pagar" ON contas_pagar;
DROP POLICY IF EXISTS "users_insert_own_contas_pagar" ON contas_pagar;
DROP POLICY IF EXISTS "users_update_own_contas_pagar" ON contas_pagar;
DROP POLICY IF EXISTS "users_delete_own_contas_pagar" ON contas_pagar;

-- 2. Criar função helper se não existir
CREATE OR REPLACE FUNCTION get_current_user_id()
RETURNS UUID AS $$
DECLARE
  current_user_id UUID;
  parent_id UUID;
BEGIN
  -- Pegar o user_id do usuário autenticado
  current_user_id := auth.uid();
  
  -- Se não há usuário autenticado, retornar NULL (prevenir erros)
  IF current_user_id IS NULL THEN
    RETURN NULL;
  END IF;
  
  -- Verificar se é funcionário (tem parent_user_id no user_metadata)
  BEGIN
    SELECT (auth.jwt() -> 'user_metadata' ->> 'parent_user_id')::UUID INTO parent_id;
  EXCEPTION WHEN OTHERS THEN
    -- Se houver erro ao ler metadata, retornar current_user_id
    RETURN current_user_id;
  END;
  
  -- Se for funcionário, retornar o ID do proprietário
  IF parent_id IS NOT NULL THEN
    RETURN parent_id;
  END IF;
  
  -- Senão, retornar o próprio user_id
  RETURN current_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- 3. Criar novas políticas usando get_current_user_id()
CREATE POLICY "users_select_own_contas_pagar"
  ON contas_pagar
  FOR SELECT
  USING (user_id = get_current_user_id());

CREATE POLICY "users_insert_own_contas_pagar"
  ON contas_pagar
  FOR INSERT
  WITH CHECK (user_id = get_current_user_id());

CREATE POLICY "users_update_own_contas_pagar"
  ON contas_pagar
  FOR UPDATE
  USING (user_id = get_current_user_id())
  WITH CHECK (user_id = get_current_user_id());

CREATE POLICY "users_delete_own_contas_pagar"
  ON contas_pagar
  FOR DELETE
  USING (user_id = get_current_user_id());

-- 4. Verificar políticas criadas
SELECT 
    tablename,
    policyname,
    cmd,
    CASE 
        WHEN policyname LIKE '%select%' THEN 'SELECT'
        WHEN policyname LIKE '%insert%' THEN 'INSERT'
        WHEN policyname LIKE '%update%' THEN 'UPDATE'
        WHEN policyname LIKE '%delete%' THEN 'DELETE'
    END as operacao
FROM pg_policies
WHERE tablename = 'contas_pagar'
ORDER BY policyname;

-- 5. Verificar se a função foi criada
SELECT 
    routine_name as funcao,
    routine_type as tipo,
    'Função criada com sucesso' as status
FROM information_schema.routines
WHERE routine_name = 'get_current_user_id'
AND routine_schema = 'public';

-- ⚠️ IMPORTANTE: O teste abaixo só funciona quando executado
-- dentro de uma sessão autenticada (com usuário logado via app)
-- Se executar direto no SQL Editor sem estar logado, retornará NULL
-- 
-- Para testar de verdade:
-- 1. Faça login no sistema PDV
-- 2. Tente salvar uma conta a pagar
-- 3. Deve funcionar sem erro 403
