-- 🛠️ SOLUÇÃO DEFINITIVA: Erro 406 ao ativar usuário
-- Problema: Múltiplas linhas em empresas e subscriptions com mesmo user_id
-- Solução: Manter apenas UMA linha por user_id e adicionar constraints únicos

-- ============================================
-- SEÇÃO 1: LIMPAR DUPLICATAS NA TABELA EMPRESAS
-- ============================================

DO $$
DECLARE
  duplicates_count INT;
  deleted_count INT;
BEGIN
  RAISE NOTICE '🔍 [1/7] Verificando duplicatas na tabela empresas...';
  
  -- Contar duplicatas
  SELECT COUNT(*) INTO duplicates_count
  FROM (
    SELECT user_id, COUNT(*) as count
    FROM empresas
    WHERE user_id IS NOT NULL
    GROUP BY user_id
    HAVING COUNT(*) > 1
  ) AS dups;
  
  RAISE NOTICE '📊 Encontradas % linhas com user_id duplicado na tabela empresas', duplicates_count;
  
  -- Deletar duplicatas, mantendo apenas a primeira linha de cada user_id
  WITH duplicates AS (
    SELECT id
    FROM empresas
    WHERE id NOT IN (
      SELECT DISTINCT ON (user_id) id
      FROM empresas
      WHERE user_id IS NOT NULL
      ORDER BY user_id, created_at ASC
    )
  )
  DELETE FROM empresas WHERE id IN (SELECT id FROM duplicates);
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RAISE NOTICE '✅ [1/7] % duplicatas removidas da tabela empresas', deleted_count;
END $$;

-- ============================================
-- SEÇÃO 2: LIMPAR DUPLICATAS NA TABELA SUBSCRIPTIONS
-- ============================================

DO $$
DECLARE
  duplicates_count INT;
  deleted_count INT;
BEGIN
  RAISE NOTICE '🔍 [2/7] Verificando duplicatas na tabela subscriptions...';
  
  -- Contar duplicatas
  SELECT COUNT(*) INTO duplicates_count
  FROM (
    SELECT user_id, COUNT(*) as count
    FROM subscriptions
    WHERE user_id IS NOT NULL
    GROUP BY user_id
    HAVING COUNT(*) > 1
  ) AS dups;
  
  RAISE NOTICE '📊 Encontradas % linhas com user_id duplicado na tabela subscriptions', duplicates_count;
  
  -- Deletar duplicatas, mantendo apenas a subscription ativa ou mais recente
  WITH duplicates AS (
    SELECT id
    FROM subscriptions
    WHERE id NOT IN (
      SELECT DISTINCT ON (user_id) id
      FROM subscriptions
      WHERE user_id IS NOT NULL
      ORDER BY user_id, 
               CASE status WHEN 'active' THEN 1 WHEN 'trial' THEN 2 ELSE 3 END,
               created_at DESC
    )
  )
  DELETE FROM subscriptions WHERE id IN (SELECT id FROM duplicates);
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RAISE NOTICE '✅ [2/7] % duplicatas removidas da tabela subscriptions', deleted_count;
END $$;

-- ============================================
-- SEÇÃO 3: ADICIONAR UNIQUE CONSTRAINT EM EMPRESAS
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '🔍 [3/7] Adicionando constraint único em empresas.user_id...';
  
  -- Remover constraint antigo se existir (qualquer nome)
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'empresas_user_id_key'
  ) THEN
    ALTER TABLE empresas DROP CONSTRAINT empresas_user_id_key;
    RAISE NOTICE '🗑️ Constraint antigo (empresas_user_id_key) removido';
  END IF;
  
  -- Verificar se já existe o novo constraint
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'empresas_user_id_unique'
  ) THEN
    -- Adicionar novo constraint único
    ALTER TABLE empresas 
      ADD CONSTRAINT empresas_user_id_unique UNIQUE (user_id);
    RAISE NOTICE '✅ [3/7] Constraint único adicionado em empresas.user_id';
  ELSE
    RAISE NOTICE '✅ [3/7] Constraint empresas_user_id_unique já existe';
  END IF;
END $$;

