-- ============================================
-- VERIFICAR SINCRONIZAÇÃO STATUS ↔ ATIVO
-- ============================================
-- Execute este script para verificar se os triggers
-- estão funcionando corretamente
-- ============================================

-- 1. VERIFICAR FUNCIONÁRIOS ATUAIS
SELECT 
    '📋 FUNCIONÁRIOS CADASTRADOS' as info,
    id,
    nome,
    ativo as ativo_bool,
    status as status_varchar,
    CASE 
        WHEN (ativo = true AND status = 'ativo') THEN '✅ Sincronizado'
        WHEN (ativo = false AND status IN ('pausado', 'inativo')) THEN '✅ Sincronizado'
        ELSE '⚠️ Fora de sincronia'
    END as verificacao
FROM funcionarios
ORDER BY nome;

-- 2. VERIFICAR TRIGGERS CRIADOS
SELECT 
    '🔧 TRIGGERS CONFIGURADOS' as info,
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE event_object_table = 'funcionarios'
    AND trigger_name LIKE '%sync%';

-- 3. VERIFICAR FUNÇÕES CRIADAS
SELECT 
    '⚙️ FUNÇÕES DE SINCRONIZAÇÃO' as info,
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND routine_name LIKE '%sync_funcionario%';

-- 4. TESTE PRÁTICO (OPCIONAL - descomente para executar)
/*
-- Pegar o ID do primeiro funcionário para teste
DO $$
DECLARE
    v_funcionario_id UUID;
    v_nome_funcionario TEXT;
BEGIN
    -- Pegar primeiro funcionário
    SELECT id, nome INTO v_funcionario_id, v_nome_funcionario
    FROM funcionarios
    LIMIT 1;

    IF v_funcionario_id IS NULL THEN
        RAISE NOTICE '❌ Nenhum funcionário encontrado para teste';
        RETURN;
    END IF;

    RAISE NOTICE '🧪 Testando com funcionário: % (ID: %)', v_nome_funcionario, v_funcionario_id;

    -- Teste 1: Alterar STATUS para 'pausado' (ativo deve virar false)
    RAISE NOTICE '📝 Teste 1: Alterando status para pausado...';
    UPDATE funcionarios SET status = 'pausado' WHERE id = v_funcionario_id;

    -- Verificar
    PERFORM * FROM funcionarios 
    WHERE id = v_funcionario_id 
        AND status = 'pausado' 
        AND ativo = false;
    
    IF FOUND THEN
        RAISE NOTICE '✅ Teste 1 PASSOU: status=pausado sincronizou com ativo=false';
    ELSE
        RAISE NOTICE '❌ Teste 1 FALHOU: Sincronização não funcionou';
    END IF;

    -- Teste 2: Alterar ATIVO para true (status deve virar 'ativo')
    RAISE NOTICE '📝 Teste 2: Alterando ativo para true...';
    UPDATE funcionarios SET ativo = true WHERE id = v_funcionario_id;

    -- Verificar
    PERFORM * FROM funcionarios 
    WHERE id = v_funcionario_id 
        AND status = 'ativo' 
        AND ativo = true;
    
    IF FOUND THEN
        RAISE NOTICE '✅ Teste 2 PASSOU: ativo=true sincronizou com status=ativo';
    ELSE
        RAISE NOTICE '❌ Teste 2 FALHOU: Sincronização não funcionou';
    END IF;

    RAISE NOTICE '✅ Testes concluídos!';
END $$;
*/

-- 5. RESUMO FINAL
SELECT 
    '📊 RESUMO GERAL' as categoria,
    COUNT(*) as total_funcionarios,
    COUNT(CASE WHEN status = 'ativo' THEN 1 END) as status_ativo,
    COUNT(CASE WHEN status = 'pausado' THEN 1 END) as status_pausado,
    COUNT(CASE WHEN status = 'inativo' THEN 1 END) as status_inativo,
    COUNT(CASE WHEN ativo = true THEN 1 END) as ativo_true,
    COUNT(CASE WHEN ativo = false THEN 1 END) as ativo_false,
    COUNT(CASE 
        WHEN (ativo = true AND status = 'ativo') 
        OR (ativo = false AND status IN ('pausado', 'inativo'))
        THEN 1 
    END) as sincronizados
FROM funcionarios;

-- ============================================
-- INTERPRETAÇÃO DOS RESULTADOS
-- ============================================
/*
✅ SUCESSO se:
- Triggers aparecem na lista
- Funções aparecem na lista
- sincronizados = total_funcionarios
- Nenhum funcionário está "Fora de sincronia"

⚠️ PROBLEMA se:
- Triggers não aparecem → Execute CORRIGIR_STATUS_FUNCIONARIOS.sql novamente
- Funcionários fora de sincronia → Execute o UPDATE manual (PASSO 2 do script)
- Funções não aparecem → Verifique permissões do banco
*/
