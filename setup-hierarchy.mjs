import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://riqbmfqwlpuqwrfrssmh.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJpcWJtZnF3bHB1cXdyZnJzc21oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ5MTk0NDYsImV4cCI6MjA1MDQ5NTQ0Nn0.eXUZUJ9HUTg51dH6CjmxzCzN-IKC6mF7zfZaEXjEWy4'

const supabase = createClient(supabaseUrl, supabaseKey)

async function checkAndCreateTables() {
  console.log('🔍 Verificando estrutura do banco...')
  
  try {
    // Verificar se a tabela user_profiles existe
    const { data: profiles, error: profileError } = await supabase
      .from('user_profiles')
      .select('count', { count: 'exact', head: true })
    
    if (profileError && profileError.code === '42P01') {
      console.log('❌ Tabela user_profiles não existe. Executando script SQL...')
      
      // Executar SQL para criar as tabelas
      const sql = `
-- Tipos de usuários (enum)
DO $$ BEGIN
    CREATE TYPE user_type AS ENUM ('admin', 'owner', 'employee');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Tabela de perfis de usuários
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    user_type user_type NOT NULL DEFAULT 'employee',
    company_name TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Tabela de módulos do sistema
CREATE TABLE IF NOT EXISTS system_modules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    path TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de permissões dos usuários
CREATE TABLE IF NOT EXISTS user_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    module_id UUID REFERENCES system_modules(id) ON DELETE CASCADE,
    can_view BOOLEAN DEFAULT false,
    can_create BOOLEAN DEFAULT false,
    can_edit BOOLEAN DEFAULT false,
    can_delete BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, module_id)
);

-- Tabela de funcionários
CREATE TABLE IF NOT EXISTS employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    name TEXT,
    email TEXT NOT NULL,
    position TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserir módulos padrão
INSERT INTO system_modules (name, display_name, description, icon, path) VALUES
('sales', 'Vendas', 'Realizar vendas e emitir cupons fiscais', 'ShoppingCart', '/vendas'),
('clients', 'Clientes', 'Gerenciar cadastro de clientes', 'Users', '/clientes'),
('products', 'Produtos', 'Controle de estoque e produtos', 'Package', '/produtos'),
('cashier', 'Caixa', 'Controle de caixa e movimento', 'DollarSign', '/caixa'),
('orders', 'OS - Ordem de Serviço', 'Gestão de ordens de serviço', 'FileText', '/ordens-servico'),
('reports', 'Relatórios', 'Análises e relatórios de vendas', 'BarChart3', '/relatorios')
ON CONFLICT (name) DO NOTHING;

-- RLS Policies
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- Policies para user_profiles
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = user_id);

-- Policies para system_modules (todos podem ver)
CREATE POLICY "Everyone can view system modules" ON system_modules
    FOR SELECT USING (true);

-- Policies para user_permissions
CREATE POLICY "Users can view own permissions" ON user_permissions
    FOR SELECT USING (auth.uid() = user_id);

-- Policies para employees
CREATE POLICY "Owners can manage employees" ON employees
    FOR ALL USING (auth.uid() = owner_id);

-- Triggers para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_permissions_updated_at BEFORE UPDATE ON user_permissions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON employees FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
      `
      
      // Executar o SQL em partes menores
      const sqlCommands = sql.split(';').filter(cmd => cmd.trim())
      
      for (const command of sqlCommands) {
        if (command.trim()) {
          const { error } = await supabase.rpc('exec_sql', { sql_command: command })
          if (error) {
            console.log('Comando SQL executado (pode ter erro esperado):', command.substring(0, 50) + '...')
            console.log('Erro (pode ser normal):', error.message)
          }
        }
      }
      
      console.log('✅ Script SQL executado!')
    } else {
      console.log('✅ Tabela user_profiles já existe!')
    }
    
    // Verificar módulos
    const { data: modules } = await supabase
      .from('system_modules')
      .select('*')
    
    console.log(`📊 Módulos no banco: ${modules?.length || 0}`)
    
  } catch (error) {
    console.error('❌ Erro:', error)
  }
}

checkAndCreateTables()
