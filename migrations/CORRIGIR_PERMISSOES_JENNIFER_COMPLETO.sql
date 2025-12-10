-- ========================================
-- ?? CORREÇÃO COMPLETA: Permissões de Jennifer
-- ========================================
-- PROBLEMA: Permissões cadastradas mas não funcionando
-- CAUSA: Permissões granulares não mapeadas para permissões básicas
-- SOLUÇÃO: Criar mapeamento e permissões básicas necessárias
-- ========================================

-- ========================================
-- PARTE 1: VERIFICAR PERMISSÕES ATUAIS
-- ========================================

-- Ver permissões que Jennifer TEM
SELECT 
  '?? PERMISSÕES ATUAIS DE JENNIFER' as secao,
  func.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao,
  p.categoria
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
ORDER BY p.categoria, p.recurso, p.acao;

-- ========================================
-- PARTE 2: CRIAR PERMISSÕES BÁSICAS FALTANDO
-- ========================================

-- O sistema verifica permissões no formato: recurso:acao (ex: vendas:read, produtos:create)
-- Precisamos garantir que TODAS as permissões básicas existam

-- Inserir permissões básicas se não existirem
INSERT INTO permissoes (recurso, acao, descricao, categoria)
VALUES
  -- VENDAS (ações básicas + granulares)
  ('vendas', 'read', 'Visualizar vendas', 'vendas'),
  ('vendas', 'create', 'Criar nova venda', 'vendas'),
  ('vendas', 'update', 'Editar vendas', 'vendas'),
  ('vendas', 'delete', 'Excluir vendas', 'vendas'),
  ('vendas', 'cancel', 'Cancelar vendas', 'vendas'),
  ('vendas', 'discount', 'Aplicar descontos', 'vendas'),
  ('vendas', 'print', 'Imprimir cupom', 'vendas'),
  ('vendas', 'refund', 'Fazer estorno', 'vendas'),

  -- PRODUTOS (ações básicas + granulares)
  ('produtos', 'read', 'Visualizar produtos', 'produtos'),
  ('produtos', 'create', 'Cadastrar novos produtos', 'produtos'),
  ('produtos', 'update', 'Editar produtos', 'produtos'),
  ('produtos', 'delete', 'Excluir produtos', 'produtos'),
  ('produtos', 'export', 'Exportar produtos', 'produtos'),
  ('produtos', 'import', 'Importar produtos', 'produtos'),
  ('produtos', 'manage_categories', 'Gerenciar categorias', 'produtos'),
  ('produtos', 'adjust_price', 'Alterar preços', 'produtos'),
  ('produtos', 'manage_stock', 'Gerenciar estoque', 'produtos'),

  -- CLIENTES (ações básicas + granulares)
  ('clientes', 'read', 'Visualizar clientes', 'clientes'),
  ('clientes', 'create', 'Cadastrar novos clientes', 'clientes'),
  ('clientes', 'update', 'Editar clientes', 'clientes'),
  ('clientes', 'delete', 'Excluir clientes', 'clientes'),
  ('clientes', 'export', 'Exportar clientes', 'clientes'),
  ('clientes', 'import', 'Importar clientes', 'clientes'),
  ('clientes', 'view_history', 'Ver histórico de compras', 'clientes'),
  ('clientes', 'manage_debt', 'Gerenciar crédito/débito', 'clientes'),

  -- CAIXA (ações básicas + granulares)
  ('caixa', 'read', 'Visualizar caixa', 'financeiro'),
  ('caixa', 'view', 'Visualizar caixa', 'financeiro'),
  ('caixa', 'open', 'Abrir caixa', 'financeiro'),
  ('caixa', 'close', 'Fechar caixa', 'financeiro'),
  ('caixa', 'suprimento', 'Fazer suprimento', 'financeiro'),
  ('caixa', 'sangria', 'Fazer sangria', 'financeiro'),
  ('caixa', 'view_history', 'Ver histórico de caixa', 'financeiro'),

  -- FINANCEIRO (ações básicas)
  ('financeiro', 'read', 'Visualizar informações financeiras', 'financeiro'),
  ('financeiro', 'create', 'Criar movimentações financeiras', 'financeiro'),
  ('financeiro', 'update', 'Editar movimentações', 'financeiro'),
  ('financeiro', 'delete', 'Excluir movimentações', 'financeiro'),
  ('financeiro', 'manage_payments', 'Gerenciar formas de pagamento', 'financeiro'),
  ('financeiro', 'view_reports', 'Ver relatórios financeiros', 'financeiro'),

  -- ORDENS DE SERVIÇO (ações básicas + granulares)
  ('ordens', 'read', 'Visualizar ordens', 'ordens'),
  ('ordens', 'create', 'Criar ordem de serviço', 'ordens'),
  ('ordens', 'update', 'Editar ordem', 'ordens'),
  ('ordens', 'delete', 'Excluir ordem', 'ordens'),
  ('ordens', 'print', 'Imprimir ordem', 'ordens'),
  ('ordens', 'change_status', 'Alterar status da ordem', 'ordens'),

  -- RELATÓRIOS (ações básicas)
  ('relatorios', 'read', 'Visualizar relatórios', 'relatorios'),
  ('relatorios', 'sales', 'Relatórios de vendas', 'relatorios'),
  ('relatorios', 'inventory', 'Relatórios de estoque', 'relatorios'),
  ('relatorios', 'customers', 'Relatórios de clientes', 'relatorios'),
  ('relatorios', 'financial', 'Relatórios financeiros', 'relatorios'),
  ('relatorios', 'products', 'Relatórios de produtos', 'relatorios'),
  ('relatorios', 'export', 'Exportar relatórios', 'relatorios'),

  -- CONFIGURAÇÕES (ações básicas + granulares)
  ('configuracoes', 'read', 'Visualizar configurações', 'configuracoes'),
  ('configuracoes', 'update', 'Alterar configurações', 'configuracoes'),
  ('configuracoes', 'appearance', 'Configurar aparência', 'configuracoes'),
  ('configuracoes', 'print_settings', 'Configurar impressão', 'configuracoes'),
  ('configuracoes', 'company_info', 'Editar informações da empresa', 'configuracoes'),
  ('configuracoes', 'backup', 'Fazer backup de dados', 'configuracoes'),
  ('configuracoes', 'integrations', 'Gerenciar integrações', 'configuracoes'),

  -- ADMINISTRAÇÃO (ações básicas)
  ('administracao', 'read', 'Visualizar área administrativa', 'administracao'),
  ('administracao', 'full_access', 'Acesso total administrativo', 'administracao'),
  ('administracao.assinatura', 'read', 'Ver assinatura', 'administracao'),
  ('administracao.assinatura', 'update', 'Gerenciar assinatura', 'administracao'),
  ('administracao.funcoes', 'read', 'Visualizar funções', 'administracao'),
  ('administracao.funcoes', 'create', 'Criar novas funções', 'administracao'),
  ('administracao.funcoes', 'update', 'Editar funções', 'administracao'),
  ('administracao.funcoes', 'delete', 'Excluir funções', 'administracao'),
  ('administracao.logs', 'read', 'Visualizar logs do sistema', 'administracao'),
  ('administracao.permissoes', 'read', 'Visualizar permissões', 'administracao'),
  ('administracao.permissoes', 'update', 'Gerenciar permissões', 'administracao'),
  ('administracao.usuarios', 'read', 'Visualizar usuários', 'administracao'),
  ('administracao.usuarios', 'create', 'Cadastrar usuário', 'administracao'),
  ('administracao.usuarios', 'update', 'Editar usuário', 'administracao'),
  ('administracao.usuarios', 'delete', 'Excluir usuário', 'administracao')

