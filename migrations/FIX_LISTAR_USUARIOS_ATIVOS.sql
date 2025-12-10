-- =============================================
-- CORRIGIR RPC listar_usuarios_ativos
-- Adicionar campo 'usuario' da tabela login_funcionarios
-- =============================================

-- 1. DROPAR FUNÇÃO ANTIGA
DROP FUNCTION IF EXISTS listar_usuarios_ativos(UUID);

-- 2. RECRIAR COM CAMPO 'usuario'
CREATE OR REPLACE FUNCTION listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  email TEXT,
  foto_perfil TEXT,
  tipo_admin TEXT,
  senha_definida BOOLEAN,
  primeiro_acesso BOOLEAN,
  usuario TEXT  -- ? NOVO CAMPO
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
    COALESCE(lf.usuario, lower(regexp_replace(f.nome, '[^a-zA-Z0-9]', '', 'g'))) as usuario  -- ? JOIN com login_funcionarios
  FROM funcionarios f
  LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id AND lf.ativo = true
  WHERE f.empresa_id = p_empresa_id
    AND (f.usuario_ativo = true OR f.usuario_ativo IS NULL)
    AND (f.status = 'ativo' OR f.status IS NULL)
    AND f.senha_definida = true
  ORDER BY f.nome;
END;
$$;

-- 3. GARANTIR PERMISSÕES
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO authenticated, anon;

-- 4. TESTAR
SELECT '? TESTE - listar_usuarios_ativos com campo usuario' as teste;

-- Teste com empresa (substitua pelo ID real)
SELECT * FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00');

-- 5. VERIFICAR RESULTADO
SELECT 
  '?? Campos retornados:' as info,
  'id, nome, email, foto_perfil, tipo_admin, senha_definida, primeiro_acesso, usuario' as campos;
