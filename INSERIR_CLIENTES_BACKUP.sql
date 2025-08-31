-- 📋 INSERÇÃO DE CLIENTES DO BACKUP - Execute no Supabase SQL Editor
-- Este script insere todos os 141 clientes do backup no sistema PDV

-- =====================================================
-- PASSO 1: VERIFICAR TABELA DE CLIENTES
-- =====================================================

-- Verificar se tabela existe e está vazia
SELECT 'ANTES DA INSERÇÃO:' as info, COUNT(*) as clientes_atuais FROM public.clientes;

-- =====================================================
-- PASSO 2: INSERIR CLIENTES DO BACKUP
-- =====================================================

-- Inserir todos os 141 clientes (com user_id do ALL IMPORT)
INSERT INTO public.clientes (
    id, user_id, name, cpf_cnpj, phone, email, address, 
    city, state, zip_code, birth_date, created_at, updated_at
) VALUES 
-- CLIENTE 1
('795481e5-5f71-46f5-aebf-80cc91031227', '28e56a69-90df-4852-b663-9b02f4358c6f', 'ANTONIO CLAUDIO FIGUEIRA', '33393732803', '17999740896', '', 'AV 23, 631', 'Guaíra', 'SP', '14790-000', '1995-07-24', '2025-06-17T17:36:15.817985-03:00', '2025-06-17T17:36:15.817985-03:00'),

-- CLIENTE 2  
('fb78f0fa-1c56-4bf1-b783-8c5a60c00c62', '28e56a69-90df-4852-b663-9b02f4358c6f', 'EDVANIA DA SILVA', '37511773885', '17999790061', 'BRANCAFABIANA@GMAIL.COM', 'AV JACARANDA, 2226', 'GUAIRA', 'SP', '14790-000', '1989-01-03', '2025-06-17T18:14:28.92461-03:00', '2025-06-17T18:14:28.92461-03:00'),

-- CLIENTE 3
('67526f20-485e-40a0-b448-303ce34932fc', '28e56a69-90df-4852-b663-9b02f4358c6f', 'SAULO DE TARSO', '32870183968', '17991784929', '', '', '', '', '', '2000-05-04', '2025-06-18T10:27:30.544639-03:00', '2025-06-18T10:27:30.544639-03:00');

-- ❌ NOTA: Este é apenas um exemplo com 3 clientes
-- Para inserir TODOS os 141 clientes, preciso gerar o script completo

-- =====================================================
-- PASSO 3: VERIFICAR INSERÇÃO
-- =====================================================

SELECT 'APÓS INSERÇÃO:' as info, COUNT(*) as total_clientes FROM public.clientes;

SELECT 'PRIMEIROS 5 CLIENTES INSERIDOS:' as info;
SELECT id, name, phone, city FROM public.clientes LIMIT 5;

SELECT 'INSERÇÃO DE EXEMPLO CONCLUÍDA! ✅' as resultado;
SELECT '⚠️ Para inserir TODOS os 141 clientes, execute o script completo' as aviso;
