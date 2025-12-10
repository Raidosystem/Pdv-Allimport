-- =====================================================
-- ?? CORREÇÃO FINAL COMPLETA - JENNIFER E NOVOS USUÁRIOS
-- =====================================================
-- Este script resolve TODOS os problemas:
-- 1. OS aparecendo quando não deveria (permissao era "ordens" mas banco usa "ordens_servico")
-- 2. Relatórios não aparecendo quando deveria (permissao era "relatorios" mas banco pode usar nome diferente)
-- 3. Garante que novos vendedores terão as permissões corretas
-- =====================================================

BEGIN;

-- ============================================
-- 1?? CRIAR FUNÇÃO PARA APLICAR PERMISSÕES VENDEDOR
-- ============================================
CREATE OR REPLACE FUNCTION aplicar_permissoes_vendedor(p_funcionario_id UUID)
RETURNS void AS $$
BEGIN
  -- Aplicar EXATAMENTE as permissões que um vendedor deve ter
  UPDATE funcionarios
  SET permissoes = jsonb_build_object(
    -- ? MÓDULOS QUE O VENDEDOR VÊ
    'vendas', true,           -- ? Vendedor VÊ vendas
    'clientes', true,          -- ? Vendedor VÊ clientes  
    'produtos', true,          -- ? Vendedor VÊ produtos
    'ordens_servico', false,   -- ? Vendedor NÃO VÊ OS
    'relatorios', false,       -- ? Vendedor NÃO VÊ relatórios
    'caixa', false,            -- ? Vendedor NÃO VÊ caixa
    'configuracoes', false,    -- ? Vendedor NÃO VÊ config
    'backup', false,           -- ? Vendedor NÃO VÊ backup
    'funcionarios', false,     -- ? Vendedor NÃO VÊ func
    
    -- ? PERMISSÕES ESPECÍFICAS DE VENDAS
    'pode_criar_vendas', true,
    'pode_editar_vendas', false,
    'pode_cancelar_vendas', false,
    'pode_aplicar_desconto', false,
    
    -- ? PERMISSÕES ESPECÍFICAS DE PRODUTOS
    'pode_criar_produtos', false,
    'pode_editar_produtos', false,
    'pode_deletar_produtos', false,
    'pode_gerenciar_estoque', false,
    
    -- ? PERMISSÕES ESPECÍFICAS DE CLIENTES
    'pode_criar_clientes', true,
    'pode_editar_clientes', true,
    'pode_deletar_clientes', false,
    
    -- ? PERMISSÕES ESPECÍFICAS DE CAIXA (NENHUMA)
    'pode_abrir_caixa', false,
    'pode_fechar_caixa', false,
    'pode_gerenciar_movimentacoes', false,
    'pode_fazer_sangria', false,
    'pode_fazer_suprimento', false,
    
    -- ? PERMISSÕES ESPECÍFICAS DE OS (NENHUMA)
    'pode_criar_os', false,
    'pode_editar_os', false,
    'pode_finalizar_os', false,
    
    -- ? PERMISSÕES ESPECÍFICAS DE RELATÓRIOS (NENHUMA)
    'pode_ver_todos_relatorios', false,
    'pode_exportar_dados', false,
    
    -- ? PERMISSÕES ADMINISTRATIVAS (NENHUMA)
    'pode_alterar_configuracoes', false,
    'pode_gerenciar_funcionarios', false,
    'pode_fazer_backup', false
  ),
  updated_at = NOW()
  WHERE id = p_funcionario_id;
  
  RAISE NOTICE '? Permissões de VENDEDOR aplicadas ao funcionário %', p_funcionario_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 2?? CORRIGIR PERMISSÕES DA JENNIFER AGORA
-- ============================================
DO $$
DECLARE
  v_jennifer_id UUID;
BEGIN
  -- Buscar Jennifer
  SELECT id INTO v_jennifer_id
  FROM funcionarios
  WHERE nome = 'Jennifer'
  LIMIT 1;
  
  IF v_jennifer_id IS NULL THEN
    RAISE EXCEPTION '? Jennifer não encontrada!';
  END IF;
  
  -- Aplicar permissões corretas
  PERFORM aplicar_permissoes_vendedor(v_jennifer_id);
  
  RAISE NOTICE '?? PERMISSÕES DA JENNIFER CORRIGIDAS!';
  RAISE NOTICE '   ? Deve ver: Vendas, Clientes, Produtos';
  RAISE NOTICE '   ? NÃO deve ver: OS, Relatórios, Caixa';
END $$;

-- ============================================
-- 3?? VERIFICAR RESULTADO FINAL
-- ============================================
SELECT 
  '?? PERMISSÕES DA JENNIFER (FINAL)' as info,
  permissoes->>'vendas' as vendas,
  permissoes->>'clientes' as clientes,
  permissoes->>'produtos' as produtos,
  permissoes->>'ordens_servico' as ordens_servico,
  permissoes->>'relatorios' as relatorios,
  permissoes->>'caixa' as caixa,
  permissoes->>'configuracoes' as configuracoes
FROM funcionarios
WHERE nome = 'Jennifer';

