-- 🔍 DIAGNÓSTICO COMPLETO DE TRIGGERS E FUNÇÕES ATIVAS
-- Este script verifica o que está ativo no banco de dados

DO $$
DECLARE
  v_trigger RECORD;
  v_function RECORD;
  v_count integer;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '╔══════════════════════════════════════════════════════════════╗';
  RAISE NOTICE '║  🔍 DIAGNÓSTICO COMPLETO DO BANCO DE DADOS                   ║';
  RAISE NOTICE '╚══════════════════════════════════════════════════════════════╝';
  RAISE NOTICE '';

  -- ========================================
  -- 1. VERIFICAR FUNÇÃO criar_backup_automatico_diario
  -- ========================================
  RAISE NOTICE '📦 [1] VERIFICANDO FUNÇÃO criar_backup_automatico_diario';
  RAISE NOTICE '────────────────────────────────────────────────────────────────';
  
  SELECT COUNT(*) INTO v_count
  FROM pg_proc p
  JOIN pg_namespace n ON p.pronamespace = n.oid
  WHERE p.proname = 'criar_backup_automatico_diario'
    AND n.nspname = 'public';
  
  IF v_count > 0 THEN
    RAISE NOTICE '❌ PROBLEMA: Função criar_backup_automatico_diario EXISTE no banco!';
    RAISE NOTICE '   ⚠️  Esta função deveria ter sido removida';
    
    FOR v_function IN
      SELECT 
        p.proname as funcao,
        pg_get_functiondef(p.oid) as definicao
      FROM pg_proc p
      JOIN pg_namespace n ON p.pronamespace = n.oid
      WHERE p.proname = 'criar_backup_automatico_diario'
        AND n.nspname = 'public'
    LOOP
      RAISE NOTICE '   📝 Definição:';
      RAISE NOTICE '%', v_function.definicao;
    END LOOP;
  ELSE
    RAISE NOTICE '✅ OK: Função criar_backup_automatico_diario NÃO existe';
  END IF;
  
  RAISE NOTICE '';

  -- ========================================
  -- 2. VERIFICAR TRIGGERS ÓRFÃOS
  -- ========================================
  RAISE NOTICE '🎯 [2] VERIFICANDO TRIGGERS QUE CHAMAM criar_backup_automatico_diario';
  RAISE NOTICE '────────────────────────────────────────────────────────────────';
  
  SELECT COUNT(*) INTO v_count
  FROM pg_trigger t
  JOIN pg_class c ON t.tgrelid = c.oid
  JOIN pg_proc p ON t.tgfoid = p.oid
  WHERE p.proname = 'criar_backup_automatico_diario';
  
  IF v_count > 0 THEN
    RAISE NOTICE '❌ PROBLEMA: Existem % triggers órfãos chamando a função!', v_count;
    
    FOR v_trigger IN
      SELECT 
        c.relname as tabela,
        t.tgname as trigger_nome,
        p.proname as funcao
      FROM pg_trigger t
      JOIN pg_class c ON t.tgrelid = c.oid
      JOIN pg_proc p ON t.tgfoid = p.oid
      WHERE p.proname = 'criar_backup_automatico_diario'
    LOOP
      RAISE NOTICE '   🔴 Trigger: % | Tabela: % | Função: %', 
        v_trigger.trigger_nome, v_trigger.tabela, v_trigger.funcao;
    END LOOP;
  ELSE
    RAISE NOTICE '✅ OK: Nenhum trigger órfão encontrado';
  END IF;
  
  RAISE NOTICE '';

  -- ========================================
  -- 3. VERIFICAR TRIGGERS COM NOME ESPECÍFICO
  -- ========================================
  RAISE NOTICE '🎯 [3] VERIFICANDO TRIGGERS COM NOME "trigger_criar_backup_automatico_diario"';
  RAISE NOTICE '────────────────────────────────────────────────────────────────';
  
  SELECT COUNT(*) INTO v_count
  FROM pg_trigger t
  JOIN pg_class c ON t.tgrelid = c.oid
  WHERE t.tgname = 'trigger_criar_backup_automatico_diario';
  
  IF v_count > 0 THEN
    RAISE NOTICE '❌ PROBLEMA: Existem % triggers com este nome!', v_count;
    
    FOR v_trigger IN
      SELECT 
        c.relname as tabela,
        t.tgname as trigger_nome,
        pg_get_triggerdef(t.oid) as definicao
      FROM pg_trigger t
      JOIN pg_class c ON t.tgrelid = c.oid
      WHERE t.tgname = 'trigger_criar_backup_automatico_diario'
    LOOP
      RAISE NOTICE '   🔴 Tabela: %', v_trigger.tabela;
      RAISE NOTICE '   📝 Definição: %', v_trigger.definicao;
      RAISE NOTICE '';
    END LOOP;
  ELSE
    RAISE NOTICE '✅ OK: Nenhum trigger com este nome encontrado';
  END IF;
  
  RAISE NOTICE '';

  -- ========================================
  -- 4. VERIFICAR TODOS OS TRIGGERS NA TABELA CLIENTES
  -- ========================================
  RAISE NOTICE '👥 [4] VERIFICANDO TODOS OS TRIGGERS NA TABELA "clientes"';
  RAISE NOTICE '────────────────────────────────────────────────────────────────';
  
  SELECT COUNT(*) INTO v_count
  FROM pg_trigger t
  JOIN pg_class c ON t.tgrelid = c.oid
  WHERE c.relname = 'clientes'
    AND NOT t.tgisinternal;
  
  IF v_count > 0 THEN
    RAISE NOTICE 'ℹ️  Existem % triggers na tabela clientes:', v_count;
    
    FOR v_trigger IN
      SELECT 
        t.tgname as trigger_nome,
        p.proname as funcao,
        CASE 
          WHEN t.tgtype & 2 = 2 THEN 'BEFORE'
          WHEN t.tgtype & 64 = 64 THEN 'INSTEAD OF'
          ELSE 'AFTER'
        END as momento,
        CASE 
          WHEN t.tgtype & 4 = 4 THEN 'INSERT'
          WHEN t.tgtype & 8 = 8 THEN 'DELETE'
          WHEN t.tgtype & 16 = 16 THEN 'UPDATE'
          ELSE 'UNKNOWN'
        END as evento
      FROM pg_trigger t
      JOIN pg_class c ON t.tgrelid = c.oid
      LEFT JOIN pg_proc p ON t.tgfoid = p.oid
      WHERE c.relname = 'clientes'
        AND NOT t.tgisinternal
    LOOP
      RAISE NOTICE '   📌 Trigger: % | Função: % | Momento: % | Evento: %', 
        v_trigger.trigger_nome, v_trigger.funcao, v_trigger.momento, v_trigger.evento;
    END LOOP;
  ELSE
    RAISE NOTICE '✅ Nenhum trigger personalizado na tabela clientes';
  END IF;
  
  RAISE NOTICE '';

  -- ========================================
  -- 5. VERIFICAR FUNÇÃO atualizar_cliente_seguro
  -- ========================================
  RAISE NOTICE '🔧 [5] VERIFICANDO FUNÇÃO atualizar_cliente_seguro';
  RAISE NOTICE '────────────────────────────────────────────────────────────────';
  
  SELECT COUNT(*) INTO v_count
  FROM pg_proc p
  JOIN pg_namespace n ON p.pronamespace = n.oid
  WHERE p.proname = 'atualizar_cliente_seguro'
    AND n.nspname = 'public';
  
  IF v_count > 0 THEN
    RAISE NOTICE '✅ Função atualizar_cliente_seguro existe';
    
    FOR v_function IN
      SELECT 
        pg_get_functiondef(p.oid) as definicao
      FROM pg_proc p
      JOIN pg_namespace n ON p.pronamespace = n.oid
      WHERE p.proname = 'atualizar_cliente_seguro'
        AND n.nspname = 'public'
    LOOP
      RAISE NOTICE '   📝 Definição (primeiras linhas):';
      RAISE NOTICE '%', substring(v_function.definicao from 1 for 500);
      
      -- Verificar se contém referência a backup
      IF v_function.definicao LIKE '%criar_backup_automatico_diario%' THEN
        RAISE NOTICE '   ❌ PROBLEMA: Função contém referência a criar_backup_automatico_diario!';
      ELSE
        RAISE NOTICE '   ✅ OK: Função NÃO contém referência a backup';
      END IF;
    END LOOP;
  ELSE
    RAISE NOTICE '❌ PROBLEMA: Função atualizar_cliente_seguro NÃO existe!';
  END IF;
  
  RAISE NOTICE '';

  -- ========================================
  -- 6. VERIFICAR FUNÇÃO atualizar_produto_seguro
  -- ========================================
  RAISE NOTICE '🔧 [6] VERIFICANDO FUNÇÃO atualizar_produto_seguro';
  RAISE NOTICE '────────────────────────────────────────────────────────────────';
  
  SELECT COUNT(*) INTO v_count
  FROM pg_proc p
  JOIN pg_namespace n ON p.pronamespace = n.oid
  WHERE p.proname = 'atualizar_produto_seguro'
    AND n.nspname = 'public';
  
  IF v_count > 0 THEN
    RAISE NOTICE '✅ Função atualizar_produto_seguro existe';
    
    FOR v_function IN
      SELECT 
        pg_get_functiondef(p.oid) as definicao
      FROM pg_proc p
      JOIN pg_namespace n ON p.pronamespace = n.oid
      WHERE p.proname = 'atualizar_produto_seguro'
        AND n.nspname = 'public'
    LOOP
      -- Verificar se contém referência a backup
      IF v_function.definicao LIKE '%criar_backup_automatico_diario%' THEN
        RAISE NOTICE '   ❌ PROBLEMA: Função contém referência a criar_backup_automatico_diario!';
      ELSE
        RAISE NOTICE '   ✅ OK: Função NÃO contém referência a backup';
      END IF;
    END LOOP;
  ELSE
    RAISE NOTICE '⚠️  AVISO: Função atualizar_produto_seguro NÃO existe';
  END IF;
  
  RAISE NOTICE '';

  -- ========================================
  -- RESUMO
  -- ========================================
  RAISE NOTICE '╔══════════════════════════════════════════════════════════════╗';
  RAISE NOTICE '║  📊 RESUMO DO DIAGNÓSTICO                                    ║';
  RAISE NOTICE '╚══════════════════════════════════════════════════════════════╝';
  RAISE NOTICE '';
  RAISE NOTICE '🔍 Execute este script no SQL Editor do Supabase';
  RAISE NOTICE '📋 Copie TODOS os resultados e envie para análise';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Diagnóstico concluído!';
  
END $$;
