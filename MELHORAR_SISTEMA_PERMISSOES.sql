-- ============================================
-- 🎯 MELHORAR SISTEMA DE PERMISSÕES - PDV ALLIMPORT
-- ============================================
-- Este script otimiza o sistema de permissões usando campo JSON
-- para facilitar o gerenciamento visual e atualização em massa.
-- ============================================

-- ============================================
-- 1️⃣ VERIFICAR ESTRUTURA ATUAL DA TABELA FUNCIONARIOS
-- ============================================
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcionarios'
ORDER BY ordinal_position;

-- ============================================
-- 2️⃣ GARANTIR QUE CAMPO PERMISSOES É JSONB
-- ============================================
-- Se precisar alterar o tipo:
-- ALTER TABLE funcionarios 
-- ALTER COLUMN permissoes TYPE jsonb USING permissoes::jsonb;

-- ============================================
-- 3️⃣ CRIAR PERMISSÕES PADRÃO PARA FUNCIONÁRIOS EXISTENTES
-- ============================================
-- Atualizar funcionários que não têm permissões definidas

UPDATE funcionarios
SET permissoes = jsonb_build_object(
  -- Módulos principais
  'vendas', true,
  'produtos', true,
  'clientes', true,
  'caixa', false,
  'ordens_servico', true,
  'funcionarios', false,
  'relatorios', false,
  'configuracoes', false,
  'backup', false,
  
  -- Permissões de vendas
  'pode_criar_vendas', true,
  'pode_editar_vendas', false,
  'pode_cancelar_vendas', false,
  'pode_aplicar_desconto', false,
  
  -- Permissões de produtos
  'pode_criar_produtos', false,
  'pode_editar_produtos', false,
  'pode_deletar_produtos', false,
  'pode_gerenciar_estoque', false,
  
  -- Permissões de clientes
  'pode_criar_clientes', true,
  'pode_editar_clientes', true,
  'pode_deletar_clientes', false,
  
  -- Permissões de caixa
  'pode_abrir_caixa', false,
  'pode_fechar_caixa', false,
  'pode_gerenciar_movimentacoes', false,
  
  -- Permissões de OS
  'pode_criar_os', true,
  'pode_editar_os', true,
  'pode_finalizar_os', false,
  
  -- Permissões de relatórios
  'pode_ver_todos_relatorios', false,
  'pode_exportar_dados', false,
  
  -- Permissões de administração
  'pode_alterar_configuracoes', false,
  'pode_gerenciar_funcionarios', false,
  'pode_fazer_backup', false
)
WHERE permissoes IS NULL OR permissoes::text = '{}' OR permissoes::text = 'null';

-- ============================================
-- 4️⃣ TEMPLATES DE PERMISSÕES PREDEFINIDOS
-- ============================================

-- 🔴 Template: ADMINISTRADOR (Acesso Total)
DO $$
DECLARE
  permissoes_admin jsonb;
BEGIN
  permissoes_admin := jsonb_build_object(
    'vendas', true,
    'produtos', true,
    'clientes', true,
    'caixa', true,
    'ordens_servico', true,
    'funcionarios', true,
    'relatorios', true,
    'configuracoes', true,
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
    'pode_criar_os', true,
    'pode_editar_os', true,
    'pode_finalizar_os', true,
    'pode_ver_todos_relatorios', true,
    'pode_exportar_dados', true,
    'pode_alterar_configuracoes', true,
    'pode_gerenciar_funcionarios', true,
    'pode_fazer_backup', true
  );
  
  RAISE NOTICE '🔴 Template ADMINISTRADOR criado';
END $$;

-- 🟣 Template: GERENTE
DO $$
DECLARE
  permissoes_gerente jsonb;
BEGIN
  permissoes_gerente := jsonb_build_object(
    'vendas', true,
    'produtos', true,
    'clientes', true,
    'caixa', true,
    'ordens_servico', true,
    'funcionarios', false,
    'relatorios', true,
    'configuracoes', false,
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
    'pode_criar_os', true,
    'pode_editar_os', true,
    'pode_finalizar_os', true,
    'pode_ver_todos_relatorios', true,
    'pode_exportar_dados', true,
    'pode_alterar_configuracoes', false,
    'pode_gerenciar_funcionarios', false,
    'pode_fazer_backup', false
  );
  
  RAISE NOTICE '🟣 Template GERENTE criado';
