-- ============================================
-- TESTAR FUNÇÕES DE CONFIGURAÇÕES DE IMPRESSÃO
-- Execute este script para verificar se as funções estão funcionando
-- ============================================

-- 1. Verificar usuário atual (execute PRIMEIRO para pegar o UUID)
SELECT auth.uid() as current_user_id;

-- 2. Verificar se a tabela existe e tem a estrutura correta
SELECT * FROM information_schema.columns 
WHERE table_name = 'configuracoes_impressao' 
ORDER BY ordinal_position;

-- 3. Verificar permissões da tabela
SELECT grantee, privilege_type 
FROM information_schema.table_privileges 
WHERE table_name = 'configuracoes_impressao';

-- 4. Teste básico: inserir configuração para o usuário atual
-- Esta query usa auth.uid() diretamente, não precisa substituir nada
INSERT INTO public.configuracoes_impressao (
    user_id,
    cabecalho_personalizado,
    rodape_linha1,
    rodape_linha2,
    rodape_linha3,
    rodape_linha4
) VALUES (
    auth.uid(),
    'TESTE CABEÇALHO MANUAL',
    'Teste linha 1',
    'Teste linha 2',
    'Teste linha 3',
    'Teste linha 4'
) ON CONFLICT (user_id) 
DO UPDATE SET 
    cabecalho_personalizado = EXCLUDED.cabecalho_personalizado,
    rodape_linha1 = EXCLUDED.rodape_linha1,
    rodape_linha2 = EXCLUDED.rodape_linha2,
    rodape_linha3 = EXCLUDED.rodape_linha3,
    rodape_linha4 = EXCLUDED.rodape_linha4,
    atualizado_em = NOW();

-- 5. Testar função de busca para o usuário atual
SELECT * FROM public.buscar_configuracoes_impressao_usuario(auth.uid());

-- 6. Testar função de migração/salvamento para o usuário atual
SELECT public.migrar_configuracoes_impressao_usuario(
    auth.uid(),
    'TESTE CABEÇALHO VIA FUNÇÃO',
    'Função linha 1',
    'Função linha 2',
    'Função linha 3',
    'Função linha 4'
);

-- 7. Verificar se foi salvo
SELECT * FROM public.configuracoes_impressao WHERE user_id = auth.uid();

-- 8. Ver todas as configurações (para debug)
SELECT * FROM public.configuracoes_impressao ORDER BY atualizado_em DESC LIMIT 5;

-- ============================================
-- INSTRUÇÕES SIMPLIFICADAS:
-- 1. Execute as consultas uma por uma na ordem
-- 2. Agora usa auth.uid() automaticamente - não precisa substituir nada!
-- 3. Se der erro "auth.uid() is null", você não está logado no Supabase
-- ============================================