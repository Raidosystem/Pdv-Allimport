-- =====================================================
-- 🔒 PARTE 2 - PREENCHER DADOS E CRIAR TRIGGERS
-- =====================================================
-- Execute DEPOIS da PARTE 1
-- =====================================================

-- =====================================================
-- PREENCHER EMPRESA_ID NOS DADOS EXISTENTES
-- =====================================================

-- ORDENS_SERVICO
UPDATE ordens_servico os
SET empresa_id = e.id
FROM empresas e
WHERE os.empresa_id IS NULL
  AND os.usuario_id IS NOT NULL
  AND e.user_id = os.usuario_id;

-- PRODUTOS
UPDATE produtos p
SET empresa_id = e.id
FROM empresas e
WHERE p.empresa_id IS NULL
  AND p.user_id IS NOT NULL
  AND e.user_id = p.user_id;

-- VENDAS
UPDATE vendas v
SET empresa_id = e.id
FROM empresas e
WHERE v.empresa_id IS NULL
  AND v.user_id IS NOT NULL
  AND e.user_id = v.user_id;

-- CAIXA
UPDATE caixa cx
SET empresa_id = e.id
FROM empresas e
WHERE cx.empresa_id IS NULL
  AND cx.user_id IS NOT NULL
  AND e.user_id = cx.user_id;

-- =====================================================
-- CRIAR TRIGGER UNIVERSAL
-- =====================================================

CREATE OR REPLACE FUNCTION auto_set_empresa_id()
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

-- Aplicar triggers
DROP TRIGGER IF EXISTS trigger_auto_empresa_id_ordens ON ordens_servico;
CREATE TRIGGER trigger_auto_empresa_id_ordens
  BEFORE INSERT ON ordens_servico
  FOR EACH ROW EXECUTE FUNCTION auto_set_empresa_id();

DROP TRIGGER IF EXISTS trigger_auto_empresa_id_produtos ON produtos;
CREATE TRIGGER trigger_auto_empresa_id_produtos
  BEFORE INSERT ON produtos
  FOR EACH ROW EXECUTE FUNCTION auto_set_empresa_id();

DROP TRIGGER IF EXISTS trigger_auto_empresa_id_vendas ON vendas;
CREATE TRIGGER trigger_auto_empresa_id_vendas
  BEFORE INSERT ON vendas
  FOR EACH ROW EXECUTE FUNCTION auto_set_empresa_id();

DROP TRIGGER IF EXISTS trigger_auto_empresa_id_caixa ON caixa;
CREATE TRIGGER trigger_auto_empresa_id_caixa
  BEFORE INSERT ON caixa
  FOR EACH ROW EXECUTE FUNCTION auto_set_empresa_id();

-- ✅ Concluído! Execute PARTE 3
