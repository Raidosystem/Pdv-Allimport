-- =====================================================
-- 🔒 CORREÇÃO CRÍTICA - ISOLAMENTO TOTAL DE CLIENTES
-- =====================================================
-- PROBLEMA IDENTIFICADO:
-- 1. Clientes têm user_id mas não têm empresa_id
-- 2. Políticas RLS usam user_id ao invés de empresa_id
-- 3. Frontend não está enviando empresa_id ao criar clientes
--
-- SOLUÇÃO:
-- 1. Preencher empresa_id em clientes existentes
-- 2. Atualizar políticas RLS para usar empresa_id
-- 3. Frontend precisa ser corrigido para enviar empresa_id
-- =====================================================

-- =====================================================
-- 1️⃣ REMOVER TODAS AS POLÍTICAS ANTIGAS DE CLIENTES
-- =====================================================

DROP POLICY IF EXISTS clientes_select_policy ON clientes;
DROP POLICY IF EXISTS clientes_insert_policy ON clientes;
DROP POLICY IF EXISTS clientes_update_policy ON clientes;
DROP POLICY IF EXISTS clientes_delete_policy ON clientes;
DROP POLICY IF EXISTS clientes_all_policy ON clientes;
DROP POLICY IF EXISTS clientes_all_simple ON clientes;
DROP POLICY IF EXISTS clientes_select ON clientes;
DROP POLICY IF EXISTS clientes_insert ON clientes;
DROP POLICY IF EXISTS clientes_update ON clientes;
DROP POLICY IF EXISTS clientes_delete ON clientes;
DROP POLICY IF EXISTS clientes_select_own ON clientes;
DROP POLICY IF EXISTS clientes_insert_own ON clientes;
DROP POLICY IF EXISTS clientes_update_own ON clientes;
DROP POLICY IF EXISTS clientes_delete_own ON clientes;

-- =====================================================
-- 2️⃣ GARANTIR QUE CLIENTES TEM EMPRESA_ID
-- =====================================================

-- Adicionar empresa_id se não existir
ALTER TABLE clientes 
  ADD COLUMN IF NOT EXISTS empresa_id UUID REFERENCES empresas(id);

-- Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_clientes_empresa_id ON clientes(empresa_id);
CREATE INDEX IF NOT EXISTS idx_clientes_user_id ON clientes(user_id);

-- =====================================================
-- 3️⃣ ATUALIZAR CLIENTES SEM EMPRESA_ID
-- =====================================================
-- Associar clientes órfãos à empresa do user_id

UPDATE clientes c
SET empresa_id = e.id
FROM empresas e
WHERE c.empresa_id IS NULL
  AND c.user_id IS NOT NULL
  AND e.user_id = c.user_id;

-- Verificar quantos foram atualizados
SELECT 
  '✅ Clientes atualizados' as status,
  COUNT(*) as total_atualizado
FROM clientes
WHERE empresa_id IS NOT NULL;

-- =====================================================
-- 4️⃣ ATIVAR RLS NA TABELA CLIENTES
-- =====================================================

ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 5️⃣ CRIAR TRIGGER PARA AUTO-PREENCHER EMPRESA_ID
-- =====================================================
-- Garantir que empresa_id seja preenchido automaticamente
-- mesmo se o frontend esquecer de enviar

CREATE OR REPLACE FUNCTION auto_set_empresa_id_clientes()
RETURNS TRIGGER AS $$
DECLARE
  v_empresa_id UUID;
BEGIN
  -- Se empresa_id já foi fornecido, manter
  IF NEW.empresa_id IS NOT NULL THEN
    RETURN NEW;
  END IF;
  
  -- Se não foi fornecido, buscar pela empresa do usuário
  SELECT id INTO v_empresa_id
  FROM empresas
  WHERE user_id = auth.uid()
  LIMIT 1;
  
  -- Se encontrou, definir
  IF v_empresa_id IS NOT NULL THEN
    NEW.empresa_id := v_empresa_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger ANTES de inserir
DROP TRIGGER IF EXISTS trigger_auto_empresa_id_clientes ON clientes;
CREATE TRIGGER trigger_auto_empresa_id_clientes
  BEFORE INSERT ON clientes
  FOR EACH ROW
  EXECUTE FUNCTION auto_set_empresa_id_clientes();

-- =====================================================
-- 6️⃣ CRIAR POLÍTICAS RLS ESTRITAS
-- =====================================================

-- Remover políticas novas se já existirem
DROP POLICY IF EXISTS clientes_select_own_empresa ON clientes;
DROP POLICY IF EXISTS clientes_insert_own_empresa ON clientes;
DROP POLICY IF EXISTS clientes_update_own_empresa ON clientes;
DROP POLICY IF EXISTS clientes_delete_own_empresa ON clientes;

-- Política de SELECT (leitura)
-- Usuário só vê clientes da sua própria empresa
CREATE POLICY clientes_select_own_empresa ON clientes
  FOR SELECT
  TO authenticated
  USING (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

-- Política de INSERT (criação)
-- Usuário só pode criar clientes na sua própria empresa
CREATE POLICY clientes_insert_own_empresa ON clientes
  FOR INSERT
  TO authenticated
  WITH CHECK (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

-- Política de UPDATE (atualização)
-- Usuário só pode atualizar clientes da sua própria empresa
CREATE POLICY clientes_update_own_empresa ON clientes
  FOR UPDATE
  TO authenticated
  USING (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  )
  WITH CHECK (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

-- Política de DELETE (exclusão)
-- Usuário só pode deletar clientes da sua própria empresa
CREATE POLICY clientes_delete_own_empresa ON clientes
  FOR DELETE
  TO authenticated
  USING (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

-- =====================================================
-- 7️⃣ VERIFICAR CORREÇÃO
-- =====================================================

-- Ver políticas criadas
SELECT 
  '✅ Políticas RLS criadas' as status,
  policyname,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'clientes'
ORDER BY policyname;

-- Ver clientes por empresa
SELECT 
  '✅ Distribuição por empresa' as status,
  e.nome as empresa_nome,
  au.email,
  COUNT(c.id) as total_clientes
FROM empresas e
INNER JOIN auth.users au ON au.id = e.user_id
LEFT JOIN clientes c ON c.empresa_id = e.id
WHERE au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%DELETED%'
GROUP BY e.id, e.nome, au.email
ORDER BY e.nome;

-- =====================================================
-- 🎯 RESULTADO ESPERADO
-- =====================================================
-- ✅ RLS ativado em clientes
-- ✅ 4 políticas criadas (SELECT, INSERT, UPDATE, DELETE)
-- ✅ Cada política filtra por empresa_id
-- ✅ Usuários veem APENAS clientes da sua empresa
-- ✅ Isolamento total entre empresas
-- =====================================================

-- =====================================================
-- 🧪 TESTE FINAL (OPCIONAL)
-- =====================================================
-- Para testar, faça login como usuário A e tente:
-- SELECT * FROM clientes;
-- Deve retornar APENAS clientes da empresa do usuário A
-- 
-- Se logar como usuário B:
-- SELECT * FROM clientes;
-- Deve retornar APENAS clientes da empresa do usuário B
-- 
-- NUNCA deve misturar clientes de empresas diferentes!
-- =====================================================
