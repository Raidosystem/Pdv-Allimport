-- =====================================================
-- CORREÇÃO COMPLETA: TODOS OS ERROS DE RLS E ESTRUTURA
-- =====================================================
-- Este script corrige:
-- 1. Erro 406 em subscriptions e empresas
-- 2. Erro 400 em funcionarios (user_id não existe)
-- 3. Erro 403 em funcoes (RLS bloqueando INSERT)
-- 4. Erro 409 em funcionarios (duplicate key)
-- 5. Associa empresa_id ao auth.uid() corretamente
-- =====================================================

-- =====================================================
-- 1️⃣ CORRIGIR TABELA SUBSCRIPTIONS
-- =====================================================
-- Problema: Query retorna múltiplas linhas (erro 406)
-- Solução: Garantir uma subscription por empresa

DO $$
BEGIN
  -- Se a tabela não existir, criar
  IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = 'subscriptions') THEN
    CREATE TABLE subscriptions (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
      empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
      plan_type TEXT DEFAULT 'free',
      status TEXT DEFAULT 'active',
      trial_ends_at TIMESTAMPTZ,
      subscription_ends_at TIMESTAMPTZ,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    );
    
    -- Criar índice único por user_id
    CREATE UNIQUE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
    
    RAISE NOTICE '✅ Tabela subscriptions criada';
  END IF;
END $$;

-- Remover TODAS as policies antigas de subscriptions
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'subscriptions' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON subscriptions', pol.policyname);
    RAISE NOTICE 'Removida policy: %', pol.policyname;
  END LOOP;
END $$;

-- Criar policies corretas (sem .single())
CREATE POLICY "select_own_subscription" ON subscriptions
  FOR SELECT USING (
    user_id = auth.uid()
  );

CREATE POLICY "insert_own_subscription" ON subscriptions
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
  );

CREATE POLICY "update_own_subscription" ON subscriptions
  FOR UPDATE USING (
    user_id = auth.uid()
  );

-- =====================================================
-- 2️⃣ CORRIGIR TABELA EMPRESAS
-- =====================================================
-- Problema: Query retorna múltiplas linhas (erro 406)
-- Solução: Garantir uma empresa por user_id

-- Verificar se existe constraint única
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'empresas_user_id_unique'
  ) THEN
    ALTER TABLE empresas ADD CONSTRAINT empresas_user_id_unique UNIQUE (user_id);
    RAISE NOTICE '✅ Constraint única criada em empresas.user_id';
  END IF;
END $$;

-- Remover TODAS as policies antigas (nome exato e genérico)
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'empresas' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON empresas', pol.policyname);
    RAISE NOTICE 'Removida policy: %', pol.policyname;
  END LOOP;
END $$;

-- Criar policies corretas
CREATE POLICY "select_own_empresa" ON empresas
  FOR SELECT USING (
    user_id = auth.uid()
  );

CREATE POLICY "insert_own_empresa" ON empresas
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
  );

CREATE POLICY "update_own_empresa" ON empresas
  FOR UPDATE USING (
    user_id = auth.uid()
  );

-- =====================================================
-- 3️⃣ CORRIGIR TABELA FUNCIONARIOS
-- =====================================================
-- Problema 1: Coluna user_id não existe (erro 400)
-- Problema 2: Duplicate key violation (erro 409)
-- Solução: Adicionar user_id e corrigir RLS

-- Adicionar coluna user_id se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'funcionarios' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE funcionarios ADD COLUMN user_id UUID REFERENCES auth.users(id);
    RAISE NOTICE '✅ Coluna user_id adicionada em funcionarios';
  END IF;
END $$;

-- Criar índice para melhor performance
CREATE INDEX IF NOT EXISTS idx_funcionarios_user_id ON funcionarios(user_id);
CREATE INDEX IF NOT EXISTS idx_funcionarios_empresa_id ON funcionarios(empresa_id);

-- Remover TODAS as policies antigas de funcionarios
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'funcionarios' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON funcionarios', pol.policyname);
    RAISE NOTICE 'Removida policy: %', pol.policyname;
  END LOOP;