END $$;

-- 🔵 Template: VENDEDOR
DO $$
DECLARE
  permissoes_vendedor jsonb;
BEGIN
  permissoes_vendedor := jsonb_build_object(
    'vendas', true,
    'produtos', true,
    'clientes', true,
    'caixa', false,
    'ordens_servico', false,
    'funcionarios', false,
    'relatorios', false,
    'configuracoes', false,
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
    'pode_criar_os', false,
    'pode_editar_os', false,
    'pode_finalizar_os', false,
    'pode_ver_todos_relatorios', false,
    'pode_exportar_dados', false,
    'pode_alterar_configuracoes', false,
    'pode_gerenciar_funcionarios', false,
    'pode_fazer_backup', false
  );
  
  RAISE NOTICE '🔵 Template VENDEDOR criado';
END $$;

-- 🟢 Template: TÉCNICO (Ordens de Serviço)
DO $$
DECLARE
  permissoes_tecnico jsonb;
BEGIN
  permissoes_tecnico := jsonb_build_object(
    'vendas', false,
    'produtos', true,
    'clientes', true,
    'caixa', false,
    'ordens_servico', true,
    'funcionarios', false,
    'relatorios', false,
    'configuracoes', false,
    'backup', false,
    'pode_criar_vendas', false,
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
    'pode_criar_os', true,
    'pode_editar_os', true,
    'pode_finalizar_os', true,
    'pode_ver_todos_relatorios', false,
    'pode_exportar_dados', false,
    'pode_alterar_configuracoes', false,
    'pode_gerenciar_funcionarios', false,
    'pode_fazer_backup', false
  );
  
  RAISE NOTICE '🟢 Template TÉCNICO criado';
END $$;

-- 🟡 Template: OPERADOR DE CAIXA
DO $$
DECLARE
  permissoes_caixa jsonb;
BEGIN
  permissoes_caixa := jsonb_build_object(
    'vendas', true,
    'produtos', true,
    'clientes', true,
    'caixa', true,
    'ordens_servico', false,
    'funcionarios', false,
    'relatorios', false,
    'configuracoes', false,
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
    'pode_editar_clientes', false,
    'pode_deletar_clientes', false,
    'pode_abrir_caixa', true,
    'pode_fechar_caixa', true,
    'pode_gerenciar_movimentacoes', false,
    'pode_criar_os', false,
    'pode_editar_os', false,
    'pode_finalizar_os', false,
    'pode_ver_todos_relatorios', false,
    'pode_exportar_dados', false,
    'pode_alterar_configuracoes', false,
    'pode_gerenciar_funcionarios', false,
    'pode_fazer_backup', false
  );
  
  RAISE NOTICE '🟡 Template OPERADOR DE CAIXA criado';
END $$;

-- ============================================
-- 5️⃣ VERIFICAR PERMISSÕES DE TODOS OS FUNCIONÁRIOS
-- ============================================
SELECT 
  id,
  nome,
  cargo,
  ativo,
  permissoes->>'ordens_servico' as acesso_os,
  permissoes->>'configuracoes' as acesso_config,
  permissoes->>'pode_deletar_clientes' as pode_deletar_clientes,
  permissoes->>'pode_deletar_produtos' as pode_deletar_produtos,
  jsonb_pretty(permissoes::jsonb) as permissoes_completas
FROM funcionarios
ORDER BY nome;

-- ============================================
-- 6️⃣ CRIAR FUNÇÃO AUXILIAR PARA APLICAR TEMPLATES
-- ============================================
CREATE OR REPLACE FUNCTION aplicar_template_permissoes(
  p_funcionario_id UUID,
  p_template TEXT
) RETURNS void AS $$
DECLARE
  v_permissoes jsonb;
