-- 🏢 CRIAÇÃO DAS TABELAS PARA SISTEMA DE EMPRESA E FUNCIONÁRIOS

-- =====================================
-- TABELA: empresas
-- =====================================
CREATE TABLE IF NOT EXISTS public.empresas (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    nome text NOT NULL,
    cnpj text,
    telefone text,
    email text,
    endereco text,
    cidade text,
    estado text,
    cep text,
    logo_url text,
    created_at timestamptz DEFAULT NOW() NOT NULL,
    updated_at timestamptz DEFAULT NOW() NOT NULL,
    
    -- Constraint: Uma empresa por usuário
    UNIQUE(user_id)
);

-- =====================================
-- TABELA: funcionarios  
-- =====================================
CREATE TABLE IF NOT EXISTS public.funcionarios (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id uuid REFERENCES empresas(id) ON DELETE CASCADE NOT NULL,
    nome text NOT NULL,
    email text NOT NULL,
    telefone text,
    cargo text,
    ativo boolean DEFAULT true NOT NULL,
    permissoes jsonb NOT NULL DEFAULT '{
        "vendas": true,
        "produtos": true,
        "clientes": true,
        "caixa": false,
        "ordens_servico": true,
        "relatorios": false,
        "configuracoes": false,
        "backup": false,
        "pode_criar_vendas": true,
        "pode_editar_vendas": false,
        "pode_cancelar_vendas": false,
        "pode_aplicar_desconto": false,
        "pode_criar_produtos": false,
        "pode_editar_produtos": false,
        "pode_deletar_produtos": false,
        "pode_gerenciar_estoque": false,
        "pode_criar_clientes": true,
        "pode_editar_clientes": true,
        "pode_deletar_clientes": false,
        "pode_abrir_caixa": false,
        "pode_fechar_caixa": false,
        "pode_gerenciar_movimentacoes": false,
        "pode_criar_os": true,
        "pode_editar_os": true,
        "pode_finalizar_os": false,
        "pode_ver_todos_relatorios": false,
        "pode_exportar_dados": false,
        "pode_alterar_configuracoes": false,
        "pode_gerenciar_funcionarios": false,
        "pode_fazer_backup": false
    }'::jsonb,
    created_at timestamptz DEFAULT NOW() NOT NULL,
    updated_at timestamptz DEFAULT NOW() NOT NULL,
    
    -- Constraint: Email único por empresa
    UNIQUE(empresa_id, email)
);

-- =====================================
-- TABELA: login_funcionarios
-- =====================================
CREATE TABLE IF NOT EXISTS public.login_funcionarios (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    funcionario_id uuid REFERENCES funcionarios(id) ON DELETE CASCADE NOT NULL,
    usuario text NOT NULL,
    senha text NOT NULL, -- Em produção usar hash
    ativo boolean DEFAULT true NOT NULL,
    ultimo_acesso timestamptz,
    created_at timestamptz DEFAULT NOW() NOT NULL,
    
    -- Constraint: Um login por funcionário
    UNIQUE(funcionario_id),
    -- Constraint: Nome de usuário único
    UNIQUE(usuario)
);

