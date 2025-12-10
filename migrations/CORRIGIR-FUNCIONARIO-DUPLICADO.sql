-- =====================================================
-- CORRIGIR FUNCIONÁRIO DUPLICADO
-- =====================================================
-- Problema: Existem 2 registros de funcionário para o mesmo email
-- - Um com empresa_id errado (f1726fcf...)
-- - Outro com empresa_id correto (f7fdf4cf...)
-- Solução: Identificar qual usar e deletar o duplicado
-- =====================================================

-- Desabilitar triggers temporariamente
SET session_replication_role = replica;

-- =====================================================
-- 1. IDENTIFICAR OS DOIS FUNCIONÁRIOS
-- =====================================================

SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo,
  created_at,
  CASE 
    WHEN empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN '✅ CORRETO - MANTER'
    WHEN empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00' THEN '❌ ERRADO - DELETAR'
    ELSE '⚠️ OUTRO'
  END as status
FROM funcionarios 
WHERE email = 'assistenciaallimport10@gmail.com'
ORDER BY created_at DESC;

-- =====================================================
-- 2. VERIFICAR QUAL ESTÁ SENDO USADO NO localStorage
-- =====================================================

-- O ID do localStorage é: 23f89969-3c78-4b1e-8131-d98c4b81facb
-- Vamos ver qual empresa_id ele tem
SELECT 
  id,
  empresa_id,
  nome,
  CASE 
    WHEN id = '23f89969-3c78-4b1e-8131-d98c4b81facb' THEN '🔑 ESTE ESTÁ NO localStorage'
    ELSE 'Outro registro'
  END as no_localstorage
FROM funcionarios 
WHERE email = 'assistenciaallimport10@gmail.com';

-- =====================================================
-- 3. DELETAR O FUNCIONÁRIO COM EMPRESA_ID ERRADO
-- =====================================================

-- Deletar o funcionário com empresa_id errado
DELETE FROM funcionarios 
WHERE email = 'assistenciaallimport10@gmail.com'
  AND empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

-- =====================================================
-- 4. VERIFICAR QUE SOBROU APENAS UM
-- =====================================================

-- Deve retornar apenas 1 funcionário com empresa_id correto
SELECT 
  id,
  empresa_id,
  nome,
  email,
  tipo_admin,
  ativo,
  '✅ ÚNICO FUNCIONÁRIO RESTANTE' as status
FROM funcionarios 
WHERE email = 'assistenciaallimport10@gmail.com';

-- =====================================================
-- 5. VERIFICAR CLIENTES VISÍVEIS
-- =====================================================

SELECT 
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN telefone != '' THEN 1 END) as com_telefone,
  COUNT(CASE WHEN cpf_cnpj != '' THEN 1 END) as com_cpf_cnpj
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND ativo = true;

-- Reabilitar triggers
SET session_replication_role = DEFAULT;

-- =====================================================
-- APÓS EXECUTAR ESTE SQL:
-- =====================================================
-- 1. LIMPAR localStorage da aplicação:
--    - Abrir DevTools (F12)
--    - Console tab
--    - Executar: localStorage.clear()
--    
-- 2. FAZER LOGOUT e LOGIN novamente
--
-- 3. Sistema vai buscar o funcionário correto automaticamente
--
-- 4. Clientes deverão aparecer (138 com telefones e CPF)
-- =====================================================