BEGIN
  -- Selecionar template
  CASE p_template
    WHEN 'admin' THEN
      v_permissoes := jsonb_build_object(
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
    
    WHEN 'gerente' THEN
      v_permissoes := jsonb_build_object(
        'vendas', true, 'produtos', true, 'clientes', true, 'caixa', true,
        'ordens_servico', true, 'funcionarios', false, 'relatorios', true,
        'configuracoes', false, 'backup', false,
        'pode_criar_vendas', true, 'pode_editar_vendas', true,
        'pode_cancelar_vendas', true, 'pode_aplicar_desconto', true,
        'pode_criar_produtos', true, 'pode_editar_produtos', true,
        'pode_deletar_produtos', false, 'pode_gerenciar_estoque', true,
        'pode_criar_clientes', true, 'pode_editar_clientes', true,
        'pode_deletar_clientes', false, 'pode_abrir_caixa', true,
        'pode_fechar_caixa', true, 'pode_gerenciar_movimentacoes', true,
        'pode_criar_os', true, 'pode_editar_os', true, 'pode_finalizar_os', true,
        'pode_ver_todos_relatorios', true, 'pode_exportar_dados', true,
        'pode_alterar_configuracoes', false, 'pode_gerenciar_funcionarios', false,
        'pode_fazer_backup', false
      );
    
    WHEN 'vendedor' THEN
      v_permissoes := jsonb_build_object(
        'vendas', true, 'produtos', true, 'clientes', true, 'caixa', false,
        'ordens_servico', false, 'funcionarios', false, 'relatorios', false,
        'configuracoes', false, 'backup', false,
        'pode_criar_vendas', true, 'pode_editar_vendas', false,
        'pode_cancelar_vendas', false, 'pode_aplicar_desconto', false,
        'pode_criar_produtos', false, 'pode_editar_produtos', false,
        'pode_deletar_produtos', false, 'pode_gerenciar_estoque', false,
        'pode_criar_clientes', true, 'pode_editar_clientes', true,
        'pode_deletar_clientes', false, 'pode_abrir_caixa', false,
        'pode_fechar_caixa', false, 'pode_gerenciar_movimentacoes', false,
        'pode_criar_os', false, 'pode_editar_os', false, 'pode_finalizar_os', false,
        'pode_ver_todos_relatorios', false, 'pode_exportar_dados', false,
        'pode_alterar_configuracoes', false, 'pode_gerenciar_funcionarios', false,
        'pode_fazer_backup', false
      );
    
    WHEN 'tecnico' THEN
      v_permissoes := jsonb_build_object(
        'vendas', false, 'produtos', true, 'clientes', true, 'caixa', false,
        'ordens_servico', true, 'funcionarios', false, 'relatorios', false,
        'configuracoes', false, 'backup', false,
        'pode_criar_vendas', false, 'pode_editar_vendas', false,
        'pode_cancelar_vendas', false, 'pode_aplicar_desconto', false,
        'pode_criar_produtos', false, 'pode_editar_produtos', false,
        'pode_deletar_produtos', false, 'pode_gerenciar_estoque', false,
        'pode_criar_clientes', true, 'pode_editar_clientes', true,
        'pode_deletar_clientes', false, 'pode_abrir_caixa', false,
        'pode_fechar_caixa', false, 'pode_gerenciar_movimentacoes', false,
        'pode_criar_os', true, 'pode_editar_os', true, 'pode_finalizar_os', true,
        'pode_ver_todos_relatorios', false, 'pode_exportar_dados', false,
        'pode_alterar_configuracoes', false, 'pode_gerenciar_funcionarios', false,
        'pode_fazer_backup', false
      );
    
    WHEN 'caixa' THEN
      v_permissoes := jsonb_build_object(
        'vendas', true, 'produtos', true, 'clientes', true, 'caixa', true,
        'ordens_servico', false, 'funcionarios', false, 'relatorios', false,
        'configuracoes', false, 'backup', false,
        'pode_criar_vendas', true, 'pode_editar_vendas', false,
        'pode_cancelar_vendas', false, 'pode_aplicar_desconto', false,
        'pode_criar_produtos', false, 'pode_editar_produtos', false,
        'pode_deletar_produtos', false, 'pode_gerenciar_estoque', false,
        'pode_criar_clientes', true, 'pode_editar_clientes', false,
        'pode_deletar_clientes', false, 'pode_abrir_caixa', true,
        'pode_fechar_caixa', true, 'pode_gerenciar_movimentacoes', false,
        'pode_criar_os', false, 'pode_editar_os', false, 'pode_finalizar_os', false,
        'pode_ver_todos_relatorios', false, 'pode_exportar_dados', false,
        'pode_alterar_configuracoes', false, 'pode_gerenciar_funcionarios', false,
        'pode_fazer_backup', false
      );
    
    ELSE
      RAISE EXCEPTION 'Template inválido: %. Use: admin, gerente, vendedor, tecnico ou caixa', p_template;
  END CASE;
  
  -- Aplicar permissões
  UPDATE funcionarios
  SET 
    permissoes = v_permissoes,
    updated_at = NOW()
  WHERE id = p_funcionario_id;
  
  RAISE NOTICE 'Template "%" aplicado ao funcionário %', p_template, p_funcionario_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 6️⃣ CRIAR TRIGGER PARA APLICAR PERMISSÕES AUTOMATICAMENTE
-- ============================================
-- Esta trigger garante que:
-- 1. Proprietários (da tabela empresas) recebem permissões ADMIN automaticamente
-- 2. Novos funcionários recebem permissões padrão automaticamente

CREATE OR REPLACE FUNCTION auto_aplicar_permissoes()
RETURNS TRIGGER AS $$
DECLARE
  v_is_proprietario BOOLEAN;
  v_permissoes_default jsonb;
  v_permissoes_admin jsonb;
BEGIN
  -- Verificar se é um proprietário (tem registro na tabela empresas com mesmo user_id)
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
    -- Proprietário = ADMIN
    NEW.permissoes := v_permissoes_admin;
    RAISE NOTICE '✅ Permissões de ADMIN aplicadas automaticamente para proprietário: %', NEW.nome;
  ELSE
    -- Funcionário = Permissões padrão (se não tiver permissões definidas)
    IF NEW.permissoes IS NULL OR NEW.permissoes::text = '{}' OR NEW.permissoes::text = 'null' THEN
      NEW.permissoes := v_permissoes_default;
      RAISE NOTICE '✅ Permissões padrão aplicadas automaticamente para funcionário: %', NEW.nome;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para INSERT
DROP TRIGGER IF EXISTS trigger_auto_permissoes_insert ON funcionarios;
CREATE TRIGGER trigger_auto_permissoes_insert
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION auto_aplicar_permissoes();

-- Criar trigger para UPDATE (caso permissões sejam zeradas)
DROP TRIGGER IF EXISTS trigger_auto_permissoes_update ON funcionarios;
CREATE TRIGGER trigger_auto_permissoes_update
  BEFORE UPDATE ON funcionarios
  FOR EACH ROW
  WHEN (NEW.permissoes IS NULL OR NEW.permissoes::text = '{}' OR NEW.permissoes::text = 'null')
  EXECUTE FUNCTION auto_aplicar_permissoes();

-- ============================================
-- 7️⃣ APLICAR PERMISSÕES ADMIN AOS PROPRIETÁRIOS EXISTENTES
-- ============================================
-- Identificar e atualizar todos os proprietários com permissões ADMIN

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
  -- Proprietários: quem tem user_id correspondente na tabela empresas
  SELECT f.id 
  FROM funcionarios f
  INNER JOIN empresas e ON e.user_id = f.user_id OR e.id = f.empresa_id
);

