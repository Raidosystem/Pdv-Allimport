-- 🔍 VERIFICAÇÃO RÁPIDA: FUNÇÕES E PERMISSÕES PERDIDAS

-- ====================================
-- 1. VERIFICAR FUNÇÕES RPC ESSENCIAIS
-- ====================================
SELECT 
  '🔍 FUNÇÕES RPC EXISTENTES' as info,
  routine_name,
  routine_type,
  security_type
FROM information_schema.routines
WHERE routine_name IN (
  'listar_usuarios_ativos',
  'validar_senha_local',
  'generate_verification_code',
  'verify_whatsapp_code'
)
ORDER BY routine_name;

-- ====================================
-- 2. VERIFICAR ESTRUTURA DA TABELA FUNCIONÁRIOS
-- ====================================
SELECT 
  '📋 COLUNAS FUNCIONÁRIOS' as info,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'funcionarios'
  AND column_name IN ('usuario_ativo', 'senha_definida', 'status', 'tipo_admin')
ORDER BY column_name;

-- ====================================
-- 3. VERIFICAR FUNCIONÁRIOS ATIVOS
-- ====================================
SELECT 
  '👥 STATUS FUNCIONÁRIOS' as info,
  COUNT(*) as total,
  COUNT(CASE WHEN usuario_ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN senha_definida = true THEN 1 END) as com_senha,
  COUNT(CASE WHEN status = 'ativo' THEN 1 END) as status_ativo
FROM funcionarios;

-- ====================================
-- 4. FUNCIONÁRIOS POR TIPO
-- ====================================
SELECT 
  '📊 POR TIPO ADMIN' as info,
  tipo_admin,
  COUNT(*) as quantidade,
  COUNT(CASE WHEN usuario_ativo = true AND senha_definida = true THEN 1 END) as funcionais
FROM funcionarios
GROUP BY tipo_admin
ORDER BY tipo_admin;

-- ====================================
-- 5. VERIFICAR POLÍTICAS RLS
-- ====================================
SELECT 
  '🔒 POLÍTICAS RLS' as info,
  schemaname,
  tablename,
  policyname,
  permissive
FROM pg_policies
WHERE tablename IN ('funcionarios', 'login_funcionarios')
ORDER BY tablename, policyname;

-- ====================================
-- 6. VERIFICAR TABELA LOGIN_FUNCIONARIOS
-- ====================================
SELECT 
  '🔑 LOGIN FUNCIONÁRIOS' as info,
  COUNT(*) as total_logins,
  COUNT(CASE WHEN ativo = true THEN 1 END) as logins_ativos
FROM login_funcionarios;

-- ====================================
-- CONCLUSÃO: O QUE PRECISA SER RECRIADO
-- ====================================
SELECT 
  '💡 DIAGNÓSTICO FINAL' as info,
  'Se não apareceram funções RPC, elas foram removidas e precisam ser recriadas' as conclusao;