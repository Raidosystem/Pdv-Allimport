-- =====================================================
-- DIAGNOSTICAR FUNÇÕES E PERMISSÕES DUPLICADAS
-- =====================================================

-- 1. VERIFICAR FUNÇÕES DUPLICADAS
-- =====================================================
SELECT 
  nome,
  COUNT(*) as quantidade,
  STRING_AGG(id::text, ', ') as ids
FROM funcoes
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
GROUP BY nome
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

-- 2. LISTAR TODAS AS FUNÇÕES DA EMPRESA
-- =====================================================
SELECT 
  id,
  nome,
  nivel,
  descricao,
  created_at
FROM funcoes
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY nome, created_at;

-- 3. VERIFICAR FUNCIONÁRIOS E SUAS FUNÇÕES
-- =====================================================
SELECT 
  f.id as funcionario_id,
  f.nome as funcionario_nome,
  f.funcao_id,
  func.nome as funcao_atribuida,
  func.nivel as nivel_funcao,
  f.permissoes as permissoes_funcionario
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.nome;

-- 4. REMOVER FUNÇÕES DUPLICADAS (mantém a mais antiga)
-- =====================================================
WITH funcoes_duplicadas AS (
  SELECT 
    id,
    nome,
    empresa_id,
    ROW_NUMBER() OVER (PARTITION BY nome, empresa_id ORDER BY created_at ASC) as rn
  FROM funcoes
  WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
)
DELETE FROM funcoes
WHERE id IN (
  SELECT id FROM funcoes_duplicadas WHERE rn > 1
);

-- 5. CRIAR FUNÇÕES PADRÃO SE NÃO EXISTIREM
-- =====================================================
-- (Funções agora não têm campo permissoes - isso fica em funcionarios)

-- Admin
INSERT INTO funcoes (empresa_id, nome, nivel, descricao, created_at)
SELECT 
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'Administrador',
  4,
  'Acesso total ao sistema',
  now()
WHERE NOT EXISTS (
  SELECT 1 FROM funcoes 
  WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' 
  AND nome = 'Administrador'
);

-- Gerente
INSERT INTO funcoes (empresa_id, nome, nivel, descricao, created_at)
SELECT 
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'Gerente',
  3,
  'Gerenciamento de vendas e relatórios',
  now()
WHERE NOT EXISTS (
  SELECT 1 FROM funcoes 
  WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' 
  AND nome = 'Gerente'
);

-- Vendedor
INSERT INTO funcoes (empresa_id, nome, nivel, descricao, created_at)
SELECT 
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'Vendedor',
  2,
  'Realização de vendas e cadastro de clientes',
  now()
WHERE NOT EXISTS (
  SELECT 1 FROM funcoes 
  WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' 
  AND nome = 'Vendedor'
);

-- 6. ATUALIZAR PERMISSÕES DOS FUNCIONÁRIOS BASEADO NA FUNÇÃO
-- =====================================================
-- Administrador - Todas as permissões
UPDATE funcionarios f
SET permissoes = jsonb_build_object(
    'vendas', true,
    'produtos', true,
    'clientes', true,
    'caixa', true,
    'relatorios', true,
    'configuracoes', true,
    'ordens_servico', true,
    'backup', true,
    'pode_criar_vendas', true,
    'pode_editar_vendas', true,
    'pode_cancelar_vendas', true,
    'pode_aplicar_desconto', true,
    'pode_criar_produtos', true,
    'pode_editar_produtos', true,
    'pode_deletar_produtos', true,
    'pode_gerenciar_estoque', true,
    'pode_criar_clientes', true,
    'pode_editar_clientes', true,
    'pode_deletar_clientes', true,
    'pode_abrir_caixa', true,
    'pode_fechar_caixa', true,
    'pode_gerenciar_movimentacoes', true,
    'pode_ver_todos_relatorios', true,
    'pode_exportar_dados', true,
    'pode_alterar_configuracoes', true,
    'pode_gerenciar_funcionarios', true,
    'pode_fazer_backup', true,
    'pode_criar_os', true,
    'pode_editar_os', true,
    'pode_finalizar_os', true
  )
