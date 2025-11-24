-- =====================================================
-- 🔒 ISOLAMENTO COMPLETO DE CLIENTES POR USUÁRIO
-- =====================================================
-- OBJETIVO: Garantir que cada usuário veja APENAS seus próprios clientes
-- MÉTODO: Row Level Security (RLS) usando user_id
-- =====================================================

-- =====================================================
-- PASSO 1: VERIFICAR ESTRUTURA ATUAL
-- =====================================================

-- Ver se user_id existe na tabela clientes
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'clientes' AND column_name = 'user_id'
    ) THEN
        RAISE EXCEPTION 'ERRO: Coluna user_id não existe na tabela clientes. Execute primeiro o script de criação da estrutura.';
    END IF;
    RAISE NOTICE '✅ Coluna user_id existe na tabela clientes';
END $$;

-- =====================================================
-- PASSO 2: PREENCHER user_id EM CLIENTES EXISTENTES
-- =====================================================

-- Contar clientes sem user_id
DO $$
DECLARE
    clientes_sem_user INTEGER;
BEGIN
    SELECT COUNT(*) INTO clientes_sem_user FROM clientes WHERE user_id IS NULL;
    
    IF clientes_sem_user > 0 THEN
        RAISE NOTICE 'Encontrados % clientes sem user_id. Será necessário atribuí-los manualmente.', clientes_sem_user;
        
        -- Se você quiser atribuir todos ao primeiro usuário (APENAS PARA TESTES):
        -- UPDATE clientes SET user_id = (SELECT id FROM auth.users ORDER BY created_at LIMIT 1) WHERE user_id IS NULL;
    ELSE
        RAISE NOTICE '✅ Todos os clientes já têm user_id';
    END IF;
END $$;

-- =====================================================
-- PASSO 3: REMOVER POLÍTICAS ANTIGAS (INSEGURAS)
-- =====================================================

DROP POLICY IF EXISTS "clientes_select_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_insert_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_update_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_delete_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_all_policy" ON clientes;
DROP POLICY IF EXISTS "clientes_all_simple" ON clientes;
DROP POLICY IF EXISTS "clientes_select" ON clientes;
DROP POLICY IF EXISTS "clientes_insert" ON clientes;
DROP POLICY IF EXISTS "clientes_update" ON clientes;
DROP POLICY IF EXISTS "clientes_delete" ON clientes;
DROP POLICY IF EXISTS "clientes_select_own" ON clientes;
DROP POLICY IF EXISTS "clientes_insert_own" ON clientes;
DROP POLICY IF EXISTS "clientes_update_own" ON clientes;
DROP POLICY IF EXISTS "clientes_delete_own" ON clientes;
DROP POLICY IF EXISTS "enable_read_for_authenticated" ON clientes;
DROP POLICY IF EXISTS "enable_insert_for_authenticated" ON clientes;
DROP POLICY IF EXISTS "enable_update_for_authenticated" ON clientes;
DROP POLICY IF EXISTS "enable_delete_for_authenticated" ON clientes;

RAISE NOTICE '✅ Todas as políticas antigas foram removidas';

-- =====================================================
-- PASSO 4: ATIVAR RLS
-- =====================================================

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
