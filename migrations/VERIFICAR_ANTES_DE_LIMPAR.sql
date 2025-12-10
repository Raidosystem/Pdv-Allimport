-- ============================================
-- VERIFICAÇÃO PRÉVIA: O QUE SERÁ DELETADO?
-- Execute ESTE script PRIMEIRO para ver o que será removido
-- ============================================

-- ============================================
-- 📊 RESUMO EXECUTIVO
-- ============================================

SELECT 
  '📊 RESUMO DO QUE SERÁ DELETADO' as titulo;

SELECT 
  (SELECT COUNT(*) FROM auth.users WHERE deleted_at IS NOT NULL) as "1️⃣ Users deletados (auth)",
  (SELECT COUNT(*) FROM empresas e LEFT JOIN auth.users u ON u.id = e.user_id WHERE u.id IS NULL) as "2️⃣ Empresas órfãs",
  (SELECT COUNT(*) FROM empresas e JOIN auth.users u ON u.id = e.user_id WHERE u.deleted_at IS NULL) as "✅ Empresas ATIVAS (preservadas)";

-- ============================================
-- ❌ LISTA COMPLETA DO QUE SERÁ DELETADO
-- ============================================

-- 1️⃣ Usuários deletados no auth.users
SELECT 
  '1️⃣ USUÁRIOS DELETADOS NO AUTH.USERS' as categoria,
  id,
  email,
  created_at,
  deleted_at,
  '❌ Será removido' as acao
FROM auth.users 
WHERE deleted_at IS NOT NULL
ORDER BY email;

-- 2️⃣ Empresas órfãs (sem usuário no auth.users)
SELECT 
  '2️⃣ EMPRESAS ÓRFÃS (sem auth.users)' as categoria,
  e.user_id,
  e.email,
  e.nome,
  e.cnpj,
  e.tipo_conta,
  e.created_at,
  '❌ Será removida' as acao
FROM empresas e
LEFT JOIN auth.users u ON u.id = e.user_id
WHERE u.id IS NULL
ORDER BY e.email;

-- ============================================
-- ✅ O QUE SERÁ PRESERVADO (USUÁRIOS ATIVOS)
-- ============================================

SELECT 
  '✅ EMPRESAS ATIVAS (PRESERVADAS)' as categoria,
  u.email,
  e.nome,
  e.cnpj,
  e.tipo_conta,
  e.created_at,
  '✅ Mantido intacto' as acao
FROM empresas e
JOIN auth.users u ON u.id = e.user_id
WHERE u.deleted_at IS NULL
ORDER BY u.email;

-- ============================================
-- 📊 DADOS RELACIONADOS QUE SERÃO DELETADOS
-- ============================================

-- Lista de user_ids que serão deletados
SELECT 
  'User IDs que serão deletados:' as info,
  COUNT(*) as total
FROM (
  SELECT DISTINCT e.user_id
  FROM empresas e
  LEFT JOIN auth.users u ON u.id = e.user_id
  WHERE u.id IS NULL  -- Órfãos
     OR u.deleted_at IS NOT NULL  -- Deletados no auth
) as deletados;

-- ============================================
-- ⚠️ CONFIRMAÇÃO FINAL
-- ============================================

SELECT 
  '⚠️ ATENÇÃO!' as alerta,
  'Revise a lista acima antes de executar o script de limpeza' as mensagem,
  'Todos os dados relacionados serão PERMANENTEMENTE deletados' as aviso;

SELECT 
  '✅ SE ESTIVER TUDO OK' as proximo_passo,
  'Execute o script: LIMPAR_DELETADOS_MANTER_ATIVOS.sql' as acao;
