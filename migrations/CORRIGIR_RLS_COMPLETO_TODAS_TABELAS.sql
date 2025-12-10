-- =====================================================
-- VERIFICAÇÃO COMPLETA: RLS em todas as tabelas principais
-- =====================================================
-- Verificar se produtos, vendas, etc também têm problema
-- =====================================================

-- 🔍 VERIFICAR TODAS AS TABELAS
SELECT 
    t.tablename,
    t.rowsecurity as rls_ativo,
    (SELECT COUNT(*) FROM pg_policies p WHERE p.tablename = t.tablename) as num_politicas,
    (
        SELECT COUNT(*) 
        FROM information_schema.columns c 
        WHERE c.table_name = t.tablename 
        AND c.column_name = 'user_id'
    ) as tem_user_id
FROM pg_tables t
WHERE t.schemaname = 'public'
AND t.tablename IN ('clientes', 'produtos', 'vendas', 'vendas_itens', 'caixa', 'ordem_servico')
ORDER BY t.tablename;

-- =====================================================
-- 🔧 CORREÇÃO COMPLETA: Aplicar RLS correto em TODAS as tabelas
-- =====================================================

-- ========== PRODUTOS ==========
DROP POLICY IF EXISTS "produtos_select_user" ON produtos;
DROP POLICY IF EXISTS "produtos_insert_user" ON produtos;
DROP POLICY IF EXISTS "produtos_update_user" ON produtos;
DROP POLICY IF EXISTS "produtos_delete_user" ON produtos;

CREATE POLICY "produtos_select_user" ON produtos FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "produtos_insert_user" ON produtos FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "produtos_update_user" ON produtos FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "produtos_delete_user" ON produtos FOR DELETE TO authenticated USING (user_id = auth.uid());

-- Trigger produtos
DROP TRIGGER IF EXISTS trigger_set_user_id_produtos ON produtos;
CREATE TRIGGER trigger_set_user_id_produtos
  BEFORE INSERT ON produtos
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_user_id_clientes(); -- Reutiliza função

-- ========== VENDAS ==========
DROP POLICY IF EXISTS "vendas_select_user" ON vendas;
DROP POLICY IF EXISTS "vendas_insert_user" ON vendas;
DROP POLICY IF EXISTS "vendas_update_user" ON vendas;
DROP POLICY IF EXISTS "vendas_delete_user" ON vendas;

CREATE POLICY "vendas_select_user" ON vendas FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "vendas_insert_user" ON vendas FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "vendas_update_user" ON vendas FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "vendas_delete_user" ON vendas FOR DELETE TO authenticated USING (user_id = auth.uid());

-- Trigger vendas
DROP TRIGGER IF EXISTS trigger_set_user_id_vendas ON vendas;
CREATE TRIGGER trigger_set_user_id_vendas
  BEFORE INSERT ON vendas
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_user_id_clientes();

-- ========== CAIXA ==========
DROP POLICY IF EXISTS "caixa_select_user" ON caixa;
DROP POLICY IF EXISTS "caixa_insert_user" ON caixa;
DROP POLICY IF EXISTS "caixa_update_user" ON caixa;
DROP POLICY IF EXISTS "caixa_delete_user" ON caixa;

CREATE POLICY "caixa_select_user" ON caixa FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "caixa_insert_user" ON caixa FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "caixa_update_user" ON caixa FOR UPDATE TO authenticated USING (user_id = auth.uid());
CREATE POLICY "caixa_delete_user" ON caixa FOR DELETE TO authenticated USING (user_id = auth.uid());

-- Trigger caixa
DROP TRIGGER IF EXISTS trigger_set_user_id_caixa ON caixa;
CREATE TRIGGER trigger_set_user_id_caixa
  BEFORE INSERT ON caixa
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_user_id_clientes();

-- ========== ORDEM_SERVICO (se existir) ==========
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'ordem_servico') THEN
    EXECUTE 'DROP POLICY IF EXISTS "ordem_servico_select_user" ON ordem_servico';
    EXECUTE 'DROP POLICY IF EXISTS "ordem_servico_insert_user" ON ordem_servico';
    EXECUTE 'DROP POLICY IF EXISTS "ordem_servico_update_user" ON ordem_servico';
    EXECUTE 'DROP POLICY IF EXISTS "ordem_servico_delete_user" ON ordem_servico';
    
    EXECUTE 'CREATE POLICY "ordem_servico_select_user" ON ordem_servico FOR SELECT TO authenticated USING (user_id = auth.uid())';
    EXECUTE 'CREATE POLICY "ordem_servico_insert_user" ON ordem_servico FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid())';
    EXECUTE 'CREATE POLICY "ordem_servico_update_user" ON ordem_servico FOR UPDATE TO authenticated USING (user_id = auth.uid())';
    EXECUTE 'CREATE POLICY "ordem_servico_delete_user" ON ordem_servico FOR DELETE TO authenticated USING (user_id = auth.uid())';
    
    EXECUTE 'DROP TRIGGER IF EXISTS trigger_set_user_id_ordem_servico ON ordem_servico';
    EXECUTE 'CREATE TRIGGER trigger_set_user_id_ordem_servico BEFORE INSERT ON ordem_servico FOR EACH ROW EXECUTE FUNCTION auto_set_user_id_clientes()';
  END IF;
END $$;

-- =====================================================
-- 🔧 CORRIGIR DADOS ÓRFÃOS (SEM user_id)
-- =====================================================

-- Ver totais de registros órfãos
SELECT 'CLIENTES SEM USER_ID' as tabela, COUNT(*) as total FROM clientes WHERE user_id IS NULL
UNION ALL
SELECT 'PRODUTOS SEM USER_ID', COUNT(*) FROM produtos WHERE user_id IS NULL
UNION ALL
SELECT 'VENDAS SEM USER_ID', COUNT(*) FROM vendas WHERE user_id IS NULL
UNION ALL
SELECT 'CAIXA SEM USER_ID', COUNT(*) FROM caixa WHERE user_id IS NULL;

-- ⚠️ ATENÇÃO: Só execute se você for o ÚNICO usuário do sistema!
-- Associa todos os registros órfãos ao usuário logado

/*
-- Obter seu user_id primeiro:
SELECT auth.uid() as meu_user_id;

-- Depois, atualize (descomente para executar):
UPDATE clientes SET user_id = auth.uid() WHERE user_id IS NULL;
UPDATE produtos SET user_id = auth.uid() WHERE user_id IS NULL;
UPDATE vendas SET user_id = auth.uid() WHERE user_id IS NULL;
UPDATE caixa SET user_id = auth.uid() WHERE user_id IS NULL;
*/

-- OU atualizar para um user_id específico:
/*
UPDATE clientes SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' WHERE user_id IS NULL;
UPDATE produtos SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' WHERE user_id IS NULL;
UPDATE vendas SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' WHERE user_id IS NULL;
UPDATE caixa SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' WHERE user_id IS NULL;
*/

-- =====================================================
-- ✅ VERIFICAÇÃO FINAL
-- =====================================================

SELECT 
    'RESUMO FINAL' as info,
    (SELECT COUNT(*) FROM clientes WHERE user_id = auth.uid()) as meus_clientes,
    (SELECT COUNT(*) FROM produtos WHERE user_id = auth.uid()) as meus_produtos,
    (SELECT COUNT(*) FROM vendas WHERE user_id = auth.uid()) as minhas_vendas,
    (SELECT COUNT(*) FROM caixa WHERE user_id = auth.uid()) as meus_caixas;
