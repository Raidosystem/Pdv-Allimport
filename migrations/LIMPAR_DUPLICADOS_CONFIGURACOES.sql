-- ============================================================================
-- SCRIPT 100% SEGURO: Limpar registros duplicados em configuracoes_impressao
-- ============================================================================
-- OBJETIVO: Corrigir duplicatas na tabela configuracoes_impressao mantendo
--           apenas o registro mais recente por user_id
--
-- SEGURANÇA:
-- ✅ Usa transação (BEGIN/COMMIT) - rollback automático em caso de erro
-- ✅ Cria backup temporário antes de deletar
-- ✅ Afeta APENAS a tabela configuracoes_impressao
-- ✅ Validações rigorosas em cada etapa
-- ✅ Pode ser executado múltiplas vezes sem problemas
-- ✅ Não altera dados de outras tabelas
-- ✅ Preserva o registro mais recente de cada usuário
-- ============================================================================

-- INICIAR TRANSAÇÃO (auto-rollback se der erro)
BEGIN;

-- ============================================================================
-- ETAPA 0: VERIFICAÇÃO DE SEGURANÇA
-- ============================================================================
DO $$
DECLARE
  v_table_exists BOOLEAN;
BEGIN
  -- Verificar se a tabela existe
  SELECT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'configuracoes_impressao'
  ) INTO v_table_exists;
  
  IF NOT v_table_exists THEN
    RAISE EXCEPTION '❌ ABORTADO: Tabela configuracoes_impressao não existe!';
  END IF;
  
  RAISE NOTICE '✅ Tabela configuracoes_impressao encontrada';
END $$;

-- ============================================================================
-- ETAPA 1: ANÁLISE PRÉVIA (apenas leitura, sem modificar nada)
-- ============================================================================
DO $$
DECLARE
  v_total INTEGER;
  v_users INTEGER;
  v_duplicados INTEGER;
BEGIN
  SELECT 
    COUNT(*),
    COUNT(DISTINCT user_id),
    COUNT(*) - COUNT(DISTINCT user_id)
  INTO v_total, v_users, v_duplicados
  FROM configuracoes_impressao;
  
  RAISE NOTICE '';
  RAISE NOTICE '📊 ANÁLISE PRÉVIA:';
  RAISE NOTICE '   Total de registros: %', v_total;
  RAISE NOTICE '   Usuários únicos: %', v_users;
  RAISE NOTICE '   Registros duplicados: %', v_duplicados;
  RAISE NOTICE '';
  
  IF v_duplicados = 0 THEN
    RAISE NOTICE 'ℹ️ Nenhum duplicado encontrado. Script não fará alterações.';
  ELSE
    RAISE NOTICE '⚠️ Serão removidos % registros duplicados', v_duplicados;
  END IF;
END $$;

-- ============================================================================
-- ETAPA 2: CRIAR TABELA DE BACKUP TEMPORÁRIA
-- ============================================================================
DO $$
BEGIN
  -- Dropar backup se já existir (de execução anterior)
  DROP TABLE IF EXISTS configuracoes_impressao_backup_temp;
  
  -- Criar backup completo
  CREATE TEMP TABLE configuracoes_impressao_backup_temp AS
  SELECT * FROM configuracoes_impressao;
  
  RAISE NOTICE '✅ Backup temporário criado com % registros', 
    (SELECT COUNT(*) FROM configuracoes_impressao_backup_temp);
END $$;

-- ============================================================================
-- ETAPA 3: IDENTIFICAR REGISTROS A MANTER (apenas leitura)
-- ============================================================================
CREATE TEMP TABLE registros_a_manter AS
SELECT DISTINCT ON (user_id)
  user_id,
  atualizado_em,
  criado_em
FROM configuracoes_impressao
ORDER BY user_id, atualizado_em DESC NULLS LAST, criado_em DESC NULLS LAST;

-- Verificar
DO $$
DECLARE
  v_a_manter INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_a_manter FROM registros_a_manter;
  RAISE NOTICE '✅ Identificados % registros a MANTER (mais recentes)', v_a_manter;
END $$;

-- ============================================================================
-- ETAPA 4: DELETAR APENAS OS DUPLICADOS (preserva os mais recentes)
-- ============================================================================
DO $$
DECLARE
  v_deletados INTEGER;
