-- =========================================================================
-- CORREÇÃO MULTI-TENANT COM UUID VÁLIDO
-- Execute primeiro DIAGNOSTICAR_UUID_VALIDO.sql para encontrar o UUID correto
-- =========================================================================

-- PASSO 1: EXECUTE O DIAGNÓSTICO PRIMEIRO!
-- Antes de continuar, execute DIAGNOSTICAR_UUID_VALIDO.sql e pegue o UUID recomendado

-- PASSO 2: SUBSTITUA O UUID ABAIXO PELO UUID ENCONTRADO NO DIAGNÓSTICO
-- SUBSTITUA ESTE UUID PELO UUID VÁLIDO ENCONTRADO:
-- SET @USUARIO_VALIDO = 'COLE_AQUI_O_UUID_ENCONTRADO';

-- VERSÃO MANUAL - SUBSTITUA O UUID ABAIXO:
DO $$
DECLARE
    usuario_valido UUID;
    clientes_atualizados INTEGER;
    produtos_atualizados INTEGER;
BEGIN
    -- *** SUBSTITUA ESTE UUID PELO UUID VÁLIDO ENCONTRADO NO DIAGNÓSTICO ***
    -- Exemplo: se o diagnóstico mostrou '5716d14d-4d2d-44e1-96e5-92c07503c263'
    -- usuario_valido := '5716d14d-4d2d-44e1-96e5-92c07503c263'::uuid;
    
    -- DEIXE ESTE COMENTADO ATÉ SUBSTITUIR O UUID ACIMA:
    -- usuario_valido := 'SUBSTITUA_PELO_UUID_CORRETO'::uuid;
    
    -- TEMPORÁRIO: Vamos usar o primeiro usuário válido encontrado
    SELECT id INTO usuario_valido 
    FROM auth.users 
    ORDER BY created_at 
    LIMIT 1;
    
    IF usuario_valido IS NULL THEN
        RAISE EXCEPTION 'Nenhum usuário encontrado em auth.users. Crie um usuário primeiro.';
    END IF;
    
    RAISE NOTICE 'Usando UUID: %', usuario_valido;
    
    -- 1. DESABILITAR RLS TEMPORARIAMENTE
    ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
    ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;
    
    -- 2. ATUALIZAR CLIENTES
    UPDATE clientes 
    SET user_id = usuario_valido
    WHERE user_id IS NULL OR user_id != usuario_valido;
    
    GET DIAGNOSTICS clientes_atualizados = ROW_COUNT;
    RAISE NOTICE 'Clientes atualizados: %', clientes_atualizados;
    
    -- 3. ATUALIZAR PRODUTOS  
    UPDATE produtos 
    SET user_id = usuario_valido
    WHERE user_id IS NULL OR user_id != usuario_valido;
    
    GET DIAGNOSTICS produtos_atualizados = ROW_COUNT;
    RAISE NOTICE 'Produtos atualizados: %', produtos_atualizados;
    
    -- 4. REMOVER POLÍTICAS EXISTENTES
    DROP POLICY IF EXISTS "assistencia_clientes_all" ON clientes;
    DROP POLICY IF EXISTS "assistencia_produtos_all" ON produtos;
    
    -- Remover outras políticas possíveis
    DROP POLICY IF EXISTS "Isolamento_clientes_SELECT" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_INSERT" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_UPDATE" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_clientes_DELETE" ON clientes;
    DROP POLICY IF EXISTS "Isolamento_produtos_SELECT" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_INSERT" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_UPDATE" ON produtos;
    DROP POLICY IF EXISTS "Isolamento_produtos_DELETE" ON produtos;
    
    -- 5. CRIAR POLÍTICAS SIMPLES
    EXECUTE format('CREATE POLICY "user_clientes_all" ON clientes FOR ALL USING (user_id = %L) WITH CHECK (user_id = %L)', usuario_valido, usuario_valido);
    EXECUTE format('CREATE POLICY "user_produtos_all" ON produtos FOR ALL USING (user_id = %L) WITH CHECK (user_id = %L)', usuario_valido, usuario_valido);
    
    -- 6. REABILITAR RLS
    ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
    ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;
    
    RAISE NOTICE '✅ Correção concluída com UUID: %', usuario_valido;
    RAISE NOTICE '📊 Clientes associados: %', clientes_atualizados;
    RAISE NOTICE '📦 Produtos associados: %', produtos_atualizados;

END
$$;

-- 7. VERIFICAÇÃO FINAL
SELECT 
  'RESULTADO FINAL' as status,
  'clientes' as tabela,
  user_id,
  COUNT(*) as total
FROM clientes 
GROUP BY user_id

UNION ALL

SELECT 
  'RESULTADO FINAL' as status,
  'produtos' as tabela,
  user_id,
  COUNT(*) as total
FROM produtos 
GROUP BY user_id
ORDER BY tabela;

-- 8. LISTAR POLÍTICAS CRIADAS
SELECT 
  'POLÍTICAS ATIVAS' as info,
  tablename,
  policyname
FROM pg_policies 
WHERE tablename IN ('clientes', 'produtos')
ORDER BY tablename, policyname;

-- =========================================================================
-- IMPORTANTE: 
-- 1. Execute DIAGNOSTICAR_UUID_VALIDO.sql primeiro
-- 2. Pegue o UUID recomendado
-- 3. Substitua no script acima se necessário
-- 4. Este script usa automaticamente o primeiro usuário válido encontrado
-- =========================================================================