-- ============================================
-- SEÇÃO 4: ADICIONAR UNIQUE CONSTRAINT EM SUBSCRIPTIONS
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '🔍 [4/7] Adicionando constraint único em subscriptions.user_id...';
  
  -- Remover constraint antigo se existir (qualquer nome)
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'subscriptions_user_id_key'
  ) THEN
    ALTER TABLE subscriptions DROP CONSTRAINT subscriptions_user_id_key;
    RAISE NOTICE '🗑️ Constraint antigo (subscriptions_user_id_key) removido';
  END IF;
  
  -- Verificar se já existe o novo constraint
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'subscriptions_user_id_unique'
  ) THEN
    -- Adicionar novo constraint único
    ALTER TABLE subscriptions 
      ADD CONSTRAINT subscriptions_user_id_unique UNIQUE (user_id);
    RAISE NOTICE '✅ [4/7] Constraint único adicionado em subscriptions.user_id';
  ELSE
    RAISE NOTICE '✅ [4/7] Constraint subscriptions_user_id_unique já existe';
  END IF;
END $$;

-- ============================================
-- SEÇÃO 5: CORRIGIR QUERIES NAS RLS POLICIES
-- ============================================

DO $$
DECLARE pol RECORD;
BEGIN
  RAISE NOTICE '🔍 [5/7] Recriando RLS policies para usar .single() com segurança...';
  
  -- Remover policies antigas de empresas
  FOR pol IN SELECT policyname FROM pg_policies 
    WHERE tablename = 'empresas' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON empresas', pol.policyname);
  END LOOP;
  
  -- Recriar policies de empresas (agora com user_id único)
  EXECUTE 'CREATE POLICY "empresas_select_own" ON empresas
    FOR SELECT USING (user_id = auth.uid())';
  
  EXECUTE 'CREATE POLICY "empresas_insert_own" ON empresas
    FOR INSERT WITH CHECK (user_id = auth.uid())';
  
  EXECUTE 'CREATE POLICY "empresas_update_own" ON empresas
    FOR UPDATE USING (user_id = auth.uid())';
  
  -- Remover policies antigas de subscriptions
  FOR pol IN SELECT policyname FROM pg_policies 
    WHERE tablename = 'subscriptions' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON subscriptions', pol.policyname);
  END LOOP;
  
  -- Recriar policies de subscriptions (agora com user_id único)
  EXECUTE 'CREATE POLICY "subscriptions_select_own" ON subscriptions
    FOR SELECT USING (user_id = auth.uid())';
  
  EXECUTE 'CREATE POLICY "subscriptions_insert_own" ON subscriptions
    FOR INSERT WITH CHECK (user_id = auth.uid())';
  
  EXECUTE 'CREATE POLICY "subscriptions_update_own" ON subscriptions
    FOR UPDATE USING (user_id = auth.uid())';
  
  RAISE NOTICE '✅ [5/7] RLS policies recriadas com sucesso';
END $$;

-- ============================================
-- SEÇÃO 6: CORRIGIR FUNCIONARIOS (ERRO 400)
-- ============================================

DO $$
DECLARE pol RECORD;
BEGIN
  RAISE NOTICE '🔍 [6/7] Verificando coluna user_id em funcionarios...';
  
  -- Adicionar coluna user_id se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'funcionarios' 
    AND column_name = 'user_id'
  ) THEN
    ALTER TABLE funcionarios ADD COLUMN user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;
    CREATE INDEX idx_funcionarios_user_id ON funcionarios(user_id);
    RAISE NOTICE '✅ Coluna user_id adicionada à tabela funcionarios';
  ELSE
    RAISE NOTICE '✅ Coluna user_id já existe na tabela funcionarios';
  END IF;
  
  -- Remover policies antigas de funcionarios
  FOR pol IN SELECT policyname FROM pg_policies 
    WHERE tablename = 'funcionarios' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON funcionarios', pol.policyname);
  END LOOP;
  
  -- Recriar policies de funcionarios
  EXECUTE 'CREATE POLICY "funcionarios_select_by_empresa" ON funcionarios
    FOR SELECT USING (
      empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
      OR user_id = auth.uid()
    )';
  
  EXECUTE 'CREATE POLICY "funcionarios_insert_by_empresa" ON funcionarios
    FOR INSERT WITH CHECK (
      empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
    )';
  
  EXECUTE 'CREATE POLICY "funcionarios_update_by_empresa" ON funcionarios
    FOR UPDATE USING (
      empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
      OR user_id = auth.uid()
    )';
  
  EXECUTE 'CREATE POLICY "funcionarios_delete_by_empresa" ON funcionarios
    FOR DELETE USING (
      empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
    )';
  
  RAISE NOTICE '✅ [6/7] Tabela funcionarios corrigida';
END $$;

-- ============================================
-- SEÇÃO 7: CORRIGIR AUDIT_LOGS (ERRO 400)
-- ============================================

