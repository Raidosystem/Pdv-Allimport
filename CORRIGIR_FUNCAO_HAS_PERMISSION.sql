-- ============================================
-- CORRIGIR FUNÇÃO has_permission
-- Remove referências a empresa_id que não existem nas tabelas
-- ============================================

-- Recriar função has_permission sem usar fp.empresa_id e ff.empresa_id
CREATE OR REPLACE FUNCTION public.has_permission(p_recurso text, p_acao text)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  WITH user_context AS (
    SELECT 
      public.jwt_user_id() AS user_id,
      public.jwt_empresa_id() AS empresa_id
  ),
  funcionario_info AS (
    SELECT f.id AS funcionario_id, f.status, f.empresa_id
    FROM public.funcionarios f
    JOIN user_context uc ON uc.user_id = f.user_id
    WHERE f.empresa_id = (SELECT empresa_id FROM user_context)
      AND f.status = 'ativo'
  ),
  user_roles AS (
    SELECT ff.funcao_id, func.empresa_id
    FROM public.funcionario_funcoes ff
    JOIN funcionario_info fi ON fi.funcionario_id = ff.funcionario_id
    JOIN public.funcoes func ON func.id = ff.funcao_id
    WHERE func.empresa_id = (SELECT empresa_id FROM user_context)
  )
  SELECT EXISTS (
    SELECT 1
    FROM public.funcao_permissoes fp
    JOIN public.permissoes p ON p.id = fp.permissao_id
    JOIN user_roles ur ON ur.funcao_id = fp.funcao_id
    JOIN public.funcoes f ON f.id = fp.funcao_id
    WHERE f.empresa_id = (SELECT empresa_id FROM user_context)
      AND p.recurso = p_recurso
      AND p.acao = p_acao
  );
$$;

-- Verificar se a função foi criada
SELECT 
  proname as function_name,
  'Função corrigida com sucesso!' as status
FROM pg_proc
WHERE proname = 'has_permission'
  AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

DO $$
BEGIN
  RAISE NOTICE '✅ Função has_permission corrigida!';
  RAISE NOTICE '📝 Agora execute CRIAR_FUNCOES_PERMISSOES_DIRETO.sql';
END $$;
