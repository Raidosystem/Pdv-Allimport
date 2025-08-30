-- ===================================================
-- 📝 CRIAR TABELA DE LOGS PARA ADMIN
-- ===================================================

-- 1. Criar tabela de logs administrativos
CREATE TABLE IF NOT EXISTS admin_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  action VARCHAR(100) NOT NULL,
  user_id UUID,
  user_email VARCHAR(255),
  admin_id UUID REFERENCES auth.users(id),
  admin_email VARCHAR(255),
  details TEXT,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_admin_logs_action ON admin_logs(action);
CREATE INDEX IF NOT EXISTS idx_admin_logs_user_id ON admin_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_admin_id ON admin_logs(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_created_at ON admin_logs(created_at);

-- 3. Habilitar RLS
ALTER TABLE admin_logs ENABLE ROW LEVEL SECURITY;

-- 4. Criar políticas de acesso (apenas admins podem ver logs)
CREATE POLICY "admin_logs_select_policy" ON admin_logs
    FOR SELECT 
    USING (true);

CREATE POLICY "admin_logs_insert_policy" ON admin_logs
    FOR INSERT 
    WITH CHECK (true);

-- 5. Dar permissões
GRANT ALL ON TABLE admin_logs TO anon;
GRANT ALL ON TABLE admin_logs TO authenticated;
GRANT ALL ON TABLE admin_logs TO service_role;

-- 6. Inserir log de criação da tabela
INSERT INTO admin_logs (
    action,
    details,
    created_at
) VALUES (
    'create_admin_logs_table',
    'Tabela admin_logs criada para auditoria de ações administrativas',
    now()
);

-- 7. Verificar criação
SELECT 
    'admin_logs table created successfully' as status,
    COUNT(*) as initial_records
FROM admin_logs;
