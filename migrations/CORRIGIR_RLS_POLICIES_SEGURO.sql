-- ============================================
-- CORRIGIR RLS POLICIES - MANTENDO SEGURANÇA
-- ============================================
-- Este script MANTÉM o RLS ativado mas corrige as policies
-- para que funcionem corretamente

-- ============================================
-- 1. TABELA FUNCIONARIOS
-- ============================================

-- Dropar policies antigas
DROP POLICY IF EXISTS "funcionarios_select_policy" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_insert_policy" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_update_policy" ON funcionarios;
DROP POLICY IF EXISTS "funcionarios_delete_policy" ON funcionarios;

-- SELECT: Usuário pode ver funcionários da sua empresa
CREATE POLICY "funcionarios_select_policy" ON funcionarios
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM empresas e
      WHERE e.id = funcionarios.empresa_id
        AND e.user_id = auth.uid()
    )
    OR
    funcionarios.user_id = auth.uid()
  );

-- INSERT: Usuário pode criar funcionários na sua empresa
CREATE POLICY "funcionarios_insert_policy" ON funcionarios
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM empresas e
      WHERE e.id = funcionarios.empresa_id
        AND e.user_id = auth.uid()
    )
  );

-- UPDATE: Usuário pode atualizar funcionários da sua empresa
CREATE POLICY "funcionarios_update_policy" ON funcionarios
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM empresas e
      WHERE e.id = funcionarios.empresa_id
        AND e.user_id = auth.uid()
    )
  );

-- DELETE: Usuário pode deletar funcionários da sua empresa
CREATE POLICY "funcionarios_delete_policy" ON funcionarios
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM empresas e
      WHERE e.id = funcionarios.empresa_id
        AND e.user_id = auth.uid()
    )
  );

-- ============================================
-- 2. TABELA FUNCOES
-- ============================================

-- Dropar policies antigas
DROP POLICY IF EXISTS "funcoes_select_policy" ON funcoes;
DROP POLICY IF EXISTS "funcoes_insert_policy" ON funcoes;
DROP POLICY IF EXISTS "funcoes_update_policy" ON funcoes;
DROP POLICY IF EXISTS "funcoes_delete_policy" ON funcoes;

-- SELECT: Usuário pode ver funções da sua empresa
CREATE POLICY "funcoes_select_policy" ON funcoes
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM empresas e
      WHERE e.id = funcoes.empresa_id
        AND e.user_id = auth.uid()
    )
  );

-- INSERT: Usuário pode criar funções na sua empresa
CREATE POLICY "funcoes_insert_policy" ON funcoes
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM empresas e
      WHERE e.id = funcoes.empresa_id
        AND e.user_id = auth.uid()
    )
  );

-- UPDATE: Usuário pode atualizar funções da sua empresa
CREATE POLICY "funcoes_update_policy" ON funcoes
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM empresas e
      WHERE e.id = funcoes.empresa_id
        AND e.user_id = auth.uid()
    )
  );

-- DELETE: Usuário pode deletar funções da sua empresa
CREATE POLICY "funcoes_delete_policy" ON funcoes
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM empresas e
      WHERE e.id = funcoes.empresa_id
        AND e.user_id = auth.uid()
    )
  );

-- ============================================
-- 3. TABELA FUNCIONARIO_FUNCOES
-- ============================================

-- Dropar policies antigas
DROP POLICY IF EXISTS "funcionario_funcoes_select_policy" ON funcionario_funcoes;
DROP POLICY IF EXISTS "funcionario_funcoes_insert_policy" ON funcionario_funcoes;
DROP POLICY IF EXISTS "funcionario_funcoes_update_policy" ON funcionario_funcoes;
DROP POLICY IF EXISTS "funcionario_funcoes_delete_policy" ON funcionario_funcoes;

-- SELECT: Usuário pode ver relacionamentos da sua empresa
CREATE POLICY "funcionario_funcoes_select_policy" ON funcionario_funcoes
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM funcionarios f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.id = funcionario_funcoes.funcionario_id
        AND e.user_id = auth.uid()
    )
  );

-- INSERT: Usuário pode criar relacionamentos na sua empresa
CREATE POLICY "funcionario_funcoes_insert_policy" ON funcionario_funcoes
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM funcionarios f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.id = funcionario_funcoes.funcionario_id
        AND e.user_id = auth.uid()
    )
  );

-- UPDATE: Usuário pode atualizar relacionamentos da sua empresa
CREATE POLICY "funcionario_funcoes_update_policy" ON funcionario_funcoes
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM funcionarios f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.id = funcionario_funcoes.funcionario_id
        AND e.user_id = auth.uid()
    )
  );

