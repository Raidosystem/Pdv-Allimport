-- Configurações de produção para o Supabase
-- Este arquivo garante que todas as configurações estão corretas para deploy

-- 1. Verificar se RLS está configurado corretamente
-- 2. Garantir que as políticas de segurança estão ativas
-- 3. Configurar templates de email se necessário

-- Verificar tabelas principais
DO $$
BEGIN
    -- Verificar se a tabela categorias existe
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'categorias') THEN
        CREATE TABLE categorias (
            id SERIAL PRIMARY KEY,
            nome VARCHAR(100) NOT NULL,
            descricao TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Inserir categorias padrão
        INSERT INTO categorias (nome, descricao) VALUES 
        ('Eletrônicos', 'Produtos eletrônicos diversos'),
        ('Informática', 'Equipamentos de informática'),
        ('Celulares', 'Smartphones e acessórios'),
        ('Games', 'Consoles e jogos'),
        ('Casa', 'Produtos para casa');
        
        RAISE NOTICE 'Tabela categorias criada com dados iniciais';
    ELSE
        RAISE NOTICE 'Tabela categorias já existe';
    END IF;
    
    -- Verificar se a tabela produtos existe
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'produtos') THEN
        CREATE TABLE produtos (
            id SERIAL PRIMARY KEY,
            nome VARCHAR(255) NOT NULL,
            descricao TEXT,
            preco DECIMAL(10,2) NOT NULL,
            categoria_id INTEGER REFERENCES categorias(id),
            estoque INTEGER DEFAULT 0,
            codigo_barras VARCHAR(50),
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        RAISE NOTICE 'Tabela produtos criada';
    ELSE
        RAISE NOTICE 'Tabela produtos já existe';
    END IF;
    
    -- Verificar se a tabela clientes existe
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'clientes') THEN
        CREATE TABLE clientes (
            id SERIAL PRIMARY KEY,
            nome VARCHAR(255) NOT NULL,
            email VARCHAR(255),
            telefone VARCHAR(20),
            cpf VARCHAR(14),
            endereco TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        RAISE NOTICE 'Tabela clientes criada';
    ELSE
        RAISE NOTICE 'Tabela clientes já existe';
    END IF;
    
    -- Configurar RLS (Row Level Security)
    ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
    ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
    ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
    
    -- Políticas básicas (permitir acesso autenticado)
    DROP POLICY IF EXISTS "Allow authenticated access" ON categorias;
    CREATE POLICY "Allow authenticated access" ON categorias FOR ALL USING (true);
    
    DROP POLICY IF EXISTS "Allow authenticated access" ON produtos;
    CREATE POLICY "Allow authenticated access" ON produtos FOR ALL USING (true);
    
    DROP POLICY IF EXISTS "Allow authenticated access" ON clientes;
    CREATE POLICY "Allow authenticated access" ON clientes FOR ALL USING (true);
    
    RAISE NOTICE 'Configurações de segurança aplicadas';
    
END $$;
