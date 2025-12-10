-- ============================================
-- TESTE ALTERNATIVO - SEM AUTENTICAÇÃO
-- Use se auth.uid() retornar null
-- ============================================

-- 1. Ver estrutura da tabela
SELECT * FROM information_schema.columns 
WHERE table_name = 'configuracoes_impressao' 
ORDER BY ordinal_position;

-- 2. Ver todos os usuários que têm configurações
SELECT user_id, cabecalho_personalizado, rodape_linha1 
FROM public.configuracoes_impressao 
ORDER BY atualizado_em DESC 
LIMIT 10;

-- 3. Contar quantos registros existem
SELECT COUNT(*) as total_configuracoes 
FROM public.configuracoes_impressao;

-- 4. Ver as políticas RLS
SELECT schemaname, tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'configuracoes_impressao';

-- 5. Testar as funções com um UUID qualquer (só para ver se funcionam)
-- Esta é só uma simulação - não vai salvar dados reais
SELECT 'Testando função migrar...' as teste;
-- SELECT public.migrar_configuracoes_impressao_usuario(
--     gen_random_uuid(),
--     'TESTE SIMULADO',
--     'Linha 1 simulada',
--     'Linha 2 simulada', 
--     'Linha 3 simulada',
--     'Linha 4 simulada'
-- );

-- 6. Ver se as funções existem
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name LIKE '%configuracoes_impressao%' 
  AND routine_schema = 'public';

-- ============================================
-- PARA DESCOBRIR O UUID DO USUÁRIO:
-- 1. Vá na aplicação (http://localhost:5175)
-- 2. Abra o Console (F12)
-- 3. Digite: console.log(JSON.parse(localStorage.getItem('sb-cgqxjxgjspqlngzezphf-auth-token')))
-- 4. O UUID estará em user.id
-- ============================================