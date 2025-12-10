-- ============================================
-- CORREÇÃO COMPLETA - CAIXA + TRIGGERS + FUNÇÃO
-- ============================================

-- ============================================
-- ETAPA 1: CRIAR FUNÇÃO HELPER get_user_empresa_id()
-- ============================================

CREATE OR REPLACE FUNCTION get_user_empresa_id()
RETURNS UUID AS $$
BEGIN
  RETURN (SELECT id FROM empresas WHERE user_id = auth.uid() LIMIT 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================
-- ETAPA 2: CRIAR FUNÇÃO PARA AUTO-PREENCHER
-- ============================================

CREATE OR REPLACE FUNCTION auto_fill_empresa_user_id()
RETURNS TRIGGER AS $$
BEGIN
  -- Se user_id não foi informado, pegar do auth.uid()
  IF NEW.user_id IS NULL THEN
    NEW.user_id := auth.uid();
  END IF;
  
  -- Se empresa_id não foi informado, pegar da empresa do usuário
  IF NEW.empresa_id IS NULL THEN
    NEW.empresa_id := (SELECT id FROM empresas WHERE user_id = auth.uid() LIMIT 1);
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- ETAPA 3: APLICAR TRIGGERS EM TODAS AS TABELAS
-- ============================================

-- CAIXA
DROP TRIGGER IF EXISTS trigger_auto_fill_caixa ON caixa;
CREATE TRIGGER trigger_auto_fill_caixa
  BEFORE INSERT ON caixa
  FOR EACH ROW
  EXECUTE FUNCTION auto_fill_empresa_user_id();

-- PRODUTOS
DROP TRIGGER IF EXISTS trigger_auto_fill_produtos ON produtos;
CREATE TRIGGER trigger_auto_fill_produtos
  BEFORE INSERT ON produtos
  FOR EACH ROW
  EXECUTE FUNCTION auto_fill_empresa_user_id();

-- CLIENTES
DROP TRIGGER IF EXISTS trigger_auto_fill_clientes ON clientes;
CREATE TRIGGER trigger_auto_fill_clientes
  BEFORE INSERT ON clientes
  FOR EACH ROW
  EXECUTE FUNCTION auto_fill_empresa_user_id();

-- VENDAS
DROP TRIGGER IF EXISTS trigger_auto_fill_vendas ON vendas;
CREATE TRIGGER trigger_auto_fill_vendas
  BEFORE INSERT ON vendas
  FOR EACH ROW
  EXECUTE FUNCTION auto_fill_empresa_user_id();

-- VENDAS_ITENS
DROP TRIGGER IF EXISTS trigger_auto_fill_vendas_itens ON vendas_itens;
CREATE TRIGGER trigger_auto_fill_vendas_itens
  BEFORE INSERT ON vendas_itens
  FOR EACH ROW
  EXECUTE FUNCTION auto_fill_empresa_user_id();

-- MOVIMENTACOES_CAIXA
DROP TRIGGER IF EXISTS trigger_auto_fill_movimentacoes_caixa ON movimentacoes_caixa;
CREATE TRIGGER trigger_auto_fill_movimentacoes_caixa
  BEFORE INSERT ON movimentacoes_caixa
  FOR EACH ROW
  EXECUTE FUNCTION auto_fill_empresa_user_id();

-- ORDENS_SERVICO
DROP TRIGGER IF EXISTS trigger_auto_fill_ordens_servico ON ordens_servico;
CREATE TRIGGER trigger_auto_fill_ordens_servico
  BEFORE INSERT ON ordens_servico
  FOR EACH ROW
  EXECUTE FUNCTION auto_fill_empresa_user_id();

-- ============================================
-- ETAPA 4: VERIFICAÇÃO
-- ============================================

-- 1. Verificar se as funções foram criadas
SELECT 
  '✅ FUNÇÕES CRIADAS' as status,
  routine_name as funcao
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('get_user_empresa_id', 'auto_fill_empresa_user_id')
ORDER BY routine_name;

-- 2. Verificar triggers criados
SELECT 
  '✅ TRIGGERS CRIADOS' as status,
  trigger_name,
  event_object_table as tabela
FROM information_schema.triggers
WHERE trigger_name LIKE 'trigger_auto_fill%'
ORDER BY event_object_table;

-- 3. Ver empresas cadastradas
SELECT 
  '✅ EMPRESAS CADASTRADAS' as status,
  e.id,
  e.nome,
  au.email as dono
FROM empresas e
JOIN auth.users au ON au.id = e.user_id
ORDER BY e.nome;

-- 4. Testar a função (só funciona quando estiver logado no frontend)
SELECT 
  '✅ TESTE: get_user_empresa_id()' as info,
  'Execute este teste depois de fazer login no sistema' as instrucao;

-- ============================================
-- RESULTADO ESPERADO:
-- ============================================
-- ✅ 2 funções criadas (get_user_empresa_id, auto_fill_empresa_user_id)
-- ✅ 7 triggers criados (um para cada tabela)
-- ✅ Empresas listadas corretamente
-- ============================================

SELECT '🎉 CORREÇÃO COMPLETA! Agora faça LOGIN no sistema e tente abrir o caixa.' as resultado;
