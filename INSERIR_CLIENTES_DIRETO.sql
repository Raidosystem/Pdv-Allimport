-- 🔧 INSERÇÃO DIRETA DE CLIENTES - Método Simples e Seguro
-- Execute este script no Supabase SQL Editor

-- =====================================================
-- VERIFICAÇÃO INICIAL
-- =====================================================
SELECT 'CLIENTES ANTES:' as status, COUNT(*) as total FROM public.clientes;

-- =====================================================
-- INSERÇÃO DIRETA (5 CLIENTES TESTE)
-- =====================================================

-- Cliente 1
INSERT INTO public.clientes (
    id, user_id, nome, cpf_cnpj, telefone, email, endereco, 
    cidade, estado, cep, ativo, criado_em, atualizado_em
) VALUES (
    '795481e5-5f71-46f5-aebf-80cc91031227'::uuid, 
    '28e56a69-90df-4852-b663-9b02f4358c6f'::uuid, 
    'ANTONIO CLAUDIO FIGUEIRA', 
    '33393732803', 
    '17999740896', 
    '', 
    'AV 23, 631', 
    'Guaíra', 
    'SP', 
    '14790-000', 
    true, 
    '2025-06-17T17:36:15.817985-03:00'::timestamptz, 
    '2025-06-17T17:36:15.817985-03:00'::timestamptz
) ON CONFLICT (id) DO NOTHING;

-- Cliente 2
INSERT INTO public.clientes (
    id, user_id, nome, cpf_cnpj, telefone, email, endereco, 
    cidade, estado, cep, ativo, criado_em, atualizado_em
) VALUES (
    'fb78f0fa-1c56-4bf1-b783-8c5a60c00c62'::uuid, 
    '28e56a69-90df-4852-b663-9b02f4358c6f'::uuid, 
    'EDVANIA DA SILVA', 
    '37511773885', 
    '17999790061', 
    'BRANCAFABIANA@GMAIL.COM', 
    'AV JACARANDA, 2226', 
    'GUAIRA', 
    'SP', 
    '14790-000', 
    true, 
    '2025-06-17T18:14:28.92461-03:00'::timestamptz, 
    '2025-06-17T18:14:28.92461-03:00'::timestamptz
) ON CONFLICT (id) DO NOTHING;

-- Cliente 3
INSERT INTO public.clientes (
    id, user_id, nome, cpf_cnpj, telefone, email, endereco, 
    cidade, estado, cep, ativo, criado_em, atualizado_em
) VALUES (
    '67526f20-485e-40a0-b448-303ce34932fc'::uuid, 
    '28e56a69-90df-4852-b663-9b02f4358c6f'::uuid, 
    'SAULO DE TARSO', 
    '32870183968', 
    '17991784929', 
    '', 
    '', 
    '', 
    '', 
    '', 
    true, 
    '2025-06-18T10:27:30.544639-03:00'::timestamptz, 
    '2025-06-18T10:27:30.544639-03:00'::timestamptz
) ON CONFLICT (id) DO NOTHING;

-- Cliente 4
INSERT INTO public.clientes (
    id, user_id, nome, cpf_cnpj, telefone, email, endereco, 
    cidade, estado, cep, ativo, criado_em, atualizado_em
) VALUES (
    '98e0b7d7-7362-4855-89f0-fa7c1644964f'::uuid, 
    '28e56a69-90df-4852-b663-9b02f4358c6f'::uuid, 
    'ALINE CRISTINA CAMARGO', 
    '37784514808', 
    '17999746003', 
    '', 
    '', 
    '', 
    '', 
    '', 
    true, 
    '2025-06-18T10:47:31.189798-03:00'::timestamptz, 
    '2025-06-18T10:47:31.189798-03:00'::timestamptz
) ON CONFLICT (id) DO NOTHING;

-- Cliente 5
INSERT INTO public.clientes (
    id, user_id, nome, cpf_cnpj, telefone, email, endereco, 
    cidade, estado, cep, ativo, criado_em, atualizado_em
) VALUES (
    '7af82c1b-9588-471f-b700-d2427b18c6ec'::uuid, 
    '28e56a69-90df-4852-b663-9b02f4358c6f'::uuid, 
    'WINDERSON RODRIGUES LELIS', 
    '23510133870', 
    '16991879011', 
    '', 
    'AV 29, COAB 1', 
    'GUAIRA', 
    'SP', 
    '14790-000', 
    true, 
    '2025-06-18T13:55:28.144765-03:00'::timestamptz, 
    '2025-06-18T13:55:28.144765-03:00'::timestamptz
) ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================
SELECT 'INSERÇÃO CONCLUÍDA! ✅' as status;
SELECT 'CLIENTES DEPOIS:' as status, COUNT(*) as total FROM public.clientes;

-- Mostrar clientes inseridos
SELECT 'CLIENTES INSERIDOS:' as info;
SELECT nome, telefone, cidade FROM public.clientes ORDER BY criado_em DESC LIMIT 5;

SELECT '✅ TESTE FUNCIONANDO! Use INSERIR_CLIENTES_UUID_CORRETO.sql para inserir todos os 141 clientes!' as proximo_passo;
