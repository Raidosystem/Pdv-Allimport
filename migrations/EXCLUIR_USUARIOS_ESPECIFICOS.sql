-- ============================================
-- EXCLUIR USUÁRIOS ESPECÍFICOS COMPLETAMENTE
-- ============================================
-- Execute este script no SQL Editor do Supabase
-- Dashboard > SQL Editor > New Query

-- Lista de emails para excluir
DO $$ 
DECLARE
    emails_to_delete TEXT[] := ARRAY[
        'teste123@teste.com',
        'silviobritoempreendedor@gmail.com', 
        'admin@pdv.com',
        'marcovalentim04@gmail.com',
        'smartcellinova@gmail.com'
    ];
    email_item TEXT;
    user_uuid UUID;
BEGIN
    FOREACH email_item IN ARRAY emails_to_delete
    LOOP
        -- Buscar UUID do usuário pelo email
        SELECT id INTO user_uuid 
        FROM auth.users 
        WHERE email = email_item;
        
        IF user_uuid IS NOT NULL THEN
            RAISE NOTICE 'Excluindo usuário: % (ID: %)', email_item, user_uuid;
            
            -- ORDEM CORRETA: Excluir tabelas dependentes PRIMEIRO, depois as principais
            
            -- 1. Excluir itens de venda (dependem de vendas)
            BEGIN
                DELETE FROM public.itens_venda WHERE venda_id IN (SELECT id FROM public.vendas WHERE user_id = user_uuid);
                RAISE NOTICE '  ✓ Removido itens de venda';
            EXCEPTION WHEN undefined_table THEN
                RAISE NOTICE '  ⚠ Tabela itens_venda não existe';
            END;
            
            -- 2. Excluir vendas_itens (dependem de vendas)
            BEGIN
                DELETE FROM public.vendas_itens WHERE venda_id IN (SELECT id FROM public.vendas WHERE user_id = user_uuid);
                RAISE NOTICE '  ✓ Removido vendas_itens';
            EXCEPTION WHEN undefined_table THEN
                RAISE NOTICE '  ⚠ Tabela vendas_itens não existe';
            END;
            
            -- 3. Excluir movimentações de caixa (antes de caixa)
            BEGIN
                DELETE FROM public.movimentacoes_caixa WHERE user_id = user_uuid;
                RAISE NOTICE '  ✓ Removido movimentações de caixa';
            EXCEPTION WHEN undefined_table THEN
                RAISE NOTICE '  ⚠ Tabela movimentacoes_caixa não existe';
            END;
            
            -- 4. Excluir vendas do usuário
            BEGIN
                -- Primeiro, remover referências de cliente das vendas
                UPDATE public.vendas SET cliente_id = NULL WHERE user_id = user_uuid;
                -- Depois excluir as vendas
                DELETE FROM public.vendas WHERE user_id = user_uuid;
                RAISE NOTICE '  ✓ Removido vendas';
            EXCEPTION WHEN undefined_table THEN
                RAISE NOTICE '  ⚠ Tabela vendas não existe';
            END;
            
            -- 5. Excluir ordens de serviço
            BEGIN
                DELETE FROM public.ordens_servico WHERE user_id = user_uuid;
                RAISE NOTICE '  ✓ Removido ordens de serviço';
            EXCEPTION WHEN undefined_table THEN
                RAISE NOTICE '  ⚠ Tabela ordens_servico não existe';
            END;
            
            -- 6. Excluir caixa
            BEGIN
                DELETE FROM public.caixa WHERE user_id = user_uuid;
                RAISE NOTICE '  ✓ Removido caixa';
            EXCEPTION WHEN undefined_table THEN
                RAISE NOTICE '  ⚠ Tabela caixa não existe';
            END;
            
            -- 7. Excluir produtos (ANTES de categorias e clientes)
            BEGIN
                -- Remover a referência de categoria APENAS dos produtos deste usuário
                UPDATE public.produtos SET categoria_id = NULL WHERE user_id = user_uuid;
                -- Excluir os produtos
                DELETE FROM public.produtos WHERE user_id = user_uuid;
                RAISE NOTICE '  ✓ Removido produtos';
            EXCEPTION WHEN undefined_table THEN
                RAISE NOTICE '  ⚠ Tabela produtos não existe';
            END;
            
            -- 8. Excluir categorias (DEPOIS de produtos)
            BEGIN
                -- Tentar excluir, mas se houver FK de outros usuários, ignorar
                DELETE FROM public.categorias WHERE user_id = user_uuid;
                RAISE NOTICE '  ✓ Removido categorias';
            EXCEPTION 
                WHEN undefined_table THEN
                    RAISE NOTICE '  ⚠ Tabela categorias não existe';
                WHEN foreign_key_violation THEN
                    -- Categorias sendo usadas por outros usuários não serão excluídas
                    RAISE NOTICE '  ⚠ Categorias estão sendo usadas por outros usuários, mantendo...';
            END;
            
            -- 9. Excluir clientes (DEPOIS de produtos)
            BEGIN
                -- Tentar excluir, mas se houver FK de outros usuários, ignorar
                DELETE FROM public.clientes WHERE user_id = user_uuid;
                RAISE NOTICE '  ✓ Removido clientes';
            EXCEPTION 
                WHEN undefined_table THEN
                    RAISE NOTICE '  ⚠ Tabela clientes não existe';
                WHEN foreign_key_violation THEN
                    -- Clientes sendo usados por outros usuários não serão excluídos
                    RAISE NOTICE '  ⚠ Clientes estão sendo usados por outros usuários, mantendo...';
            END;
            
            -- 10. Excluir configurações
            BEGIN
                DELETE FROM public.configuracoes WHERE user_id = user_uuid;
                RAISE NOTICE '  ✓ Removido configurações';
            EXCEPTION WHEN undefined_table THEN
                RAISE NOTICE '  ⚠ Tabela configuracoes não existe';
            END;
            
            -- 11. Excluir configurações de impressão
            BEGIN
                DELETE FROM public.configuracoes_impressao WHERE user_id = user_uuid;
                RAISE NOTICE '  ✓ Removido configurações de impressão';
            EXCEPTION WHEN undefined_table THEN
                RAISE NOTICE '  ⚠ Tabela configuracoes_impressao não existe';
            END;
            
            -- 12. Excluir configurações da empresa
            BEGIN
                DELETE FROM public.configuracoes_empresa WHERE user_id = user_uuid;
                RAISE NOTICE '  ✓ Removido configurações da empresa';
            EXCEPTION WHEN undefined_table THEN
                RAISE NOTICE '  ⚠ Tabela configuracoes_empresa não existe';
            END;
            
            -- 13. Excluir da tabela funcionarios
            BEGIN
                DELETE FROM public.funcionarios WHERE user_id = user_uuid;
                RAISE NOTICE '  ✓ Removido de funcionarios';
            EXCEPTION WHEN undefined_table THEN
                RAISE NOTICE '  ⚠ Tabela funcionarios não existe';
            END;
            
            -- 14. Excluir da tabela empresas
            BEGIN
                DELETE FROM public.empresas WHERE user_id = user_uuid;
                RAISE NOTICE '  ✓ Removido de empresas';
            EXCEPTION WHEN undefined_table THEN
                RAISE NOTICE '  ⚠ Tabela empresas não existe';
            END;
            
            -- 15. Excluir da tabela subscriptions
            DELETE FROM public.subscriptions WHERE user_id = user_uuid;
            RAISE NOTICE '  ✓ Removido de subscriptions';
            
            -- 16. Excluir da tabela user_approvals
            DELETE FROM public.user_approvals WHERE user_id = user_uuid;
            RAISE NOTICE '  ✓ Removido de user_approvals';
            
            -- 17. FINALMENTE excluir do auth.users (com proteção contra FK)
            BEGIN
                DELETE FROM auth.users WHERE id = user_uuid;
                RAISE NOTICE '  ✓ Removido de auth.users';
            EXCEPTION 
                WHEN foreign_key_violation THEN
                    -- Se houver FK que impedem exclusão, desabilitar a conta
                    RAISE NOTICE '  ⚠ Não foi possível excluir auth.users (FK constraints)';
                    RAISE NOTICE '  🔒 Desabilitando conta do usuário...';
                    -- Alterar email para invalidar login
                    UPDATE auth.users 
                    SET email = 'DELETED_' || user_uuid || '@deleted.invalid',
                        email_confirmed_at = NULL,
                        deleted_at = NOW()
                    WHERE id = user_uuid;
                    RAISE NOTICE '  ✓ Conta desabilitada (não pode mais fazer login)';
            END;
            
            RAISE NOTICE '✅ Usuário % processado completamente!', email_item;
        ELSE
            RAISE NOTICE '❌ Usuário % não encontrado', email_item;
        END IF;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE '🎉 PROCESSO CONCLUÍDO!';
END $$;

-- Verificar se foram excluídos
SELECT 
    'Usuários restantes:' as info,
    COUNT(*) as total
FROM auth.users;
