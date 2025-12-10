-- ===== DIAGNÓSTICO DO SISTEMA DE FUNCIONÁRIOS =====
-- Verificar o que está causando o erro de login dos funcionários

DO $$
BEGIN
    RAISE NOTICE '🔍 === DIAGNÓSTICO DE FUNCIONÁRIOS ===';
    RAISE NOTICE '';
END $$;

-- 1. VERIFICAR TABELAS ESSENCIAIS
DO $$
DECLARE
    tabela text;
    existe boolean;
BEGIN
    RAISE NOTICE '📋 VERIFICANDO TABELAS ESSENCIAIS:';
    
    FOREACH tabela IN ARRAY ARRAY['funcionarios', 'empresas', 'user_approvals']
    LOOP
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_name = tabela
        ) INTO existe;
        
        IF existe THEN
            RAISE NOTICE '  ✅ Tabela % existe', tabela;
        ELSE
            RAISE NOTICE '  ❌ Tabela % NÃO EXISTE', tabela;
        END IF;
    END LOOP;
END $$;

-- 2. VERIFICAR FUNÇÕES RPC
DO $$
DECLARE
    funcao text;
    existe boolean;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '⚙️  VERIFICANDO FUNÇÕES RPC:';
    
    FOREACH funcao IN ARRAY ARRAY['listar_usuarios_ativos', 'generate_verification_code', 'verify_whatsapp_code']
    LOOP
        SELECT EXISTS (
            SELECT FROM information_schema.routines 
            WHERE routine_name = funcao
        ) INTO existe;
        
        IF existe THEN
            RAISE NOTICE '  ✅ Função % existe', funcao;
        ELSE
            RAISE NOTICE '  ❌ Função % NÃO EXISTE', funcao;
        END IF;
    END LOOP;
END $$;

-- 3. VERIFICAR DADOS EXISTENTES (se tabelas existem)
DO $$
DECLARE
    count_funcionarios integer := 0;
    count_empresas integer := 0;
    count_approvals integer := 0;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '📊 VERIFICANDO DADOS EXISTENTES:';
    
    -- Funcionários
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcionarios') THEN
        EXECUTE 'SELECT COUNT(*) FROM funcionarios' INTO count_funcionarios;
        RAISE NOTICE '  👥 Funcionários: % registros', count_funcionarios;
    END IF;
    
    -- Empresas
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'empresas') THEN
        EXECUTE 'SELECT COUNT(*) FROM empresas' INTO count_empresas;
        RAISE NOTICE '  🏢 Empresas: % registros', count_empresas;
    END IF;
    
    -- User Approvals
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_approvals') THEN
        EXECUTE 'SELECT COUNT(*) FROM user_approvals' INTO count_approvals;
        RAISE NOTICE '  📝 User Approvals: % registros', count_approvals;
    END IF;
END $$;

-- 4. VERIFICAR ESTRUTURA DAS TABELAS (se existem)
DO $$
DECLARE
    col_info RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔍 ESTRUTURA DAS TABELAS:';
    
    -- Estrutura da tabela funcionarios
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcionarios') THEN
        RAISE NOTICE '';
        RAISE NOTICE '  📋 Colunas da tabela funcionarios:';
        FOR col_info IN
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'funcionarios'
            ORDER BY ordinal_position
        LOOP
            RAISE NOTICE '    - % (%, nullable: %)', 
                col_info.column_name, 
                col_info.data_type, 
                col_info.is_nullable;
        END LOOP;
    END IF;
    
    -- Estrutura da tabela empresas
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'empresas') THEN
        RAISE NOTICE '';
        RAISE NOTICE '  📋 Colunas da tabela empresas:';
        FOR col_info IN
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'empresas'
            ORDER BY ordinal_position
        LOOP
            RAISE NOTICE '    - % (%, nullable: %)', 
                col_info.column_name, 
                col_info.data_type, 
                col_info.is_nullable;
        END LOOP;
    END IF;
END $$;

-- 5. VERIFICAR POLÍTICAS RLS
DO $$
DECLARE
    policy_record RECORD;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🔒 POLÍTICAS RLS:';
    
    FOR policy_record IN
        SELECT tablename, policyname, permissive, roles, cmd
        FROM pg_policies
        WHERE tablename IN ('funcionarios', 'empresas', 'user_approvals')
        ORDER BY tablename, policyname
    LOOP
        RAISE NOTICE '  🔐 %.% - %', 
            policy_record.tablename,
            policy_record.policyname,
            policy_record.cmd;
    END LOOP;
END $$;

-- 6. VERIFICAR AUTH USERS
DO $$
DECLARE
    auth_count integer := 0;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '👤 VERIFICANDO AUTH.USERS:';
    
    SELECT COUNT(*) INTO auth_count FROM auth.users;
    RAISE NOTICE '  📈 Total de usuários autenticados: %', auth_count;
    
    -- Mostrar alguns exemplos (sem dados sensíveis)
    IF auth_count > 0 THEN
        RAISE NOTICE '  📋 Usuários encontrados:';
        FOR i IN 1..LEAST(auth_count, 5) LOOP
            RAISE NOTICE '    - Usuário % (email: %)', 
                i, 
                COALESCE((SELECT email FROM auth.users LIMIT 1 OFFSET i-1), 'N/A');
        END LOOP;
    END IF;
END $$;

RAISE NOTICE '';
RAISE NOTICE '🎯 === DIAGNÓSTICO CONCLUÍDO ===';
RAISE NOTICE '';
RAISE NOTICE '💡 POSSÍVEIS CAUSAS DO PROBLEMA:';
RAISE NOTICE '   1. Tabelas funcionarios/empresas foram removidas';
RAISE NOTICE '   2. Funções RPC não existem';
RAISE NOTICE '   3. Políticas RLS bloqueando acesso';
RAISE NOTICE '   4. Dados foram perdidos na limpeza';
RAISE NOTICE '';