-- =====================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================
CREATE INDEX IF NOT EXISTS idx_empresas_user_id ON empresas(user_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_empresa_id ON funcionarios(empresa_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_email ON funcionarios(email);
CREATE INDEX IF NOT EXISTS idx_funcionarios_ativo ON funcionarios(ativo);
CREATE INDEX IF NOT EXISTS idx_login_funcionarios_funcionario_id ON login_funcionarios(funcionario_id);
CREATE INDEX IF NOT EXISTS idx_login_funcionarios_usuario ON login_funcionarios(usuario);

-- =====================================
-- POLÍTICAS RLS PARA EMPRESAS
-- =====================================
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can only see own empresa" ON empresas;
DROP POLICY IF EXISTS "Users can only insert own empresa" ON empresas;
DROP POLICY IF EXISTS "Users can only update own empresa" ON empresas;
DROP POLICY IF EXISTS "Users can only delete own empresa" ON empresas;

CREATE POLICY "Users can only see own empresa" ON empresas
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert own empresa" ON empresas
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update own empresa" ON empresas
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete own empresa" ON empresas
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================
-- POLÍTICAS RLS PARA FUNCIONARIOS
-- =====================================
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can only see own company funcionarios" ON funcionarios;
DROP POLICY IF EXISTS "Users can only insert own company funcionarios" ON funcionarios;
DROP POLICY IF EXISTS "Users can only update own company funcionarios" ON funcionarios;
DROP POLICY IF EXISTS "Users can only delete own company funcionarios" ON funcionarios;

CREATE POLICY "Users can only see own company funcionarios" ON funcionarios
    FOR SELECT USING (
        empresa_id IN (
            SELECT id FROM empresas WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can only insert own company funcionarios" ON funcionarios
    FOR INSERT WITH CHECK (
        empresa_id IN (
            SELECT id FROM empresas WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can only update own company funcionarios" ON funcionarios
    FOR UPDATE USING (
        empresa_id IN (
            SELECT id FROM empresas WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can only delete own company funcionarios" ON funcionarios
    FOR DELETE USING (
        empresa_id IN (
            SELECT id FROM empresas WHERE user_id = auth.uid()
        )
    );

-- =====================================
-- POLÍTICAS RLS PARA LOGIN_FUNCIONARIOS
-- =====================================
ALTER TABLE login_funcionarios ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can only see own company logins" ON login_funcionarios;
DROP POLICY IF EXISTS "Users can only insert own company logins" ON login_funcionarios;
DROP POLICY IF EXISTS "Users can only update own company logins" ON login_funcionarios;
DROP POLICY IF EXISTS "Users can only delete own company logins" ON login_funcionarios;

CREATE POLICY "Users can only see own company logins" ON login_funcionarios
    FOR SELECT USING (
        funcionario_id IN (
            SELECT f.id FROM funcionarios f
            JOIN empresas e ON f.empresa_id = e.id
            WHERE e.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can only insert own company logins" ON login_funcionarios
    FOR INSERT WITH CHECK (
        funcionario_id IN (
            SELECT f.id FROM funcionarios f
            JOIN empresas e ON f.empresa_id = e.id
            WHERE e.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can only update own company logins" ON login_funcionarios
    FOR UPDATE USING (
        funcionario_id IN (
            SELECT f.id FROM funcionarios f
            JOIN empresas e ON f.empresa_id = e.id
            WHERE e.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can only delete own company logins" ON login_funcionarios
    FOR DELETE USING (
        funcionario_id IN (
            SELECT f.id FROM funcionarios f
            JOIN empresas e ON f.empresa_id = e.id
            WHERE e.user_id = auth.uid()
        )
    );

-- =====================================
-- TRIGGERS PARA AUTO TIMESTAMPS
-- =====================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para empresas
DROP TRIGGER IF EXISTS trigger_empresas_updated_at ON empresas;
CREATE TRIGGER trigger_empresas_updated_at
    BEFORE UPDATE ON empresas
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger para funcionarios
DROP TRIGGER IF EXISTS trigger_funcionarios_updated_at ON funcionarios;
CREATE TRIGGER trigger_funcionarios_updated_at
    BEFORE UPDATE ON funcionarios
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =====================================
-- FUNÇÕES AUXILIARES
-- =====================================

-- Função para validar permissões
CREATE OR REPLACE FUNCTION public.validar_permissoes_funcionario(permissoes_json jsonb)
RETURNS boolean
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verificar se todas as chaves obrigatórias existem
    IF NOT (
        permissoes_json ? 'vendas' AND
        permissoes_json ? 'produtos' AND
        permissoes_json ? 'clientes' AND
        permissoes_json ? 'caixa' AND
        permissoes_json ? 'ordens_servico' AND
        permissoes_json ? 'relatorios' AND
        permissoes_json ? 'configuracoes' AND
        permissoes_json ? 'backup'
    ) THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
$$;

-- Função para obter funcionário por login
CREATE OR REPLACE FUNCTION public.get_funcionario_by_login(usuario_login text)
RETURNS TABLE (
    funcionario_id uuid,
    funcionario_nome text,
    funcionario_email text,
    funcionario_cargo text,
    funcionario_ativo boolean,
    funcionario_permissoes jsonb,
    empresa_id uuid,
    empresa_nome text,
    login_ativo boolean,
    ultimo_acesso timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.id,
        f.nome,
        f.email,
        f.cargo,
        f.ativo,
        f.permissoes,
        e.id,
        e.nome,
        lf.ativo,
        lf.ultimo_acesso
    FROM login_funcionarios lf
    JOIN funcionarios f ON lf.funcionario_id = f.id
    JOIN empresas e ON f.empresa_id = e.id
    WHERE lf.usuario = usuario_login
    AND lf.ativo = true
    AND f.ativo = true;
END;
$$;

-- Função para registrar último acesso
CREATE OR REPLACE FUNCTION public.registrar_ultimo_acesso_funcionario(usuario_login text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE login_funcionarios 
    SET ultimo_acesso = NOW()
    WHERE usuario = usuario_login;
    
    RETURN FOUND;
END;
$$;

-- =====================================
-- STORAGE BUCKET PARA LOGOS
-- =====================================

-- Criar bucket para logos das empresas (executar no console do Supabase)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('empresas', 'empresas', true);

-- Política de storage para logos
-- CREATE POLICY "Users can upload own company logo" ON storage.objects
-- FOR INSERT WITH CHECK (bucket_id = 'empresas' AND auth.uid()::text = (storage.foldername(name))[1]);

-- CREATE POLICY "Public can view logos" ON storage.objects
-- FOR SELECT USING (bucket_id = 'empresas');

-- CREATE POLICY "Users can update own company logo" ON storage.objects
-- FOR UPDATE USING (bucket_id = 'empresas' AND auth.uid()::text = (storage.foldername(name))[1]);

-- CREATE POLICY "Users can delete own company logo" ON storage.objects
-- FOR DELETE USING (bucket_id = 'empresas' AND auth.uid()::text = (storage.foldername(name))[1]);

-- =====================================
-- VERIFICAÇÃO FINAL
-- =====================================

-- Verificar se as tabelas foram criadas
SELECT 
    table_name,
    CASE 
        WHEN table_name IS NOT NULL THEN '✅ Criada'
        ELSE '❌ Erro'
    END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('empresas', 'funcionarios', 'login_funcionarios')
ORDER BY table_name;

-- Verificar se as políticas RLS estão ativas
SELECT 
    schemaname, 
    tablename, 
    policyname,
    CASE 
        WHEN policyname IS NOT NULL THEN '✅ Ativa'
        ELSE '❌ Inativa'
    END as status
FROM pg_policies 
WHERE schemaname = 'public'
AND tablename IN ('empresas', 'funcionarios', 'login_funcionarios')
ORDER BY tablename, policyname;

-- ✅ SISTEMA DE EMPRESA E FUNCIONÁRIOS CONFIGURADO!
SELECT '🏢 Sistema de Empresa e Funcionários configurado com sucesso!' as resultado;
