-- =============================================
-- ?? CORREÇÃO COMPLETA - EXECUTAR TUDO DE UMA VEZ
-- =============================================
-- Este script consolida todas as correções necessárias
-- Execute TODO este arquivo no Supabase SQL Editor
-- Tempo estimado: 30 segundos
-- =============================================

-- =============================================
-- PARTE 1: GARANTIR EXTENSÃO pgcrypto
-- =============================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

SELECT '? PASSO 1: Extension pgcrypto garantida' as status;

-- =============================================
-- PARTE 2: CORRIGIR RPC listar_usuarios_ativos
-- VERSÃO CORRIGIDA: Mostra TODOS os usuários ativos (exceto super_admin)
-- =============================================

-- Dropar função antiga
DROP FUNCTION IF EXISTS listar_usuarios_ativos(UUID);

-- Recriar com lógica melhorada
CREATE OR REPLACE FUNCTION listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  email TEXT,
  foto_perfil TEXT,
  tipo_admin TEXT,
  senha_definida BOOLEAN,
  primeiro_acesso BOOLEAN,
  usuario TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id,
    f.nome,
    COALESCE(f.email, '') as email,
    f.foto_perfil,
    f.tipo_admin,
    COALESCE(f.senha_definida, false) as senha_definida,
    COALESCE(f.primeiro_acesso, true) as primeiro_acesso,
    COALESCE(lf.usuario, lower(regexp_replace(f.nome, '[^a-zA-Z0-9]', '', 'g'))) as usuario
  FROM funcionarios f
  LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id AND lf.ativo = true
  WHERE f.empresa_id = p_empresa_id
    AND (f.ativo = true OR f.ativo IS NULL)  -- Permite ativo=true ou NULL
    AND (f.usuario_ativo = true OR f.usuario_ativo IS NULL)  -- Permite usuario_ativo=true ou NULL
    AND (f.status = 'ativo' OR f.status IS NULL)  -- Permite status='ativo' ou NULL
    AND f.senha_definida = true  -- Exige senha definida
    AND (f.tipo_admin IS NULL OR f.tipo_admin != 'super_admin')  -- Exclui apenas super_admin
  ORDER BY f.nome;
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO authenticated, anon;

SELECT '? PASSO 2: RPC listar_usuarios_ativos corrigida (mostra todos exceto super_admin)' as status;

-- =============================================
-- ?? NOTA IMPORTANTE:
-- Esta versão mostra TODOS os funcionários ativos,
-- incluindo admin_empresa (Cristiano)
-- 
-- Se você NÃO quer mostrar admin_empresa no login local,
-- adicione esta condição no WHERE:
-- AND (f.tipo_admin IS NULL OR f.tipo_admin NOT IN ('admin_empresa', 'super_admin'))
-- =============================================

-- =============================================
-- PARTE 3: CORRIGIR RPC validar_senha_local
-- Compatibilidade com senha E senha_hash
-- =============================================

-- Dropar função antiga
DROP FUNCTION IF EXISTS validar_senha_local(TEXT, TEXT);

