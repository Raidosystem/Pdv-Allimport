-- ============================================
-- CORRIGIR ERRO AO ABRIR CAIXA
-- ============================================

-- 🎯 PROBLEMA:
-- RLS está bloqueando a abertura de caixa porque empresa_id não está sendo preenchido automaticamente

-- ============================================
-- ETAPA 1: CRIAR TRIGGER PARA PREENCHER empresa_id E user_id AUTOMATICAMENTE
-- ============================================

-- Função que preenche empresa_id e user_id antes de inserir
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
-- ETAPA 2: APLICAR TRIGGERS EM TODAS AS TABELAS
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
-- ETAPA 3: VERIFICAR SE TABELA CAIXA EXISTE E TEM ESTRUTURA CORRETA
-- ============================================

-- Ver estrutura da tabela caixa
SELECT 
  '📋 ESTRUTURA DA TABELA CAIXA' as info,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'caixa'
ORDER BY ordinal_position;

-- ============================================
-- ETAPA 4: VERIFICAR SE RLS ESTÁ CONFIGURADO CORRETAMENTE
-- ============================================

-- Ver políticas RLS do caixa
SELECT 
  '🔒 POLÍTICAS RLS - CAIXA' as info,
  policyname,
  cmd,
  permissive
FROM pg_policies
WHERE tablename = 'caixa';

-- ============================================
-- ETAPA 5: VERIFICAR SE USUÁRIO TEM EMPRESA
-- ============================================

-- Ver empresas cadastradas
SELECT 
  '🏢 EMPRESAS CADASTRADAS' as info,
  e.id,
  e.nome,
  au.email as dono
FROM empresas e
JOIN auth.users au ON au.id = e.user_id
ORDER BY e.nome;

-- ============================================
-- ETAPA 6: TESTAR SE EMPRESA_ID ESTÁ SENDO PREENCHIDA
-- ============================================

-- Verificar se a função get_user_empresa_id() funciona
SELECT 
  '🔍 TESTE: get_user_empresa_id()' as info,
  get_user_empresa_id() as empresa_id_do_usuario_atual;

-- ============================================
-- RESULTADO ESPERADO:
-- ============================================
-- ✅ Função auto_fill_empresa_user_id() criada
-- ✅ Triggers aplicados em todas as tabelas
-- ✅ Tabela caixa existe com colunas empresa_id e user_id
-- ✅ Políticas RLS configuradas
-- ✅ Usuário tem empresa cadastrada
-- ✅ get_user_empresa_id() retorna UUID válido
-- ============================================

SELECT '✅ TRIGGERS CRIADOS! Agora tente abrir o caixa novamente.' as resultado;

-- ============================================
-- 🎯 TESTE MANUAL (OPCIONAL)
-- ============================================
-- Após executar este script, tente abrir o caixa no sistema.
-- O empresa_id e user_id serão preenchidos automaticamente!
