-- ============================================
-- TESTE COM UUID REAL ENCONTRADO
-- UUID: f1726fcf-d23b-4cca-8079-39314ae56e00
-- ============================================

-- 1. Testar função de busca com o UUID real
SELECT * FROM public.buscar_configuracoes_impressao_usuario('f1726fcf-d23b-4cca-8079-39314ae56e00'::UUID);

-- 2. Testar função de salvamento com o UUID real
SELECT public.migrar_configuracoes_impressao_usuario(
    'f1726fcf-d23b-4cca-8079-39314ae56e00'::UUID,
    'TESTE CABEÇALHO VIA FUNÇÃO RPC',
    'RPC linha 1',
    'RPC linha 2', 
    'RPC linha 3',
    'RPC linha 4'
);

-- 3. Verificar se foi atualizado
SELECT 
    user_id,
    cabecalho_personalizado,
    rodape_linha1,
    rodape_linha2,
    rodape_linha3,
    rodape_linha4,
    atualizado_em
FROM public.configuracoes_impressao 
WHERE user_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'::UUID;

-- 4. Testar busca novamente após atualização
SELECT * FROM public.buscar_configuracoes_impressao_usuario('f1726fcf-d23b-4cca-8079-39314ae56e00'::UUID);

-- 5. Atualizar apenas o cabeçalho (simulando a aplicação)
SELECT public.migrar_configuracoes_impressao_usuario(
    'f1726fcf-d23b-4cca-8079-39314ae56e00'::UUID,
    'MINHA EMPRESA TESTE FINAL',
    'RPC linha 1',
    'RPC linha 2',
    'RPC linha 3', 
    'RPC linha 4'
);

-- 6. Verificar resultado final
SELECT * FROM public.configuracoes_impressao 
WHERE user_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'::UUID;