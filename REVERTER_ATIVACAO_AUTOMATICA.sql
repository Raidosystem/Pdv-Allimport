-- ==============================================================================
-- REVERTER ATIVAÇÃO AUTOMÁTICA DE FUNCIONÁRIOS
-- ==============================================================================
-- Este script reverte as ativações feitas pelo script anterior e restaura
-- o fluxo original onde o dono do sistema escolhe o admin manualmente
-- ==============================================================================

-- ====================================
-- PARTE 1: DESATIVAR FUNCIONÁRIOS ATIVADOS AUTOMATICAMENTE
-- ====================================

-- 1.1: Verificar funcionários ativos ANTES da reversão
SELECT 
  '📊 ANTES DA REVERSÃO' as status,
  COUNT(*) as total_funcionarios,
  COUNT(CASE WHEN usuario_ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN senha_definida = true THEN 1 END) as com_senha,
  COUNT(CASE WHEN status = 'ativo' THEN 1 END) as status_ativo
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 1.2: Listar funcionários que serão desativados
SELECT 
  '🔍 FUNCIONÁRIOS QUE SERÃO DESATIVADOS:' as info,
  id,
  nome,
  email,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  status,
  created_at
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND usuario_ativo = true
ORDER BY created_at;

-- 1.3: DESATIVAR todos os funcionários ativados automaticamente
-- Isso força o fluxo de ativação manual pelo dono do sistema
UPDATE funcionarios
SET 
  usuario_ativo = false,
  status = 'pendente',
  primeiro_acesso = true
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- ====================================
-- PARTE 2: REMOVER USUÁRIO FANTASMA (SE EXISTIR)
-- ====================================

-- 2.1: Verificar se existe funcionário com mesmo email do dono
SELECT 
  '🔍 VERIFICANDO USUÁRIO FANTASMA:' as info,
  id,
  nome,
  email,
  empresa_id,
  created_at
FROM funcionarios
WHERE email = 'assistenciaallimport10@gmail.com'
   OR (empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' 
       AND id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- 2.2: Remover funcionário fantasma (se existir)
DELETE FROM funcionarios
WHERE email = 'assistenciaallimport10@gmail.com'
   OR (empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' 
       AND id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- ====================================
-- PARTE 3: RESTAURAR FLUXO ORIGINAL
-- ====================================

-- 3.1: Garantir que RPC listar_usuarios_ativos existe mas retorna vazio
-- (até que o dono ative manualmente o primeiro admin)
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
  -- Retornar apenas funcionários EXPLICITAMENTE ativados pelo admin
  RETURN QUERY
  SELECT 
    f.id,
    f.nome,
    COALESCE(f.email, '') as email,
    f.foto_perfil,
    f.tipo_admin,
    COALESCE(f.senha_definida, false) as senha_definida,
    COALESCE(f.primeiro_acesso, true) as primeiro_acesso
  FROM funcionarios f
  WHERE f.empresa_id = p_empresa_id
    AND f.usuario_ativo = true  -- Deve estar explicitamente ativo
    AND f.status = 'ativo'       -- Status deve ser ativo
    AND f.senha_definida = true  -- Deve ter senha configurada
  ORDER BY f.nome;
END;
$$;

-- 3.2: Garantir permissões
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO anon;

-- ====================================
-- PARTE 4: VERIFICAÇÃO FINAL
-- ====================================

-- 4.1: Verificar funcionários DEPOIS da reversão
SELECT 
  '✅ DEPOIS DA REVERSÃO' as status,
  COUNT(*) as total_funcionarios,
  COUNT(CASE WHEN usuario_ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN senha_definida = true THEN 1 END) as com_senha,
  COUNT(CASE WHEN status = 'ativo' THEN 1 END) as status_ativo,
  COUNT(CASE WHEN status = 'pendente' THEN 1 END) as status_pendente
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- 4.2: Listar todos os funcionários e seus status
SELECT 
  '📋 LISTA FINAL DE FUNCIONÁRIOS:' as info,
  nome,
  email,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  status,
  primeiro_acesso,
  created_at
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY created_at;

-- 4.3: Testar RPC (deve retornar vazio ou apenas funcionários já ativos)
SELECT 
  '🧪 TESTE RPC (deve estar vazio ou com poucos usuários)' as tipo,
  COUNT(*) as total_usuarios_ativos
FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- 4.4: Verificar se usuário fantasma foi removido
SELECT 
  '🗑️ VERIFICAR REMOÇÃO DO USUÁRIO FANTASMA:' as info,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ Removido com sucesso'
    ELSE '⚠️ Ainda existe'
  END as resultado
FROM funcionarios
WHERE email = 'assistenciaallimport10@gmail.com'
   OR (empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' 
       AND id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- ====================================
-- RESULTADO
-- ====================================
SELECT 
  '🎉 REVERSÃO CONCLUÍDA' as status,
  'Fluxo de ativação manual restaurado!' as mensagem,
  'Agora o dono do sistema deve escolher o admin manualmente' as proxima_acao;

-- ====================================
-- INSTRUÇÕES PARA O DONO DO SISTEMA
-- ====================================
/*
📝 PRÓXIMOS PASSOS:

1. Execute este script no Supabase SQL Editor
2. Faça login no sistema com: assistenciaallimport10@gmail.com
3. O sistema detectará que não há funcionários ativos
4. Você verá a tela para ESCOLHER qual funcionário será o ADMIN
5. Escolha o funcionário desejado e defina a senha
6. Depois o admin poderá ativar outros funcionários

✅ FLUXO ORIGINAL RESTAURADO!
*/
