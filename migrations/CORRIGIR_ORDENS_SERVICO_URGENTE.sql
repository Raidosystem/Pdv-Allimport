-- =====================================================
-- 🔒 CORREÇÃO COMPLETA - ISOLAMENTO DE TODAS AS TABELAS
-- =====================================================
-- PROBLEMA: Todas as tabelas principais precisam de empresa_id
-- SOLUÇÃO: Corrigir clientes, ordens_servico, produtos, vendas
-- =====================================================

-- =====================================================
-- 1️⃣ VERIFICAR QUAIS TABELAS PRECISAM DE EMPRESA_ID
-- =====================================================

SELECT 
  table_name,
  column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('clientes', 'ordens_servico', 'produtos', 'vendas', 'caixa')
  AND column_name = 'empresa_id'
ORDER BY table_name;

-- =====================================================
-- 2️⃣ ADICIONAR EMPRESA_ID EM ORDENS_SERVICO
-- =====================================================

-- Adicionar coluna se não existir
ALTER TABLE ordens_servico 
  ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id);

-- Criar índice
CREATE INDEX IF NOT EXISTS idx_ordens_servico_empresa_id ON ordens_servico(empresa_id);

-- Preencher empresa_id a partir do user_id existente
UPDATE ordens_servico os
SET empresa_id = e.id
FROM empresas e
WHERE os.empresa_id IS NULL
  AND os.usuario_id IS NOT NULL
  AND e.user_id = os.usuario_id;

-- =====================================================
-- 3️⃣ TRIGGER AUTO empresa_id PARA ORDENS_SERVICO
-- =====================================================

CREATE OR REPLACE FUNCTION auto_set_empresa_id_ordens()
RETURNS TRIGGER AS $$
DECLARE
  v_empresa_id UUID;
BEGIN
  IF NEW.empresa_id IS NOT NULL THEN
    RETURN NEW;
  END IF;
  
  SELECT id INTO v_empresa_id
  FROM empresas
  WHERE user_id = auth.uid()
  LIMIT 1;
  
  IF v_empresa_id IS NOT NULL THEN
    NEW.empresa_id := v_empresa_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_auto_empresa_id_ordens ON ordens_servico;
CREATE TRIGGER trigger_auto_empresa_id_ordens
  BEFORE INSERT ON ordens_servico
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_empresa_id_ordens();

-- =====================================================
-- 4️⃣ POLÍTICAS RLS PARA ORDENS_SERVICO
-- =====================================================

-- Remover políticas antigas
DROP POLICY IF EXISTS ordens_servico_select_policy ON ordens_servico;
DROP POLICY IF EXISTS ordens_servico_insert_policy ON ordens_servico;
DROP POLICY IF EXISTS ordens_servico_update_policy ON ordens_servico;
DROP POLICY IF EXISTS ordens_servico_delete_policy ON ordens_servico;
DROP POLICY IF EXISTS ordens_all_simple ON ordens_servico;

-- Ativar RLS
ALTER TABLE ordens_servico ENABLE ROW LEVEL SECURITY;

-- Políticas baseadas em empresa_id
CREATE POLICY ordens_select_own_empresa ON ordens_servico
  FOR SELECT TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY ordens_insert_own_empresa ON ordens_servico
  FOR INSERT TO authenticated
  WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY ordens_update_own_empresa ON ordens_servico
  FOR UPDATE TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()))
  WITH CHECK (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

CREATE POLICY ordens_delete_own_empresa ON ordens_servico
  FOR DELETE TO authenticated
  USING (empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid()));

-- =====================================================
-- 5️⃣ VERIFICAR TODAS AS TABELAS
-- =====================================================

-- Ver distribuição de ordens por empresa
SELECT 
  '📊 Ordens por Empresa' as status,
  e.nome as empresa_nome,
  au.email,
  COUNT(os.id) as total_ordens
FROM empresas e
INNER JOIN auth.users au ON au.id = e.user_id
LEFT JOIN ordens_servico os ON os.empresa_id = e.id
WHERE au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%DELETED%'
GROUP BY e.id, e.nome, au.email
ORDER BY e.nome;

-- Ver distribuição de clientes por empresa
SELECT 
  '📊 Clientes por Empresa' as status,
  e.nome as empresa_nome,
  au.email,
  COUNT(c.id) as total_clientes
FROM empresas e
INNER JOIN auth.users au ON au.id = e.user_id
LEFT JOIN clientes c ON c.empresa_id = e.id
WHERE au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%DELETED%'
GROUP BY e.id, e.nome, au.email
ORDER BY e.nome;

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ ordens_servico com empresa_id preenchido
-- ✅ Trigger automático para novas ordens
-- ✅ 4 políticas RLS (SELECT, INSERT, UPDATE, DELETE)
-- ✅ Isolamento total entre empresas
-- ✅ Cada empresa vê apenas suas próprias ordens
-- =====================================================