FROM funcoes func
WHERE f.funcao_id = func.id
  AND func.nome = 'Administrador'
  AND f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Gerente - Permissões de gerenciamento
UPDATE funcionarios f
SET permissoes = jsonb_build_object(
    'vendas', true,
    'produtos', true,
    'clientes', true,
    'caixa', true,
    'relatorios', true,
    'configuracoes', false,
    'ordens_servico', true,
    'backup', false,
    'pode_criar_vendas', true,
    'pode_editar_vendas', true,
    'pode_cancelar_vendas', true,
    'pode_aplicar_desconto', true,
    'pode_criar_produtos', true,
    'pode_editar_produtos', true,
    'pode_deletar_produtos', false,
    'pode_gerenciar_estoque', true,
    'pode_criar_clientes', true,
    'pode_editar_clientes', true,
    'pode_deletar_clientes', false,
    'pode_abrir_caixa', true,
    'pode_fechar_caixa', true,
    'pode_gerenciar_movimentacoes', true,
    'pode_ver_todos_relatorios', true,
    'pode_exportar_dados', true,
    'pode_alterar_configuracoes', false,
    'pode_gerenciar_funcionarios', false,
    'pode_fazer_backup', false,
    'pode_criar_os', true,
    'pode_editar_os', true,
    'pode_finalizar_os', true
  )
FROM funcoes func
WHERE f.funcao_id = func.id
  AND func.nome = 'Gerente'
  AND f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Vendedor - Permissões básicas
UPDATE funcionarios f
SET permissoes = jsonb_build_object(
    'vendas', true,
    'produtos', true,
    'clientes', true,
    'caixa', false,
    'relatorios', false,
    'configuracoes', false,
    'ordens_servico', true,
    'backup', false,
    'pode_criar_vendas', true,
    'pode_editar_vendas', false,
    'pode_cancelar_vendas', false,
    'pode_aplicar_desconto', false,
    'pode_criar_produtos', false,
    'pode_editar_produtos', false,
    'pode_deletar_produtos', false,
    'pode_gerenciar_estoque', false,
    'pode_criar_clientes', true,
    'pode_editar_clientes', true,
    'pode_deletar_clientes', false,
    'pode_abrir_caixa', false,
    'pode_fechar_caixa', false,
    'pode_gerenciar_movimentacoes', false,
    'pode_ver_todos_relatorios', false,
    'pode_exportar_dados', false,
    'pode_alterar_configuracoes', false,
    'pode_gerenciar_funcionarios', false,
    'pode_fazer_backup', false,
    'pode_criar_os', true,
    'pode_editar_os', true,
    'pode_finalizar_os', false
  )
FROM funcoes func
WHERE f.funcao_id = func.id
  AND func.nome = 'Vendedor'
  AND f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 7. VERIFICAR RESULTADO FINAL
-- =====================================================
SELECT 
  f.id as funcionario_id,
  f.nome as funcionario_nome,
  func.nome as funcao,
  func.nivel,
  f.permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.nome;

-- 8. RESULTADO
-- =====================================================
DO $$
DECLARE
  v_funcoes_unicas INT;
  v_funcionarios_atualizados INT;
BEGIN
  SELECT COUNT(DISTINCT nome) INTO v_funcoes_unicas
  FROM funcoes
  WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';
  
  SELECT COUNT(*) INTO v_funcionarios_atualizados
  FROM funcionarios
  WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
    AND funcao_id IS NOT NULL;

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ FUNÇÕES E PERMISSÕES CORRIGIDAS!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Estatísticas:';
  RAISE NOTICE '   Funções únicas: %', v_funcoes_unicas;
  RAISE NOTICE '   Funcionários com função: %', v_funcionarios_atualizados;
  RAISE NOTICE '';
  RAISE NOTICE '🔧 Ações executadas:';
  RAISE NOTICE '   • Funções duplicadas removidas';
  RAISE NOTICE '   • Funções padrão criadas (Administrador, Gerente, Vendedor)';
  RAISE NOTICE '   • Permissões dos funcionários sincronizadas com suas funções';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Próximo passo:';
  RAISE NOTICE '   Recarregue a página (F5) e teste as permissões!';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
END;
$$;
