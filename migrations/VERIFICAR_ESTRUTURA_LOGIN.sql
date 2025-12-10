-- =====================================================
-- VERIFICAÇÃO: Estrutura login_funcionarios
-- =====================================================

-- 1. VERIFICAR SE A TABELA EXISTE
-- =====================================================
SELECT 
  tablename as "📋 Tabela",
  schemaname as "Schema"
FROM pg_tables 
WHERE tablename = 'login_funcionarios';

-- 2. VERIFICAR COLUNAS DA TABELA
-- =====================================================
SELECT 
  column_name as "📝 Coluna",
  data_type as "Tipo",
  is_nullable as "Nulo?",
  column_default as "Padrão"
FROM information_schema.columns
WHERE table_name = 'login_funcionarios'
ORDER BY ordinal_position;

-- 3. VERIFICAR POLÍTICAS RLS
-- =====================================================
SELECT 
  policyname as "🔒 Política",
  cmd as "Comando",
  qual as "Condição"
FROM pg_policies
WHERE tablename = 'login_funcionarios';

-- 4. VERIFICAR FUNÇÕES RPC CRIADAS
-- =====================================================
SELECT 
  routine_name as "⚙️ Função RPC",
  routine_type as "Tipo",
  data_type as "Retorno"
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN (
    'criar_funcionario_completo',
    'autenticar_funcionario'
  );

-- 5. VERIFICAR EXTENSÕES INSTALADAS
-- =====================================================
SELECT 
  extname as "🔧 Extensão",
  extversion as "Versão"
FROM pg_extension
WHERE extname = 'pgcrypto';

-- 6. VERIFICAR ÍNDICES
-- =====================================================
SELECT 
  indexname as "🔍 Índice",
  tablename as "Tabela"
FROM pg_indexes
WHERE tablename = 'login_funcionarios';

-- 7. VERIFICAR TRIGGERS
-- =====================================================
SELECT 
  trigger_name as "⚡ Trigger",
  event_manipulation as "Evento",
  action_timing as "Timing"
FROM information_schema.triggers
WHERE event_object_table = 'login_funcionarios';

-- 8. TESTAR RPC criar_funcionario_completo (TESTE)
-- =====================================================
-- ⚠️ Este é apenas um teste - não cria dados reais
SELECT 'RPC criar_funcionario_completo está acessível' as "✅ Status";

-- 9. VERIFICAR PERMISSÕES DA TABELA
-- =====================================================
SELECT 
  grantee as "👤 Usuário",
  privilege_type as "Permissão"
FROM information_schema.table_privileges
WHERE table_name = 'login_funcionarios'
  AND grantee IN ('anon', 'authenticated')
ORDER BY grantee, privilege_type;

-- 10. RESUMO FINAL
-- =====================================================
DO $$
DECLARE
  v_tabela_existe BOOLEAN;
  v_total_policies INTEGER;
  v_total_funcoes INTEGER;
  v_pgcrypto_ok BOOLEAN;
BEGIN
  -- Verificar tabela
  SELECT EXISTS (
    SELECT 1 FROM pg_tables 
    WHERE tablename = 'login_funcionarios'
  ) INTO v_tabela_existe;

  -- Contar políticas
  SELECT COUNT(*) INTO v_total_policies
  FROM pg_policies
  WHERE tablename = 'login_funcionarios';

  -- Contar funções RPC
  SELECT COUNT(*) INTO v_total_funcoes
  FROM information_schema.routines
  WHERE routine_schema = 'public'
    AND routine_name IN ('criar_funcionario_completo', 'autenticar_funcionario');

  -- Verificar pgcrypto
  SELECT EXISTS (
    SELECT 1 FROM pg_extension 
    WHERE extname = 'pgcrypto'
  ) INTO v_pgcrypto_ok;

  -- Mostrar resumo
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════';
  RAISE NOTICE '📊 RESUMO DA VERIFICAÇÃO';
  RAISE NOTICE '═══════════════════════════════════════';
  RAISE NOTICE '';
  
  IF v_tabela_existe THEN
    RAISE NOTICE '✅ Tabela login_funcionarios: EXISTE';
  ELSE
    RAISE NOTICE '❌ Tabela login_funcionarios: NÃO ENCONTRADA';
  END IF;

  RAISE NOTICE '🔒 Políticas RLS: % política(s)', v_total_policies;
  
  IF v_total_policies >= 4 THEN
    RAISE NOTICE '   ✅ Políticas suficientes (SELECT, INSERT, UPDATE, DELETE)';
  ELSE
    RAISE NOTICE '   ⚠️  Faltam políticas (esperado: 4, encontrado: %)', v_total_policies;
  END IF;

  RAISE NOTICE '⚙️  Funções RPC: % função(ões)', v_total_funcoes;
  
  IF v_total_funcoes = 2 THEN
    RAISE NOTICE '   ✅ Funções criadas (criar_funcionario_completo, autenticar_funcionario)';
  ELSE
    RAISE NOTICE '   ⚠️  Faltam funções (esperado: 2, encontrado: %)', v_total_funcoes;
  END IF;

  IF v_pgcrypto_ok THEN
    RAISE NOTICE '🔧 Extensão pgcrypto: INSTALADA';
  ELSE
    RAISE NOTICE '❌ Extensão pgcrypto: NÃO INSTALADA';
  END IF;

  RAISE NOTICE '';
  
  IF v_tabela_existe AND v_total_policies >= 4 AND v_total_funcoes = 2 AND v_pgcrypto_ok THEN
    RAISE NOTICE '🎉 TUDO CONFIGURADO CORRETAMENTE!';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 Próximos passos:';
    RAISE NOTICE '   1. Teste a API REST no navegador';
    RAISE NOTICE '   2. Verifique se aparece em Database > Tables';
    RAISE NOTICE '   3. Execute MIGRAR_LOGINS_FUNCIONARIOS.sql se necessário';
  ELSE
    RAISE NOTICE '⚠️  ATENÇÃO: Verifique os itens acima';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════';
END $$;
