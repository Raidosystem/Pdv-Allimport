-- =====================================================
-- 🎯 LIMPEZA SILENCIOSA - SEM TABELAS DE DEBUG
-- =====================================================
-- Versão sem exibir tabelas de debug/integridade
-- =====================================================

-- APENAS A LIMPEZA ESSENCIAL - SEM RELATÓRIOS VISUAIS

-- 1️⃣ LIMPEZA DE EMPRESAS SEM USER_ID
DELETE FROM vendas WHERE empresa_id IN (SELECT id FROM empresas WHERE user_id IS NULL);
DELETE FROM ordens_servico WHERE empresa_id IN (SELECT id FROM empresas WHERE user_id IS NULL);
DELETE FROM caixa WHERE empresa_id IN (SELECT id FROM empresas WHERE user_id IS NULL);
DELETE FROM produtos WHERE empresa_id IN (SELECT id FROM empresas WHERE user_id IS NULL);
DELETE FROM clientes WHERE empresa_id IN (SELECT id FROM empresas WHERE user_id IS NULL);
DELETE FROM fornecedores WHERE empresa_id IN (SELECT id FROM empresas WHERE user_id IS NULL);
DELETE FROM funcionarios WHERE empresa_id IN (SELECT id FROM empresas WHERE user_id IS NULL);
DELETE FROM empresas WHERE user_id IS NULL;

-- 2️⃣ LIMPEZA DE DADOS ÓRFÃOS
DELETE FROM produtos WHERE empresa_id NOT IN (SELECT id FROM empresas);
DELETE FROM clientes WHERE empresa_id NOT IN (SELECT id FROM empresas);
DELETE FROM fornecedores WHERE empresa_id NOT IN (SELECT id FROM empresas);
DELETE FROM funcionarios WHERE empresa_id NOT IN (SELECT id FROM empresas);
DELETE FROM vendas WHERE empresa_id NOT IN (SELECT id FROM empresas);
DELETE FROM ordens_servico WHERE empresa_id NOT IN (SELECT id FROM empresas);
DELETE FROM caixa WHERE empresa_id NOT IN (SELECT id FROM empresas);

-- 3️⃣ LIMPEZA DE DADOS DE TESTE
DELETE FROM produtos WHERE nome ILIKE '%teste%' OR codigo_barras IN ('7891234567890', '1234567890123', '0000000000000');
DELETE FROM clientes WHERE nome ILIKE '%teste%' OR email LIKE '%@example.com' OR cpf_cnpj IN ('000.000.000-00', '111.111.111-11');
DELETE FROM fornecedores WHERE nome ILIKE '%teste%' OR email LIKE '%@example.com' OR cnpj IN ('00.000.000/0000-00', '11.111.111/1111-11');

-- 4️⃣ RESETAR SEQUÊNCIAS (SEM FEEDBACK VISUAL)
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'funcionarios_id_seq') THEN
    PERFORM setval('funcionarios_id_seq', COALESCE((SELECT MAX(id) FROM funcionarios), 1));
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'produtos_id_seq') THEN
    PERFORM setval('produtos_id_seq', COALESCE((SELECT MAX(id) FROM produtos), 1));
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'clientes_id_seq') THEN
    PERFORM setval('clientes_id_seq', COALESCE((SELECT MAX(id) FROM clientes), 1));
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'fornecedores_id_seq') THEN
    PERFORM setval('fornecedores_id_seq', COALESCE((SELECT MAX(id) FROM fornecedores), 1));
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'vendas_id_seq') THEN
    PERFORM setval('vendas_id_seq', COALESCE((SELECT MAX(id) FROM vendas), 1));
  END IF;
  
  IF EXISTS (SELECT 1 FROM pg_sequences WHERE sequencename = 'ordens_servico_id_seq') THEN
    PERFORM setval('ordens_servico_id_seq', COALESCE((SELECT MAX(id) FROM ordens_servico), 1));
  END IF;
END $$;

-- 5️⃣ CONFIRMAÇÃO SILENCIOSA
SELECT '✅ Limpeza concluída com sucesso!' as resultado;