-- =============================================
-- CORREÇÃO: Erro 406 - Busca de Empresa
-- =============================================
-- Problema: RLS bloqueando acesso à tabela empresas
-- Solução: Criar política que permite usuário ver sua própria empresa
-- =============================================

-- 1. Remover política antiga se existir
DROP POLICY IF EXISTS "Usuários podem ver sua empresa" ON empresas;
DROP POLICY IF EXISTS "Users can view their own company" ON empresas;
DROP POLICY IF EXISTS "Empresas isoladas por user_id" ON empresas;

-- 2. Criar nova política para SELECT
CREATE POLICY "Usuários podem ver sua empresa"
ON empresas
FOR SELECT
USING (
  auth.uid() = user_id
);

-- 3. Criar política para INSERT (caso necessário)
DROP POLICY IF EXISTS "Usuários podem criar empresa" ON empresas;

CREATE POLICY "Usuários podem criar empresa"
ON empresas
FOR INSERT
WITH CHECK (
  auth.uid() = user_id
);

-- 4. Criar política para UPDATE (caso necessário)
DROP POLICY IF EXISTS "Usuários podem atualizar sua empresa" ON empresas;

CREATE POLICY "Usuários podem atualizar sua empresa"
ON empresas
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 5. Verificar se RLS está habilitado
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;

-- =============================================
-- VERIFICAÇÃO
-- =============================================
-- Execute para verificar se funcionou:
-- SELECT * FROM empresas WHERE user_id = auth.uid();

-- =============================================
-- ALTERNATIVA: Função RPC (se acima não funcionar)
-- =============================================
/*
CREATE OR REPLACE FUNCTION get_user_empresa_id()
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT id 
  FROM empresas 
  WHERE user_id = auth.uid()
  LIMIT 1;
$$;

-- Dar permissão para usar a função
GRANT EXECUTE ON FUNCTION get_user_empresa_id() TO authenticated;

-- Usar no código TypeScript:
-- const { data, error } = await supabase.rpc('get_user_empresa_id')
*/

-- =============================================
-- LOG DE EXECUÇÃO
-- =============================================
DO $$
BEGIN
  RAISE NOTICE '✅ Políticas RLS da tabela empresas criadas com sucesso!';
  RAISE NOTICE 'Execute: SELECT * FROM empresas WHERE user_id = auth.uid();';
  RAISE NOTICE 'Para testar se está funcionando.';
END $$;
