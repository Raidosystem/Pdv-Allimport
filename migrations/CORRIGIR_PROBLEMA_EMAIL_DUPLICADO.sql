-- ========================================
-- CORRIGIR PROBLEMA DE FUNCIONÁRIO EXCLUÍDO FICA ATIVO
-- ========================================
-- Problema: Ao excluir funcionário, o registro em auth.users não é removido
-- Ao tentar recriar com mesmo email, sistema diz "email já cadastrado"
-- Solução: Implementar exclusão em cascata e verificação melhorada

-- ========================================
-- 1️⃣ DIAGNOSTICAR O PROBLEMA
-- ========================================
-- Verificar funcionários excluídos mas com usuário ativo em auth.users

SELECT 
  '🔍 USUÁRIOS ÓRFÃOS (auth.users SEM funcionarios)' as diagnostico,
  au.id as user_id,
  au.email,
  au.created_at,
  au.deleted_at,
  CASE 
    WHEN f.id IS NULL THEN '❌ Funcionário excluído mas usuário ativo'
    ELSE '✅ OK'
  END as status
FROM auth.users au
LEFT JOIN funcionarios f ON f.user_id = au.id
WHERE au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%@allimport%' -- emails do sistema
ORDER BY au.created_at DESC
LIMIT 20;

-- ========================================
-- 2️⃣ ATUALIZAR FUNÇÃO DE EXCLUSÃO (handleExcluirFuncionario)
-- ========================================
-- A função de excluir precisa remover de auth.users também

CREATE OR REPLACE FUNCTION excluir_funcionario_completo(
  p_funcionario_id uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_nome text;
BEGIN
  -- Buscar user_id antes de excluir
  SELECT user_id, nome INTO v_user_id, v_nome
  FROM funcionarios
  WHERE id = p_funcionario_id;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Funcionário não encontrado'
    );
  END IF;

  -- 1. Excluir de login_funcionarios (FK)
  DELETE FROM login_funcionarios
  WHERE funcionario_id = p_funcionario_id;

  -- 2. Excluir de funcao_permissoes (se houver FK)
  DELETE FROM funcao_permissoes
  WHERE funcionario_id = p_funcionario_id;

  -- 3. Excluir de user_approvals (se houver)
  DELETE FROM user_approvals
  WHERE funcionario_id = p_funcionario_id;

  -- 4. Excluir de sessao_ativa_funcionario (se houver)
  DELETE FROM sessao_ativa_funcionario
  WHERE funcionario_id = p_funcionario_id;

  -- 5. Excluir de funcionarios
  DELETE FROM funcionarios
  WHERE id = p_funcionario_id;

  -- 6. ✅ CRÍTICO: Excluir de auth.users (liberar email)
  -- MAS APENAS SE NÃO HOUVER DADOS VINCULADOS (vendas, produtos, etc.)
  IF v_user_id IS NOT NULL THEN
    -- Verificar se usuário tem dados vinculados
    IF NOT EXISTS (SELECT 1 FROM vendas WHERE user_id = v_user_id)
       AND NOT EXISTS (SELECT 1 FROM vendas_itens WHERE user_id = v_user_id)
       AND NOT EXISTS (SELECT 1 FROM produtos WHERE user_id = v_user_id)
       AND NOT EXISTS (SELECT 1 FROM clientes WHERE user_id = v_user_id)
       AND NOT EXISTS (SELECT 1 FROM empresas WHERE id = v_user_id) THEN
      
      -- Seguro deletar
      DELETE FROM auth.users WHERE id = v_user_id;
      
      RETURN json_build_object(
        'success', true,
        'message', 'Funcionário ' || v_nome || ' excluído completamente (email liberado)'
      );
    ELSE
      -- Não pode deletar auth.users, mas funcionário foi removido
      RETURN json_build_object(
        'success', true,
        'message', 'Funcionário ' || v_nome || ' excluído (dados históricos mantidos)'
      );
    END IF;
  END IF;

  RETURN json_build_object(
    'success', true,
    'message', 'Funcionário ' || v_nome || ' excluído completamente'
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Erro ao excluir funcionário: ' || SQLERRM
    );