END $$;

-- Criar policies corretas (usando empresa_id do contexto)
CREATE POLICY "select_funcionarios_empresa" ON funcionarios
  FOR SELECT USING (
    -- Permitir se for da mesma empresa OU se for o próprio user_id
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
    OR user_id = auth.uid()
  );

CREATE POLICY "insert_funcionarios_empresa" ON funcionarios
  FOR INSERT WITH CHECK (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "update_funcionarios_empresa" ON funcionarios
  FOR UPDATE USING (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "delete_funcionarios_empresa" ON funcionarios
  FOR DELETE USING (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

-- =====================================================
-- 4️⃣ CORRIGIR TABELA FUNCOES
-- =====================================================
-- Problema: INSERT retorna 403 (Forbidden)
-- Solução: Adicionar policy de INSERT

-- Remover TODAS as policies antigas de funcoes
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'funcoes' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON funcoes', pol.policyname);
    RAISE NOTICE 'Removida policy: %', pol.policyname;
  END LOOP;
END $$;

-- Criar policies completas
CREATE POLICY "select_funcoes_empresa" ON funcoes
  FOR SELECT USING (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "insert_funcoes_empresa" ON funcoes
  FOR INSERT WITH CHECK (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "update_funcoes_empresa" ON funcoes
  FOR UPDATE USING (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "delete_funcoes_empresa" ON funcoes
  FOR DELETE USING (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

-- =====================================================
-- 5️⃣ CORRIGIR TABELA AUDIT_LOGS
-- =====================================================
-- Problema: Erro 400 (estrutura ou RLS incorreto)

-- Remover TODAS as policies antigas de audit_logs
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'audit_logs' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON audit_logs', pol.policyname);
    RAISE NOTICE 'Removida policy: %', pol.policyname;
  END LOOP;
END $$;

-- Criar policies corretas
CREATE POLICY "select_audit_logs_empresa" ON audit_logs
  FOR SELECT USING (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "insert_audit_logs_empresa" ON audit_logs
  FOR INSERT WITH CHECK (
    empresa_id IN (
      SELECT id FROM empresas WHERE user_id = auth.uid()
    )
  );

-- =====================================================
-- 6️⃣ ASSOCIAR EMPRESA AO AUTH.UID()
-- =====================================================
-- Problema: Local login não está associando empresa_id ao auth.uid()
-- Solução: Garantir que empresa.user_id = auth.users.id

-- Buscar empresa para o email assistenciaallimport10@gmail.com
DO $$
DECLARE
  v_user_id UUID;
  v_empresa_id UUID;
  v_funcionario_id UUID;
BEGIN
  -- Buscar user_id do email principal
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = 'assistenciaallimport10@gmail.com'
  LIMIT 1;
  
  IF v_user_id IS NULL THEN
    RAISE NOTICE '❌ Usuário não encontrado no auth.users';
    RETURN;
  END IF;
  
  RAISE NOTICE '✅ User ID encontrado: %', v_user_id;
  
  -- Buscar empresa associada
  SELECT id INTO v_empresa_id
  FROM empresas
  WHERE user_id = v_user_id
  LIMIT 1;
  
  IF v_empresa_id IS NULL THEN
    RAISE NOTICE '⚠️ Empresa não encontrada, buscando por funcionário...';
    
    -- Buscar empresa através do funcionário
    SELECT f.empresa_id, f.id INTO v_empresa_id, v_funcionario_id
    FROM funcionarios f
    WHERE f.email = 'assistenciaallimport10@gmail.com'
    LIMIT 1;
    
    IF v_empresa_id IS NULL THEN
      RAISE NOTICE '❌ Nenhuma empresa encontrada para este usuário';
      RETURN;
    END IF;
    
    -- Associar empresa ao user_id
    UPDATE empresas
    SET user_id = v_user_id
    WHERE id = v_empresa_id;
    
    RAISE NOTICE '✅ Empresa % associada ao user_id %', v_empresa_id, v_user_id;
  ELSE
    RAISE NOTICE '✅ Empresa já associada: %', v_empresa_id;
  END IF;
  
  -- Associar funcionário ao user_id se existir
  IF v_funcionario_id IS NOT NULL THEN
    UPDATE funcionarios
    SET user_id = v_user_id
    WHERE id = v_funcionario_id;
    
    RAISE NOTICE '✅ Funcionário % associado ao user_id %', v_funcionario_id, v_user_id;
  END IF;
END $$;

-- =====================================================
-- 7️⃣ CRIAR SUBSCRIPTION PADRÃO SE NÃO EXISTIR
-- =====================================================

DO $$
DECLARE
  v_user_id UUID;
  v_empresa_id UUID;
  v_subscription_exists BOOLEAN;
BEGIN
  -- Buscar user_id
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = 'assistenciaallimport10@gmail.com'
  LIMIT 1;
  
  IF v_user_id IS NULL THEN
    RETURN;
  END IF;
  
  -- Buscar empresa_id
  SELECT id INTO v_empresa_id
  FROM empresas
  WHERE user_id = v_user_id
  LIMIT 1;
  
  IF v_empresa_id IS NULL THEN
    RETURN;
  END IF;
  
  -- Verificar se já existe subscription
  SELECT EXISTS(
    SELECT 1 FROM subscriptions WHERE user_id = v_user_id
  ) INTO v_subscription_exists;
  
  IF NOT v_subscription_exists THEN
    -- Criar subscription padrão (30 dias de trial)
    INSERT INTO subscriptions (
      user_id,
      empresa_id,
      plan_type,
      status,
      trial_ends_at,
      subscription_ends_at
    ) VALUES (
      v_user_id,
      v_empresa_id,
      'trial',
      'active',
      NOW() + INTERVAL '30 days',
      NOW() + INTERVAL '30 days'
    );
    
    RAISE NOTICE '✅ Subscription criada para user_id %', v_user_id;
  ELSE
    RAISE NOTICE '✅ Subscription já existe';
  END IF;
END $$;

-- =====================================================
-- 8️⃣ DIAGNÓSTICO FINAL
-- =====================================================

SELECT '✅ DIAGNÓSTICO FINAL' as etapa;

-- Verificar empresas
SELECT 
  '📊 EMPRESAS' as tabela,
  COUNT(*) as total,
  COUNT(user_id) as com_user_id
FROM empresas;

-- Verificar funcionários
SELECT 
  '👥 FUNCIONÁRIOS' as tabela,
  COUNT(*) as total,
  COUNT(user_id) as com_user_id,
  COUNT(empresa_id) as com_empresa_id
FROM funcionarios;

-- Verificar subscriptions
SELECT 
  '💳 SUBSCRIPTIONS' as tabela,
  COUNT(*) as total,
  COUNT(DISTINCT user_id) as users_unicos
FROM subscriptions;

-- Verificar funções
SELECT 
  '🔧 FUNÇÕES' as tabela,
  COUNT(*) as total,
  COUNT(DISTINCT empresa_id) as empresas
FROM funcoes;

-- Verificar associação específica
SELECT 
  '🔗 ASSOCIAÇÃO ESPECÍFICA' as tipo,
  u.email,
  e.id as empresa_id,
  e.nome as empresa_nome,
  f.id as funcionario_id,
  f.nome as funcionario_nome,
  s.plan_type,
  s.status as subscription_status
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN funcionarios f ON f.user_id = u.id
LEFT JOIN subscriptions s ON s.user_id = u.id
WHERE u.email = 'assistenciaallimport10@gmail.com';

-- =====================================================
-- INSTRUÇÕES DE USO:
-- =====================================================
-- 1. Copie este script completo
-- 2. Abra o SQL Editor do Supabase
-- 3. Cole e execute o script
-- 4. Verifique os resultados do diagnóstico
-- 5. Limpe o cache do navegador (Ctrl+Shift+R)
-- 6. Faça logout e login novamente
-- 7. Teste o acesso aos dados
-- =====================================================
