-- =====================================================
-- ADICIONAR user_id EM TODAS AS TABELAS
-- =====================================================
-- Primeiro: Adiciona coluna user_id onde não existe
-- Depois: Configura RLS correto
-- =====================================================

-- 📊 DIAGNÓSTICO: Ver quais tabelas TÊM user_id
-- =====================================================
SELECT 
    t.table_name,
    CASE 
        WHEN c.column_name IS NOT NULL THEN '✅ TEM'
        ELSE '❌ FALTA'
    END as tem_user_id
FROM information_schema.tables t
LEFT JOIN information_schema.columns c 
    ON c.table_name = t.table_name 
    AND c.column_name = 'user_id'
WHERE t.table_schema = 'public'
AND t.table_type = 'BASE TABLE'
AND t.table_name IN ('clientes', 'produtos', 'vendas', 'vendas_itens', 'caixa', 'ordem_servico', 'movimentacoes_caixa')
ORDER BY t.table_name;

-- =====================================================
-- 🔧 ADICIONAR user_id EM TODAS AS TABELAS
-- =====================================================

-- CLIENTES
ALTER TABLE clientes 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- PRODUTOS
ALTER TABLE produtos 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- VENDAS
ALTER TABLE vendas 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- VENDAS_ITENS
ALTER TABLE vendas_itens 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- CAIXA
ALTER TABLE caixa 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- MOVIMENTACOES_CAIXA (se existir)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'movimentacoes_caixa') THEN
    EXECUTE 'ALTER TABLE movimentacoes_caixa ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE';
  END IF;
END $$;

-- ORDEM_SERVICO (se existir)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'ordem_servico') THEN
    EXECUTE 'ALTER TABLE ordem_servico ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE';
  END IF;
END $$;

-- =====================================================
-- 🔧 CRIAR FUNÇÃO UNIVERSAL PARA TRIGGERS
-- =====================================================

CREATE OR REPLACE FUNCTION auto_set_user_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NULL THEN
    NEW.user_id := auth.uid();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 🔧 CRIAR TRIGGERS EM TODAS AS TABELAS
-- =====================================================

-- CLIENTES
DROP TRIGGER IF EXISTS trigger_auto_user_id ON clientes;
CREATE TRIGGER trigger_auto_user_id
  BEFORE INSERT ON clientes
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_user_id();

-- PRODUTOS
DROP TRIGGER IF EXISTS trigger_auto_user_id ON produtos;
CREATE TRIGGER trigger_auto_user_id
  BEFORE INSERT ON produtos
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_user_id();

-- VENDAS
DROP TRIGGER IF EXISTS trigger_auto_user_id ON vendas;
CREATE TRIGGER trigger_auto_user_id
  BEFORE INSERT ON vendas
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_user_id();

-- VENDAS_ITENS (já tem trigger específico, mas garantir)
-- Já foi criado antes: trigger_auto_user_id_vendas_itens

-- CAIXA
DROP TRIGGER IF EXISTS trigger_auto_user_id ON caixa;
CREATE TRIGGER trigger_auto_user_id
  BEFORE INSERT ON caixa
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_user_id();

-- MOVIMENTACOES_CAIXA
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'movimentacoes_caixa') THEN
    EXECUTE 'DROP TRIGGER IF EXISTS trigger_auto_user_id ON movimentacoes_caixa';
    EXECUTE 'CREATE TRIGGER trigger_auto_user_id BEFORE INSERT ON movimentacoes_caixa FOR EACH ROW EXECUTE FUNCTION auto_set_user_id()';
  END IF;
END $$;

-- ORDEM_SERVICO
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'ordem_servico') THEN
    EXECUTE 'DROP TRIGGER IF EXISTS trigger_auto_user_id ON ordem_servico';
    EXECUTE 'CREATE TRIGGER trigger_auto_user_id BEFORE INSERT ON ordem_servico FOR EACH ROW EXECUTE FUNCTION auto_set_user_id()';
  END IF;
END $$;

-- =====================================================
-- 🔧 LIMPAR POLÍTICAS ANTIGAS
-- =====================================================

-- CLIENTES
DO $$
DECLARE
  pol record;
BEGIN
  FOR pol IN 
    SELECT policyname FROM pg_policies WHERE tablename = 'clientes'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON clientes', pol.policyname);
  END LOOP;
END $$;

-- PRODUTOS
DO $$
DECLARE
  pol record;
BEGIN
  FOR pol IN 
    SELECT policyname FROM pg_policies WHERE tablename = 'produtos'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON produtos', pol.policyname);
  END LOOP;
END $$;

-- VENDAS
DO $$
DECLARE
  pol record;
BEGIN
  FOR pol IN 
    SELECT policyname FROM pg_policies WHERE tablename = 'vendas'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON vendas', pol.policyname);
  END LOOP;
END $$;

-- CAIXA
DO $$
DECLARE
  pol record;