END;
$$;

COMMENT ON FUNCTION excluir_funcionario_completo IS 'Exclui funcionário COMPLETAMENTE incluindo auth.users para liberar email';

-- ========================================
-- 3️⃣ ATUALIZAR FUNÇÃO DE CADASTRO
-- ========================================
-- Melhorar validação para aceitar recriar funcionário com email órfão

CREATE OR REPLACE FUNCTION cadastrar_funcionario_simples(
  p_empresa_id uuid,
  p_nome text,
  p_email text,
  p_senha text,
  p_funcao_id uuid DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_funcionario_id uuid;
  v_user_id uuid;
  v_usuario text;
  v_email_existe boolean;
BEGIN
  -- Validações
  IF p_nome IS NULL OR trim(p_nome) = '' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Nome é obrigatório'
    );
  END IF;

  IF p_email IS NULL OR trim(p_email) = '' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Email é obrigatório'
    );
  END IF;

  IF p_senha IS NULL OR length(p_senha) < 6 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Senha deve ter no mínimo 6 caracteres'
    );
  END IF;

  -- ✅ VERIFICAÇÃO MELHORADA: Verificar se email existe E está ativo
  SELECT EXISTS (
    SELECT 1 
    FROM auth.users au
    JOIN funcionarios f ON f.user_id = au.id
    WHERE au.email = p_email
      AND f.empresa_id = p_empresa_id
  ) INTO v_email_existe;

  IF v_email_existe THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Email já cadastrado como funcionário ativo'
    );
  END IF;

  -- ✅ LIMPAR USUÁRIO ÓRFÃO (se existir)
  -- Se email existe em auth.users mas não em funcionarios, remover
  DELETE FROM auth.users
  WHERE email = p_email
    AND id NOT IN (SELECT user_id FROM funcionarios WHERE user_id IS NOT NULL);

  -- Gerar usuário a partir do nome
  v_usuario := lower(regexp_replace(split_part(p_nome, ' ', 1), '[^a-zA-Z0-9]', '', 'g'));
  
  -- Garantir que o usuário é único
  WHILE EXISTS (SELECT 1 FROM login_funcionarios WHERE usuario = v_usuario) LOOP
    v_usuario := v_usuario || floor(random() * 100)::text;
  END LOOP;

  -- 1. Criar usuário no Supabase Auth
  BEGIN
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      created_at,
      updated_at,
      raw_app_meta_data,
      raw_user_meta_data,
      is_super_admin,
      confirmation_token,
      email_change_token_new,
      recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      p_email,
      crypt(p_senha, gen_salt('bf')),
      now(),
      now(),
      now(),
      '{"provider":"email","providers":["email"]}',
      json_build_object('full_name', p_nome),
      false,
      encode(gen_random_bytes(32), 'hex'),
      '',
      ''
    )
    RETURNING id INTO v_user_id;
  EXCEPTION
    WHEN unique_violation THEN
      RETURN json_build_object(
        'success', false,
        'error', 'Email já está em uso em outro contexto'
      );
    WHEN OTHERS THEN
      RETURN json_build_object(
        'success', false,
        'error', 'Erro ao criar conta: ' || SQLERRM
      );
  END;

  -- 2. Criar registro na tabela funcionarios
  BEGIN
    INSERT INTO funcionarios (
      empresa_id,
      user_id,
      nome,
      email,
      tipo_admin,
      funcao_id,
      status,
      usuario_ativo,
      senha_definida,
      primeiro_acesso
    ) VALUES (
      p_empresa_id,
      v_user_id,
      p_nome,
      p_email,
      'funcionario',
      p_funcao_id,
      'ativo',
      true,
      false,  -- Senha ainda não foi definida pelo funcionário
      true    -- É o primeiro acesso
    )
    RETURNING id INTO v_funcionario_id;
  EXCEPTION
    WHEN OTHERS THEN
      -- Se falhar, remover usuário criado no auth
      DELETE FROM auth.users WHERE id = v_user_id;
      RETURN json_build_object(
        'success', false,
        'error', 'Erro ao criar funcionário: ' || SQLERRM
      );
  END;

  -- 3. Criar registro na tabela login_funcionarios
  BEGIN
    INSERT INTO login_funcionarios (
      funcionario_id,
      usuario,
      senha,
      ativo
    ) VALUES (
      v_funcionario_id,
      v_usuario,
      crypt(p_senha, gen_salt('bf')),
      true
    );
  EXCEPTION
    WHEN OTHERS THEN
      -- Rollback: excluir funcionário e auth.users
      DELETE FROM funcionarios WHERE id = v_funcionario_id;
      DELETE FROM auth.users WHERE id = v_user_id;
      RETURN json_build_object(
        'success', false,
        'error', 'Erro ao criar login: ' || SQLERRM
      );
  END;

  RETURN json_build_object(
    'success', true,
    'message', 'Funcionário criado com sucesso',
    'funcionario_id', v_funcionario_id,
    'usuario', v_usuario
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Erro inesperado: ' || SQLERRM
    );
