-- ============================================
-- CRIAR CONFIGURAÇÃO PARA USUÁRIO ATUAL
-- UUID: f7fdf4cf-7101-45ab-86db-5248a7ac58c1
-- ============================================

-- Inserir configuração para o usuário atual
INSERT INTO public.configuracoes_impressao (
    user_id,
    cabecalho_personalizado,
    rodape_linha1,
    rodape_linha2,
    rodape_linha3,
    rodape_linha4,
    atualizado_em
) VALUES (
    'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID,
    'ALLIMPORT - ASSISTÊNCIA TÉCNICA',
    'Obrigado pela preferência!',
    'Volte sempre!',
    'WhatsApp: (11) 99999-9999',
    'www.allimport.com.br',
    NOW()
) ON CONFLICT (user_id) 
DO UPDATE SET 
    cabecalho_personalizado = EXCLUDED.cabecalho_personalizado,
    rodape_linha1 = EXCLUDED.rodape_linha1,
    rodape_linha2 = EXCLUDED.rodape_linha2,
    rodape_linha3 = EXCLUDED.rodape_linha3,
    rodape_linha4 = EXCLUDED.rodape_linha4,
    atualizado_em = NOW();

-- Verificar se foi inserido
SELECT * FROM public.configuracoes_impressao 
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID;

-- Testar função de busca
SELECT * FROM public.buscar_configuracoes_impressao_usuario('f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID);

-- Testar função de salvamento  
SELECT public.migrar_configuracoes_impressao_usuario(
    'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID,
    'TESTE PARA USUÁRIO ATUAL',
    'Rodapé teste 1',
    'Rodapé teste 2',
    'Rodapé teste 3',
    'Rodapé teste 4'
);