BEGIN
  FOR pol IN 
    SELECT policyname FROM pg_policies WHERE tablename = 'caixa'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON caixa', pol.policyname);
  END LOOP;
END $$;

-- =====================================================
-- 🔧 CRIAR POLÍTICAS RLS CORRETAS
-- =====================================================

-- CLIENTES
CREATE POLICY "clientes_all_user" ON clientes FOR ALL TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

-- PRODUTOS
CREATE POLICY "produtos_all_user" ON produtos FOR ALL TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

-- VENDAS
CREATE POLICY "vendas_all_user" ON vendas FOR ALL TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

-- VENDAS_ITENS (via venda)
DROP POLICY IF EXISTS "vendas_itens_all_user" ON vendas_itens;
CREATE POLICY "vendas_itens_all_user" ON vendas_itens FOR ALL TO authenticated 
USING (
  EXISTS (SELECT 1 FROM vendas WHERE vendas.id = vendas_itens.venda_id AND vendas.user_id = auth.uid())
);

-- CAIXA
CREATE POLICY "caixa_all_user" ON caixa FOR ALL TO authenticated 
USING (user_id = auth.uid()) 
WITH CHECK (user_id = auth.uid());

-- =====================================================
-- 🔧 PREENCHER user_id NOS REGISTROS ANTIGOS
-- =====================================================

-- Ver quantos registros estão órfãos
SELECT 
    'ÓRFÃOS POR TABELA' as info,
    (SELECT COUNT(*) FROM clientes WHERE user_id IS NULL) as clientes_sem_user,
    (SELECT COUNT(*) FROM produtos WHERE user_id IS NULL) as produtos_sem_user,
    (SELECT COUNT(*) FROM vendas WHERE user_id IS NULL) as vendas_sem_user,
    (SELECT COUNT(*) FROM caixa WHERE user_id IS NULL) as caixa_sem_user;

-- ⚠️ IMPORTANTE: Só execute se você for o ÚNICO usuário!
-- Obtém o user_id atual
SELECT 
    'MEU USER_ID' as info,
    auth.uid() as user_id;

-- Descomente para atualizar (ou use o user_id específico abaixo):
/*
UPDATE clientes SET user_id = auth.uid() WHERE user_id IS NULL;
UPDATE produtos SET user_id = auth.uid() WHERE user_id IS NULL;
UPDATE vendas SET user_id = auth.uid() WHERE user_id IS NULL;
UPDATE caixa SET user_id = auth.uid() WHERE user_id IS NULL;
*/

-- OU use o user_id específico:
UPDATE clientes SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' WHERE user_id IS NULL;
UPDATE produtos SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' WHERE user_id IS NULL;
UPDATE vendas SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' WHERE user_id IS NULL;
UPDATE caixa SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' WHERE user_id IS NULL;
UPDATE vendas_itens SET user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' WHERE user_id IS NULL;

-- =====================================================
-- ✅ VERIFICAÇÃO FINAL
-- =====================================================

-- 1. Ver estrutura atualizada
SELECT 
    '1. COLUNAS CRIADAS' as etapa,
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name IN ('clientes', 'produtos', 'vendas', 'vendas_itens', 'caixa')
AND column_name = 'user_id';

-- 2. Ver triggers criados
SELECT 
    '2. TRIGGERS' as etapa,
    event_object_table as tabela,
    trigger_name,
    action_timing
FROM information_schema.triggers
WHERE event_object_table IN ('clientes', 'produtos', 'vendas', 'caixa')
AND trigger_schema = 'public'
ORDER BY event_object_table;

-- 3. Ver políticas RLS
SELECT 
    '3. POLÍTICAS RLS' as etapa,
    tablename,
    policyname
FROM pg_policies
WHERE tablename IN ('clientes', 'produtos', 'vendas', 'vendas_itens', 'caixa')
ORDER BY tablename;

-- 4. Ver dados visíveis
SELECT 
    '4. DADOS VISÍVEIS' as etapa,
    (SELECT COUNT(*) FROM clientes WHERE user_id = auth.uid()) as meus_clientes,
    (SELECT COUNT(*) FROM produtos WHERE user_id = auth.uid()) as meus_produtos,
    (SELECT COUNT(*) FROM vendas WHERE user_id = auth.uid()) as minhas_vendas,
    (SELECT COUNT(*) FROM caixa WHERE user_id = auth.uid()) as meus_caixas;

-- 5. Verificar se ainda há órfãos
SELECT 
    '5. ÓRFÃOS RESTANTES' as etapa,
    (SELECT COUNT(*) FROM clientes WHERE user_id IS NULL) as clientes,
    (SELECT COUNT(*) FROM produtos WHERE user_id IS NULL) as produtos,
    (SELECT COUNT(*) FROM vendas WHERE user_id IS NULL) as vendas,
    (SELECT COUNT(*) FROM caixa WHERE user_id IS NULL) as caixa;
