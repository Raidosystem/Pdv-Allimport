-- ============================================
-- LIMPAR REGISTROS ÓRFÃOS E DUPLICADOS
-- ============================================

-- Este script:
-- 1. Verifica registros órfãos (empresas sem user no auth.users)
-- 2. Deleta automaticamente registros órfãos
-- 3. Verifica duplicatas de CPF/CNPJ

-- ============================================
-- 1️⃣ VERIFICAR REGISTROS ÓRFÃOS
-- ============================================
SELECT 
  e.user_id,
  e.email,
  e.nome,
  e.cnpj,
  e.created_at,
  '❌ ÓRFÃO - Será deletado' as status
FROM empresas e
LEFT JOIN auth.users u ON u.id = e.user_id
WHERE u.id IS NULL  -- Não existe no auth.users
  AND REGEXP_REPLACE(e.cnpj, '[^0-9]', '', 'g') = '28219618809';

-- ============================================
-- 2️⃣ DELETAR REGISTROS ÓRFÃOS PARA ESTE CPF
-- ============================================
DELETE FROM empresas 
WHERE user_id IN (
  SELECT e.user_id
  FROM empresas e
  LEFT JOIN auth.users u ON u.id = e.user_id
  WHERE u.id IS NULL  -- Órfão
    AND REGEXP_REPLACE(e.cnpj, '[^0-9]', '', 'g') = '28219618809'
);

-- ============================================
-- 3️⃣ VERIFICAR SE LIMPOU
-- ============================================
SELECT 
  COUNT(*) as total_registros,
  'Registros restantes com este CPF' as descricao
FROM empresas
WHERE REGEXP_REPLACE(cnpj, '[^0-9]', '', 'g') = '28219618809';

-- ============================================
-- 4️⃣ LIMPAR TAMBÉM POR EMAIL (se houver)
-- ============================================
DELETE FROM empresas 
WHERE LOWER(TRIM(email)) = LOWER('cris-ramos30@hotmail.com')
  AND user_id NOT IN (SELECT id FROM auth.users);

-- ============================================
-- 5️⃣ VERIFICAÇÃO FINAL
-- ============================================
SELECT 
  validate_document_uniqueness('28219618809') as validacao_cpf;

-- Deve retornar: {"valid": true, "document_type": "CPF", "message": "CPF disponível para cadastro"}

-- ============================================
-- 6️⃣ LIMPAR TODOS OS REGISTROS ÓRFÃOS DO SISTEMA (OPCIONAL)
-- ============================================
-- Descomente para limpar TODOS os registros órfãos (não só este CPF)

-- SELECT COUNT(*) as total_orfaos FROM empresas e
-- LEFT JOIN auth.users u ON u.id = e.user_id
-- WHERE u.id IS NULL;

-- DELETE FROM empresas 
-- WHERE user_id NOT IN (SELECT id FROM auth.users);