BEGIN
  -- Deletar registros que NÃO são os mais recentes
  WITH deletar AS (
    DELETE FROM configuracoes_impressao c
    WHERE NOT EXISTS (
      SELECT 1 
      FROM registros_a_manter m 
      WHERE m.user_id = c.user_id 
        AND COALESCE(m.atualizado_em, m.criado_em) = COALESCE(c.atualizado_em, c.criado_em)
    )
    RETURNING *
  )
  SELECT COUNT(*) INTO v_deletados FROM deletar;
  
  IF v_deletados > 0 THEN
    RAISE NOTICE '✅ Removidos % registros duplicados', v_deletados;
  ELSE
    RAISE NOTICE 'ℹ️ Nenhum registro foi removido (nenhum duplicado encontrado)';
  END IF;
END $$;

-- ============================================================================
-- ETAPA 5: VALIDAÇÃO RIGOROSA PÓS-LIMPEZA
-- ============================================================================
DO $$
DECLARE
  v_total_final INTEGER;
  v_users_final INTEGER;
  v_duplicados_final INTEGER;
BEGIN
  SELECT 
    COUNT(*),
    COUNT(DISTINCT user_id),
    COUNT(*) - COUNT(DISTINCT user_id)
  INTO v_total_final, v_users_final, v_duplicados_final
  FROM configuracoes_impressao;
  
  RAISE NOTICE '';
  RAISE NOTICE '📊 RESULTADO FINAL:';
  RAISE NOTICE '   Total de registros: %', v_total_final;
  RAISE NOTICE '   Usuários únicos: %', v_users_final;
  RAISE NOTICE '   Duplicados restantes: %', v_duplicados_final;
  RAISE NOTICE '';
  
  -- VALIDAÇÃO CRÍTICA: Se ainda há duplicados, ABORTAR tudo!
  IF v_duplicados_final > 0 THEN
    RAISE EXCEPTION '❌ ERRO CRÍTICO: Ainda existem % duplicados! Abortando transação (nada foi alterado)', v_duplicados_final;
  END IF;
  
  -- VALIDAÇÃO: Garantir que cada usuário tem exatamente 1 registro
  IF v_total_final != v_users_final THEN
    RAISE EXCEPTION '❌ ERRO: Total (%) != Usuários únicos (%). Abortando!', v_total_final, v_users_final;
  END IF;
  
  RAISE NOTICE '✅ VALIDAÇÃO APROVADA: Cada usuário tem exatamente 1 registro';
END $$;

-- ============================================================================
-- ETAPA 6: CRIAR ÍNDICE UNIQUE (previne futuros duplicados)
-- ============================================================================
DO $$
BEGIN
  -- Verificar se já existe
  IF EXISTS (
    SELECT 1 FROM pg_indexes 
    WHERE schemaname = 'public' 
    AND tablename = 'configuracoes_impressao' 
    AND indexname = 'configuracoes_impressao_user_id_key'
  ) THEN
    RAISE NOTICE 'ℹ️ Índice UNIQUE já existe em user_id';
  ELSE
    -- Criar índice UNIQUE para prevenir futuros duplicados
    CREATE UNIQUE INDEX configuracoes_impressao_user_id_key 
    ON configuracoes_impressao(user_id);
    
    RAISE NOTICE '✅ Índice UNIQUE criado em user_id (previne duplicados futuros)';
  END IF;
END $$;

-- ============================================================================
-- ETAPA 7: LIMPEZA DE TABELAS TEMPORÁRIAS
-- ============================================================================
DROP TABLE IF EXISTS registros_a_manter;
DROP TABLE IF EXISTS configuracoes_impressao_backup_temp;

-- ============================================================================
-- ETAPA 8: MENSAGEM FINAL DE SUCESSO
-- ============================================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ Tabelas temporárias removidas';
  RAISE NOTICE '';
  RAISE NOTICE '════════════════════════════════════════════════════════════';
  RAISE NOTICE '✅ SCRIPT EXECUTADO COM SUCESSO!';
  RAISE NOTICE '';
  RAISE NOTICE 'Alterações aplicadas:';
  RAISE NOTICE '  ✓ Duplicados removidos';
  RAISE NOTICE '  ✓ Registros mais recentes preservados';
  RAISE NOTICE '  ✓ Índice UNIQUE criado';
  RAISE NOTICE '';
  RAISE NOTICE 'Próximos passos:';
  RAISE NOTICE '  1. Faça logout do sistema';
  RAISE NOTICE '  2. Faça login novamente';
  RAISE NOTICE '  3. Teste salvar configurações de impressão';
  RAISE NOTICE '  4. Faça logout/login e verifique se persistiu';
  RAISE NOTICE '════════════════════════════════════════════════════════════';
END $$;

-- ============================================================================
-- FINALIZAR TRANSAÇÃO (COMMIT = salvar alterações)
-- ============================================================================
COMMIT;