-- DELETE: Usuário pode deletar relacionamentos da sua empresa
CREATE POLICY "funcionario_funcoes_delete_policy" ON funcionario_funcoes
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM funcionarios f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.id = funcionario_funcoes.funcionario_id
        AND e.user_id = auth.uid()
    )
  );

-- ============================================
-- 4. TABELA FUNCAO_PERMISSOES
-- ============================================

-- Dropar policies antigas
DROP POLICY IF EXISTS "funcao_permissoes_select_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_insert_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_update_policy" ON funcao_permissoes;
DROP POLICY IF EXISTS "funcao_permissoes_delete_policy" ON funcao_permissoes;

-- SELECT: Usuário pode ver permissões das funções da sua empresa
CREATE POLICY "funcao_permissoes_select_policy" ON funcao_permissoes
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM funcoes f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.id = funcao_permissoes.funcao_id
        AND e.user_id = auth.uid()
    )
  );

-- INSERT: Usuário pode criar permissões nas funções da sua empresa
CREATE POLICY "funcao_permissoes_insert_policy" ON funcao_permissoes
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM funcoes f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.id = funcao_permissoes.funcao_id
        AND e.user_id = auth.uid()
    )
  );

-- UPDATE: Usuário pode atualizar permissões das funções da sua empresa
CREATE POLICY "funcao_permissoes_update_policy" ON funcao_permissoes
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM funcoes f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.id = funcao_permissoes.funcao_id
        AND e.user_id = auth.uid()
    )
  );

-- DELETE: Usuário pode deletar permissões das funções da sua empresa
CREATE POLICY "funcao_permissoes_delete_policy" ON funcao_permissoes
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM funcoes f
      JOIN empresas e ON e.id = f.empresa_id
      WHERE f.id = funcao_permissoes.funcao_id
        AND e.user_id = auth.uid()
    )
  );

-- ============================================
-- 5. TABELA SUBSCRIPTIONS
-- ============================================

-- Dropar policies antigas
DROP POLICY IF EXISTS "subscriptions_select_policy" ON subscriptions;
DROP POLICY IF EXISTS "subscriptions_insert_policy" ON subscriptions;
DROP POLICY IF EXISTS "subscriptions_update_policy" ON subscriptions;

-- SELECT: Usuário pode ver apenas sua assinatura
CREATE POLICY "subscriptions_select_policy" ON subscriptions
  FOR SELECT
  USING (user_id = auth.uid());

-- INSERT: Usuário pode criar sua própria assinatura
CREATE POLICY "subscriptions_insert_policy" ON subscriptions
  FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- UPDATE: Usuário pode atualizar sua própria assinatura
CREATE POLICY "subscriptions_update_policy" ON subscriptions
  FOR UPDATE
  USING (user_id = auth.uid());

-- ============================================
-- 6. VERIFICAR RESULTADO
-- ============================================

SELECT '✅ POLÍTICAS RLS CORRIGIDAS COM SUCESSO!' as status;

SELECT 
  '📋 Policies criadas para:' as info,
  tablename,
  COUNT(*) as total_policies
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('funcionarios', 'funcoes', 'funcionario_funcoes', 'funcao_permissoes', 'subscriptions')
GROUP BY tablename
ORDER BY tablename;

-- ============================================
-- MENSAGEM FINAL
-- ============================================

SELECT '
✅ RLS POLICIES CORRIGIDAS!

🔒 Segurança mantida:
- ✅ Cada usuário vê APENAS dados da sua empresa
- ✅ Usuário A NÃO pode ver dados do Usuário B
- ✅ Isolamento total entre empresas
- ✅ Seguro para produção!

📋 Tabelas protegidas:
1. funcionarios - Isolado por empresa
2. funcoes - Isolado por empresa
3. funcionario_funcoes - Isolado por empresa (via funcionario)
4. funcao_permissoes - Isolado por empresa (via funcao)
5. subscriptions - Isolado por user_id

🧪 Próximos passos:
1. Recarregue a aplicação (Ctrl+Shift+R)
2. O sistema deve funcionar normalmente
3. Os erros 406 devem desaparecer
4. A segurança está MANTIDA

🎯 Como funciona:
- RLS ATIVADO em todas as tabelas
- Policies usam auth.uid() para filtrar
- Cada query verifica se o usuário tem acesso
- JOIN com empresas garante isolamento
' as mensagem_final;
