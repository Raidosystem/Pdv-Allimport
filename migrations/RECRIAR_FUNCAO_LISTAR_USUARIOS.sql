-- 🔧 RECRIAR FUNÇÃO listar_usuarios_ativos

-- ✅ Passo 1: Remover a função antiga
DROP FUNCTION IF EXISTS listar_usuarios_ativos(UUID);

-- ✅ Passo 2: Recriar a função com as colunas corretas
CREATE OR REPLACE FUNCTION listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  email TEXT,
  foto_perfil TEXT,
  tipo_admin TEXT,
  senha_definida BOOLEAN,
  primeiro_acesso BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id,
    f.nome,
    f.email,
    f.foto_perfil,
    f.tipo_admin,
    f.senha_definida,
    f.primeiro_acesso
  FROM funcionarios f
  WHERE f.empresa_id = p_empresa_id
  AND f.usuario_ativo = TRUE
  ORDER BY 
    CASE WHEN f.tipo_admin = 'admin_empresa' THEN 0 ELSE 1 END,
    f.nome;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ✅ Passo 3: Verificar se a função foi recriada
SELECT 
  '✅ FUNÇÃO RECRIADA' as status,
  proname as nome_funcao,
  pg_get_function_identity_arguments(oid) as argumentos
FROM pg_proc
WHERE proname = 'listar_usuarios_ativos';

-- ✅ Passo 4: Testar a função agora
SELECT 
  '✅ TESTE DA FUNÇÃO' as status,
  id,
  nome,
  email,
  tipo_admin,
  senha_definida,
  primeiro_acesso
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- ✅ Passo 5: Contar resultados
SELECT 
  '✅ TOTAL' as status,
  COUNT(*) as total,
  COUNT(CASE WHEN tipo_admin = 'admin_empresa' THEN 1 END) as admins,
  COUNT(CASE WHEN tipo_admin = 'funcionario' THEN 1 END) as funcionarios
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- ✅ Passo 6: Maria Silva está incluída?
SELECT 
  '✅ MARIA SILVA APARECE?' as status,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1')
      WHERE id = '96c36a45-3cf3-4e76-b291-c3a5475e02aa'
    ) THEN '🎉 SIM! Maria Silva aparece!'
    ELSE '❌ NÃO! Ainda não aparece'
  END as resultado;
