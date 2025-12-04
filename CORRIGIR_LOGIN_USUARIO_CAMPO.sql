-- =====================================================
-- CORREÇÃO: Adicionar campo 'usuario' em listar_usuarios_ativos
-- =====================================================
-- 
-- PROBLEMA IDENTIFICADO:
-- - A função listar_usuarios_ativos() retorna campos da tabela funcionarios
-- - MAS não retorna o campo 'usuario' da tabela login_funcionarios
-- - O frontend precisa do campo 'usuario' para chamar validar_senha_local()
-- 
-- SOLUÇÃO:
-- - Recriar listar_usuarios_ativos() com JOIN em login_funcionarios
-- - Incluir campo 'usuario' no retorno
-- =====================================================

-- 1. RECRIAR FUNÇÃO listar_usuarios_ativos (COM CAMPO 'usuario')
-- =====================================================

DROP FUNCTION IF EXISTS public.listar_usuarios_ativos(UUID) CASCADE;

CREATE OR REPLACE FUNCTION public.listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  email TEXT,
  foto_perfil TEXT,
  tipo_admin TEXT,
  senha_definida BOOLEAN,
  primeiro_acesso BOOLEAN,
  usuario TEXT  -- ⭐ NOVO CAMPO para login
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id,
    f.nome,
    f.email,
    f.foto_perfil,
    f.tipo_admin,
    f.senha_definida,
    f.primeiro_acesso,
    COALESCE(lf.usuario, f.email) as usuario  -- ⭐ Campo usuario da tabela login_funcionarios (ou email como fallback)
  FROM public.funcionarios f
  LEFT JOIN public.login_funcionarios lf ON lf.funcionario_id = f.id AND lf.ativo = true
  WHERE f.empresa_id = p_empresa_id
    AND f.usuario_ativo = true
    AND f.senha_definida = true
  ORDER BY 
    CASE WHEN f.tipo_admin = 'admin_empresa' THEN 0 ELSE 1 END,
    f.nome;
END;
$$;

-- 2. GARANTIR PERMISSÕES
-- =====================================================
GRANT EXECUTE ON FUNCTION public.listar_usuarios_ativos(UUID) TO anon, authenticated;

-- 3. VERIFICAR RESULTADO
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ CORREÇÃO APLICADA COM SUCESSO!';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Mudanças aplicadas:';
  RAISE NOTICE '   • listar_usuarios_ativos() agora retorna campo "usuario"';
  RAISE NOTICE '   • Campo "usuario" vem da tabela login_funcionarios';
  RAISE NOTICE '   • Fallback para email caso login_funcionarios não exista';
  RAISE NOTICE '';
  RAISE NOTICE '🔧 Próximos passos:';
  RAISE NOTICE '   1. Atualizar TypeScript para usar "usuario" ao invés de "id"';
  RAISE NOTICE '   2. Chamar validar_senha_local(p_usuario, p_senha)';
  RAISE NOTICE '';
  RAISE NOTICE '📝 Exemplo de uso no frontend:';
  RAISE NOTICE '   const { data } = await supabase.rpc("validar_senha_local", {';
  RAISE NOTICE '     p_usuario: usuarioSelecionado.usuario,  // ⭐ NÃO mais p_funcionario_id';
  RAISE NOTICE '     p_senha: senha';
  RAISE NOTICE '   })';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
END;
$$;
