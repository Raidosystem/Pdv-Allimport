-- =============================================
-- FIX: Adicionar CONSTRAINT UNIQUE em login_funcionarios
-- =============================================
-- Erro: "there is no unique or exclusion constraint matching the ON CONFLICT specification"
-- Solução: Adicionar constraint UNIQUE na coluna funcionario_id
-- =============================================

-- 1️⃣ VERIFICAR SE JÁ EXISTE A CONSTRAINT
SELECT 
  '🔍 Verificando constraints existentes' as info,
  conname as constraint_name,
  contype as constraint_type,
  pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'login_funcionarios'::regclass;

-- 2️⃣ REMOVER DUPLICATAS (SE EXISTIREM)
-- Antes de adicionar UNIQUE, precisamos garantir que não há duplicatas
DO $$
DECLARE
  v_deleted INTEGER := 0;
BEGIN
  -- Manter apenas o registro mais antigo de cada funcionario_id
  DELETE FROM login_funcionarios
  WHERE id IN (
    SELECT lf.id
    FROM login_funcionarios lf
    WHERE EXISTS (
      SELECT 1 
      FROM login_funcionarios lf2
      WHERE lf2.funcionario_id = lf.funcionario_id
      AND lf2.created_at < lf.created_at
    )
  );
  
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  
  IF v_deleted > 0 THEN
    RAISE NOTICE '🗑️ % duplicatas removidas', v_deleted;
  ELSE
    RAISE NOTICE '✅ Nenhuma duplicata encontrada';
  END IF;
END $$;

-- 3️⃣ ADICIONAR CONSTRAINT UNIQUE NA COLUNA funcionario_id
DO $$
BEGIN
  -- Tentar adicionar constraint se não existir
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conrelid = 'login_funcionarios'::regclass 
    AND conname = 'login_funcionarios_funcionario_id_key'
  ) THEN
    ALTER TABLE login_funcionarios 
    ADD CONSTRAINT login_funcionarios_funcionario_id_key 
    UNIQUE (funcionario_id);
    
    RAISE NOTICE '✅ Constraint UNIQUE adicionada com sucesso!';
  ELSE
    RAISE NOTICE '⚠️ Constraint já existe';
  END IF;
END $$;

-- 4️⃣ VERIFICAR RESULTADO
SELECT 
  '✅ CONSTRAINTS APÓS CORREÇÃO' as info,
  conname as constraint_name,
  contype as constraint_type,
  pg_get_constraintdef(oid) as constraint_definition
FROM pg_constraint
WHERE conrelid = 'login_funcionarios'::regclass;

-- 5️⃣ TESTAR ON CONFLICT (deve funcionar agora)
DO $$
DECLARE
  v_test_funcionario_id UUID;
BEGIN
  -- Pegar um funcionário existente
  SELECT id INTO v_test_funcionario_id
  FROM funcionarios
  LIMIT 1;
  
  -- Tentar inserir com ON CONFLICT (não deve dar erro agora)
  INSERT INTO login_funcionarios (
    funcionario_id,
    usuario,
    senha,
    ativo
  )
  VALUES (
    v_test_funcionario_id,
    'teste_conflict',
    crypt('123456', gen_salt('bf')),
    true
  )
  ON CONFLICT (funcionario_id) DO UPDATE
  SET 
    usuario = EXCLUDED.usuario,
    updated_at = NOW();
  
  RAISE NOTICE '✅ Teste ON CONFLICT funcionou!';
  
  -- Limpar teste
  DELETE FROM login_funcionarios WHERE usuario = 'teste_conflict';
END $$;

-- 6️⃣ COMENTÁRIO
COMMENT ON CONSTRAINT login_funcionarios_funcionario_id_key ON login_funcionarios IS 
'Garante que cada funcionário tenha apenas um registro de login';

SELECT '🎉 Correção aplicada com sucesso! Agora o trigger e ON CONFLICT funcionarão.' as resultado;