END;
$$;

COMMENT ON FUNCTION cadastrar_funcionario_simples IS 'Cadastra funcionário com validação melhorada e limpeza de registros órfãos';

-- ========================================
-- 4️⃣ LIMPAR USUÁRIOS ÓRFÃOS EXISTENTES (SEGURO)
-- ========================================
-- Remover APENAS usuários que não têm funcionário NEM dados vinculados

DO $$
DECLARE
  v_count integer;
  v_user_id uuid;
BEGIN
  -- Deletar auth.users que:
  -- 1. Não tem funcionario associado
  -- 2. Não tem vendas
  -- 3. Não tem produtos
  -- 4. Não tem clientes
  -- 5. Não são admins de empresa
  
  FOR v_user_id IN (
    SELECT au.id
    FROM auth.users au
    WHERE au.role = 'authenticated'
      AND au.email NOT LIKE '%@supabase%'
      AND au.email NOT LIKE '%allimport%'
      -- Não tem funcionário
      AND NOT EXISTS (SELECT 1 FROM funcionarios WHERE user_id = au.id)
      -- Não tem vendas
      AND NOT EXISTS (SELECT 1 FROM vendas WHERE user_id = au.id)
      AND NOT EXISTS (SELECT 1 FROM vendas_itens WHERE user_id = au.id)
      -- Não tem produtos
      AND NOT EXISTS (SELECT 1 FROM produtos WHERE user_id = au.id)
      -- Não tem clientes
      AND NOT EXISTS (SELECT 1 FROM clientes WHERE user_id = au.id)
      -- Não tem empresa
      AND NOT EXISTS (SELECT 1 FROM empresas WHERE id = au.id)
  ) LOOP
    BEGIN
      DELETE FROM auth.users WHERE id = v_user_id;
      v_count := v_count + 1;
    EXCEPTION
      WHEN foreign_key_violation THEN
        RAISE NOTICE '⚠️ Usuário % tem dependências, mantido', v_user_id;
    END;
  END LOOP;

  RAISE NOTICE '✅ % usuários órfãos removidos com segurança', COALESCE(v_count, 0);
END $$;

-- ========================================
-- 5️⃣ VERIFICAÇÃO FINAL
-- ========================================
SELECT 
  '✅ VERIFICAÇÃO PÓS-LIMPEZA' as status,
  COUNT(*) as usuarios_orfaos
FROM auth.users au
LEFT JOIN funcionarios f ON f.user_id = au.id
WHERE f.id IS NULL
  AND au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%@allimport%'
  AND au.role = 'authenticated';

