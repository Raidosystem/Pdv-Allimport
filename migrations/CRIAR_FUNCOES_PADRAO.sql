-- =====================================================
-- CRIAR FUNÇÕES PADRÃO DO SISTEMA PDV
-- =====================================================
-- Este script cria as 5 funções padrão que servem como
-- exemplo para o usuário entender o sistema de permissões.
-- O usuário pode ativar as permissões depois conforme necessário.
-- =====================================================

-- =====================================================
-- PASSO 1: ADICIONAR COLUNAS NECESSÁRIAS (SE NÃO EXISTIREM)
-- =====================================================
DO $$ 
BEGIN
  -- Adicionar coluna 'sistema' se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'funcoes' 
    AND column_name = 'sistema'
  ) THEN
    ALTER TABLE funcoes ADD COLUMN sistema BOOLEAN DEFAULT false;
    RAISE NOTICE '✅ Coluna "sistema" adicionada';
  END IF;

  -- Adicionar coluna 'ativo' se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'funcoes' 
    AND column_name = 'ativo'
  ) THEN
    ALTER TABLE funcoes ADD COLUMN ativo BOOLEAN DEFAULT true;
    RAISE NOTICE '✅ Coluna "ativo" adicionada';
  END IF;

  -- Adicionar coluna 'created_at' se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'funcoes' 
    AND column_name = 'created_at'
  ) THEN
    ALTER TABLE funcoes ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();
    RAISE NOTICE '✅ Coluna "created_at" adicionada';
  END IF;

  -- Adicionar coluna 'updated_at' se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'funcoes' 
    AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE funcoes ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
    RAISE NOTICE '✅ Coluna "updated_at" adicionada';
  END IF;

  RAISE NOTICE '🎉 Estrutura da tabela funcoes atualizada!';
END $$;

-- =====================================================
-- PASSO 2: DEFINIR EMPRESA_ID E LIMPAR FUNÇÕES ANTIGAS
-- =====================================================
DO $$ 
DECLARE
  v_empresa_id UUID;
BEGIN
  -- 🔧 Pegar a primeira empresa (se você tem apenas 1 empresa)
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  
  -- 🔧 OU pegar pelo user_id (descomente se souber o user_id):
  -- SELECT id INTO v_empresa_id FROM empresas WHERE user_id = auth.uid();
  
  IF v_empresa_id IS NULL THEN
    RAISE EXCEPTION '❌ Nenhuma empresa encontrada! Crie uma empresa primeiro.';
  END IF;
  
  RAISE NOTICE '✅ Usando empresa_id: %', v_empresa_id;
  
  -- Limpar funções padrão antigas
  DELETE FROM funcao_permissoes WHERE funcao_id IN (
    SELECT id FROM funcoes 
    WHERE empresa_id = v_empresa_id
    AND nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico')
  );

  DELETE FROM funcoes 
  WHERE empresa_id = v_empresa_id
  AND nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico');
  
  RAISE NOTICE '🧹 Funções antigas removidas (se existiam)';
END $$;

-- =====================================================
-- PASSO 3: CRIAR AS 5 FUNÇÕES PADRÃO
-- =====================================================
DO $$ 
DECLARE
  v_empresa_id UUID;
BEGIN
  -- Pegar empresa_id novamente
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;

-- =====================================================
-- 1. ADMINISTRADOR
-- =====================================================
INSERT INTO funcoes (
  empresa_id,
  nome,
  descricao,
  nivel,
  sistema,
  ativo,
  created_at,
  updated_at
) VALUES (
  v_empresa_id,
  'Administrador',
  'Acesso total ao sistema. Pode gerenciar todas as funcionalidades, usuários, configurações e realizar qualquer operação.',
  10,
  true,
  true,
  NOW(),
  NOW()
);

-- =====================================================
-- 2. GERENTE
-- =====================================================
INSERT INTO funcoes (
  empresa_id,
  nome,
  descricao,
  nivel,
  sistema,
  ativo,
  created_at,
  updated_at
) VALUES (
  v_empresa_id,
  'Gerente',
  'Gerenciamento completo da loja. Pode visualizar relatórios, gerenciar estoque, produtos, clientes e supervisionar vendas.',
  8,
  true,
  true,
  NOW(),
  NOW()
);

-- =====================================================
-- 3. VENDEDOR
-- =====================================================
INSERT INTO funcoes (
  empresa_id,
  nome,
  descricao,
  nivel,
  sistema,
  ativo,
  created_at,
  updated_at
) VALUES (
  v_empresa_id,
  'Vendedor',
  'Responsável por vendas. Pode realizar vendas, consultar produtos, cadastrar clientes e emitir recibos.',
  5,
  true,
  true,
  NOW(),
  NOW()
);

-- =====================================================
-- 4. CAIXA
-- =====================================================
INSERT INTO funcoes (
  empresa_id,
  nome,
  descricao,
  nivel,
  sistema,
  ativo,
  created_at,
  updated_at
) VALUES (
  v_empresa_id,
  'Caixa',
  'Operação de caixa. Pode abrir/fechar caixa, processar vendas, receber pagamentos e gerar relatórios de caixa.',
  4,
  true,
  true,
  NOW(),
  NOW()
);

-- =====================================================
-- 5. TÉCNICO
-- =====================================================
INSERT INTO funcoes (
  empresa_id,
  nome,
  descricao,
  nivel,
  sistema,
  ativo,
  created_at,
  updated_at
) VALUES (
  v_empresa_id,
  'Técnico',
  'Gerenciamento de assistência técnica. Pode criar ordens de serviço, gerenciar equipamentos e atualizar status de reparos.',
  6,
  true,
  true,
  NOW(),
  NOW()
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
  nivel,
  sistema,
  ativo,
  created_at
FROM funcoes
WHERE nome IN ('Administrador', 'Gerente', 'Vendedor', 'Caixa', 'Técnico')
ORDER BY nivel DESC;

-- =====================================================
-- NOTAS IMPORTANTES:
-- =====================================================
-- 1. Todas as funções são marcadas como "sistema = true"
--    para indicar que são funções padrão do sistema.
--
-- 2. Todas estão ativas (ativo = true) por padrão.
--
-- 3. Os níveis definem a hierarquia:
--    - Administrador: 10 (máximo)
--    - Gerente: 8
--    - Técnico: 6
--    - Vendedor: 5
--    - Caixa: 4
--
-- 4. NENHUMA PERMISSÃO é atribuída automaticamente.
--    O usuário deve ATIVAR as permissões manualmente
--    através da interface AdminRolesPermissionsPageNew.
--
-- 5. O botão "Criar Nova Função" permanece disponível
--    para que o usuário possa criar funções customizadas.
--
-- 6. Estas funções servem como EXEMPLO para o usuário
--    entender como o sistema funciona.
-- =====================================================
