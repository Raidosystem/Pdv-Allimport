-- 🔧 CORREÇÃO DEFINITIVA - JENNIFER APARECENDO NO LOGIN

-- ====================================
-- 1. GARANTIR QUE JENNIFER TENHA OS FLAGS CORRETOS
-- ====================================
UPDATE funcionarios
SET 
  usuario_ativo = true,
  senha_definida = true,
  primeiro_acesso = false
WHERE nome = 'Jennifer Sousa'
  AND empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

SELECT 
  '✅ JENNIFER ATUALIZADA' as status,
  id,
  nome,
  usuario_ativo,
  senha_definida,
  primeiro_acesso
FROM funcionarios
WHERE nome = 'Jennifer Sousa';

-- ====================================
-- 2. VERIFICAR SE JENNIFER TEM LOGIN ATIVO
-- ====================================
UPDATE login_funcionarios
SET ativo = true
WHERE funcionario_id IN (SELECT id FROM funcionarios WHERE nome = 'Jennifer Sousa');

SELECT 
  '✅ LOGIN JENNIFER ATIVADO' as status,
  lf.id,
  lf.usuario,
  lf.ativo,
  f.nome as funcionario_nome
FROM login_funcionarios lf
JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE f.nome = 'Jennifer Sousa';

-- ====================================
-- 3. TESTAR A RPC listar_usuarios_ativos
-- ====================================
SELECT 
  '👥 RESULTADO DA RPC' as teste,
  *
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00')
ORDER BY nome;

-- ====================================
-- 4. SE AINDA NÃO APARECER, RECRIAR A RPC
-- ====================================
DROP FUNCTION IF EXISTS listar_usuarios_ativos(UUID);

CREATE OR REPLACE FUNCTION listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  email TEXT,
  foto_perfil TEXT,
  tipo_admin TEXT,
  senha_definida BOOLEAN,
  primeiro_acesso BOOLEAN
) 
LANGUAGE plpgsql
SECURITY DEFINER
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
    f.primeiro_acesso
  FROM funcionarios f
  WHERE f.empresa_id = p_empresa_id
    AND f.usuario_ativo = true
    AND f.senha_definida = true
  ORDER BY 
    CASE WHEN f.tipo_admin = 'admin_empresa' THEN 0 ELSE 1 END,
    f.nome;
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO anon;

SELECT '✅ RPC RECRIADA' as status;

-- ====================================
-- 5. TESTAR NOVAMENTE APÓS CORREÇÕES
-- ====================================
SELECT 
  '🎯 TESTE FINAL' as teste,
  id,
  nome,
  email,
  tipo_admin,
  senha_definida,
  primeiro_acesso,
  CASE 
    WHEN senha_definida THEN '✅ DEVE APARECER'
    ELSE '❌ NÃO VAI APARECER'
  END as status
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00')
ORDER BY nome;

-- ====================================
-- 6. RESUMO FINAL
-- ====================================
SELECT 
  '📊 RESUMO' as info,
  COUNT(*) as total_usuarios,
  COUNT(CASE WHEN nome LIKE '%Jennifer%' THEN 1 END) as jennifer_presente,
  COUNT(CASE WHEN nome LIKE '%Cristiano%' THEN 1 END) as cristiano_presente
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00');
