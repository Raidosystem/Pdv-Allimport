-- 🛡️ SCRIPT DE VERIFICAÇÃO DE SISTEMA
-- Execute ANTES de qualquer script crítico para garantir que o sistema está funcionando

-- ====================================
-- 1. VERIFICAR FUNÇÕES CRÍTICAS DE LOGIN
-- ====================================
SELECT 
  '🔍 VERIFICAÇÃO DE FUNÇÕES CRÍTICAS' as titulo,
  CASE 
    WHEN EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'listar_usuarios_ativos') 
    THEN '✅ listar_usuarios_ativos EXISTE'
    ELSE '❌ listar_usuarios_ativos AUSENTE - SISTEMA QUEBRADO!'
  END as funcao_login,
  CASE 
    WHEN EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'validar_senha_local') 
    THEN '✅ validar_senha_local EXISTE'
    ELSE '❌ validar_senha_local AUSENTE - SISTEMA QUEBRADO!'
  END as funcao_validacao;

-- ====================================
-- 2. VERIFICAR ESTRUTURA DE TABELAS CRÍTICAS
-- ====================================
SELECT 
  '📋 VERIFICAÇÃO DE TABELAS' as titulo,
  CASE 
    WHEN EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'funcionarios') 
    THEN '✅ Tabela funcionarios EXISTE'
    ELSE '❌ Tabela funcionarios AUSENTE!'
  END as tab_funcionarios,
  CASE 
    WHEN EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'empresas') 
    THEN '✅ Tabela empresas EXISTE'
    ELSE '❌ Tabela empresas AUSENTE!'
  END as tab_empresas,
  CASE 
    WHEN EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'login_funcionarios') 
    THEN '✅ Tabela login_funcionarios EXISTE'
    ELSE '❌ Tabela login_funcionarios AUSENTE!'
  END as tab_login;

-- ====================================
-- 3. VERIFICAR COLUNAS ESSENCIAIS
-- ====================================
SELECT 
  '🔧 VERIFICAÇÃO DE COLUNAS FUNCIONÁRIOS' as titulo,
  CASE 
    WHEN EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'funcionarios' AND column_name = 'usuario_ativo') 
    THEN '✅ usuario_ativo EXISTE'
    ELSE '❌ usuario_ativo AUSENTE!'
  END as col_usuario_ativo,
  CASE 
    WHEN EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'funcionarios' AND column_name = 'senha_definida') 
    THEN '✅ senha_definida EXISTE'
    ELSE '❌ senha_definida AUSENTE!'
  END as col_senha_definida,
  CASE 
    WHEN EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'funcionarios' AND column_name = 'tipo_admin') 
    THEN '✅ tipo_admin EXISTE'
    ELSE '❌ tipo_admin AUSENTE!'
  END as col_tipo_admin;

-- ====================================
-- 4. CONTAR DADOS CRÍTICOS
-- ====================================
SELECT 
  '📊 CONTAGEM DE DADOS' as titulo,
  (SELECT COUNT(*) FROM funcionarios) as total_funcionarios,
  (SELECT COUNT(*) FROM funcionarios WHERE usuario_ativo = true) as funcionarios_ativos,
  (SELECT COUNT(*) FROM funcionarios WHERE senha_definida = true) as funcionarios_com_senha,
  (SELECT COUNT(*) FROM empresas) as total_empresas;

-- ====================================
-- 5. FUNCIONÁRIOS POR TIPO (DEVEM EXISTIR)
-- ====================================
SELECT 
  '👥 FUNCIONÁRIOS POR TIPO' as titulo,
  tipo_admin,
  COUNT(*) as quantidade,
  COUNT(CASE WHEN usuario_ativo = true AND senha_definida = true THEN 1 END) as funcionais
FROM funcionarios
GROUP BY tipo_admin
ORDER BY tipo_admin;

-- ====================================
-- 6. TESTE RÁPIDO DE FUNÇÃO (SE EXISTIR EMPRESA)
-- ====================================
DO $$
DECLARE
  v_empresa_id UUID;
  v_count INTEGER;
BEGIN
  -- Pegar primeira empresa para teste
  SELECT id INTO v_empresa_id FROM empresas LIMIT 1;
  
  IF v_empresa_id IS NOT NULL THEN
    -- Testar função listar_usuarios_ativos
    SELECT COUNT(*) INTO v_count FROM listar_usuarios_ativos(v_empresa_id);
    RAISE NOTICE '🧪 TESTE DA FUNÇÃO: listar_usuarios_ativos retornou % usuários para empresa %', v_count, v_empresa_id;
  ELSE
    RAISE NOTICE '⚠️ Nenhuma empresa encontrada para teste';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERRO NO TESTE DA FUNÇÃO: %', SQLERRM;
END $$;

-- ====================================
-- 7. RESULTADO FINAL DA VERIFICAÇÃO
-- ====================================
SELECT 
  '🎯 RESULTADO FINAL' as titulo,
  CASE 
    WHEN EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'listar_usuarios_ativos')
         AND EXISTS (SELECT FROM information_schema.routines WHERE routine_name = 'validar_senha_local')
         AND EXISTS (SELECT FROM funcionarios WHERE usuario_ativo = true AND senha_definida = true)
    THEN '✅ SISTEMA FUNCIONANDO - SEGURO PARA EXECUTAR OUTROS SCRIPTS'
    ELSE '❌ SISTEMA COM PROBLEMAS - NÃO EXECUTE OUTROS SCRIPTS!'
  END as status_sistema;

-- ====================================
-- 8. INSTRUÇÕES
-- ====================================
SELECT 
  '📝 INSTRUÇÕES' as titulo,
  'Se aparecer ❌ em qualquer verificação acima, execute CORRECAO_RAPIDA_LOGIN.sql antes de continuar!' as instrucao;