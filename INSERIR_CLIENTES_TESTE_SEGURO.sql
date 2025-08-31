-- 🔧 INSERÇÃO INTELIGENTE DE CLIENTES - Evita duplicatas
-- Execute este script no Supabase SQL Editor

-- =====================================================
-- PASSO 1: VERIFICAÇÃO INICIAL
-- =====================================================

SELECT 'VERIFICANDO TABELA DE CLIENTES...' as info;
SELECT COUNT(*) as clientes_existentes FROM public.clientes;

-- =====================================================
-- PASSO 2: LIMPEZA OPCIONAL (DESCOMENTE SE NECESSÁRIO)
-- =====================================================

-- ⚠️ DESCOMENTE APENAS SE QUISER LIMPAR A TABELA PRIMEIRO
-- DELETE FROM public.clientes;
-- SELECT 'TABELA LIMPA!' as info;

-- =====================================================
-- PASSO 3: INSERÇÃO COM VERIFICAÇÃO DE CONFLITOS
-- =====================================================

-- Inserir apenas clientes que não existem (usando ON CONFLICT DO NOTHING)
INSERT INTO public.clientes (
    id, user_id, nome, cpf_cnpj, telefone, email, endereco, 
    cidade, estado, cep, ativo, criado_em, atualizado_em
) 
SELECT 
    id::uuid, user_id::uuid, nome, cpf_cnpj, telefone, email, endereco, 
    cidade, estado, cep, ativo, criado_em::timestamptz, atualizado_em::timestamptz
FROM (VALUES 
    -- Primeiros 5 clientes como teste
    ('795481e5-5f71-46f5-aebf-80cc91031227', '28e56a69-90df-4852-b663-9b02f4358c6f', 'ANTONIO CLAUDIO FIGUEIRA', '33393732803', '17999740896', '', 'AV 23, 631', 'Guaíra', 'SP', '14790-000', true, '2025-06-17T17:36:15.817985-03:00', '2025-06-17T17:36:15.817985-03:00'),
    ('fb78f0fa-1c56-4bf1-b783-8c5a60c00c62', '28e56a69-90df-4852-b663-9b02f4358c6f', 'EDVANIA DA SILVA', '37511773885', '17999790061', 'BRANCAFABIANA@GMAIL.COM', 'AV JACARANDA, 2226', 'GUAIRA', 'SP', '14790-000', true, '2025-06-17T18:14:28.92461-03:00', '2025-06-17T18:14:28.92461-03:00'),
    ('67526f20-485e-40a0-b448-303ce34932fc', '28e56a69-90df-4852-b663-9b02f4358c6f', 'SAULO DE TARSO', '32870183968', '17991784929', '', '', '', '', '', true, '2025-06-18T10:27:30.544639-03:00', '2025-06-18T10:27:30.544639-03:00'),
    ('98e0b7d7-7362-4855-89f0-fa7c1644964f', '28e56a69-90df-4852-b663-9b02f4358c6f', 'ALINE CRISTINA CAMARGO', '37784514808', '17999746003', '', '', '', '', '', true, '2025-06-18T10:47:31.189798-03:00', '2025-06-18T10:47:31.189798-03:00'),
    ('7af82c1b-9588-471f-b700-d2427b18c6ec', '28e56a69-90df-4852-b663-9b02f4358c6f', 'WINDERSON RODRIGUES LELIS', '23510133870', '16991879011', '', 'AV 29, COAB 1', 'GUAIRA', 'SP', '14790-000', true, '2025-06-18T13:55:28.144765-03:00', '2025-06-18T13:55:28.144765-03:00')
) AS dados(id, user_id, nome, cpf_cnpj, telefone, email, endereco, cidade, estado, cep, ativo, criado_em, atualizado_em)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- PASSO 4: VERIFICAÇÃO FINAL
-- =====================================================

SELECT 'INSERÇÃO DE TESTE CONCLUÍDA!' as resultado;
SELECT COUNT(*) as total_clientes_agora FROM public.clientes;

-- Mostrar clientes inseridos
SELECT 'CLIENTES INSERIDOS:' as info;
SELECT nome, telefone, cidade FROM public.clientes ORDER BY criado_em DESC LIMIT 5;

SELECT '✅ TESTE CONCLUÍDO! Para inserir TODOS os 141 clientes, use o arquivo: INSERIR_TODOS_CLIENTES_COMPLETO.sql' as proximo_passo;
