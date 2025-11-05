-- ============================================
-- VERIFICAR CONFIGURAÇÕES DO USUÁRIO ATUAL
-- UUID: f7fdf4cf-7101-45ab-86db-5248a7ac58c1
-- ============================================

-- 1. Verificar se as configurações do usuário atual estão no banco
SELECT 
    user_id,
    cabecalho_personalizado,
    rodape_linha1,
    rodape_linha2,
    rodape_linha3,
    rodape_linha4,
    criado_em,
    atualizado_em
FROM public.configuracoes_impressao 
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID;

-- 2. Se não existir, inserir configurações padrão
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
    'ASSISTÊNCIA ALL-IMPORT - Configuração Inicial',
    'Obrigado pela preferência!',
    'Volte sempre!',
    'www.allimport.com.br',
    'WhatsApp: (11) 99999-9999',
    NOW()
) ON CONFLICT (user_id) 
DO UPDATE SET 
    cabecalho_personalizado = EXCLUDED.cabecalho_personalizado,
    rodape_linha1 = EXCLUDED.rodape_linha1,
    rodape_linha2 = EXCLUDED.rodape_linha2,
    rodape_linha3 = EXCLUDED.rodape_linha3,
    rodape_linha4 = EXCLUDED.rodape_linha4,
    atualizado_em = NOW();

-- 3. Testar função de busca para o usuário atual
SELECT * FROM public.buscar_configuracoes_impressao_usuario('f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID);

-- 4. Verificar resultado final
SELECT 
    user_id,
    cabecalho_personalizado,
    rodape_linha1,
    rodape_linha2, 
    rodape_linha3,
    rodape_linha4,
    atualizado_em
FROM public.configuracoes_impressao 
WHERE user_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::UUID;

-- 5. Ver todas as configurações de impressão no sistema
SELECT 
    user_id,
    LEFT(cabecalho_personalizado, 50) as cabecalho_preview,
    rodape_linha1,
    atualizado_em
FROM public.configuracoes_impressao 
ORDER BY atualizado_em DESC;

-- ============================================
-- SCRIPT PARA TODOS OS USUÁRIOS DO SISTEMA
-- Criar configurações padrão para todos os usuários existentes
-- ============================================

-- 6. Inserir configurações padrão para TODOS os usuários que não têm
INSERT INTO public.configuracoes_impressao (
    user_id,
    cabecalho_personalizado,
    rodape_linha1,
    rodape_linha2,
    rodape_linha3,
    rodape_linha4,
    atualizado_em
)
SELECT 
    u.id,
    'PDV ALLIMPORT - Sistema Completo' as cabecalho_personalizado,
    'Obrigado pela preferência!' as rodape_linha1,
    'Volte sempre!' as rodape_linha2,
    'www.allimport.com.br' as rodape_linha3,
    'Suporte: suporte@allimport.com.br' as rodape_linha4,
    NOW() as atualizado_em
FROM auth.users u
LEFT JOIN public.configuracoes_impressao ci ON u.id = ci.user_id
WHERE ci.user_id IS NULL
  AND u.email IS NOT NULL;

-- 7. Verificar quantos usuários foram contemplados
SELECT 
    COUNT(*) as total_configuracoes,
    COUNT(DISTINCT user_id) as usuarios_unicos
FROM public.configuracoes_impressao;