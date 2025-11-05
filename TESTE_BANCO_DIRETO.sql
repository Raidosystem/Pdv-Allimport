-- ============================================
-- TESTAR BANCO DE DADOS DIRETO
-- Execute para verificar se as funções RPC funcionam
-- ============================================

-- 1. Verificar usuários no sistema (para pegar um UUID real)
SELECT 
    u.id as user_id,
    u.email,
    f.nome as nome_funcionario
FROM auth.users u
LEFT JOIN public.funcionarios f ON u.id::text = f.user_id::text
WHERE u.email IS NOT NULL
ORDER BY u.created_at DESC
LIMIT 10;

-- 2. Ver se já existem configurações de impressão
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
ORDER BY atualizado_em DESC;

-- 3. TESTE MANUAL: Inserir configuração para um usuário específico
-- SUBSTITUA o UUID abaixo por um UUID real da consulta acima
/*
INSERT INTO public.configuracoes_impressao (
    user_id,
    cabecalho_personalizado,
    rodape_linha1,
    rodape_linha2,
    rodape_linha3,
    rodape_linha4,
    atualizado_em
) VALUES (
    'COLE-UUID-AQUI'::UUID,
    'TESTE CABEÇALHO DIRETO NO BANCO',
    'Rodapé linha 1 teste',
    'Rodapé linha 2 teste',
    'Rodapé linha 3 teste',
    'Rodapé linha 4 teste',
    NOW()
) ON CONFLICT (user_id) 
DO UPDATE SET 
    cabecalho_personalizado = EXCLUDED.cabecalho_personalizado,
    rodape_linha1 = EXCLUDED.rodape_linha1,
    rodape_linha2 = EXCLUDED.rodape_linha2,
    rodape_linha3 = EXCLUDED.rodape_linha3,
    rodape_linha4 = EXCLUDED.rodape_linha4,
    atualizado_em = NOW();
*/

-- 4. Verificar se inseriu
SELECT * FROM public.configuracoes_impressao ORDER BY atualizado_em DESC;

-- 5. Testar função de busca com UUID real
-- SUBSTITUA o UUID abaixo
/*
SELECT * FROM public.buscar_configuracoes_impressao_usuario('COLE-UUID-AQUI'::UUID);
*/

-- 6. Testar função de salvamento com UUID real  
-- SUBSTITUA o UUID abaixo
/*
SELECT public.migrar_configuracoes_impressao_usuario(
    'COLE-UUID-AQUI'::UUID,
    'CABEÇALHO VIA FUNÇÃO RPC',
    'RPC linha 1',
    'RPC linha 2',
    'RPC linha 3',
    'RPC linha 4'
);
*/

-- ============================================
-- INSTRUÇÕES:
-- 1. Execute a consulta 1 para ver os usuários
-- 2. Copie um UUID da coluna user_id
-- 3. Descomente e execute as consultas substituindo o UUID
-- 4. Isso vai testar se o banco está funcionando corretamente
-- ============================================