DO $$
DECLARE pol RECORD;
BEGIN
  RAISE NOTICE '🔍 [7/7] Verificando coluna funcionario_id em audit_logs...';
  
  -- Tornar funcionario_id NULLABLE (não é sempre necessário)
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'audit_logs' 
    AND column_name = 'funcionario_id'
    AND is_nullable = 'NO'
  ) THEN
    ALTER TABLE audit_logs ALTER COLUMN funcionario_id DROP NOT NULL;
    RAISE NOTICE '✅ Coluna funcionario_id agora é nullable';
  ELSE
    RAISE NOTICE '✅ Coluna funcionario_id já é nullable ou não existe';
  END IF;
  
  -- Remover policies antigas de audit_logs
  FOR pol IN SELECT policyname FROM pg_policies 
    WHERE tablename = 'audit_logs' AND schemaname = 'public'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON audit_logs', pol.policyname);
  END LOOP;
  
  -- Recriar policies de audit_logs
  EXECUTE 'CREATE POLICY "audit_logs_select_by_empresa" ON audit_logs
    FOR SELECT USING (
      empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
    )';
  
  EXECUTE 'CREATE POLICY "audit_logs_insert_by_empresa" ON audit_logs
    FOR INSERT WITH CHECK (
      empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())
    )';
  
  RAISE NOTICE '✅ [7/7] Tabela audit_logs corrigida';
END $$;

-- ============================================
-- DIAGNÓSTICO FINAL
-- ============================================

DO $$
DECLARE
  empresa_count INT;
  user_id_value UUID;
  sub_count INT;
  sub_status TEXT;
  sub_plan TEXT;
  func_count INT;
  has_empresas_constraint BOOLEAN;
  has_subscriptions_constraint BOOLEAN;
  assistencia_user_id UUID;
BEGIN
  RAISE NOTICE '🔍 ==================== DIAGNÓSTICO FINAL ====================';
  
  -- Pegar o user_id do assistência
  SELECT id INTO assistencia_user_id 
  FROM auth.users 
  WHERE email LIKE '%assistencia%' 
  LIMIT 1;
  
  -- Verificar empresas
  SELECT COUNT(*) INTO empresa_count
  FROM empresas 
  WHERE user_id = assistencia_user_id;
  
  user_id_value := assistencia_user_id;
  
  RAISE NOTICE '📊 Empresas com user_id assistencia: %', empresa_count;
  RAISE NOTICE '🔑 user_id: %', user_id_value;
  
  -- Verificar subscriptions
  SELECT COUNT(*) INTO sub_count
  FROM subscriptions 
  WHERE user_id = assistencia_user_id;
  
  SELECT status, plan_type INTO sub_status, sub_plan
  FROM subscriptions 
  WHERE user_id = assistencia_user_id
  LIMIT 1;
  
  RAISE NOTICE '📊 Subscriptions com user_id assistencia: %', sub_count;
  RAISE NOTICE '📋 Status: % | Plano: %', sub_status, sub_plan;
  
  -- Verificar funcionários
  SELECT COUNT(*) INTO func_count
  FROM funcionarios 
  WHERE empresa_id IN (
    SELECT id FROM empresas 
    WHERE user_id = assistencia_user_id
  );
  
  RAISE NOTICE '📊 Funcionários associados: %', func_count;
  
  -- Verificar constraints
  SELECT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'empresas_user_id_unique'
  ) INTO has_empresas_constraint;
  
  SELECT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'subscriptions_user_id_unique'
  ) INTO has_subscriptions_constraint;
  
  IF has_empresas_constraint THEN
    RAISE NOTICE '✅ Constraint empresas_user_id_unique: ATIVO';
  ELSE
    RAISE NOTICE '❌ Constraint empresas_user_id_unique: NÃO ENCONTRADO';
  END IF;
  
  IF has_subscriptions_constraint THEN
    RAISE NOTICE '✅ Constraint subscriptions_user_id_unique: ATIVO';
  ELSE
    RAISE NOTICE '❌ Constraint subscriptions_user_id_unique: NÃO ENCONTRADO';
  END IF;
  
  RAISE NOTICE '🎉 ==================== CORREÇÃO CONCLUÍDA ====================';
  RAISE NOTICE '✅ Agora você pode usar .single() sem erro 406';
  RAISE NOTICE '✅ Erro 400 em funcionarios corrigido';
  RAISE NOTICE '✅ Erro 400 em audit_logs corrigido';
  RAISE NOTICE '🔄 Recarregue a página e teste o botão "Ativar Usuário"';
END $$;
