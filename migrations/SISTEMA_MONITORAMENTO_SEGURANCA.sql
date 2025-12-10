-- 🛡️ SISTEMA DE MONITORAMENTO DE SEGURANÇA
-- Execute no SQL Editor para criar validações automáticas

-- 1. Função para validar se user_id existe (se não existir, criar)
CREATE OR REPLACE FUNCTION validate_user_exists(user_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM auth.users WHERE id = user_id
  );
END;
$$;

-- 2. Trigger para prevenir dados órfãos em clientes
CREATE OR REPLACE FUNCTION prevent_orphan_cliente()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Se usuario_id for NULL, usar o ID padrão da assistência
  IF NEW.usuario_id IS NULL THEN
    NEW.usuario_id := 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid;
  END IF;
  
  -- Verificar se o user_id existe
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = NEW.usuario_id) THEN
    RAISE WARNING 'User ID não encontrado: %. Usando ID padrão.', NEW.usuario_id;
    NEW.usuario_id := 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid;
  END IF;
  
  RETURN NEW;
END;
$$;

-- 3. Trigger para prevenir dados órfãos em ordens
CREATE OR REPLACE FUNCTION prevent_orphan_ordem()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Se usuario_id for NULL, usar o ID padrão da assistência
  IF NEW.usuario_id IS NULL THEN
    NEW.usuario_id := 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid;
  END IF;
  
  -- Verificar se o user_id existe
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = NEW.usuario_id) THEN
    RAISE WARNING 'User ID não encontrado: %. Usando ID padrão.', NEW.usuario_id;
    NEW.usuario_id := 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid;
  END IF;
  
  RETURN NEW;
END;
$$;

-- 4. Aplicar triggers
DROP TRIGGER IF EXISTS trigger_prevent_orphan_cliente ON clientes;
CREATE TRIGGER trigger_prevent_orphan_cliente
  BEFORE INSERT OR UPDATE ON clientes
  FOR EACH ROW
  EXECUTE FUNCTION prevent_orphan_cliente();

DROP TRIGGER IF EXISTS trigger_prevent_orphan_ordem ON ordens_servico;
CREATE TRIGGER trigger_prevent_orphan_ordem
  BEFORE INSERT OR UPDATE ON ordens_servico
  FOR EACH ROW
  EXECUTE FUNCTION prevent_orphan_ordem();

-- 5. Função para auditoria de segurança
CREATE OR REPLACE FUNCTION audit_security()
RETURNS TABLE(
  tabela text,
  total_registros bigint,
  registros_orfaos bigint,
  percentual_orfaos numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    'clientes'::text,
    COUNT(*)::bigint as total,
    COUNT(*) FILTER (WHERE c.usuario_id NOT IN (SELECT id FROM auth.users))::bigint as orfaos,
    ROUND(
      (COUNT(*) FILTER (WHERE c.usuario_id NOT IN (SELECT id FROM auth.users))::numeric / COUNT(*)::numeric) * 100, 
      2
    ) as percentual
  FROM clientes c
  
  UNION ALL
  
  SELECT 
    'ordens_servico'::text,
    COUNT(*)::bigint as total,
    COUNT(*) FILTER (WHERE o.usuario_id NOT IN (SELECT id FROM auth.users))::bigint as orfaos,
    ROUND(
      (COUNT(*) FILTER (WHERE o.usuario_id NOT IN (SELECT id FROM auth.users))::numeric / COUNT(*)::numeric) * 100, 
      2
    ) as percentual
  FROM ordens_servico o;
END;
$$;

-- 6. Testar o sistema de auditoria
SELECT * FROM audit_security();

-- 7. Testar inserção protegida (deve funcionar mesmo com user_id nulo)
INSERT INTO clientes (nome, telefone, usuario_id) 
VALUES ('Teste Segurança', '11999999998', NULL)
RETURNING nome, telefone, usuario_id, 'Inserção protegida' as status;