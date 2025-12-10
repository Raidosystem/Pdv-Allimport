-- =====================================================
-- 🔒 PARTE 1 - ADICIONAR COLUNAS E ÍNDICES
-- =====================================================
-- Execute esta parte PRIMEIRO
-- =====================================================

-- ORDENS_SERVICO
ALTER TABLE ordens_servico 
  ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id);
CREATE INDEX IF NOT EXISTS idx_ordens_servico_empresa_id ON ordens_servico(empresa_id);

-- PRODUTOS
ALTER TABLE produtos 
  ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id);
CREATE INDEX IF NOT EXISTS idx_produtos_empresa_id ON produtos(empresa_id);

-- VENDAS
ALTER TABLE vendas 
  ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id);
CREATE INDEX IF NOT EXISTS idx_vendas_empresa_id ON vendas(empresa_id);

-- CAIXA
ALTER TABLE caixa 
  ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id);
CREATE INDEX IF NOT EXISTS idx_caixa_empresa_id ON caixa(empresa_id);

-- ✅ Concluído! Execute PARTE 2
