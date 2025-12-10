-- =====================================================
-- CRIAR 5 FUNÇÕES PADRÃO - VERSÃO FINAL
-- =====================================================
-- Estrutura da tabela funcoes:
-- - id, empresa_id, nome, descricao, created_at, escopo_lojas, nivel
-- =====================================================

DO $$ 
DECLARE
  v_empresa_id UUID;
BEGIN
  -- 🔧 Pegar a primeira empresa
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  
  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION '❌ Nenhuma empresa encontrada! Crie uma empresa primeiro.';
  END IF;
  
  RAISE NOTICE '✅ Usando empresa_id: %', v_empresa_id;
  
  -- =====================================================
  -- LIMPAR FUNÇÕES PADRÃO ANTIGAS (SE EXISTIREM)
  -- =====================================================
  DELETE FROM funcao_permissoes WHERE funcao_id IN (
    SELECT id FROM funcoes 
    WHERE empresa_id = v_empresa_id
    AND nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico')
  );

  DELETE FROM funcoes 
  WHERE empresa_id = v_empresa_id
  AND nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico');
  
  RAISE NOTICE '🧹 Funções antigas removidas';

  -- =====================================================
  -- CRIAR AS 5 FUNÇÕES PADRÃO
  -- =====================================================
  
  -- 1. ADMINISTRADOR
  INSERT INTO funcoes (empresa_id, nome, descricao, nivel, escopo_lojas)
  VALUES (
    v_empresa_id,
    'Administrador',
    'Acesso total ao sistema. Pode gerenciar todas as funcionalidades, usuários, configurações e realizar qualquer operação.',
    10,
    '[]'::jsonb
  );
  
  -- 2. GERENTE
  INSERT INTO funcoes (empresa_id, nome, descricao, nivel, escopo_lojas)
  VALUES (
    v_empresa_id,
    'Gerente',
    'Gerenciamento completo da loja. Pode visualizar relatórios, gerenciar estoque, produtos, clientes e supervisionar vendas.',
    8,
    '[]'::jsonb
  );
  
  -- 3. VENDEDOR
  INSERT INTO funcoes (empresa_id, nome, descricao, nivel, escopo_lojas)
  VALUES (
    v_empresa_id,
    'Vendedor',
    'Responsável por vendas. Pode realizar vendas, consultar produtos, cadastrar clientes e emitir recibos.',
    5,
    '[]'::jsonb
  );
  
  -- 4. CAIXA
  INSERT INTO funcoes (empresa_id, nome, descricao, nivel, escopo_lojas)
  VALUES (
    v_empresa_id,
    'Caixa',
    'Operação de caixa. Pode abrir/fechar caixa, processar vendas, receber pagamentos e gerar relatórios de caixa.',
    4,
    '[]'::jsonb
  );
  
  -- 5. TÉCNICO
  INSERT INTO funcoes (empresa_id, nome, descricao, nivel, escopo_lojas)
  VALUES (
    v_empresa_id,
    'Técnico',
    'Gerenciamento de assistência técnica. Pode criar ordens de serviço, gerenciar equipamentos e atualizar status de reparos.',
    6,
    '[]'::jsonb
  );

  RAISE NOTICE '🎉 5 funções padrão criadas com sucesso!';
END $$;

-- =====================================================
-- VERIFICAÇÃO
-- =====================================================
SELECT 
  id,
  nome,
  descricao,
  nivel,
  created_at
FROM funcoes
WHERE nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico')
ORDER BY nivel DESC;

-- =====================================================
-- RESULTADO ESPERADO:
-- =====================================================
-- ✅ 5 funções criadas com hierarquia de níveis:
--
-- | nome          | descricao                     | nivel |
-- |---------------|-------------------------------|-------|
-- | Administrador | Acesso total ao sistema...    | 10    |
-- | Gerente       | Gerenciamento completo...     | 8     |
-- | Técnico       | Gerenciamento assistência...  | 6     |
-- | Vendedor      | Responsável por vendas...     | 5     |
-- | Caixa         | Operação de caixa...          | 4     |
--
-- ✅ Todas criadas para a mesma empresa_id
-- ✅ SEM permissões atribuídas (ative na interface)
-- ✅ Pronto para uso!
-- =====================================================
