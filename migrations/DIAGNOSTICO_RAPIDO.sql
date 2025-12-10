-- ============================================
-- DIAGNÓSTICO RÁPIDO - ERRO 406
-- ============================================
-- Execute este script para descobrir o problema

-- 1. SEU USER ID ATUAL
SELECT auth.uid() as meu_user_id;

-- 2. VERIFICAR SE EXISTE EMPRESA
SELECT 
  id,
  nome,
  user_id
FROM empresas
WHERE user_id = auth.uid();

-- 3. VERIFICAR TODAS AS EMPRESAS (para ver se o problema é RLS)
SELECT 
  COUNT(*) as total_empresas
FROM empresas;

-- 4. VERIFICAR SE RLS ESTÁ ATIVO
SELECT 
  tablename,
  rowsecurity as rls_ativo
FROM pg_tables 
WHERE tablename = 'empresas';

-- 5. VERIFICAR POLÍTICAS
SELECT 
  policyname,
  cmd,
  permissive,
  CASE 
    WHEN qual IS NOT NULL THEN 'Tem restrição'
    ELSE 'Sem restrição'
  END as tem_restricao
FROM pg_policies 
WHERE tablename = 'empresas';

-- 6. SE NÃO EXISTIR EMPRESA, CRIAR AGORA
INSERT INTO empresas (
  user_id,
  nome,
  cnpj,
  telefone,
  email,
  endereco,
  cidade,
  estado,
  cep
)
SELECT
  auth.uid(),
  'Assistência All-Import',
  '00.000.000/0000-00',
  '(11) 99999-9999',
  'contato@allimport.com.br',
  'Rua Exemplo, 123',
  'São Paulo',
  'SP',
  '00000-000'
WHERE NOT EXISTS (
  SELECT 1 FROM empresas WHERE user_id = auth.uid()
);

-- 7. VERIFICAR SE FOI CRIADA
SELECT 
  id,
  nome,
  user_id,
  created_at
FROM empresas
WHERE user_id = auth.uid();

-- 8. VERIFICAR SUBSCRIPTION
SELECT 
  id,
  user_id,
  plan_type,
  status,
  subscription_end_date
FROM subscriptions
WHERE user_id = auth.uid();

-- 9. SE NÃO EXISTIR SUBSCRIPTION, CRIAR
INSERT INTO subscriptions (
  user_id,
  plan_type,
  status,
  subscription_start_date,
  subscription_end_date
)
SELECT
  auth.uid(),
  'yearly',
  'active',
  NOW(),
  NOW() + INTERVAL '1 year'
WHERE NOT EXISTS (
  SELECT 1 FROM subscriptions WHERE user_id = auth.uid()
);

-- 10. VERIFICAR RESULTADO FINAL
SELECT 
  e.nome as empresa_nome,
  s.plan_type as plano,
  s.status as status,
  s.subscription_end_date as validade
FROM empresas e
LEFT JOIN subscriptions s ON s.user_id = e.user_id
WHERE e.user_id = auth.uid();
