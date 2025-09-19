-- Script para corrigir rapidamente acesso administrativo
-- Execute este script no SQL Editor do Supabase

-- 1. Verificar usuários cadastrados no auth.users
SELECT 
  u.id as user_id,
  u.email,
  u.created_at,
  f.id as funcionario_id,
  f.nome,
  f.tipo_admin,
  f.status,
  e.nome as empresa_nome
FROM auth.users u
LEFT JOIN funcionarios f ON u.id = f.user_id
LEFT JOIN empresas e ON f.empresa_id = e.id
ORDER BY u.created_at DESC;

-- 2. Se não houver empresa, criar uma
INSERT INTO empresas (nome, cnpj, telefone, email) 
SELECT 'Allimport', '00.000.000/0001-00', '(00) 0000-0000', 'admin@allimport.com'
WHERE NOT EXISTS (SELECT 1 FROM empresas LIMIT 1);

-- 3. Para cada usuário que deveria ser admin mas não está configurado:
-- SUBSTITUA 'SEU_EMAIL_AQUI' pelo email do usuário que precisa ser admin

DO $$
DECLARE
    v_user_id uuid;
    v_empresa_id uuid;
    v_funcionario_id uuid;
    v_funcao_admin_id uuid;
    v_user_email text := 'SEU_EMAIL_AQUI'; -- <<< ALTERE AQUI
BEGIN
    -- Buscar ID do usuário pelo email
    SELECT id INTO v_user_id 
    FROM auth.users 
    WHERE email = v_user_email;
    
    IF v_user_id IS NULL THEN
        RAISE NOTICE 'Usuário com email % não encontrado', v_user_email;
        RETURN;
    END IF;
    
    -- Buscar empresa (pegar a primeira se houver múltiplas)
    SELECT id INTO v_empresa_id 
    FROM empresas 
    LIMIT 1;
    
    IF v_empresa_id IS NULL THEN
        RAISE NOTICE 'Nenhuma empresa encontrada';
        RETURN;
    END IF;
    
    -- Verificar se já existe funcionário
    SELECT id INTO v_funcionario_id
    FROM funcionarios
    WHERE user_id = v_user_id;
    
    -- Se não existe, criar funcionário admin
    IF v_funcionario_id IS NULL THEN
        INSERT INTO funcionarios (
            user_id, 
            empresa_id, 
            nome, 
            email, 
            tipo_admin, 
            status
        ) VALUES (
            v_user_id,
            v_empresa_id,
            split_part(v_user_email, '@', 1),
            v_user_email,
            'admin_empresa',
            'ativo'
        ) RETURNING id INTO v_funcionario_id;
        
        RAISE NOTICE 'Funcionário criado com ID: %', v_funcionario_id;
    ELSE
        -- Se existe, garantir que é admin
        UPDATE funcionarios 
        SET tipo_admin = 'admin_empresa', status = 'ativo'
        WHERE id = v_funcionario_id;
        
        RAISE NOTICE 'Funcionário % atualizado para admin', v_funcionario_id;
    END IF;
    
    -- Verificar se existe função de Administrador
    SELECT id INTO v_funcao_admin_id
    FROM funcoes
    WHERE empresa_id = v_empresa_id 
    AND nome = 'Administrador';
    
    -- Se não existe, criar função de Administrador
    IF v_funcao_admin_id IS NULL THEN
        INSERT INTO funcoes (
            empresa_id,
            nome,
            descricao,
            is_system
        ) VALUES (
            v_empresa_id,
            'Administrador',
            'Acesso total ao sistema',
            true
        ) RETURNING id INTO v_funcao_admin_id;
        
        -- Associar todas as permissões à função de Administrador
        INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
        SELECT v_funcao_admin_id, p.id, v_empresa_id
        FROM permissoes p;
        
        RAISE NOTICE 'Função Administrador criada com ID: %', v_funcao_admin_id;
    END IF;
    
    -- Associar funcionário à função de Administrador (se não já associado)
    INSERT INTO funcionario_funcoes (funcionario_id, funcao_id, empresa_id)
    SELECT v_funcionario_id, v_funcao_admin_id, v_empresa_id
    WHERE NOT EXISTS (
        SELECT 1 FROM funcionario_funcoes 
        WHERE funcionario_id = v_funcionario_id 
        AND funcao_id = v_funcao_admin_id
    );
    
    RAISE NOTICE 'Configuração completa para usuário %', v_user_email;
    
END $$;

-- 4. Verificar se deu certo
SELECT 
  u.email,
  f.nome,
  f.tipo_admin,
  f.status,
  e.nome as empresa,
  array_agg(fn.nome) as funcoes
FROM auth.users u
JOIN funcionarios f ON u.id = f.user_id
JOIN empresas e ON f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON f.id = ff.funcionario_id
LEFT JOIN funcoes fn ON ff.funcao_id = fn.id
GROUP BY u.email, f.nome, f.tipo_admin, f.status, e.nome
ORDER BY u.email;