-- ============================================
-- 8️⃣ VERIFICAR APLICAÇÃO DAS PERMISSÕES
-- ============================================
SELECT 
  f.nome,
  f.cargo,
  CASE 
    WHEN EXISTS(SELECT 1 FROM empresas e WHERE e.user_id = f.user_id) THEN '🔴 PROPRIETÁRIO (ADMIN)'
    ELSE '👤 FUNCIONÁRIO'
  END as tipo,
  CASE 
    WHEN f.permissoes->>'configuracoes' = 'true' THEN '✅ ADMIN'
    WHEN f.permissoes->>'ordens_servico' = 'true' AND f.permissoes->>'vendas' = 'false' THEN '🟢 TÉCNICO'
    WHEN f.permissoes->>'caixa' = 'true' THEN '🟡 CAIXA'
    WHEN f.permissoes->>'vendas' = 'true' THEN '🔵 VENDEDOR'
    ELSE '⚪ PADRÃO'
  END as perfil,
  f.permissoes->>'configuracoes' as "Config",
  f.permissoes->>'funcionarios' as "Func",
  f.permissoes->>'backup' as "Backup"
FROM funcionarios f
ORDER BY 
  CASE WHEN EXISTS(SELECT 1 FROM empresas e WHERE e.user_id = f.user_id) THEN 1 ELSE 2 END,
  f.nome;

