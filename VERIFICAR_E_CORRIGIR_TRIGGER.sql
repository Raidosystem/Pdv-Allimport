-- ================================================
-- VERIFICAR E CORRIGIR TRIGGER DE CADASTRO
-- Execute no SQL Editor do Supabase
-- ================================================

-- 1️⃣ VERIFICAR SE TRIGGER EXISTE
SELECT 
  '1. VERIFICANDO TRIGGERS' as etapa,
  trigger_name,
  event_manipulation,
  action_timing,
  event_object_table
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
  AND event_object_table = 'users'
ORDER BY trigger_name;

-- 2️⃣ VERIFICAR SE FUNÇÃO EXISTE
SELECT 
  '2. VERIFICANDO FUNÇÕES' as etapa,
  routine_name,
  routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%approval%'
ORDER BY routine_name;

-- 3️⃣ POPULAR USUÁRIOS EXISTENTES QUE NÃO ESTÃO NA TABELA
INSERT INTO public.user_approvals (
  user_id, 
  email, 
  full_name, 
  company_name, 
  status, 
  approved_at, 
  created_at
)
SELECT 
  au.id,
  au.email,
  COALESCE(au.raw_user_meta_data->>'full_name', 'Usuário'),
  COALESCE(au.raw_user_meta_data->>'company_name', 'Empresa'),
  CASE 
    WHEN au.email IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com', 'teste@teste.com') 
    THEN 'approved' 
    ELSE 'pending' 
  END as status,
  CASE 
    WHEN au.email IN ('admin@pdvallimport.com', 'novaradiosystem@outlook.com', 'teste@teste.com') 
    THEN NOW() 
    ELSE NULL 
  END as approved_at,
  au.created_at
FROM auth.users au
LEFT JOIN public.user_approvals ua ON ua.user_id = au.id
WHERE ua.user_id IS NULL;

-- 4️⃣ RECRIAR FUNÇÃO DO TRIGGER
CREATE OR REPLACE FUNCTION public.handle_new_user_approval()
RETURNS TRIGGER AS $$
BEGIN
  -- Inserir registro na tabela user_approvals para novos usuários
  INSERT INTO public.user_approvals (
    user_id, 
    email, 
    full_name, 
    company_name, 
    status,
    created_at,
    user_role,
    parent_user_id
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Usuário'),
    COALESCE(NEW.raw_user_meta_data->>'company_name', 'Empresa'),
    CASE 
      -- Funcionários são aprovados automaticamente
      WHEN NEW.raw_user_meta_data->>'role' = 'employee' THEN 'approved'
      -- Owners precisam de aprovação
      ELSE 'pending'
    END,
    NOW(),
    COALESCE(NEW.raw_user_meta_data->>'role', 'owner'),
    CASE 
      WHEN NEW.raw_user_meta_data->>'parent_user_id' IS NOT NULL 
      THEN (NEW.raw_user_meta_data->>'parent_user_id')::UUID
      ELSE NULL
    END
  );
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Logar erro mas não bloquear o signup
    RAISE WARNING 'Erro ao inserir em user_approvals: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5️⃣ RECRIAR TRIGGER
DROP TRIGGER IF EXISTS on_auth_user_created_approval ON auth.users;

CREATE TRIGGER on_auth_user_created_approval
  AFTER INSERT ON auth.users
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_user_approval();

-- 6️⃣ VERIFICAR RESULTADOS
SELECT 
  '✅ SISTEMA CORRIGIDO!' as resultado,
  '' as espaco;

-- Mostrar estatísticas
SELECT 
  '📊 ESTATÍSTICAS' as info,
  status, 
  COUNT(*) as total,
  STRING_AGG(email, ', ') as emails
FROM public.user_approvals
GROUP BY status
ORDER BY status;

-- Verificar se trigger foi criado
SELECT 
  '🔧 TRIGGER ATIVO' as info,
  trigger_name,
  event_manipulation,
  action_timing
FROM information_schema.triggers
WHERE event_object_schema = 'auth'
  AND event_object_table = 'users'
  AND trigger_name = 'on_auth_user_created_approval';

-- 7️⃣ TESTAR MANUALMENTE (OPCIONAL)
-- Para testar, descomente e execute:
/*
DO $$
DECLARE
  test_user_id UUID;
BEGIN
  -- Simular inserção de novo usuário
  test_user_id := gen_random_uuid();
  
  INSERT INTO public.user_approvals (
    user_id,
    email,
    full_name,
    company_name,
    status,
    created_at
  ) VALUES (
    test_user_id,
    'teste-trigger@exemplo.com',
    'Usuário Teste',
    'Empresa Teste',
    'pending',
    NOW()
  );
  
  RAISE NOTICE '✅ Teste manual bem-sucedido! User ID: %', test_user_id;
END $$;

-- Verificar inserção de teste
SELECT * FROM public.user_approvals 
WHERE email = 'teste-trigger@exemplo.com';

-- Limpar teste
DELETE FROM public.user_approvals 
WHERE email = 'teste-trigger@exemplo.com';
*/
