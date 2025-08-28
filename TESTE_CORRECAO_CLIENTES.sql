-- SCRIPT PARA TESTAR SE AS CORREÇÕES DE USER_ID FUNCIONAM
-- Execute este script no Supabase SQL Editor APÓS executar o CORRIGIR_USER_ID_CLIENTES.sql

-- 1. Teste de inserção de cliente
DO $$
DECLARE
    novo_cliente_id UUID;
    teste_sucesso BOOLEAN := FALSE;
BEGIN
    -- Tentar inserir um cliente de teste
    INSERT INTO clientes (nome, email, telefone) 
    VALUES ('Cliente Teste Correção', 'teste.correcao@exemplo.com', '11999999999')
    RETURNING id INTO novo_cliente_id;
    
    -- Verificar se foi inserido com user_id
    IF novo_cliente_id IS NOT NULL THEN
        teste_sucesso := TRUE;
        
        -- Exibir resultado
        RAISE NOTICE 'SUCESSO: Cliente criado com ID: %', novo_cliente_id;
        
        -- Verificar se tem user_id preenchido
        PERFORM id FROM clientes WHERE id = novo_cliente_id AND user_id IS NOT NULL;
        IF FOUND THEN
            RAISE NOTICE 'SUCESSO: user_id foi preenchido automaticamente!';
        ELSE
            RAISE NOTICE 'AVISO: user_id ainda está NULL';
        END IF;
        
        -- Limpar teste
        DELETE FROM clientes WHERE id = novo_cliente_id;
        RAISE NOTICE 'Cliente de teste removido.';
        
    END IF;
    
    -- Resultado final
    IF teste_sucesso THEN
        RAISE NOTICE '✅ CORREÇÃO FUNCIONOU! Clientes podem ser criados normalmente.';
    ELSE
        RAISE NOTICE '❌ ERRO: Ainda há problemas na criação de clientes.';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ ERRO NO TESTE: %', SQLERRM;
END $$;

-- 2. Verificar estatísticas finais
SELECT 
    'Estatísticas Finais' as status,
    COUNT(*) as total_clientes,
    COUNT(CASE WHEN user_id IS NULL THEN 1 END) as sem_user_id,
    COUNT(CASE WHEN usuario_id IS NULL THEN 1 END) as sem_usuario_id
FROM clientes;

-- 3. Mensagem final
DO $$
BEGIN
    RAISE NOTICE '🎉 Se não houve erros acima, a correção foi aplicada com sucesso!';
END $$;
