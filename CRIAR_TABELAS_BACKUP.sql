-- 🔍 VERIFICAÇÃO E CRIAÇÃO DE TABELAS PARA BACKUP

-- Verificar se todas as tabelas existem com coluna user_id
DO $$
DECLARE
    tabela_nome text;
    coluna_existe boolean;
BEGIN
    -- Lista das tabelas necessárias
    FOR tabela_nome IN SELECT unnest(ARRAY[
        'clientes', 'categorias', 'produtos', 'vendas', 
        'itens_venda', 'caixa', 'movimentacoes_caixa', 'ordens_servico', 'configuracoes'
    ])
    LOOP
        -- Verificar se tabela existe
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = tabela_nome
        ) THEN
            RAISE NOTICE '❌ Tabela % não existe!', tabela_nome;
            
            -- Criar tabelas básicas se não existirem
            CASE tabela_nome
                WHEN 'clientes' THEN
                    CREATE TABLE clientes (
                        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
                        user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
                        name text NOT NULL,
                        email text,
                        telefone text,
                        cpf text,
                        endereco text,
                        cidade text,
                        cep text,
                        created_at timestamptz DEFAULT NOW(),
                        updated_at timestamptz DEFAULT NOW()
                    );
                    RAISE NOTICE '✅ Tabela clientes criada';
                    
                WHEN 'categorias' THEN
                    CREATE TABLE categorias (
                        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
                        user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
                        name text NOT NULL,
                        cor text DEFAULT '#3B82F6',
                        ativo boolean DEFAULT true,
                        created_at timestamptz DEFAULT NOW(),
                        updated_at timestamptz DEFAULT NOW()
                    );
                    RAISE NOTICE '✅ Tabela categorias criada';
                    
                WHEN 'produtos' THEN
                    CREATE TABLE produtos (
                        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
                        user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
                        name text NOT NULL,
                        preco numeric(10,2) DEFAULT 0,
                        codigo text,
                        categoria text,
                        estoque integer DEFAULT 0,
                        ativo boolean DEFAULT true,
                        created_at timestamptz DEFAULT NOW(),
                        updated_at timestamptz DEFAULT NOW()
                    );
                    RAISE NOTICE '✅ Tabela produtos criada';
                    
                WHEN 'vendas' THEN
                    CREATE TABLE vendas (
                        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
                        user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
                        cliente_id uuid REFERENCES clientes(id),
                        total numeric(10,2) DEFAULT 0,
                        desconto numeric(10,2) DEFAULT 0,
                        status text DEFAULT 'finalizada',
                        created_at timestamptz DEFAULT NOW(),
                        updated_at timestamptz DEFAULT NOW()
                    );
                    RAISE NOTICE '✅ Tabela vendas criada';
                    
                WHEN 'itens_venda' THEN
                    CREATE TABLE itens_venda (
                        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
                        user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
                        venda_id uuid REFERENCES vendas(id) ON DELETE CASCADE,
                        produto_id uuid REFERENCES produtos(id),
                        quantidade integer DEFAULT 1,
                        preco_unitario numeric(10,2) DEFAULT 0,
                        subtotal numeric(10,2) DEFAULT 0,
                        created_at timestamptz DEFAULT NOW()
                    );
                    RAISE NOTICE '✅ Tabela itens_venda criada';
                    
                WHEN 'caixa' THEN
                    CREATE TABLE caixa (
                        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
                        user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
                        data_abertura timestamptz DEFAULT NOW(),
                        data_fechamento timestamptz,
                        valor_inicial numeric(10,2) DEFAULT 0,
                        valor_final numeric(10,2) DEFAULT 0,
                        status text DEFAULT 'aberto',
                        created_at timestamptz DEFAULT NOW(),
                        updated_at timestamptz DEFAULT NOW()
                    );
                    RAISE NOTICE '✅ Tabela caixa criada';
                    
                WHEN 'movimentacoes_caixa' THEN
                    CREATE TABLE movimentacoes_caixa (
                        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
                        user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
                        caixa_id uuid REFERENCES caixa(id) ON DELETE CASCADE,
                        tipo text NOT NULL, -- 'entrada' ou 'saida'
                        valor numeric(10,2) NOT NULL,
                        descricao text,
                        created_at timestamptz DEFAULT NOW()
                    );
                    RAISE NOTICE '✅ Tabela movimentacoes_caixa criada';
                    
                WHEN 'configuracoes' THEN
                    CREATE TABLE configuracoes (
                        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
                        user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
                        chave text NOT NULL,
                        valor jsonb,
                        created_at timestamptz DEFAULT NOW(),
                        updated_at timestamptz DEFAULT NOW(),
                        UNIQUE(user_id, chave)
                    );
                    RAISE NOTICE '✅ Tabela configuracoes criada';
                    
                WHEN 'ordens_servico' THEN
                    CREATE TABLE ordens_servico (
                        id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
                        user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
                        cliente_id uuid REFERENCES clientes(id),
                        equipamento text NOT NULL,
                        defeito text NOT NULL,
                        status text DEFAULT 'aguardando',
                        data_entrada timestamptz DEFAULT NOW(),
                        data_previsao timestamptz,
                        valor numeric(10,2) DEFAULT 0,
                        observacoes text,
                        created_at timestamptz DEFAULT NOW(),
                        updated_at timestamptz DEFAULT NOW()
                    );
                    RAISE NOTICE '✅ Tabela ordens_servico criada';
                    
                ELSE
                    RAISE NOTICE '⚠️ Não sei como criar tabela %', tabela_nome;
            END CASE;
        ELSE
            -- Verificar se tem coluna user_id
            SELECT EXISTS (
                SELECT 1 FROM information_schema.columns 
                WHERE table_schema = 'public' 
                AND table_name = tabela_nome 
                AND column_name = 'user_id'
            ) INTO coluna_existe;
            
            IF NOT coluna_existe THEN
                RAISE NOTICE '⚠️ Tabela % existe mas não tem coluna user_id', tabela_nome;
                
                -- Adicionar coluna user_id
                EXECUTE format('ALTER TABLE %I ADD COLUMN user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE', tabela_nome);
                RAISE NOTICE '✅ Coluna user_id adicionada à tabela %', tabela_nome;
            ELSE
                RAISE NOTICE '✅ Tabela % OK (tem user_id)', tabela_nome;
            END IF;
        END IF;
    END LOOP;
END $$;

-- Verificar resultado final
SELECT 
    t.table_name,
    CASE 
        WHEN c.column_name IS NOT NULL THEN '✅ OK'
        ELSE '❌ SEM user_id'
    END as status
FROM information_schema.tables t
LEFT JOIN information_schema.columns c ON (
    c.table_name = t.table_name 
    AND c.table_schema = t.table_schema 
    AND c.column_name = 'user_id'
)
WHERE t.table_schema = 'public'
AND t.table_name IN (
    'clientes', 'categorias', 'produtos', 'vendas', 
    'itens_venda', 'caixa', 'movimentacoes_caixa', 'ordens_servico', 'configuracoes'
)
ORDER BY t.table_name;
