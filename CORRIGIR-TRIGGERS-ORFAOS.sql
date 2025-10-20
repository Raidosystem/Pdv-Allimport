-- =====================================================
-- CORRIGIR TRIGGERS PROBLEMÁTICOS
-- =====================================================
-- Problema: trigger_prevent_orphan_cliente tenta acessar tabela "users" inexistente
-- Solução: Remover ou recriar triggers com lógica correta

-- 1. REMOVER TRIGGERS PROBLEMÁTICOS
DROP TRIGGER IF EXISTS trigger_prevent_orphan_cliente ON clientes;
DROP TRIGGER IF EXISTS trg_normalize_cpf ON clientes;
DROP FUNCTION IF EXISTS prevent_orphan_cliente() CASCADE;
DROP FUNCTION IF EXISTS normalize_cpf_digits() CASCADE;

-- 2. REMOVER TRIGGERS DUPLICADOS
DROP TRIGGER IF EXISTS handle_updated_at_clientes ON clientes;
DROP TRIGGER IF EXISTS tg_clientes_updated_at ON clientes;
DROP TRIGGER IF EXISTS trigger_update_endereco_completo ON clientes;
DROP TRIGGER IF EXISTS update_clientes_updated_at ON clientes;

-- 3. MANTER APENAS OS TRIGGERS ESSENCIAIS (user_id e updated_at)

-- Trigger para SET updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_set_updated_at_clientes
BEFORE UPDATE ON clientes
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

-- Trigger para SET user_id se não fornecido
CREATE OR REPLACE FUNCTION auto_set_user_id()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NULL OR NEW.user_id = '' THEN
    NEW.user_id = auth.uid();
  END IF;
  IF NEW.empresa_id IS NULL OR NEW.empresa_id = '' THEN
    NEW.empresa_id = auth.uid();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_auto_set_user_id_clientes
BEFORE INSERT ON clientes
FOR EACH ROW
EXECUTE FUNCTION auto_set_user_id();

-- 4. VERIFICAR TRIGGERS RESTANTES
SELECT 
  trigger_schema,
  trigger_name,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'clientes'
ORDER BY trigger_name;

-- =====================================================
-- RESULTADO ESPERADO:
-- - 2 triggers apenas: set_updated_at e auto_set_user_id
-- - Nenhuma referência a tabela "users"
-- - INSERT e UPDATE funcionando perfeitamente
-- =====================================================