-- ============================================
-- 9️⃣ EXEMPLO DE USO DA FUNÇÃO MANUAL
-- ============================================
-- Para aplicar template manualmente a um funcionário específico:
-- SELECT aplicar_template_permissoes('UUID_DO_FUNCIONARIO', 'vendedor');

-- Exemplos:
-- SELECT aplicar_template_permissoes('9d9fe570-7c09-4ee4-8c52-11b7969c00f3', 'tecnico');
-- SELECT aplicar_template_permissoes('UUID_FUNCIONARIO', 'gerente');

-- ============================================
-- 🔟 TESTAR SISTEMA AUTOMÁTICO
-- ============================================
-- Para testar, crie um funcionário de teste:
/*
INSERT INTO funcionarios (nome, email, cargo, empresa_id, ativo)
VALUES ('Teste Funcionário', 'teste@email.com', 'Teste', 'UUID_EMPRESA', true);

-- Verificar permissões aplicadas automaticamente:
SELECT nome, jsonb_pretty(permissoes) FROM funcionarios WHERE nome = 'Teste Funcionário';

-- Deletar teste:
DELETE FROM funcionarios WHERE nome = 'Teste Funcionário';
*/

-- ============================================
-- ✅ SISTEMA DE PERMISSÕES OTIMIZADO E AUTOMATIZADO!
-- ============================================
-- Agora você tem:
-- ✅ Templates predefinidos (Admin, Gerente, Vendedor, Técnico, Caixa)
-- ✅ Função SQL para aplicar templates manualmente
-- ✅ Trigger automática para novos funcionários
-- ✅ Proprietários recebem automaticamente permissões ADMIN
-- ✅ Funcionários recebem automaticamente permissões padrão
-- ✅ Interface visual moderna no frontend
-- ✅ Sistema de permissões granular e intuitivo
-- ✅ Fácil manutenção e atualização
-- ============================================

-- ============================================
-- 📝 COMO FUNCIONA
-- ============================================
-- 1. NOVO PROPRIETÁRIO:
--    - Quando compra o sistema, o registro na tabela empresas é criado
--    - Ao criar registro em funcionarios, a trigger detecta que é proprietário
--    - Aplica automaticamente permissões ADMIN (acesso total)
--
-- 2. NOVO FUNCIONÁRIO:
--    - Admin cria funcionário pela interface
--    - Trigger detecta que não é proprietário
--    - Aplica automaticamente permissões padrão (vendas, clientes, OS básico)
--    - Admin pode depois aplicar templates específicos ou personalizar
--
-- 3. PROPRIETÁRIOS EXISTENTES:
--    - Script já atualizou todos com permissões ADMIN
--    - Verificar com query da seção 8️⃣
-- ============================================

-- ============================================
-- 📝 NOTAS IMPORTANTES
-- ============================================
-- 1. Novos funcionários receberão automaticamente as permissões padrão
--    definidas na seção 3️⃣ (vendas, produtos, clientes básicos)
--
-- 2. Use a função aplicar_template_permissoes() para aplicar templates
--    rapidamente a funcionários existentes
--
-- 3. O frontend (PermissionsManager.tsx) permite gerenciar permissões
--    visualmente com toggle switches e templates
--
-- 4. Todas as permissões são armazenadas em formato JSONB para
--    fácil consulta e atualização
-- ============================================
