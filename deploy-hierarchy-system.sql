-- =============================================
-- SISTEMA DE HIERARQUIA DE USUÁRIOS E PERMISSÕES
-- =============================================

-- Tabela de tipos de usuário
CREATE TABLE IF NOT EXISTS public.user_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserir tipos de usuário
INSERT INTO public.user_types (name, description) VALUES 
('admin', 'Administrador do sistema'),
('owner', 'Dono da empresa (quem comprou o sistema)'),
('employee', 'Funcionário da empresa')
ON CONFLICT (name) DO NOTHING;

-- Tabela de perfis de usuário
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    owner_id UUID REFERENCES auth.users(id), -- Para funcionários, referencia o dono
    user_type VARCHAR(50) REFERENCES user_types(name) DEFAULT 'employee',
    company_name VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de módulos do sistema
CREATE TABLE IF NOT EXISTS public.system_modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    path VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inserir módulos do sistema
INSERT INTO public.system_modules (name, display_name, description, icon, path) VALUES 
('sales', 'Vendas', 'Módulo de vendas e PDV', 'ShoppingCart', '/vendas'),
('products', 'Produtos', 'Gestão de produtos e estoque', 'Package', '/produtos'),
('clients', 'Clientes', 'Cadastro e gestão de clientes', 'Users', '/clientes'),
('cashier', 'Caixa', 'Controle de caixa e movimento', 'DollarSign', '/caixa'),
('orders', 'Ordens de Serviço', 'Gestão de ordens de serviço', 'FileText', '/ordens-servico'),
('reports', 'Relatórios', 'Relatórios e análises', 'BarChart3', '/relatorios'),
('settings', 'Configurações', 'Configurações da empresa', 'Settings', '/configuracoes'),
('admin', 'Administração', 'Administração do sistema', 'Shield', '/admin')
ON CONFLICT (name) DO NOTHING;

-- Tabela de permissões por usuário
CREATE TABLE IF NOT EXISTS public.user_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    module_name VARCHAR(100) REFERENCES system_modules(name) NOT NULL,
    can_view BOOLEAN DEFAULT false,
    can_create BOOLEAN DEFAULT false,
    can_edit BOOLEAN DEFAULT false,
    can_delete BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, module_name)
);

-- Tabela de funcionários
CREATE TABLE IF NOT EXISTS public.employees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    position VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS nas novas tabelas
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;

-- Políticas para user_profiles
CREATE POLICY "Users can see their own profile" ON public.user_profiles 
FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Owners can see their employees profiles" ON public.user_profiles 
FOR SELECT USING (auth.uid() = owner_id);

-- Políticas para user_permissions
CREATE POLICY "Users can see their own permissions" ON public.user_permissions 
FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Owners can manage employee permissions" ON public.user_permissions 
FOR ALL USING (
    auth.uid() IN (
        SELECT owner_id FROM user_profiles WHERE user_id = user_permissions.user_id
    )
);

-- Políticas para employees
CREATE POLICY "Owners can manage their employees" ON public.employees 
FOR ALL USING (auth.uid() = owner_id);

-- Função para verificar se é admin
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    target_user_id UUID;
    user_email TEXT;
BEGIN
    target_user_id := COALESCE(user_id, auth.uid());
    
    SELECT email INTO user_email FROM auth.users WHERE id = target_user_id;
    
    -- Lista de emails de admin
    RETURN user_email IN (
        'admin@pdvallimport.com',
        'novaradiosystem@outlook.com',
        'teste@teste.com'
    );
END;
$$;

-- Função para verificar se é dono
CREATE OR REPLACE FUNCTION public.is_owner(user_id UUID DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    target_user_id UUID;
    profile_type TEXT;
BEGIN
    target_user_id := COALESCE(user_id, auth.uid());
    
    SELECT user_type INTO profile_type 
    FROM user_profiles 
    WHERE user_id = target_user_id;
    
    RETURN COALESCE(profile_type, 'employee') = 'owner';
END;
$$;

-- Função para obter permissões do usuário
CREATE OR REPLACE FUNCTION public.get_user_permissions(user_id UUID DEFAULT NULL)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    target_user_id UUID;
    permissions_data JSONB;
    is_admin_user BOOLEAN;
    is_owner_user BOOLEAN;
BEGIN
    target_user_id := COALESCE(user_id, auth.uid());
    
    -- Verificar se é admin
    SELECT public.is_admin(target_user_id) INTO is_admin_user;
    
    -- Verificar se é owner
    SELECT public.is_owner(target_user_id) INTO is_owner_user;
    
    -- Admin vê tudo
    IF is_admin_user THEN
        SELECT jsonb_object_agg(
            sm.name,
            jsonb_build_object(
                'can_view', true,
                'can_create', true,
                'can_edit', true,
                'can_delete', true,
                'display_name', sm.display_name,
                'icon', sm.icon,
                'path', sm.path
            )
        ) INTO permissions_data
        FROM system_modules sm
        WHERE sm.is_active = true;
        
    -- Owner vê tudo exceto admin
    ELSIF is_owner_user THEN
        SELECT jsonb_object_agg(
            sm.name,
            jsonb_build_object(
                'can_view', true,
                'can_create', true,
                'can_edit', true,
                'can_delete', true,
                'display_name', sm.display_name,
                'icon', sm.icon,
                'path', sm.path
            )
        ) INTO permissions_data
        FROM system_modules sm
        WHERE sm.is_active = true AND sm.name != 'admin';
        
    -- Funcionário vê apenas o que foi liberado
    ELSE
        SELECT jsonb_object_agg(
            sm.name,
            jsonb_build_object(
                'can_view', COALESCE(up.can_view, false),
                'can_create', COALESCE(up.can_create, false),
                'can_edit', COALESCE(up.can_edit, false),
                'can_delete', COALESCE(up.can_delete, false),
                'display_name', sm.display_name,
                'icon', sm.icon,
                'path', sm.path
            )
        ) INTO permissions_data
        FROM system_modules sm
        LEFT JOIN user_permissions up ON sm.name = up.module_name AND up.user_id = target_user_id
        WHERE sm.is_active = true AND sm.name != 'admin' AND sm.name != 'settings'
        AND COALESCE(up.can_view, false) = true;
    END IF;
    
    RETURN COALESCE(permissions_data, '{}'::jsonb);
END;
$$;

-- Função para criar perfil de usuário automaticamente
CREATE OR REPLACE FUNCTION public.create_user_profile()
RETURNS TRIGGER AS $$
DECLARE
    user_email TEXT;
    profile_type TEXT;
BEGIN
    -- Pegar email do usuário
    SELECT email INTO user_email FROM auth.users WHERE id = NEW.id;
    
    -- Determinar tipo de usuário
    IF public.is_admin(NEW.id) THEN
        profile_type := 'admin';
    ELSE
        profile_type := 'owner'; -- Por padrão, novos usuários são owners
    END IF;
    
    -- Criar perfil
    INSERT INTO public.user_profiles (user_id, user_type)
    VALUES (NEW.id, profile_type)
    ON CONFLICT (user_id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para criar perfil automaticamente
CREATE TRIGGER create_profile_on_user_creation
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.create_user_profile();

-- Conceder permissões
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_types TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_profiles TO authenticated;
GRANT SELECT ON public.system_modules TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_permissions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.employees TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;

SELECT 'Sistema de hierarquia de usuários criado com sucesso!' as status;
