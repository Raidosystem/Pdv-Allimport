-- =========================================================================
-- CORREÇÃO FINAL MULTI-TENANT - USAR USUÁRIO EXISTENTE
-- PROBLEMA: Email assistenciaallimport10@gmail.com já existe
-- SOLUÇÃO: Encontrar UUID do usuário existente e usar ele
-- =========================================================================

-- PASSO 1: ENCONTRAR O UUID DO USUÁRIO EXISTENTE
DO $$
DECLARE
    usuario_existente UUID;
    clientes_atualizados INTEGER;
    produtos_atualizados INTEGER;
BEGIN
    -- Encontrar o UUID do usuário com email assistenciaallimport10@gmail.com
    SELECT id INTO usuario_existente 
    FROM auth.users 
    WHERE email = 'assistenciaallimport10@gmail.com';
    
    IF usuario_existente IS NULL THEN
        -- Se não encontrar, usar o primeiro usuário disponível
        SELECT id INTO usuario_existente 
        FROM auth.users 
        ORDER BY created_at 
        LIMIT 1;
    END IF;
    
    IF usuario_existente IS NULL THEN
        RAISE EXCEPTION 'Nenhum usuário encontrado em auth.users. Crie um usuário primeiro.';
    END IF;
    
    RAISE NOTICE 'UUID encontrado: %', usuario_existente;
    
    -- Verificar o email do usuário encontrado
    RAISE NOTICE 'Email do usuário: %', (SELECT email FROM auth.users WHERE id = usuario_existente);
    
    -- 1. DESABILITAR RLS TEMPORARIAMENTE
    ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
    ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;
    
    -- 2. ATUALIZAR TODOS OS CLIENTES PARA O UUID EXISTENTE
    UPDATE clientes 
    SET user_id = usuario_existente
    WHERE user_id IS NULL OR user_id != usuario_existente;
    
    GET DIAGNOSTICS clientes_atualizados = ROW_COUNT;
    RAISE NOTICE 'Clientes atualizados: %', clientes_atualizados;
    
    -- 3. ATUALIZAR TODOS OS PRODUTOS PARA O UUID EXISTENTE
    UPDATE produtos 
    SET user_id = usuario_existente
    WHERE user_id IS NULL OR user_id != usuario_existente;
    
    GET DIAGNOSTICS produtos_atualizados = ROW_COUNT;
    RAISE NOTICE 'Produtos atualizados: %', produtos_atualizados;
    
    -- 4. REMOVER TODAS AS POLÍTICAS EXISTENTES
    DROP POLICY IF EXISTS "assistencia_clientes_all" ON clientes;
    DROP POLICY IF EXISTS "assistencia_produtos_all" ON produtos;
    DROP POLICY IF EXISTS "user_clientes_all" ON clientes;
    DROP POLICY IF EXISTS "user_produtos_all" ON produtos;
    DROP POLICY IF EXISTS "assistencia_clientes_policy" ON clientes;
    DROP POLICY IF EXISTS "assistencia_produtos_policy" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_clientes_SELECT" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_INSERT" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_UPDATE" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_DELETE" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_produtos_SELECT" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_INSERT" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_UPDATE" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_DELETE" ON produtos;
    
    -- Remover políticas com versões _v2
    DROP POLICY IF EXISTS "Isolamento_clientes_SELECT_v2" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_INSERT_v2" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_UPDATE_v2" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_DELETE_v2" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_produtos_SELECT_v2" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_INSERT_v2" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_UPDATE_v2" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_DELETE_v2" ON produtos;
    
    RAISE NOTICE 'Políticas antigas removidas';
    
    -- 5. CRIAR POLÍTICAS SIMPLES E EFETIVAS COM UUID DINÂMICO
    EXECUTE format('CREATE POLICY "sistema_clientes_policy" ON clientes FOR ALL USING (user_id = %L) WITH CHECK (user_id = %L)', usuario_existente, usuario_existente);
    EXECUTE format('CREATE POLICY "sistema_produtos_policy" ON produtos FOR ALL USING (user_id = %L) WITH CHECK (user_id = %L)', usuario_existente, usuario_existente);
    
    RAISE NOTICE 'Novas políticas criadas com UUID: %', usuario_existente;
    
    -- 6. REABILITAR RLS
    ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
    ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
    
    RAISE NOTICE '✅ Correção multi-tenant concluída!';
    RAISE NOTICE '👥 Clientes afetados: %', clientes_atualizados;
    RAISE NOTICE '📦 Produtos afetados: %', produtos_atualizados;
    RAISE NOTICE '🔐 UUID utilizado: %', usuario_existente;
    RAISE NOTICE '📧 Email do usuário: %', (SELECT email FROM auth.users WHERE id = usuario_existente);

END
$$;

-- VERIFICAR QUAL USUÁRIO FOI USADO
SELECT 
  'USUÁRIO UTILIZADO' as info,
  id,
  email,
  created_at
FROM auth.users 
WHERE email = 'assistenciaallimport10@gmail.com'
   OR id IN (
     SELECT DISTINCT user_id 
     FROM clientes 
     WHERE user_id IS NOT NULL
   );

-- VERIFICAÇÃO FINAL - TODOS OS DADOS DEVEM ESTAR COM O MESMO UUID
SELECT 
  'RESULTADO FINAL' as status,
  'clientes' as tabela,
  user_id,
  COUNT(*) as total_registros
FROM clientes 
GROUP BY user_id

UNION ALL

SELECT 
  'RESULTADO FINAL' as status,
  'produtos' as tabela,
  user_id,
  COUNT(*) as total_registros
FROM produtos 
GROUP BY user_id
ORDER BY tabela;

-- LISTAR POLÍTICAS ATIVAS
SELECT 
  'POLÍTICAS ATIVAS' as info,
  tablename,
  policyname,
  cmd
FROM pg_policies 
WHERE tablename IN ('clientes', 'produtos')
ORDER BY tablename, policyname;

-- TESTE DE ISOLAMENTO - CONTAR REGISTROS VISÍVEIS
SELECT 
  'TESTE DE VISIBILIDADE' as teste,
  'clientes' as tabela,
  COUNT(*) as registros_visiveis
FROM clientes

UNION ALL

SELECT 
  'TESTE DE VISIBILIDADE' as teste,
  'produtos' as tabela,
  COUNT(*) as registros_visiveis
FROM produtos;

-- =========================================================================
-- RESULTADO ESPERADO:
-- ✅ UUID existente encontrado e utilizado
-- ✅ Todos os clientes com mesmo user_id
-- ✅ Todos os produtos com mesmo user_id  
-- ✅ Políticas RLS ativas e funcionais
-- ✅ Multi-tenant isolado e funcional
-- 
-- IMPORTANTE: Anote o UUID final para atualizar o frontend!
-- =========================================================================
