-- ============================================
-- ATIVAR RLS EM TODAS AS TABELAS - ISOLAMENTO COMPLETO
-- ============================================

-- 🎯 OBJETIVO:
-- Cada usuário (empresa) vê APENAS seus próprios dados
-- Cristiano vê apenas dados do Grupo RaVal
-- Assistência All-Import vê apenas seus próprios dados

-- ============================================
-- ETAPA 1: VERIFICAR E ADICIONAR COLUNAS NECESSÁRIAS
-- ============================================

-- Garantir que todas as tabelas têm empresa_id
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE vendas ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE vendas_itens ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE caixa ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE movimentacoes_caixa ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE;
ALTER TABLE ordens_servico ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE;

-- Garantir que todas as tabelas têm user_id
ALTER TABLE produtos ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE vendas ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE vendas_itens ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE caixa ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE movimentacoes_caixa ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE ordens_servico ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- ============================================
-- ETAPA 2: PREENCHER empresa_id EM DADOS EXISTENTES
-- ============================================

-- Para cada usuário, encontrar sua empresa e atualizar os dados

-- Assistência All-Import
UPDATE produtos SET empresa_id = (
  SELECT id FROM empresas WHERE user_id = (
    SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
  )
) WHERE user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com');

UPDATE clientes SET empresa_id = (
  SELECT id FROM empresas WHERE user_id = (
    SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com'
  )
) WHERE user_id = (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com');

-- Cristiano
UPDATE produtos SET empresa_id = (
  SELECT id FROM empresas WHERE user_id = (
    SELECT id FROM auth.users WHERE email = 'cristiano@gruporaval.com.br'
  )
) WHERE user_id = (SELECT id FROM auth.users WHERE email = 'cristiano@gruporaval.com.br');

UPDATE clientes SET empresa_id = (
  SELECT id FROM empresas WHERE user_id = (
    SELECT id FROM auth.users WHERE email = 'cristiano@gruporaval.com.br'
  )
) WHERE user_id = (SELECT id FROM auth.users WHERE email = 'cristiano@gruporaval.com.br');

-- ============================================
-- ETAPA 3: REMOVER TODAS AS POLÍTICAS ANTIGAS
-- ============================================

-- PRODUTOS
DROP POLICY IF EXISTS "produtos_select_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_insert_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_update_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_delete_policy" ON produtos;
DROP POLICY IF EXISTS "produtos_isolamento_total" ON produtos;
DROP POLICY IF EXISTS "Enable read access for all users" ON produtos;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON produtos;
DROP POLICY IF EXISTS "Users can view produtos" ON produtos;
DROP POLICY IF EXISTS "rls_isolamento_produtos" ON produtos;

-- CLIENTES
DROP POLICY IF EXISTS "clientes_select_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_insert_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_update_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_delete_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_isolamento_total" ON clientes;
DROP POLICY IF EXISTS "Users can view all clientes" ON clientes;
DROP POLICY IF EXISTS "rls_isolamento_clientes" ON clientes;

-- VENDAS
DROP POLICY IF EXISTS "vendas_select_policy" ON vendas;
DROP POLICY IF EXISTS "vendas_insert_policy" ON vendas;
DROP POLICY IF EXISTS "vendas_update_policy" ON vendas;
DROP POLICY IF EXISTS "vendas_delete_policy" ON vendas;
DROP POLICY IF EXISTS "rls_isolamento_vendas" ON vendas;

-- VENDAS_ITENS
DROP POLICY IF EXISTS "vendas_itens_select_policy" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_insert_policy" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_update_policy" ON vendas_itens;
DROP POLICY IF EXISTS "vendas_itens_delete_policy" ON vendas_itens;

-- CAIXA
DROP POLICY IF EXISTS "caixa_select_policy" ON caixa;
DROP POLICY IF EXISTS "caixa_insert_policy" ON caixa;
DROP POLICY IF EXISTS "caixa_update_policy" ON caixa;
DROP POLICY IF EXISTS "caixa_delete_policy" ON caixa;
DROP POLICY IF EXISTS "rls_isolamento_caixa" ON caixa;

-- ORDENS_SERVICO
DROP POLICY IF EXISTS "ordens_servico_select_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_insert_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_update_policy" ON ordens_servico;
DROP POLICY IF EXISTS "ordens_servico_delete_policy" ON ordens_servico;

-- ============================================
-- ETAPA 4: ATIVAR RLS EM TODAS AS TABELAS
-- ============================================

ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendas_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE movimentacoes_caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;

-- ============================================
-- ETAPA 5: CRIAR POLÍTICAS DE ISOLAMENTO POR EMPRESA
-- ============================================

-- FUNÇÃO HELPER: Pegar empresa_id do usuário logado
CREATE OR REPLACE FUNCTION get_user_empresa_id()
RETURNS UUID AS $$
BEGIN
  RETURN (SELECT id FROM empresas WHERE user_id = auth.uid() LIMIT 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ==================== PRODUTOS ====================
CREATE POLICY "produtos_empresa_isolation" ON produtos
  FOR ALL
  TO authenticated
  USING (empresa_id = get_user_empresa_id())
  WITH CHECK (empresa_id = get_user_empresa_id());

-- ==================== CLIENTES ====================
CREATE POLICY "clientes_empresa_isolation" ON clientes
  FOR ALL
  TO authenticated
  USING (empresa_id = get_user_empresa_id())
  WITH CHECK (empresa_id = get_user_empresa_id());

-- ==================== VENDAS ====================
CREATE POLICY "vendas_empresa_isolation" ON vendas
  FOR ALL
  TO authenticated
  USING (empresa_id = get_user_empresa_id())
  WITH CHECK (empresa_id = get_user_empresa_id());

-- ==================== VENDAS_ITENS ====================
CREATE POLICY "vendas_itens_empresa_isolation" ON vendas_itens
  FOR ALL
  TO authenticated
  USING (empresa_id = get_user_empresa_id())
  WITH CHECK (empresa_id = get_user_empresa_id());

-- ==================== CAIXA ====================
CREATE POLICY "caixa_empresa_isolation" ON caixa
  FOR ALL
  TO authenticated
  USING (empresa_id = get_user_empresa_id())
  WITH CHECK (empresa_id = get_user_empresa_id());

-- ==================== MOVIMENTACOES_CAIXA ====================
CREATE POLICY "movimentacoes_caixa_empresa_isolation" ON movimentacoes_caixa
  FOR ALL
  TO authenticated
  USING (empresa_id = get_user_empresa_id())
  WITH CHECK (empresa_id = get_user_empresa_id());

-- ==================== ORDENS_SERVICO ====================
CREATE POLICY "ordens_servico_empresa_isolation" ON ordens_servico
  FOR ALL
  TO authenticated
  USING (empresa_id = get_user_empresa_id())
  WITH CHECK (empresa_id = get_user_empresa_id());

-- ==================== EMPRESAS ====================
-- Cada usuário vê apenas sua própria empresa
CREATE POLICY "empresas_own_only" ON empresas
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ==================== FUNCIONARIOS ====================
-- Cada empresa vê apenas seus próprios funcionários
CREATE POLICY "funcionarios_empresa_isolation" ON funcionarios
  FOR ALL
  TO authenticated
  USING (empresa_id = get_user_empresa_id())
  WITH CHECK (empresa_id = get_user_empresa_id());

-- ============================================
-- ETAPA 6: VERIFICAR ATIVAÇÃO
-- ============================================

SELECT 
  '✅ VERIFICAÇÃO FINAL - RLS ATIVO' as status,
  tablename,
  CASE WHEN rowsecurity THEN '✅ ATIVO' ELSE '❌ DESATIVADO' END as rls_status
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename IN (
  'produtos', 'clientes', 'vendas', 'vendas_itens', 
  'caixa', 'movimentacoes_caixa', 'ordens_servico',
  'empresas', 'funcionarios'
)
ORDER BY tablename;

-- ============================================
-- ETAPA 7: VERIFICAR POLÍTICAS CRIADAS
-- ============================================

SELECT 
  '✅ POLÍTICAS CRIADAS' as status,
  tablename,
  policyname,
  cmd as tipo_comando
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN (
  'produtos', 'clientes', 'vendas', 'vendas_itens', 
  'caixa', 'movimentacoes_caixa', 'ordens_servico',
  'empresas', 'funcionarios'
)
ORDER BY tablename, policyname;

-- ============================================
-- RESULTADO ESPERADO:
-- ✅ Todas as tabelas com RLS ATIVO
-- ✅ Uma política de isolamento por tabela
-- ✅ Cada usuário vê APENAS dados da sua empresa
-- ✅ Cristiano vê apenas Grupo RaVal
-- ✅ Assistência vê apenas Assistência All-Import
-- ============================================

SELECT '🎉 RLS ATIVADO EM TODAS AS TABELAS COM ISOLAMENTO TOTAL POR EMPRESA!' as resultado;
