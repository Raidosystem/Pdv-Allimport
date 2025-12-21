-- ========================================
-- DIAGNÓSTICO: ERRO NA COLUNA senha
-- ========================================
-- Erro: null value in column "senha" violates not-null constraint

-- ========================================
-- 1️⃣ VERIFICAR ESTRUTURA DA TABELA
-- ========================================
SELECT 
  '🔍 ESTRUTURA login_funcionarios' as info,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'login_funcionarios'
  AND column_name IN ('senha', 'senha_hash', 'password', 'encrypted_password')
ORDER BY ordinal_position;

-- ========================================
-- 2️⃣ VERIFICAR EXTENSÃO pgcrypto
-- ========================================
SELECT 
  '🔍 EXTENSÃO pgcrypto' as info,
  extname as extensao,
  extversion as versao,
  CASE 
    WHEN extname = 'pgcrypto' THEN '✅ Instalada'
    ELSE '❌ Não encontrada'
  END as status
FROM pg_extension
WHERE extname = 'pgcrypto';

-- ========================================
-- 3️⃣ TESTAR FUNÇÃO crypt()
-- ========================================
-- Verificar se a função crypt está disponível
SELECT 
  '🧪 TESTE crypt()' as teste,
  crypt('teste123', gen_salt('bf')) as senha_encriptada,
  length(crypt('teste123', gen_salt('bf'))) as tamanho;

-- ========================================
-- 4️⃣ INSTALAR pgcrypto (SE NECESSÁRIO)
-- ========================================
-- Execute apenas se a seção 2 mostrou que não está instalada
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ========================================
-- 5️⃣ CORRIGIR FUNÇÃO cadastrar_funcionario_simples
-- ========================================
-- Atualizar para usar a coluna correta (senha_hash ou senha)

-- Primeiro, vamos ver qual coluna existe
DO $$
DECLARE
  v_coluna_senha text;
BEGIN
  -- Detectar nome da coluna
  SELECT column_name INTO v_coluna_senha
  FROM information_schema.columns
  WHERE table_name = 'login_funcionarios'
    AND column_name IN ('senha', 'senha_hash', 'password')
  LIMIT 1;

  IF v_coluna_senha IS NULL THEN
    RAISE EXCEPTION 'Coluna de senha não encontrada!';
  END IF;

  RAISE NOTICE '✅ Coluna de senha detectada: %', v_coluna_senha;
END $$;
