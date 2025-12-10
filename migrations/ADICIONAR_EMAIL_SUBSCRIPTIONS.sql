-- ============================================
-- 📧 ADICIONAR COLUNA EMAIL NA TABELA SUBSCRIPTIONS
-- Execute se quiser ter o email diretamente na tabela subscriptions
-- ============================================

-- ⚠️ OPCIONAL: Isto vai adicionar a coluna email para facilitar consultas
-- Se não quiser, ignore este arquivo

-- 1. Adicionar coluna email (se não existir)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'subscriptions' 
        AND column_name = 'email'
    ) THEN
        ALTER TABLE subscriptions 
        ADD COLUMN email text;
        
        RAISE NOTICE '✅ Coluna email adicionada à tabela subscriptions';
    ELSE
        RAISE NOTICE '⚠️ Coluna email já existe em subscriptions';
    END IF;
END $$;

-- 2. Preencher emails existentes a partir do user_approvals
UPDATE subscriptions s
SET email = ua.email
FROM user_approvals ua
WHERE s.user_id = ua.user_id
  AND s.email IS NULL;

-- 3. Criar índice para melhor performance
CREATE INDEX IF NOT EXISTS idx_subscriptions_email 
ON subscriptions(email);

-- 4. Criar trigger para manter email sincronizado
CREATE OR REPLACE FUNCTION sync_subscription_email()
RETURNS TRIGGER AS $$
BEGIN
  -- Quando criar uma nova subscription, busca o email do user_approvals
  IF NEW.email IS NULL THEN
    SELECT email INTO NEW.email
    FROM user_approvals
    WHERE user_id = NEW.user_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Remover trigger antigo se existir
DROP TRIGGER IF EXISTS sync_email_on_subscription_insert ON subscriptions;

-- Criar novo trigger
CREATE TRIGGER sync_email_on_subscription_insert
  BEFORE INSERT ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION sync_subscription_email();

-- ============================================
-- ✅ PRONTO! Agora:
-- - Coluna email adicionada em subscriptions
-- - Emails existentes preenchidos
-- - Novos registros terão email automaticamente
-- ============================================

SELECT 
  '✅ EMAIL CONFIGURADO!' as status,
  'A tabela subscriptions agora tem email' as mensagem;