-- Deve retornar 0 usuários órfãos

-- ========================================
-- 6️⃣ DIAGNÓSTICO DETALHADO DE USUÁRIOS ÓRFÃOS
-- ========================================
-- Se ainda houver usuários órfãos, vamos investigar

SELECT 
  '🔍 IDENTIFICAR USUÁRIO ÓRFÃO' as diagnostico,
  au.id as user_id,
  au.email,
  au.created_at,
  au.role,
  -- Verificar dependências
  (SELECT COUNT(*) FROM vendas WHERE user_id = au.id) as total_vendas,
  (SELECT COUNT(*) FROM vendas_itens WHERE user_id = au.id) as total_vendas_itens,
  (SELECT COUNT(*) FROM produtos WHERE user_id = au.id) as total_produtos,
  (SELECT COUNT(*) FROM clientes WHERE user_id = au.id) as total_clientes,
  (SELECT COUNT(*) FROM caixa WHERE user_id = au.id) as total_caixa,
  (SELECT COUNT(*) FROM ordens_servico WHERE user_id = au.id) as total_os,
  CASE 
    WHEN EXISTS (SELECT 1 FROM empresas WHERE id = au.id) THEN '✅ É admin de empresa'
    ELSE '❌ Não é admin'
  END as tipo_conta
FROM auth.users au
LEFT JOIN funcionarios f ON f.user_id = au.id
WHERE f.id IS NULL
  AND au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%@allimport%'
  AND au.role = 'authenticated';

-- ========================================
-- 7️⃣ OPÇÕES DE RESOLUÇÃO
-- ========================================
/*
CENÁRIO 1: Usuário órfão COM vendas/produtos (histórico importante)
-> NÃO DELETAR - Manter para preservar integridade referencial
-> Email não pode ser reutilizado
-> Solução: Usar outro email para novo funcionário

CENÁRIO 2: Usuário órfão SEM dados relevantes
-> Verificar foreign keys que impedem exclusão
-> Executar query abaixo para ver todas as FKs:
*/

SELECT 
  '🔗 FOREIGN KEYS APONTANDO PARA auth.users' as info,
  conname as constraint_name,
  conrelid::regclass as table_name,
  a.attname as column_name
FROM pg_constraint c
JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
WHERE c.confrelid = 'auth.users'::regclass
  AND c.contype = 'f'
ORDER BY table_name, column_name;

-- ========================================
-- 🔍 IDENTIFICAR QUAL TABELA BLOQUEIA A EXCLUSÃO
-- ========================================
-- Esta query verifica TODAS as tabelas com FK para auth.users

DO $$
DECLARE
  v_user_id uuid;
  v_table_name text;
  v_column_name text;
  v_count integer;
  v_result text := '';
BEGIN
  -- Pegar ID do usuário órfão
  SELECT au.id INTO v_user_id
  FROM auth.users au
  LEFT JOIN funcionarios f ON f.user_id = au.id
  WHERE f.id IS NULL
    AND au.email NOT LIKE '%@supabase%'
    AND au.email NOT LIKE '%@allimport%'
    AND au.role = 'authenticated'
  LIMIT 1;

  IF v_user_id IS NULL THEN
    RAISE NOTICE '✅ Nenhum usuário órfão encontrado!';
    RETURN;
  END IF;

  RAISE NOTICE '🔍 Verificando dependências do usuário: %', v_user_id;
  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';

  -- Verificar cada tabela
  FOR v_table_name, v_column_name IN 
    SELECT 
      conrelid::regclass::text,
      a.attname
    FROM pg_constraint c
    JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
    WHERE c.confrelid = 'auth.users'::regclass
      AND c.contype = 'f'
      AND conrelid::regclass::text NOT LIKE 'auth.%'
    ORDER BY conrelid::regclass::text
  LOOP
    EXECUTE format('SELECT COUNT(*) FROM %I WHERE %I = $1', v_table_name, v_column_name)
    INTO v_count
    USING v_user_id;

    IF v_count > 0 THEN
      RAISE NOTICE '❌ % tem % registros na coluna %', v_table_name, v_count, v_column_name;
    END IF;
  END LOOP;

  RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

