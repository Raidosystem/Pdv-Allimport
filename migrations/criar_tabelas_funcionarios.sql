-- Criar tabelas para sistema de funcionários/usuários
-- Baseado na estrutura esperada pelo AdminUsersPage.tsx

-- 1. Tabela de funções/cargos
CREATE TABLE IF NOT EXISTS funcoes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    nivel INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabela de funcionários
CREATE TABLE IF NOT EXISTS funcionarios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    empresa_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    nome VARCHAR(255),
    telefone VARCHAR(20),
    status VARCHAR(20) DEFAULT 'pendente' CHECK (status IN ('ativo', 'inativo', 'pendente')),
    convite_token UUID DEFAULT gen_random_uuid(),
    convite_expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '7 days'),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Tabela de relacionamento funcionário-funções (many-to-many)
CREATE TABLE IF NOT EXISTS funcionario_funcoes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    funcionario_id UUID REFERENCES funcionarios(id) ON DELETE CASCADE,
    funcao_id UUID REFERENCES funcoes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(funcionario_id, funcao_id)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_funcionarios_empresa_id ON funcionarios(empresa_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_email ON funcionarios(email);
CREATE INDEX IF NOT EXISTS idx_funcionarios_status ON funcionarios(status);
CREATE INDEX IF NOT EXISTS idx_funcoes_empresa_id ON funcoes(empresa_id);
CREATE INDEX IF NOT EXISTS idx_funcionario_funcoes_funcionario_id ON funcionario_funcoes(funcionario_id);
CREATE INDEX IF NOT EXISTS idx_funcionario_funcoes_funcao_id ON funcionario_funcoes(funcao_id);

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_funcionarios_updated_at BEFORE UPDATE ON funcionarios FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_funcoes_updated_at BEFORE UPDATE ON funcoes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Políticas RLS (Row Level Security)
ALTER TABLE funcoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE funcionario_funcoes ENABLE ROW LEVEL SECURITY;

-- Políticas para funcoes
CREATE POLICY "Usuários podem ver funções da própria empresa" ON funcoes
    FOR SELECT USING (
        empresa_id = auth.uid() OR 
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

CREATE POLICY "Usuários podem criar funções na própria empresa" ON funcoes
    FOR INSERT WITH CHECK (
        empresa_id = auth.uid() OR 
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

CREATE POLICY "Usuários podem atualizar funções da própria empresa" ON funcoes
    FOR UPDATE USING (
        empresa_id = auth.uid() OR 
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- Políticas para funcionarios
CREATE POLICY "Usuários podem ver funcionários da própria empresa" ON funcionarios
    FOR SELECT USING (
        empresa_id = auth.uid() OR 
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

CREATE POLICY "Usuários podem criar funcionários na própria empresa" ON funcionarios
    FOR INSERT WITH CHECK (
        empresa_id = auth.uid() OR 
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

CREATE POLICY "Usuários podem atualizar funcionários da própria empresa" ON funcionarios
    FOR UPDATE USING (
        empresa_id = auth.uid() OR 
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- Políticas para funcionario_funcoes
CREATE POLICY "Usuários podem ver relações funcionário-função da própria empresa" ON funcionario_funcoes
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM funcionarios f 
            WHERE f.id = funcionario_funcoes.funcionario_id 
            AND (f.empresa_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
        )
    );

CREATE POLICY "Usuários podem criar relações funcionário-função da própria empresa" ON funcionario_funcoes
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM funcionarios f 
            WHERE f.id = funcionario_funcoes.funcionario_id 
            AND (f.empresa_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
        )
    );

CREATE POLICY "Usuários podem atualizar relações funcionário-função da própria empresa" ON funcionario_funcoes
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM funcionarios f 
            WHERE f.id = funcionario_funcoes.funcionario_id 
            AND (f.empresa_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
        )
    );

-- Inserir funções padrão para o admin atual
INSERT INTO funcoes (empresa_id, nome, descricao, nivel) VALUES
    ((SELECT id FROM auth.users WHERE email = 'admin@pdv.com'), 'Administrador', 'Acesso completo ao sistema', 5),
    ((SELECT id FROM auth.users WHERE email = 'admin@pdv.com'), 'Gerente', 'Acesso gerencial com permissões elevadas', 4),
    ((SELECT id FROM auth.users WHERE email = 'admin@pdv.com'), 'Vendedor', 'Acesso a vendas e clientes', 3),
    ((SELECT id FROM auth.users WHERE email = 'admin@pdv.com'), 'Caixa', 'Acesso ao caixa e operações básicas', 2),
    ((SELECT id FROM auth.users WHERE email = 'admin@pdv.com'), 'Funcionário', 'Acesso básico ao sistema', 1)
ON CONFLICT DO NOTHING;

-- Criar funcionário admin baseado no profile existente
INSERT INTO funcionarios (
    empresa_id, 
    email, 
    nome, 
    status
) 
SELECT 
    id as empresa_id,
    email,
    name as nome,
    'ativo' as status
FROM profiles 
WHERE email = 'admin@pdv.com'
ON CONFLICT (email) DO NOTHING;

-- Relacionar funcionário admin com função administrador
INSERT INTO funcionario_funcoes (funcionario_id, funcao_id)
SELECT 
    f.id as funcionario_id,
    fu.id as funcao_id
FROM funcionarios f
CROSS JOIN funcoes fu
WHERE f.email = 'admin@pdv.com' 
AND fu.nome = 'Administrador'
ON CONFLICT (funcionario_id, funcao_id) DO NOTHING;

-- Verificar o resultado
SELECT 
    'Tabelas criadas:' as status,
    (SELECT COUNT(*) FROM funcoes) as total_funcoes,
    (SELECT COUNT(*) FROM funcionarios) as total_funcionarios,
    (SELECT COUNT(*) FROM funcionario_funcoes) as total_relacoes;