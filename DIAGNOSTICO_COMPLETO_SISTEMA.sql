-- 🔍 DIAGNÓSTICO COMPLETO - QUAIS FUNÇÕES E PERMISSÕES SUMIRAM?

-- ====================================
-- 1. VERIFICAR TODAS AS FUNÇÕES ESPERADAS
-- ====================================
WITH funcoes_esperadas AS (
  SELECT unnest(ARRAY[
    'listar_usuarios_ativos',
    'validar_senha_local',
    'generate_verification_code', 
    'verify_whatsapp_code',
    'get_empresa_config',
    'update_empresa_config',
    'create_backup',
    'restore_backup',
    'send_whatsapp_message',
    'get_vendas_relatorio',
    'get_produtos_relatorio'
  ]) AS funcao_nome
)
SELECT 
  '🔍 VERIFICAÇÃO DE FUNÇÕES' as categoria,
  fe.funcao_nome,
  CASE 
    WHEN r.routine_name IS NOT NULL THEN '✅ EXISTE'
    ELSE '❌ AUSENTE'
  END as status
FROM funcoes_esperadas fe
LEFT JOIN information_schema.routines r 
  ON r.routine_name = fe.funcao_nome 
  AND r.routine_schema = 'public'
ORDER BY fe.funcao_nome;

-- ====================================
-- 2. VERIFICAR TABELAS CRÍTICAS
-- ====================================
WITH tabelas_criticas AS (
  SELECT unnest(ARRAY[
    'funcionarios',
    'empresas',
    'login_funcionarios',
    'produtos',
    'clientes',
    'vendas',
    'codigos_verificacao'
  ]) AS tabela_nome
)
SELECT 
  '📋 VERIFICAÇÃO DE TABELAS' as categoria,
  tc.tabela_nome,
  CASE 
    WHEN t.table_name IS NOT NULL THEN '✅ EXISTE'
    ELSE '❌ AUSENTE'
  END as status
FROM tabelas_criticas tc
LEFT JOIN information_schema.tables t 
  ON t.table_name = tc.tabela_nome 
  AND t.table_schema = 'public'
ORDER BY tc.tabela_nome;

-- ====================================
-- 3. VERIFICAR POLÍTICAS RLS
-- ====================================
SELECT 
  '🔒 POLÍTICAS RLS' as categoria,
  schemaname,
  tablename,
  policyname,
  CASE 
    WHEN permissive = 'PERMISSIVE' THEN '✅ PERMISSIVA'
    ELSE '⚠️ RESTRITIVA'
  END as tipo
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN ('funcionarios', 'empresas', 'login_funcionarios', 'produtos', 'clientes', 'vendas')
ORDER BY tablename, policyname;

-- ====================================
-- 4. VERIFICAR PERMISSÕES DE USUÁRIOS
-- ====================================
SELECT 
  '👤 PERMISSÕES DE USUÁRIOS' as categoria,
  grantee,
  privilege_type,
  is_grantable
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name IN ('funcionarios', 'empresas')
  AND grantee IN ('authenticated', 'anon')
ORDER BY table_name, grantee;

-- ====================================
-- 5. STATUS DOS FUNCIONÁRIOS
-- ====================================
SELECT 
  '👥 STATUS FUNCIONÁRIOS' as categoria,
  COUNT(*) as total,
  COUNT(CASE WHEN usuario_ativo = true THEN 1 END) as usuario_ativo_true,
  COUNT(CASE WHEN usuario_ativo IS NULL THEN 1 END) as usuario_ativo_null,
  COUNT(CASE WHEN senha_definida = true THEN 1 END) as senha_definida_true,
  COUNT(CASE WHEN senha_definida IS NULL THEN 1 END) as senha_definida_null,
  COUNT(CASE WHEN status = 'ativo' THEN 1 END) as status_ativo,
  COUNT(CASE WHEN status IS NULL THEN 1 END) as status_null
FROM funcionarios;

-- ====================================
-- 6. FUNCIONÁRIOS POR TIPO E STATUS
-- ====================================
SELECT 
  '📊 FUNCIONÁRIOS DETALHADO' as categoria,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  status,
  COUNT(*) as quantidade
FROM funcionarios
GROUP BY tipo_admin, usuario_ativo, senha_definida, status
ORDER BY tipo_admin, usuario_ativo, senha_definida, status;

-- ====================================
-- 7. VERIFICAR COLUNAS ESSENCIAIS
-- ====================================
SELECT 
  '🔧 COLUNAS FUNCIONÁRIOS' as categoria,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcionarios'
  AND column_name IN ('usuario_ativo', 'senha_definida', 'status', 'tipo_admin', 'primeiro_acesso')
ORDER BY column_name;

-- ====================================
-- 8. RESUMO GERAL DO SISTEMA
-- ====================================
SELECT 
  '🎯 RESUMO GERAL' as categoria,
  (SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public') as total_funcoes,
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public') as total_tabelas,
  (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'public') as total_politicas,
  (SELECT COUNT(*) FROM funcionarios WHERE usuario_ativo = true AND senha_definida = true) as funcionarios_funcionais;

-- ====================================
-- 9. DIAGNÓSTICO FINAL
-- ====================================
SELECT 
  '💡 DIAGNÓSTICO' as categoria,
  CASE 
    WHEN NOT EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'listar_usuarios_ativos')
    THEN '❌ FUNÇÃO DE LOGIN AUSENTE - Execute RESTAURAR_TUDO_COMPLETO.sql'
    WHEN NOT EXISTS (SELECT FROM funcionarios WHERE usuario_ativo = true AND senha_definida = true)
    THEN '❌ NENHUM FUNCIONÁRIO ATIVO - Execute RESTAURAR_TUDO_COMPLETO.sql'
    ELSE '✅ SISTEMA PARECE OK - Teste o login'
  END as recomendacao;