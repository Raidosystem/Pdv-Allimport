-- 🎯 ADICIONAR CAMPO PARA IDENTIFICAR TIPO DE CONTA

-- ====================================
-- PROBLEMA ATUAL:
-- ====================================
-- Não tem como distinguir claramente:
-- 1. Empresa que COMPROU o sistema (cliente pagante)
-- 2. Empresa em TESTE/TRIAL (gratuito temporário)
-- 3. Empresa de DEMONSTRAÇÃO (para mostrar o sistema)

-- ====================================
-- SOLUÇÃO: Adicionar coluna 'tipo_conta' na tabela empresas
-- ====================================

-- 1. Adicionar coluna tipo_conta
ALTER TABLE empresas 
ADD COLUMN IF NOT EXISTS tipo_conta VARCHAR(30) DEFAULT 'teste_ativo';

-- Valores possíveis:
-- 'assinatura_ativa' = Cliente com mensalidade paga e ativa
-- 'teste_ativo' = Período de teste/trial (30 dias gratuito)
-- 'funcionarios' = Contas de funcionários/colaboradores

-- 2. Adicionar coluna data_cadastro se não existir
ALTER TABLE empresas 
ADD COLUMN IF NOT EXISTS data_cadastro TIMESTAMPTZ DEFAULT NOW();

-- 3. Adicionar coluna data_fim_teste (para contas em teste)
ALTER TABLE empresas 
ADD COLUMN IF NOT EXISTS data_fim_teste TIMESTAMPTZ;

-- 4. Atualizar empresas existentes como 'teste_ativo' por padrão
-- (Você pode alterar manualmente depois para 'assinatura_ativa' ou 'funcionarios')
UPDATE empresas
SET tipo_conta = 'teste_ativo'
WHERE tipo_conta IS NULL;

-- 5. Criar índice para buscar por tipo de conta
CREATE INDEX IF NOT EXISTS idx_empresas_tipo_conta 
ON empresas(tipo_conta);

-- ====================================
-- 6. VERIFICAR RESULTADO
-- ====================================
SELECT 
  '✅ EMPRESAS ORGANIZADAS' as status,
  tipo_conta,
  COUNT(*) as quantidade,
  STRING_AGG(nome, ', ') as empresas
FROM empresas
GROUP BY tipo_conta
ORDER BY 
  CASE tipo_conta
    WHEN 'assinatura_ativa' THEN 1
    WHEN 'teste_ativo' THEN 2
    WHEN 'funcionarios' THEN 3
  END;

-- ====================================
-- 7. VER ESTRUTURA COMPLETA
-- ====================================
SELECT 
  '📊 CADASTROS ORGANIZADOS' as tipo,
  e.nome as empresa,
  e.tipo_conta,
  e.data_cadastro,
  COUNT(CASE WHEN f.tipo_admin = 'admin_empresa' THEN 1 END) as admins,
  COUNT(CASE WHEN f.tipo_admin != 'admin_empresa' THEN 1 END) as funcionarios
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
GROUP BY e.id, e.nome, e.tipo_conta, e.data_cadastro
ORDER BY 
  CASE e.tipo_conta
    WHEN 'assinatura_ativa' THEN 1
    WHEN 'teste_ativo' THEN 2
    WHEN 'funcionarios' THEN 3
  END,
  e.nome;