-- ========================================
-- 8️⃣ FORÇAR REMOÇÃO (APENAS SE NECESSÁRIO)
-- ========================================
/*
⚠️ ATENÇÃO: Execute apenas se tiver certeza que o usuário órfão
pode ser removido mesmo com dados históricos.

Isso vai quebrar a integridade referencial temporariamente,
mas permite deletar o usuário.

-- Desabilitar FK temporariamente (NÃO RECOMENDADO EM PRODUÇÃO)
ALTER TABLE vendas_itens DROP CONSTRAINT IF EXISTS vendas_itens_user_id_fkey;
ALTER TABLE vendas DROP CONSTRAINT IF EXISTS vendas_user_id_fkey;

-- Deletar usuário órfão
DELETE FROM auth.users
WHERE id = 'COLE_O_USER_ID_AQUI'
  AND id NOT IN (SELECT user_id FROM funcionarios WHERE user_id IS NOT NULL);

-- Recriar FK (IMPORTANTE!)
ALTER TABLE vendas_itens 
  ADD CONSTRAINT vendas_itens_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE vendas 
  ADD CONSTRAINT vendas_user_id_fkey 
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;
*/

-- ========================================
-- 9️⃣ SOLUÇÃO ALTERNATIVA: MARCAR COMO INATIVO
-- ========================================
/*
Se não puder deletar o usuário devido a foreign keys,
marque-o como inativo para evitar confusão:

UPDATE auth.users
SET 
  email = email || '.REMOVIDO',
  deleted_at = NOW(),
  raw_user_meta_data = jsonb_set(
    COALESCE(raw_user_meta_data, '{}'::jsonb),
    '{status}',
    '"removido"'
  )
WHERE id = 'COLE_O_USER_ID_AQUI'
  AND id NOT IN (SELECT user_id FROM funcionarios WHERE user_id IS NOT NULL);

-- Isso permite criar novo funcionário com o email original
*/

-- ========================================
-- 📋 COMO USAR NO FRONTEND
-- ========================================
/*
Em ActivateUsersPage.tsx, substituir handleExcluirFuncionario:

const handleExcluirFuncionario = async () => {
  try {
    if (!deleteConfirm.funcionarioId) return

    // ✅ USAR NOVA RPC QUE LIMPA TUDO
    const { data, error } = await supabase
      .rpc('excluir_funcionario_completo', {
        p_funcionario_id: deleteConfirm.funcionarioId
      })

    if (error) throw error

    if (data?.success) {
      toast.success(data.message)
      setDeleteConfirm({ isOpen: false, funcionarioId: null, funcionarioNome: '' })
      carregarFuncionarios()
    } else {
      toast.error(data?.error || 'Erro ao excluir funcionário')
    }

  } catch (error: any) {
    console.error('Erro ao excluir funcionário:', error)
    toast.error('Erro ao excluir funcionário: ' + error.message)
  }
}
*/

-- ========================================
-- 🎯 RESUMO DA CORREÇÃO
-- ========================================
/*
✅ Criada função excluir_funcionario_completo()
   - Remove de login_funcionarios
   - Remove de funcionarios
   - Remove de auth.users (libera email)

✅ Atualizada função cadastrar_funcionario_simples()
   - Verifica se email está em uso ATIVO
   - Limpa registros órfãos automaticamente
   - Permite recriar funcionário com email anterior

✅ Limpeza de usuários órfãos existentes
   - Remove auth.users sem funcionário associado

⚠️ PRÓXIMO PASSO:
   Atualizar ActivateUsersPage.tsx para usar a nova RPC
*/
