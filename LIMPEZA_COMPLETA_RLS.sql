-- =========================================================================
-- LIMPEZA COMPLETA DE POLÍTICAS RLS - RESOLVER CONFLITOS
-- PROBLEMA: Múltiplas políticas conflitantes estão causando vazamento de dados
-- SOLUÇÃO: Remover TODAS as políticas e criar apenas as necessárias
-- =========================================================================

-- PASSO 1: DESABILITAR RLS PARA LIMPEZA COMPLETA
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;

-- PASSO 2: REMOVER TODAS AS POLÍTICAS EXISTENTES (LIMPEZA TOTAL)
DO $$
DECLARE
    pol RECORD;
BEGIN
    RAISE NOTICE 'Iniciando limpeza completa de políticas...';
    
    -- Remover TODAS as políticas de clientes
    FOR pol IN (SELECT policyname FROM pg_policies WHERE tablename = 'clientes') LOOP
        EXECUTE format('DROP POLICY %I ON clientes', pol.policyname);
        RAISE NOTICE 'Removida política de clientes: %', pol.policyname;
    END LOOP;
    
    -- Remover TODAS as políticas de produtos
    FOR pol IN (SELECT policyname FROM pg_policies WHERE tablename = 'produtos') LOOP
        EXECUTE format('DROP POLICY %I ON produtos', pol.policyname);
        RAISE NOTICE 'Removida política de produtos: %', pol.policyname;
    END LOOP;
    
    RAISE NOTICE 'Limpeza de políticas concluída!';
END
$$;

-- PASSO 3: ENCONTRAR E USAR UUID VÁLIDO
DO $$
DECLARE
    usuario_target UUID;
    clientes_count INTEGER;
    produtos_count INTEGER;
BEGIN
    -- Encontrar usuário existente
    SELECT id INTO usuario_target 
    FROM auth.users 
    WHERE email = 'assistenciaallimport10@gmail.com';
    
    IF usuario_target IS NULL THEN
        SELECT id INTO usuario_target 
        FROM auth.users 
        ORDER BY created_at 
        LIMIT 1;
    END IF;
    
    IF usuario_target IS NULL THEN
        RAISE EXCEPTION 'Nenhum usuário encontrado em auth.users';
    END IF;
    
    RAISE NOTICE 'UUID utilizado: %', usuario_target;
    RAISE NOTICE 'Email: %', (SELECT email FROM auth.users WHERE id = usuario_target);
    
    -- Unificar dados para este UUID
    UPDATE clientes SET user_id = usuario_target WHERE user_id IS NULL OR user_id != usuario_target;
    UPDATE produtos SET user_id = usuario_target WHERE user_id IS NULL OR user_id != usuario_target;
    
    -- Verificar resultados
    SELECT COUNT(*) INTO clientes_count FROM clientes WHERE user_id = usuario_target;
    SELECT COUNT(*) INTO produtos_count FROM produtos WHERE user_id = usuario_target;
    
    RAISE NOTICE 'Clientes associados: %', clientes_count;
    RAISE NOTICE 'Produtos associados: %', produtos_count;
    
    -- CRIAR APENAS UMA POLÍTICA POR TABELA (SIMPLES E EFETIVA)
    EXECUTE format('CREATE POLICY "isolamento_clientes" ON clientes FOR ALL USING (user_id = %L) WITH CHECK (user_id = %L)', usuario_target, usuario_target);
    EXECUTE format('CREATE POLICY "isolamento_produtos" ON produtos FOR ALL USING (user_id = %L) WITH CHECK (user_id = %L)', usuario_target, usuario_target);
    
    RAISE NOTICE 'Políticas criadas: isolamento_clientes, isolamento_produtos';
END
$$;

-- PASSO 4: REABILITAR RLS
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

-- PASSO 5: VERIFICAÇÃO FINAL
SELECT 'POLÍTICAS FINAIS' as status, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('clientes', 'produtos')
ORDER BY tablename;

SELECT 'DADOS UNIFICADOS' as status, 'clientes' as tabela, user_id, COUNT(*) as total
FROM clientes 
GROUP BY user_id
UNION ALL
SELECT 'DADOS UNIFICADOS' as status, 'produtos' as tabela, user_id, COUNT(*) as total
FROM produtos 
GROUP BY user_id
ORDER BY tabela;

-- PASSO 6: TESTE DE VISIBILIDADE (DEVE BLOQUEAR TUDO SE RLS FUNCIONAR)
SELECT 'TESTE RLS - CLIENTES' as teste, COUNT(*) as registros_visiveis FROM clientes;
SELECT 'TESTE RLS - PRODUTOS' as teste, COUNT(*) as registros_visiveis FROM produtos;

SELECT 'UUID FINAL PARA FRONTEND' as info, user_id as uuid_para_usar
FROM clientes 
WHERE user_id IS NOT NULL
GROUP BY user_id
ORDER BY COUNT(*) DESC
LIMIT 1;

-- =========================================================================
-- RESULTADO ESPERADO APÓS EXECUÇÃO:
-- ✅ Apenas 2 políticas ativas (1 por tabela)
-- ✅ Todos os dados com mesmo user_id
-- ✅ RLS funcionando (bloqueando acesso não autorizado)
-- ✅ UUID final mostrado para atualizar frontend
-- =========================================================================