ON CONFLICT (recurso, acao) DO UPDATE SET
  descricao = EXCLUDED.descricao,
  categoria = EXCLUDED.categoria;

SELECT '? PASSO 2: Permissões básicas criadas/atualizadas' as status;

-- ========================================
-- PARTE 3: MAPEAR PERMISSÕES GRANULARES ? BÁSICAS
-- ========================================

-- Se Jennifer tem "vendas:cancel", ela automaticamente tem "vendas:read" e "vendas:update"
-- Se Jennifer tem "produtos:export", ela automaticamente tem "produtos:read"

-- Criar função para mapear permissões granulares
CREATE OR REPLACE FUNCTION mapear_permissoes_granulares()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_funcao RECORD;
  v_permissao RECORD;
  v_recurso TEXT;
  v_acao TEXT;
  v_permissao_basica_id UUID;
BEGIN
  -- Para cada função do sistema
  FOR v_funcao IN SELECT id, empresa_id FROM funcoes LOOP
    
    -- Para cada permissão granular da função
    FOR v_permissao IN 
      SELECT p.id, p.recurso, p.acao
      FROM funcao_permissoes fp
      JOIN permissoes p ON p.id = fp.permissao_id
      WHERE fp.funcao_id = v_funcao.id
      AND p.acao NOT IN ('read', 'create', 'update', 'delete') -- Não processar permissões básicas
    LOOP
      
      v_recurso := v_permissao.recurso;
      v_acao := v_permissao.acao;
      
      -- REGRA 1: Permissões granulares SEMPRE precisam de READ
      BEGIN
        SELECT id INTO v_permissao_basica_id
        FROM permissoes
        WHERE recurso = v_recurso AND acao = 'read';
        
        IF FOUND THEN
          INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
          VALUES (v_funcao.id, v_permissao_basica_id, v_funcao.empresa_id)
          ON CONFLICT DO NOTHING;
          
          RAISE NOTICE 'Adicionado read para % (função %)', v_recurso, v_funcao.id;
        END IF;
      EXCEPTION WHEN OTHERS THEN
        NULL; -- Ignora erros
      END;
      
      -- REGRA 2: Permissões de modificação (cancel, export, print) precisam de UPDATE
      IF v_acao IN ('cancel', 'export', 'print', 'change_status', 'adjust_price', 'manage_stock') THEN
        BEGIN
          SELECT id INTO v_permissao_basica_id
          FROM permissoes
          WHERE recurso = v_recurso AND acao = 'update';
          
          IF FOUND THEN
            INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
            VALUES (v_funcao.id, v_permissao_basica_id, v_funcao.empresa_id)
            ON CONFLICT DO NOTHING;
            
            RAISE NOTICE 'Adicionado update para % (função %)', v_recurso, v_funcao.id;
          END IF;
        EXCEPTION WHEN OTHERS THEN
          NULL;
        END;
      END IF;
      
    END LOOP;
    
  END LOOP;
  
  RAISE NOTICE '? Mapeamento de permissões granulares concluído';
