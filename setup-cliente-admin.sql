-- ========================================
-- CONFIGURAÇÃO: CLIENTE COMO ADMIN EMPRESA
-- Todo cliente que compra o sistema é admin da empresa
-- ========================================

-- Atualizar valor padrão para admin_empresa (clientes)
ALTER TABLE funcionarios 
ALTER COLUMN tipo_admin SET DEFAULT 'admin_empresa';

-- Função para definir primeiro usuário como admin da empresa
CREATE OR REPLACE FUNCTION set_first_user_as_admin()
RETURNS TRIGGER AS $$
BEGIN
  -- Se for o primeiro funcionário da empresa, torná-lo admin_empresa
  IF NOT EXISTS (
    SELECT 1 FROM funcionarios 
    WHERE empresa_id = NEW.empresa_id 
    AND id != NEW.id
  ) THEN
    NEW.tipo_admin = 'admin_empresa';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para executar automaticamente
DROP TRIGGER IF EXISTS trigger_first_user_admin ON funcionarios;
CREATE TRIGGER trigger_first_user_admin
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION set_first_user_as_admin();

-- Atualizar funcionários existentes para serem admin_empresa
-- (apenas se não houver nenhum admin na empresa)
UPDATE funcionarios 
SET tipo_admin = 'admin_empresa'
WHERE id IN (
  SELECT DISTINCT ON (empresa_id) id
  FROM funcionarios f1
  WHERE NOT EXISTS (
    SELECT 1 FROM funcionarios f2 
    WHERE f2.empresa_id = f1.empresa_id 
    AND f2.tipo_admin IN ('admin_empresa', 'super_admin')
  )
  ORDER BY empresa_id, created_at ASC
);

-- Função para verificar se usuário pode acessar administração
CREATE OR REPLACE FUNCTION can_access_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    SELECT tipo_admin IN ('super_admin', 'admin_empresa')
    FROM funcionarios
    WHERE user_id = auth.uid()
    AND status = 'ativo'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Comentários
COMMENT ON FUNCTION set_first_user_as_admin() IS 'Define automaticamente o primeiro usuário da empresa como admin_empresa';
COMMENT ON FUNCTION can_access_admin() IS 'Verifica se o usuário pode acessar funcionalidades administrativas';
COMMENT ON TRIGGER trigger_first_user_admin ON funcionarios IS 'Garante que o primeiro usuário de cada empresa seja admin';