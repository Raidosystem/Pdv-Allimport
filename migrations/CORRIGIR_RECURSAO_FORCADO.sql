-- 🔥 CORREÇÃO FORÇADA - RECURSÃO INFINITA (EXECUTAR NO SUPABASE SQL EDITOR)

-- ⚠️ PASSO 1: DESABILITAR RLS TEMPORARIAMENTE
ALTER TABLE funcionarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE empresas DISABLE ROW LEVEL SECURITY;

-- 🧹 PASSO 2: REMOVER TODAS AS POLÍTICAS (SEM EXCEÇÕES)
DO $$ 
DECLARE
    pol record;
BEGIN
    -- Remover todas as políticas de funcionarios
    FOR pol IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'funcionarios'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON funcionarios', pol.policyname);
        RAISE NOTICE 'Política removida: %', pol.policyname;
    END LOOP;
    
    -- Remover todas as políticas de empresas
    FOR pol IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'empresas'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON empresas', pol.policyname);
        RAISE NOTICE 'Política removida: %', pol.policyname;
    END LOOP;
END $$;

-- ✅ PASSO 3: REATIVAR RLS
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;

-- 🔒 PASSO 4: CRIAR POLÍTICAS SIMPLES E SEGURAS

-- ✅ EMPRESAS: Apenas user_id (SEM SUBQUERIES)
CREATE POLICY "empresas_owner_access"
ON empresas 
FOR ALL 
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ✅ FUNCIONARIOS: Acesso via empresa_id (SEM CONSULTAR FUNCIONARIOS!)
CREATE POLICY "funcionarios_empresa_access"
ON funcionarios 
FOR ALL 
TO authenticated
USING (
  -- Busca direto em empresas (SEM recursão!)
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
)
WITH CHECK (
  empresa_id IN (
    SELECT id FROM empresas WHERE user_id = auth.uid()
  )
);

-- 🔍 PASSO 5: VERIFICAR RESULTADO
SELECT 
  '✅ Políticas Empresas' as tabela,
  schemaname,
  tablename,
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE tablename = 'empresas'

UNION ALL

SELECT 
  '✅ Políticas Funcionarios' as tabela,
  schemaname,
  tablename,
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE tablename = 'funcionarios'
ORDER BY tabela, policyname;

-- 🧪 PASSO 6: TESTAR ACESSO
SELECT 
  '🧪 Teste Empresas' as teste,
  COUNT(*) as total,
  array_agg(nome) as empresas
FROM empresas;

SELECT 
  '🧪 Teste Funcionarios' as teste,
  COUNT(*) as total,
  array_agg(nome) as funcionarios
FROM funcionarios;

-- ✅ RESULTADO ESPERADO:
-- 1. Apenas 2 políticas (empresas_owner_access e funcionarios_empresa_access)
-- 2. Nenhum erro de recursão
-- 3. Dados visíveis apenas do usuário autenticado
