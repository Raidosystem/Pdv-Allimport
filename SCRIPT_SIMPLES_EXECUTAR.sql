-- ============================================
-- 🚀 SCRIPT SIMPLIFICADO - EXECUTAR AGORA
-- ============================================
-- Copie este script completo e execute no Supabase SQL Editor
-- Este script vai:
-- 1. Criar trigger automática
-- 2. Aplicar ADMIN aos 5 proprietários
-- 3. Configurar sistema para futuros usuários
-- ============================================

-- ============================================
-- 1️⃣ CRIAR FUNÇÃO TRIGGER AUTOMÁTICA
-- ============================================
CREATE OR REPLACE FUNCTION auto_aplicar_permissoes()
RETURNS TRIGGER AS $$
DECLARE
  v_is_proprietario BOOLEAN;
  v_permissoes_default jsonb;
  v_permissoes_admin jsonb;
BEGIN
  -- Verificar se é um proprietário (tem registro na tabela empresas)
  SELECT EXISTS(
    SELECT 1 FROM empresas 
    WHERE user_id = NEW.user_id OR id = NEW.empresa_id
  ) INTO v_is_proprietario;
  
  -- Definir permissões ADMIN (acesso total)
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
  
  -- Definir permissões padrão para funcionários
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
  
  -- Aplicar permissões apropriadas
  IF v_is_proprietario THEN
    NEW.permissoes := v_permissoes_admin;
    RAISE NOTICE '✅ ADMIN aplicado automaticamente para proprietário: %', NEW.nome;
  ELSE
    IF NEW.permissoes IS NULL OR NEW.permissoes::text = '{}' OR NEW.permissoes::text = 'null' THEN
      NEW.permissoes := v_permissoes_default;
      RAISE NOTICE '✅ Permissões padrão aplicadas para funcionário: %', NEW.nome;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 2️⃣ CRIAR TRIGGERS
-- ============================================
DROP TRIGGER IF EXISTS trigger_auto_permissoes_insert ON funcionarios;
CREATE TRIGGER trigger_auto_permissoes_insert
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION auto_aplicar_permissoes();

DROP TRIGGER IF EXISTS trigger_auto_permissoes_update ON funcionarios;
CREATE TRIGGER trigger_auto_permissoes_update
  BEFORE UPDATE ON funcionarios
  FOR EACH ROW
  WHEN (NEW.permissoes IS NULL OR NEW.permissoes::text = '{}' OR NEW.permissoes::text = 'null')
  EXECUTE FUNCTION auto_aplicar_permissoes();

-- ============================================
-- 3️⃣ APLICAR ADMIN AOS 5 PROPRIETÁRIOS
-- ============================================
UPDATE funcionarios
SET permissoes = jsonb_build_object(
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
),
updated_at = NOW()
WHERE id IN (
  '09dc2c9d-8cae-4e25-a889-6e98b03d1bf5',  -- Administrador Principal
  'ccdad2bc-3cc1-48a5-b447-be962b2956eb',  -- assistenciaallimport10
  '229271ef-567c-44c7-a996-dd738d3dd476',  -- cris-ramos30
  '23f89969-3c78-4b1e-8131-d98c4b81facb',  -- Cristiano Ramos Mendes
  '0e72a56a-d826-4731-bc82-59d9a28acba5'   -- novaradiosystem
);

-- ============================================
-- 4️⃣ VERIFICAR RESULTADO
-- ============================================
SELECT 
  f.nome,
  CASE 
    WHEN EXISTS(SELECT 1 FROM empresas e WHERE e.user_id = f.user_id) THEN '🔴 PROPRIETÁRIO'
    ELSE '👤 FUNCIONÁRIO'
  END as tipo,
  f.permissoes->>'configuracoes' as "Config",
  f.permissoes->>'funcionarios' as "Func",
  f.permissoes->>'backup' as "Backup",
  f.permissoes->>'pode_deletar_clientes' as "Deletar",
  CASE 
    WHEN f.permissoes->>'configuracoes' = 'true' THEN '✅ ADMIN'
    ELSE '⚪ PADRÃO'
  END as perfil
FROM funcionarios f
ORDER BY 
  CASE WHEN EXISTS(SELECT 1 FROM empresas e WHERE e.user_id = f.user_id) THEN 1 ELSE 2 END,
  f.nome;

-- ============================================
-- ✅ CONCLUÍDO!
-- ============================================
-- Se você ver:
-- - 5 proprietários com Config=true, Func=true, Backup=true
-- - Jennifer com Config=false
-- 
-- Então o sistema está funcionando perfeitamente! 🎉
-- 
-- Próximos passos:
-- 1. Usar interface visual (PermissionsManager) para ajustar Jennifer se necessário
-- 2. Novos funcionários receberão permissões automaticamente
-- 3. Novos proprietários receberão ADMIN automaticamente
-- ============================================
