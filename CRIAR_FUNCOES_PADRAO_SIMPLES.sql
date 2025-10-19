-- =====================================================
-- CRIAR FUNÇÕES PADRÃO (VERSÃO COM EMPRESA_ID)
-- =====================================================
-- ⚠️ IMPORTANTE: Substitua 'SEU_EMPRESA_ID_AQUI' pelo ID da sua empresa
-- Para descobrir seu empresa_id, execute:
-- SELECT id, nome FROM empresas WHERE user_id = auth.uid();
-- =====================================================

-- =====================================================
-- CONFIGURAÇÃO: Defina o empresa_id
-- =====================================================
DO $$ 
DECLARE
  v_empresa_id UUID;
BEGIN
  -- 🔧 OPÇÃO 1: Pegar a primeira empresa encontrada (se você tem apenas 1)
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  
  -- 🔧 OPÇÃO 2: Se você sabe o user_id, descomente a linha abaixo:
  -- SELECT id INTO v_empresa_id FROM empresas WHERE user_id = 'SEU-USER-ID-AQUI';
  
  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION '❌ Nenhuma empresa encontrada! Crie uma empresa primeiro.';
  END IF;
  
  RAISE NOTICE '✅ Usando empresa_id: %', v_empresa_id;
  
  -- Limpar funções padrão antigas (se existirem)
  DELETE FROM funcao_permissoes WHERE funcao_id IN (
    SELECT id FROM funcoes 
    WHERE empresa_id = v_empresa_id 
    AND nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico')
  );

  DELETE FROM funcoes 
  WHERE empresa_id = v_empresa_id 
  AND nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico');

  -- =====================================================
  -- 1. ADMINISTRADOR
  -- =====================================================
  INSERT INTO funcoes (empresa_id, nome, descricao, nivel)
  VALUES (
    v_empresa_id,
    'Administrador',
    'Acesso total ao sistema. Pode gerenciar todas as funcionalidades, usuários, configurações e realizar qualquer operação.',
    10
  );

  -- =====================================================
  -- 2. GERENTE
  -- =====================================================
  INSERT INTO funcoes (empresa_id, nome, descricao, nivel)
  VALUES (
    v_empresa_id,
    'Gerente',
    'Gerenciamento completo da loja. Pode visualizar relatórios, gerenciar estoque, produtos, clientes e supervisionar vendas.',
    8
  );

  -- =====================================================
  -- 3. VENDEDOR
  -- =====================================================
  INSERT INTO funcoes (empresa_id, nome, descricao, nivel)
  VALUES (
    v_empresa_id,
    'Vendedor',
    'Responsável por vendas. Pode realizar vendas, consultar produtos, cadastrar clientes e emitir recibos.',
    5
  );

  -- =====================================================
  -- 4. CAIXA
  -- =====================================================
  INSERT INTO funcoes (empresa_id, nome, descricao, nivel)
  VALUES (
    v_empresa_id,
    'Caixa',
    'Operação de caixa. Pode abrir/fechar caixa, processar vendas, receber pagamentos e gerar relatórios de caixa.',
    4
  );

  -- =====================================================
  -- 5. TÉCNICO
  -- =====================================================
  INSERT INTO funcoes (empresa_id, nome, descricao, nivel)
  VALUES (
    v_empresa_id,
    'Técnico',
    'Gerenciamento de assistência técnica. Pode criar ordens de serviço, gerenciar equipamentos e atualizar status de reparos.',
    6
  );

  RAISE NOTICE '🎉 5 funções padrão criadas com sucesso!';
END $$;

-- =====================================================
-- VERIFICAÇÃO
-- =====================================================
-- Mostrar as funções criadas
SELECT 
  id,
  nome,
  descricao,
  nivel
FROM funcoes
WHERE nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico')
ORDER BY nivel DESC;

-- =====================================================
-- RESULTADO ESPERADO:
-- =====================================================
-- ✅ 5 funções criadas com sucesso
-- 
-- | id | nome          | descricao                       | nivel |
-- |----|---------------|---------------------------------|-------|
-- | xx | Administrador | Acesso total ao sistema...      | 10    |
-- | xx | Gerente       | Gerenciamento completo...       | 8     |
-- | xx | Técnico       | Gerenciamento assistência...    | 6     |
-- | xx | Vendedor      | Responsável por vendas...       | 5     |
-- | xx | Caixa         | Operação de caixa...            | 4     |
--
-- ✅ Hierarquia: Administrador(10) > Gerente(8) > Técnico(6) > Vendedor(5) > Caixa(4)
-- ✅ SEM permissões atribuídas (usuário ativa manualmente na interface)
-- ✅ Pronto para uso!
-- =====================================================
