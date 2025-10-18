-- ============================================
-- DESCOBRIR ESTRUTURA DA TABELA FUNCIONARIOS
-- ============================================

-- 1. Ver todas as colunas da tabela funcionarios
SELECT 
    column_name, 
    data_type, 
    column_default,
    is_nullable,
    character_maximum_length
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND table_name = 'funcionarios' 
ORDER BY ordinal_position;

-- 2. Ver relacionamento com auth.users (se existir)
SELECT 
    f.id,
    f.nome,
    f.email,
    f.status,
    f.tipo_admin,
    f.empresa_id
FROM funcionarios f
WHERE f.tipo_admin = 'admin_empresa'
LIMIT 5;

-- 3. Ver como identificar o admin (qual coluna usar?)
-- Opções possíveis:
-- a) Por email (se existir coluna email e bater com auth.users)
-- b) Por empresa_id (se admin for criado junto com empresa)
-- c) Por outra coluna (descobrir qual)

SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND table_name = 'funcionarios'
  AND column_name LIKE '%user%'
     OR column_name LIKE '%auth%'
     OR column_name LIKE '%email%';

-- ============================================
-- RESULTADO: Execute este script para descobrir
-- como identificar o admin na tabela funcionarios
-- ============================================