-- ============================================
-- 4?? CRIAR TRIGGER PARA NOVOS VENDEDORES
-- ============================================
-- Quando criar um novo vendedor, aplicar permissões automaticamente

CREATE OR REPLACE FUNCTION trigger_aplicar_permissoes_vendedor()
RETURNS TRIGGER AS $$
BEGIN
  -- Se é novo funcionário E cargo contém "vendedor" (case insensitive)
  IF TG_OP = 'INSERT' AND LOWER(NEW.cargo) LIKE '%vendedor%' THEN
    -- Aplicar permissões de vendedor
    NEW.permissoes := jsonb_build_object(
      'vendas', true,
      'clientes', true,
      'produtos', true,
      'ordens_servico', false,
      'relatorios', false,
      'caixa', false,
      'configuracoes', false,
      'backup', false,
      'funcionarios', false,
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
      'pode_fazer_sangria', false,
      'pode_fazer_suprimento', false,
      'pode_criar_os', false,
      'pode_editar_os', false,
      'pode_finalizar_os', false,
      'pode_ver_todos_relatorios', false,
      'pode_exportar_dados', false,
      'pode_alterar_configuracoes', false,
      'pode_gerenciar_funcionarios', false,
      'pode_fazer_backup', false
    );
    
    RAISE NOTICE '? Permissões de vendedor aplicadas automaticamente para: %', NEW.nome;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger (remove old se existir)
DROP TRIGGER IF EXISTS trigger_auto_permissoes_vendedor ON funcionarios;
CREATE TRIGGER trigger_auto_permissoes_vendedor
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION trigger_aplicar_permissoes_vendedor();

-- ============================================
-- 5?? CRIAR FUNÇÃO HELPER PARA FRONTEND
-- ============================================
-- Esta função retorna TRUE/FALSE para cada módulo
-- Útil para o frontend saber o que mostrar

CREATE OR REPLACE FUNCTION check_module_permission(
  p_funcionario_id UUID,
  p_module_name TEXT
) RETURNS BOOLEAN AS $$
DECLARE
  v_has_permission BOOLEAN;
BEGIN
  -- Buscar permissão do módulo no JSONB
  SELECT COALESCE((permissoes->>p_module_name)::boolean, false)
  INTO v_has_permission
  FROM funcionarios
  WHERE id = p_funcionario_id;
  
  RETURN COALESCE(v_has_permission, false);
END;
$$ LANGUAGE plpgsql;

-- Exemplo de uso:
-- SELECT check_module_permission('jennifer_id_aqui', 'vendas');     -- TRUE
-- SELECT check_module_permission('jennifer_id_aqui', 'relatorios');  -- FALSE

-- ============================================
-- 6?? VERIFICAÇÃO FINAL COMPLETA
-- ============================================
SELECT 
  '?? RESUMO FINAL' as info,
  nome,
  cargo,
  CASE 
    WHEN permissoes->>'vendas' = 'true' THEN '?' ELSE '?' 
  END as vendas,
  CASE 
    WHEN permissoes->>'clientes' = 'true' THEN '?' ELSE '?' 
  END as clientes,
  CASE 
    WHEN permissoes->>'produtos' = 'true' THEN '?' ELSE '?' 
  END as produtos,
  CASE 
    WHEN permissoes->>'ordens_servico' = 'true' THEN '? (ERRO!)' ELSE '? (OK)' 
  END as os,
  CASE 
    WHEN permissoes->>'relatorios' = 'true' THEN '? (ERRO!)' ELSE '? (OK)' 
  END as relatorios,
  CASE 
    WHEN permissoes->>'caixa' = 'true' THEN '? (ERRO!)' ELSE '? (OK)' 
  END as caixa
FROM funcionarios
WHERE nome = 'Jennifer';

COMMIT;

-- ============================================
-- ? INSTRUÇÕES FINAIS
-- ============================================
-- 
-- 1?? Execute este script no SQL Editor do Supabase
-- 2?? Faça LOGOUT da Jennifer no sistema
-- 3?? Faça LOGIN novamente
-- 4?? Verifique o console do navegador (F12)
-- 5?? Jennifer deve ver APENAS: Vendas, Clientes, Produtos
-- 6?? Jennifer NÃO deve ver: OS, Relatórios, Caixa
-- 
-- ?? Se AINDA aparecer OS ou Relatórios:
-- 
-- 1. Limpe o cache do navegador (Ctrl + Shift + Delete)
-- 2. Feche TODAS as abas do sistema
-- 3. Abra uma aba anônima (Ctrl + Shift + N)
-- 4. Faça login novamente
-- 
-- ?? DEBUG NO CONSOLE:
-- 
-- Você deve ver algo assim:
-- 
-- ?? [useVisibleModules] Buscando permissões JSONB...
-- ? [sales] Módulo visível
-- ? [clients] Módulo visível
-- ? [products] Módulo visível
-- ? [orders] Sem permissão      <-- CORRETO!
-- ? [reports] Sem permissão     <-- CORRETO!
-- ? [cashier] Sem permissão     <-- CORRETO!
-- ?? Total módulos visíveis: 3   <-- CORRETO!
-- 
-- ============================================
