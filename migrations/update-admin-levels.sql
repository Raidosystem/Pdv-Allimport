-- ========================================
-- ATUALIZAÇÃO: NÍVEIS DE ADMINISTRADOR
-- Sistema SaaS Multi-tenant com 3 níveis:
-- 1. super_admin: Admin do sistema (desenvolvedor)
-- 2. admin_empresa: Admin da empresa (cliente)
-- 3. funcionario: Funcionário comum
-- ========================================

-- Adicionar campo tipo_admin na tabela funcionarios
ALTER TABLE funcionarios 
ADD COLUMN IF NOT EXISTS tipo_admin TEXT 
CHECK (tipo_admin IN ('super_admin', 'admin_empresa', 'funcionario')) 
DEFAULT 'funcionario';

-- Atualizar funcionários existentes como admin_empresa se eles têm permissões de admin
UPDATE funcionarios 
SET tipo_admin = 'admin_empresa' 
WHERE id IN (
  SELECT DISTINCT ff.funcionario_id 
  FROM funcionario_funcoes ff
  JOIN funcoes f ON ff.funcao_id = f.id
  JOIN funcao_permissoes fp ON f.id = fp.funcao_id
  JOIN permissoes p ON fp.permissao_id = p.id
  WHERE p.recurso = 'administracao' AND p.acao = 'full_access'
);

-- Criar função para verificar nível de admin
CREATE OR REPLACE FUNCTION get_admin_level(user_id UUID)
RETURNS TEXT AS $$
DECLARE
  admin_level TEXT;
BEGIN
  SELECT tipo_admin INTO admin_level
  FROM funcionarios
  WHERE user_id = get_admin_level.user_id
  AND status = 'ativo';
  
  RETURN COALESCE(admin_level, 'funcionario');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Atualizar RLS policies para considerar níveis de admin
DROP POLICY IF EXISTS "funcionarios_select_policy" ON funcionarios;
CREATE POLICY "funcionarios_select_policy" ON funcionarios
FOR SELECT USING (
  -- Super admin vê todos
  (SELECT get_admin_level(auth.uid()) = 'super_admin') OR
  -- Admin empresa vê apenas da sua empresa
  (empresa_id = get_current_empresa_id() AND 
   (SELECT get_admin_level(auth.uid()) IN ('admin_empresa', 'funcionario'))) OR
  -- Funcionário vê apenas a si mesmo
  (user_id = auth.uid())
);

DROP POLICY IF EXISTS "funcionarios_insert_policy" ON funcionarios;
CREATE POLICY "funcionarios_insert_policy" ON funcionarios
FOR INSERT WITH CHECK (
  -- Super admin pode inserir em qualquer empresa
  (SELECT get_admin_level(auth.uid()) = 'super_admin') OR
  -- Admin empresa pode inserir apenas na sua empresa
  (empresa_id = get_current_empresa_id() AND 
   (SELECT get_admin_level(auth.uid()) = 'admin_empresa'))
);

DROP POLICY IF EXISTS "funcionarios_update_policy" ON funcionarios;
CREATE POLICY "funcionarios_update_policy" ON funcionarios
FOR UPDATE USING (
  -- Super admin pode atualizar qualquer funcionário
  (SELECT get_admin_level(auth.uid()) = 'super_admin') OR
  -- Admin empresa pode atualizar funcionários da sua empresa (exceto outros admins)
  (empresa_id = get_current_empresa_id() AND 
   (SELECT get_admin_level(auth.uid()) = 'admin_empresa') AND
   tipo_admin = 'funcionario') OR
  -- Funcionário pode atualizar apenas a si mesmo
  (user_id = auth.uid())
);

-- Política para empresas - super admin vê todas, admin empresa vê apenas a sua
DROP POLICY IF EXISTS "empresas_select_policy" ON empresas;
CREATE POLICY "empresas_select_policy" ON empresas
FOR SELECT USING (
  -- Super admin vê todas as empresas
  (SELECT get_admin_level(auth.uid()) = 'super_admin') OR
  -- Admin empresa/funcionário vê apenas a própria empresa
  (id = get_current_empresa_id())
);

-- Função para verificar se usuário pode gerenciar funcionários
CREATE OR REPLACE FUNCTION can_manage_users()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (SELECT get_admin_level(auth.uid()) IN ('super_admin', 'admin_empresa'));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comentários para documentação
COMMENT ON COLUMN funcionarios.tipo_admin IS 'Nível de administração: super_admin (sistema), admin_empresa (cliente), funcionario (comum)';
COMMENT ON FUNCTION get_admin_level(UUID) IS 'Retorna o nível de admin do usuário';
COMMENT ON FUNCTION can_manage_users() IS 'Verifica se o usuário pode gerenciar outros usuários';