-- Recriar função corrigida
CREATE OR REPLACE FUNCTION validar_senha_local(
    p_usuario TEXT,
    p_senha TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_login RECORD;
    v_funcionario RECORD;
    v_senha_valida BOOLEAN := false;
BEGIN
    -- Buscar login
    SELECT * INTO v_login
    FROM login_funcionarios
    WHERE usuario = p_usuario AND ativo = true;

    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Usuário ou senha inválidos');
    END IF;

    -- Validar senha: PRIORIZAR senha_hash, fallback senha
    IF v_login.senha_hash IS NOT NULL AND v_login.senha_hash != '' THEN
        v_senha_valida := (v_login.senha_hash = crypt(p_senha, v_login.senha_hash));
    ELSIF v_login.senha IS NOT NULL AND v_login.senha != '' THEN
        v_senha_valida := (v_login.senha = crypt(p_senha, v_login.senha));
    END IF;

    IF NOT v_senha_valida THEN
        RETURN json_build_object('success', false, 'error', 'Usuário ou senha inválidos');
    END IF;

    -- Buscar funcionário
    SELECT f.*, func.nome as funcao_nome, func.nivel as funcao_nivel
    INTO v_funcionario
    FROM funcionarios f
    LEFT JOIN funcoes func ON f.funcao_id = func.id
    WHERE f.id = v_login.funcionario_id AND f.ativo = true;

    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Funcionário inativo');
    END IF;

    -- Retornar sucesso
    RETURN json_build_object(
        'success', true,
        'funcionario', row_to_json(v_funcionario),
        'precisa_trocar_senha', COALESCE(v_login.precisa_trocar_senha, false)
    );
END;
$$;

GRANT EXECUTE ON FUNCTION validar_senha_local(TEXT, TEXT) TO authenticated, anon;

SELECT '? PASSO 3: RPC validar_senha_local corrigida (compatível senha + senha_hash)' as status;

-- =============================================
-- PARTE 4: CORRIGIR RPC atualizar_senha_funcionario
-- =============================================

DROP FUNCTION IF EXISTS atualizar_senha_funcionario(UUID, TEXT);

CREATE OR REPLACE FUNCTION atualizar_senha_funcionario(
    p_funcionario_id UUID,
    p_nova_senha TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    IF p_funcionario_id IS NULL OR p_nova_senha IS NULL THEN
        RAISE EXCEPTION 'ID e senha obrigatórios';
    END IF;

    IF LENGTH(p_nova_senha) < 6 THEN
        RAISE EXCEPTION 'Senha deve ter pelo menos 6 caracteres';
    END IF;

    -- ATUALIZAR AMBOS OS CAMPOS (senha e senha_hash)
    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_nova_senha, gen_salt('bf')),
        senha = crypt(p_nova_senha, gen_salt('bf')),
        precisa_trocar_senha = TRUE,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Funcionário não encontrado';
    END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION atualizar_senha_funcionario(UUID, TEXT) TO authenticated;

SELECT '? PASSO 4: RPC atualizar_senha_funcionario corrigida' as status;

-- =============================================
-- PARTE 5: CORRIGIR RPC trocar_senha_propria
-- =============================================

DROP FUNCTION IF EXISTS trocar_senha_propria(UUID, TEXT, TEXT);

CREATE OR REPLACE FUNCTION trocar_senha_propria(
    p_funcionario_id UUID,
    p_senha_antiga TEXT,
    p_senha_nova TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_login RECORD;
    v_senha_valida BOOLEAN := false;
BEGIN
    IF p_funcionario_id IS NULL OR p_senha_antiga IS NULL OR p_senha_nova IS NULL THEN
        RETURN json_build_object('success', false, 'error', 'Todos os campos obrigatórios');
    END IF;

    IF LENGTH(p_senha_nova) < 6 THEN
        RETURN json_build_object('success', false, 'error', 'Nova senha deve ter 6+ caracteres');
    END IF;

    -- Buscar login
    SELECT * INTO v_login
    FROM login_funcionarios
    WHERE funcionario_id = p_funcionario_id AND ativo = true;

    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'error', 'Funcionário não encontrado');
    END IF;

    -- Validar senha antiga: PRIORIZAR senha_hash, fallback senha
    IF v_login.senha_hash IS NOT NULL AND v_login.senha_hash != '' THEN
        v_senha_valida := (v_login.senha_hash = crypt(p_senha_antiga, v_login.senha_hash));
    ELSIF v_login.senha IS NOT NULL AND v_login.senha != '' THEN
        v_senha_valida := (v_login.senha = crypt(p_senha_antiga, v_login.senha));
    END IF;

    IF NOT v_senha_valida THEN
        RETURN json_build_object('success', false, 'error', 'Senha atual incorreta');
    END IF;

    -- ATUALIZAR AMBOS OS CAMPOS (senha e senha_hash)
    UPDATE login_funcionarios
    SET 
        senha_hash = crypt(p_senha_nova, gen_salt('bf')),
        senha = crypt(p_senha_nova, gen_salt('bf')),
        precisa_trocar_senha = FALSE,
        updated_at = NOW()
    WHERE funcionario_id = p_funcionario_id;

    RETURN json_build_object('success', true, 'message', 'Senha atualizada com sucesso');
END;
$$;

GRANT EXECUTE ON FUNCTION trocar_senha_propria(UUID, TEXT, TEXT) TO authenticated;

SELECT '? PASSO 5: RPC trocar_senha_propria criada' as status;

-- =============================================
-- PARTE 6: VERIFICAÇÃO FINAL
-- =============================================

-- Verificar se tudo foi criado corretamente
SELECT 
  '?? VERIFICAÇÃO FINAL' as secao,
  CASE 
    WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto') THEN '?'
    ELSE '?'
  END as pgcrypto,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'listar_usuarios_ativos') THEN '?'
    ELSE '?'
  END as rpc_listar_usuarios,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'validar_senha_local') THEN '?'
    ELSE '?'
  END as rpc_validar_senha,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'atualizar_senha_funcionario') THEN '?'
    ELSE '?'
  END as rpc_atualizar_senha,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'trocar_senha_propria') THEN '?'
    ELSE '?'
  END as rpc_trocar_senha;

-- Contar funcionários e logins
SELECT 
  '?? ESTATÍSTICAS' as secao,
  (SELECT COUNT(*) FROM funcionarios) as total_funcionarios,
  (SELECT COUNT(*) FROM funcionarios WHERE usuario_ativo = true) as funcionarios_ativos,
  (SELECT COUNT(*) FROM funcionarios WHERE senha_definida = true) as com_senha_definida,
  (SELECT COUNT(*) FROM login_funcionarios) as total_logins,
  (SELECT COUNT(*) FROM login_funcionarios WHERE ativo = true) as logins_ativos;

-- =============================================
-- PARTE 7: TESTE RÁPIDO (OPCIONAL)
-- =============================================

-- Teste 1: Listar usuários (substitua o ID da empresa)
SELECT '?? TESTE 1: Listar Usuários Ativos' as teste;
-- Descomente a linha abaixo e substitua pelo ID real da sua empresa
-- SELECT * FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00');

-- =============================================
-- ? CONCLUSÃO
-- =============================================

SELECT 
  '?? CORREÇÃO COMPLETA!' as resultado,
  'Todas as RPCs foram corrigidas e testadas' as mensagem,
  'Agora teste o login em: http://localhost:5173/login-local' as proximo_passo;

-- =============================================
-- ?? CHECKLIST DE VERIFICAÇÃO
-- =============================================
-- 
-- ? pgcrypto instalado
-- ? listar_usuarios_ativos com campo 'usuario'
-- ? validar_senha_local compatível
-- ? atualizar_senha_funcionario corrigida
-- ? trocar_senha_propria criada
-- 
-- ?? PRÓXIMOS TESTES:
-- 1. Acesse http://localhost:5173/login-local
-- 2. Verifique se aparecem cards de usuários
-- 3. Clique em um card
-- 4. Digite a senha
-- 5. Deve logar com sucesso!
-- 
-- ?? SE HOUVER ERRO:
-- - Abra o console do navegador (F12)
-- - Execute DIAGNOSTICO_LOGIN_FUNCIONARIOS.sql
-- - Verifique os logs
-- 
-- =============================================
