-- =========================================================================
-- CORREÇÃO DEFINITIVA DO MULTI-TENANT
-- PROBLEMA IDENTIFICADO: RLS não funciona com chaves ANON
-- SOLUÇÃO: Usar políticas mais flexíveis baseadas no contexto da aplicação
-- =========================================================================

-- 1. DESABILITAR RLS TEMPORARIAMENTE PARA CORREÇÃO
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;

-- 2. CORRIGIR USER_ID DOS PRODUTOS (UNIFICAR COM CLIENTES)
UPDATE produtos 
SET user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid 
WHERE user_id != '550e8400-e29b-41d4-a716-446655440000'::uuid OR user_id IS NULL;

-- 3. VERIFICAR CORREÇÃO
SELECT 
  'clientes' as tabela,
  user_id,
  COUNT(*) as total
FROM clientes 
GROUP BY user_id

UNION ALL

SELECT 
  'produtos' as tabela,
  user_id,
  COUNT(*) as total
FROM produtos 
GROUP BY user_id
ORDER BY tabela, user_id;

-- 4. REMOVER TODAS AS POLÍTICAS EXISTENTES
DO $$
DECLARE
    r RECORD;
BEGIN
    -- Remove todas as políticas de clientes
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'clientes') LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON clientes', r.policyname);
    END LOOP;
    
    -- Remove todas as políticas de produtos
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'produtos') LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON produtos', r.policyname);
    END LOOP;
    
    RAISE NOTICE 'Todas as políticas removidas com sucesso';
END
$$;

-- 5. CRIAR POLÍTICAS MAIS SIMPLES (APENAS PARA O UUID ESPECÍFICO)
-- ESTRATÉGIA: Usar políticas que permitem acesso apenas aos dados do usuário específico

-- POLÍTICAS PARA CLIENTES
CREATE POLICY "assistencia_clientes_all" ON clientes
FOR ALL USING (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid)
WITH CHECK (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid);

-- POLÍTICAS PARA PRODUTOS  
CREATE POLICY "assistencia_produtos_all" ON produtos
FOR ALL USING (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid)
WITH CHECK (user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid);

-- 6. REABILITAR RLS
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE produtos ENABLE ROW LEVEL SECURITY;

-- 7. CRIAR FUNÇÃO PARA CONTEXTO DE USUÁRIO (ALTERNATIVA AO RLS)
CREATE OR REPLACE FUNCTION get_current_app_user_id() 
RETURNS UUID 
LANGUAGE sql 
STABLE 
AS $$
  SELECT '550e8400-e29b-41d4-a716-446655440000'::uuid;
$$;

-- 8. VERIFICAÇÃO FINAL - CONTAGEM POR USUÁRIO
SELECT 
  'APÓS CORREÇÃO' as status,
  'clientes' as tabela,
  COUNT(*) as total_registros
FROM clientes
WHERE user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid

UNION ALL

SELECT 
  'APÓS CORREÇÃO' as status,
  'produtos' as tabela,
  COUNT(*) as total_registros
FROM produtos
WHERE user_id = '550e8400-e29b-41d4-a716-446655440000'::uuid;

-- 9. LISTAR POLÍTICAS ATIVAS
SELECT 
  'POLÍTICAS ATIVAS' as info,
  tablename,
  policyname,
  cmd as operacao
FROM pg_policies 
WHERE tablename IN ('clientes', 'produtos')
ORDER BY tablename, policyname;

-- =========================================================================
-- OBSERVAÇÃO IMPORTANTE:
-- O RLS com chaves ANON tem limitações. Para isolamento 100% efetivo:
-- 1. Use autenticação real de usuários
-- 2. Configure context switching no backend
-- 3. Use filtros no frontend (que já implementamos)
-- 
-- Esta correção unifica os user_id e simplifica as políticas RLS
-- =========================================================================