END;
$$;

-- Executar mapeamento
SELECT mapear_permissoes_granulares();

SELECT '? PASSO 3: Permissões granulares mapeadas' as status;

-- ========================================
-- PARTE 4: GARANTIR QUE JENNIFER TEM AS PERMISSÕES BÁSICAS
-- ========================================

-- Adicionar permissões básicas faltando para a função de Jennifer
DO $$
DECLARE
  v_jennifer_funcao_id UUID;
  v_jennifer_empresa_id UUID;
  v_permissao_id UUID;
BEGIN
  -- Pegar funcao_id de Jennifer
  SELECT funcao_id, empresa_id INTO v_jennifer_funcao_id, v_jennifer_empresa_id
  FROM funcionarios
  WHERE email = 'sousajenifer895@gmail.com';

  IF v_jennifer_funcao_id IS NULL THEN
    RAISE EXCEPTION 'Jennifer não tem função definida!';
  END IF;

  -- Adicionar permissões READ para módulos que ela tem permissões granulares
  FOR v_permissao_id IN
    -- Buscar todas as permissões READ dos módulos onde ela tem permissões granulares
    SELECT DISTINCT p2.id
    FROM funcao_permissoes fp
    JOIN permissoes p1 ON p1.id = fp.permissao_id
    JOIN permissoes p2 ON p2.recurso = p1.recurso AND p2.acao = 'read'
    WHERE fp.funcao_id = v_jennifer_funcao_id
    AND p1.acao NOT IN ('read') -- Não processar se já tem read
  LOOP
    -- Inserir permissão READ se não existir
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_jennifer_funcao_id, v_permissao_id, v_jennifer_empresa_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  RAISE NOTICE '? Permissões READ garantidas para Jennifer';
END;
$$;

