-- ============================================
-- DIAGNÓSTICO E CORREÇÃO - CRIAÇÃO DE FUNCIONÁRIOS
-- ============================================

-- 1. VERIFICAR ESTRUTURA DA TABELA FUNCIONARIOS
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcionarios'
ORDER BY ordinal_position;

-- 2. VERIFICAR CONSTRAINTS
SELECT
  con.conname AS constraint_name,
  con.contype AS constraint_type,
  CASE 
    WHEN con.contype = 'u' THEN 'UNIQUE'
    WHEN con.contype = 'p' THEN 'PRIMARY KEY'
    WHEN con.contype = 'f' THEN 'FOREIGN KEY'
    WHEN con.contype = 'c' THEN 'CHECK'
  END AS type_description,
  pg_get_constraintdef(con.oid) AS definition
FROM pg_constraint con
JOIN pg_class rel ON rel.oid = con.conrelid
WHERE rel.relname = 'funcionarios';

-- 3. VERIFICAR SE JÁ EXISTE CONSTRAINT (empresa_id, user_id)
SELECT EXISTS (
  SELECT 1 
  FROM pg_constraint con
  JOIN pg_class rel ON rel.oid = con.conrelid
  WHERE rel.relname = 'funcionarios'
  AND con.contype = 'u'
  AND pg_get_constraintdef(con.oid) LIKE '%empresa_id%user_id%'
) as tem_constraint_user_id;

-- 4. ADICIONAR CONSTRAINT SE NÃO EXISTIR
DO $$
BEGIN
  -- Adicionar constraint UNIQUE (empresa_id, user_id) se não existir
  IF NOT EXISTS (
    SELECT 1 
    FROM pg_constraint con
    JOIN pg_class rel ON rel.oid = con.conrelid
    WHERE rel.relname = 'funcionarios'
    AND con.contype = 'u'
    AND pg_get_constraintdef(con.oid) LIKE '%empresa_id%user_id%'
  ) THEN
    ALTER TABLE funcionarios 
    ADD CONSTRAINT funcionarios_empresa_user_key UNIQUE (empresa_id, user_id);
    RAISE NOTICE '✅ Constraint UNIQUE (empresa_id, user_id) adicionada';
  ELSE
    RAISE NOTICE '⚠️ Constraint já existe';
  END IF;
END $$;

-- 5. VERIFICAR USUÁRIOS SEM FUNCIONÁRIOS
SELECT 
  u.email,
  u.id as user_id,
  e.id as empresa_id,
  e.nome as empresa_nome,
  CASE 
    WHEN f.id IS NULL THEN '❌ SEM FUNCIONÁRIO'
    ELSE '✅ COM FUNCIONÁRIO'
  END as status
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
LEFT JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
ORDER BY u.created_at;

-- 6. CRIAR FUNCIONÁRIOS PARA TODOS OS USUÁRIOS
DO $$
DECLARE
  v_user RECORD;
  v_count INT := 0;
BEGIN
  RAISE NOTICE '🚀 Criando funcionários para todos os usuários...';
  
  FOR v_user IN 
    SELECT 
      u.id as user_id,
      u.email,
      u.raw_user_meta_data->>'full_name' as full_name,
      u.phone,
      e.id as empresa_id
    FROM auth.users u
    JOIN empresas e ON e.user_id = u.id
    LEFT JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
    WHERE f.id IS NULL
  LOOP
    BEGIN
      INSERT INTO funcionarios (
        empresa_id,
        user_id,
        nome,
        email,
        telefone,
        status
      ) VALUES (
        v_user.empresa_id,
        v_user.user_id,
        COALESCE(v_user.full_name, 'Administrador'),
        v_user.email,
        COALESCE(v_user.phone, '(00) 00000-0000'),
        'ativo'
      );
      
      v_count := v_count + 1;
      RAISE NOTICE '✅ Funcionário criado para: %', v_user.email;
      
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE '❌ Erro ao criar funcionário para %: %', v_user.email, SQLERRM;
    END;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ Total de funcionários criados: %', v_count;
END $$;

-- 7. VERIFICAR RESULTADO
SELECT 
  u.email,
  f.nome as funcionario_nome,
  f.status,
  f.created_at
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
LEFT JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
ORDER BY u.created_at;

-- 8. EXECUTAR NOVAMENTE A CONFIGURAÇÃO DE PERMISSÕES
DO $$
DECLARE
  v_user RECORD;
  v_total_users INT := 0;
  v_success_count INT := 0;
BEGIN
  RAISE NOTICE '🚀 Configurando permissões para todos os usuários...';
  
  FOR v_user IN 
    SELECT u.id, u.email
    FROM auth.users u
    JOIN empresas e ON e.user_id = u.id
    ORDER BY u.created_at
  LOOP
    BEGIN
      PERFORM setup_admin_permissions_for_user(v_user.id);
      v_success_count := v_success_count + 1;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE '❌ Erro ao configurar usuário %: %', v_user.email, SQLERRM;
    END;
    
    v_total_users := v_total_users + 1;
  END LOOP;

  RAISE NOTICE '';
  RAISE NOTICE '✅ Configuração concluída!';
  RAISE NOTICE '   Total de usuários processados: %', v_total_users;
  RAISE NOTICE '   Configurados com sucesso: %', v_success_count;
  RAISE NOTICE '   Falhas: %', v_total_users - v_success_count;
END $$;

-- 9. VERIFICAR RESULTADO FINAL
SELECT 
  u.email as usuario_email,
  e.nome as empresa,
  f.nome as funcionario_nome,
  func.nome as funcao,
  COUNT(DISTINCT fp.permissao_id) as total_permissoes,
  CASE 
    WHEN COUNT(DISTINCT fp.permissao_id) >= 35 THEN '✅ COMPLETO'
    WHEN COUNT(DISTINCT fp.permissao_id) > 0 THEN '⚠️ PARCIAL'
    ELSE '❌ SEM PERMISSÕES'
  END as status
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
LEFT JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
GROUP BY u.id, u.email, e.nome, f.nome, func.nome
ORDER BY u.created_at DESC;

-- 10. RESUMO FINAL
SELECT 
  COUNT(DISTINCT u.id) as total_usuarios,
  COUNT(DISTINCT e.id) as total_empresas,
  COUNT(DISTINCT f.id) as total_funcionarios,
  COUNT(DISTINCT func.id) as total_funcoes,
  COUNT(DISTINCT fp.permissao_id) as total_permissoes_atribuidas
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id;
