-- ============================================
-- 🚨 CORREÇÃO URGENTE - Erro 409 na Trigger
-- ============================================
-- O erro 409 ocorre porque a trigger está causando conflito
-- Vamos ajustar a trigger para funcionar corretamente

-- ============================================
-- 1️⃣ REMOVER TRIGGERS PROBLEMÁTICAS
-- ============================================
DROP TRIGGER IF EXISTS trigger_auto_permissoes_insert ON funcionarios;
DROP TRIGGER IF EXISTS trigger_auto_permissoes_update ON funcionarios;

-- ============================================
-- 2️⃣ RECRIAR FUNÇÃO TRIGGER CORRIGIDA
-- ============================================
CREATE OR REPLACE FUNCTION auto_aplicar_permissoes()
RETURNS TRIGGER AS $$
DECLARE
  v_is_proprietario BOOLEAN := false;
  v_permissoes_default jsonb;
  v_permissoes_admin jsonb;
BEGIN
  -- Só aplicar se permissões estão vazias ou nulas
  IF NEW.permissoes IS NOT NULL AND NEW.permissoes::text != '{}' AND NEW.permissoes::text != 'null' THEN
    RETURN NEW;
  END IF;

  -- Verificar se é proprietário (protegido contra erros)
  BEGIN
    SELECT EXISTS(
      SELECT 1 FROM empresas 
      WHERE user_id = NEW.user_id OR id = NEW.empresa_id
    ) INTO v_is_proprietario;
  EXCEPTION WHEN OTHERS THEN
    v_is_proprietario := false;
  END;
  
  -- Definir permissões ADMIN
  v_permissoes_admin := jsonb_build_object(
    'vendas', true, 'produtos', true, 'clientes', true, 'caixa', true,
    'ordens_servico', true, 'funcionarios', true, 'relatorios', true,
    'configuracoes', true, 'backup', true,
    'pode_criar_vendas', true, 'pode_editar_vendas', true,
    'pode_cancelar_vendas', true, 'pode_aplicar_desconto', true,
    'pode_criar_produtos', true, 'pode_editar_produtos', true,
    'pode_deletar_produtos', true, 'pode_gerenciar_estoque', true,
    'pode_criar_clientes', true, 'pode_editar_clientes', true,
    'pode_deletar_clientes', true, 'pode_abrir_caixa', true,
    'pode_fechar_caixa', true, 'pode_gerenciar_movimentacoes', true,
    'pode_criar_os', true, 'pode_editar_os', true, 'pode_finalizar_os', true,
    'pode_ver_todos_relatorios', true, 'pode_exportar_dados', true,
    'pode_alterar_configuracoes', true, 'pode_gerenciar_funcionarios', true,
    'pode_fazer_backup', true
  );
  
  -- Definir permissões padrão
  v_permissoes_default := jsonb_build_object(
    'vendas', true, 'produtos', true, 'clientes', true, 'caixa', false,
    'ordens_servico', true, 'funcionarios', false, 'relatorios', false,
    'configuracoes', false, 'backup', false,
    'pode_criar_vendas', true, 'pode_editar_vendas', false,
    'pode_cancelar_vendas', false, 'pode_aplicar_desconto', false,
    'pode_criar_produtos', false, 'pode_editar_produtos', false,
    'pode_deletar_produtos', false, 'pode_gerenciar_estoque', false,
    'pode_criar_clientes', true, 'pode_editar_clientes', true,
    'pode_deletar_clientes', false, 'pode_abrir_caixa', false,
    'pode_fechar_caixa', false, 'pode_gerenciar_movimentacoes', false,
    'pode_criar_os', true, 'pode_editar_os', true, 'pode_finalizar_os', false,
    'pode_ver_todos_relatorios', false, 'pode_exportar_dados', false,
    'pode_alterar_configuracoes', false, 'pode_gerenciar_funcionarios', false,
    'pode_fazer_backup', false
  );
  
  -- Aplicar permissões
  IF v_is_proprietario THEN
    NEW.permissoes := v_permissoes_admin;
  ELSE
    NEW.permissoes := v_permissoes_default;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 3️⃣ RECRIAR TRIGGER APENAS PARA INSERT
-- ============================================
-- Trigger só para novos registros (evita conflito 409)
CREATE TRIGGER trigger_auto_permissoes_insert
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION auto_aplicar_permissoes();

-- ============================================
-- 4️⃣ VERIFICAR RLS (Row Level Security)
-- ============================================
-- Se RLS estiver muito restritivo, pode causar 409

-- Verificar políticas atuais
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'funcionarios';

-- ============================================
-- 5️⃣ TESTAR BUSCA DE FUNCIONÁRIOS
-- ============================================
-- Esta query deve funcionar sem erro 409
SELECT 
  id,
  nome,
  email,
  cargo,
  ativo,
  permissoes->>'configuracoes' as config
FROM funcionarios
ORDER BY nome;

-- ============================================
-- ✅ APÓS EXECUTAR ESTE SCRIPT:
-- ============================================
-- 1. Aguarde 30 segundos
-- 2. Recarregue a página /funcionarios (Ctrl+F5)
-- 3. Erro 409 deve ter sumido
-- 4. Lista de funcionários deve carregar corretamente
-- ============================================