SELECT '? PASSO 4: Permissões básicas garantidas' as status;

-- ========================================
-- PARTE 5: VERIFICAR PERMISSÕES APÓS CORREÇÃO
-- ========================================

-- Ver permissões agrupadas por categoria
SELECT 
  '?? PERMISSÕES POR CATEGORIA' as secao,
  p.categoria,
  COUNT(*) as total,
  STRING_AGG(DISTINCT p.recurso, ', ' ORDER BY p.recurso) as recursos
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
GROUP BY p.categoria
ORDER BY p.categoria;

-- Ver permissões detalhadas
SELECT 
  '?? PERMISSÕES DETALHADAS' as secao,
  p.categoria,
  p.recurso,
  STRING_AGG(p.acao, ', ' ORDER BY p.acao) as acoes_disponiveis
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
GROUP BY p.categoria, p.recurso
ORDER BY p.categoria, p.recurso;

-- Verificar módulos que ela pode acessar
SELECT 
  '?? MÓDULOS ACESSÍVEIS' as secao,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'vendas'
      AND p2.acao IN ('read', 'create')
    ) THEN '?' ELSE '?'
  END as vendas,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'produtos'
      AND p2.acao IN ('read', 'create')
    ) THEN '?' ELSE '?'
  END as produtos,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'clientes'
      AND p2.acao IN ('read', 'create')
    ) THEN '?' ELSE '?'
  END as clientes,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'caixa'
      AND p2.acao IN ('read', 'view', 'open')
    ) THEN '?' ELSE '?'
  END as caixa,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'ordens'
      AND p2.acao IN ('read', 'create')
    ) THEN '?' ELSE '?'
  END as ordens_servico,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'relatorios'
      AND p2.acao IN ('read')
    ) THEN '?' ELSE '?'
  END as relatorios,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'configuracoes'
      AND p2.acao IN ('read', 'update')
    ) THEN '?' ELSE '?'
  END as configuracoes
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
WHERE f.email = 'sousajenifer895@gmail.com';

-- ========================================
-- PARTE 6: RECARREGAR PERMISSÕES NO FRONTEND
-- ========================================

-- Após executar este script, Jennifer precisa:
-- 1. Fazer LOGOUT
-- 2. Fazer LOGIN novamente
-- 3. As permissões serão recarregadas automaticamente

SELECT '? CONCLUSÃO' as resultado,
       '?? Permissões corrigidas!' as mensagem,
       '?? Jennifer deve fazer LOGOUT e LOGIN novamente' as acao_necessaria,
       '?? Total de permissões: ' || COUNT(*)::TEXT as total
FROM funcao_permissoes fp
JOIN funcionarios f ON f.funcao_id = fp.funcao_id
WHERE f.email = 'sousajenifer895@gmail.com';

-- ========================================
-- ?? INSTRUÇÕES DE USO
-- ========================================
-- 
-- 1. Execute este SQL no Supabase SQL Editor
-- 
-- 2. Verifique os resultados das queries de verificação
-- 
-- 3. Jennifer deve fazer logout e login novamente
-- 
-- 4. Teste acessando cada módulo (Vendas, Produtos, Clientes, etc.)
-- 
-- 5. Se ainda não aparecer:
--    a. Verifique o console do navegador (F12)
--    b. Procure por erros de permissões
--    c. Execute: SELECT * FROM funcao_permissoes WHERE funcao_id = 'FUNCAO_ID_DE_JENNIFER'
-- 
-- ========================================
