-- =====================================================
-- 🧪 TESTE RÁPIDO - EXECUTAR AGORA NO SUPABASE
-- =====================================================

-- Verificar se a função existe
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'check_subscription_status';

-- Se retornou 0 linhas = FUNÇÃO NÃO EXISTE!
-- Neste caso, execute o arquivo: EXECUTAR_AGORA_NO_SUPABASE.sql

-- =====================================================
-- 🎯 TESTE DIRETO
-- =====================================================

-- Testar a função
SELECT check_subscription_status('cris-ramos30@hotmail.com');

-- Copie o resultado JSON e cole aqui!
-- Deve ter: "access_allowed": true

-- =====================================================
-- 🔍 VERIFICAR ESTRUTURA DO RETORNO
-- =====================================================

-- Expandir JSON para ver todos os campos
SELECT 
  jsonb_pretty(check_subscription_status('cris-ramos30@hotmail.com'));

-- =====================================================
-- ⚡ SE A FUNÇÃO NÃO EXISTE, CRIE AGORA:
-- =====================================================
-- Cole o conteúdo do arquivo:
-- CRIAR_FUNCAO_CHECK_SUBSCRIPTION_STATUS.sql
-- E execute no SQL Editor
-- =====================================================
