-- ============================================
-- VERIFICAR E CORRIGIR TRIGGER DE SIGNUP
-- Erro: "Database error saving new user"
-- ============================================

-- 1️⃣ Verificar quais triggers existem na tabela auth.users
SELECT 
  trigger_name,
  event_manipulation,
  action_statement,
  action_timing
FROM information_schema.triggers
WHERE event_object_table = 'users'
  AND event_object_schema = 'auth'
ORDER BY trigger_name;

-- 2️⃣ Verificar funções relacionadas a signup
SELECT 
  routine_name,
  routine_type,
  routine_definition
FROM information_schema.routines
WHERE routine_name LIKE '%signup%'
   OR routine_name LIKE '%user%'
   OR routine_name LIKE '%empresa%'
ORDER BY routine_name;

-- 3️⃣ DESABILITAR TEMPORARIAMENTE triggers problemáticos
-- (Descomente apenas se souber qual trigger está causando problema)

-- DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
-- DROP TRIGGER IF EXISTS handle_new_user ON auth.users;

-- 4️⃣ Verificar logs de erro do Supabase
-- Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/logs/postgres-logs

-- 5️⃣ SOLUÇÃO TEMPORÁRIA: Criar função handle_new_user simplificada
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Apenas criar registro na tabela empresas
  INSERT INTO public.empresas (
    user_id,
    nome,
    razao_social,
    cnpj,
    email,
    telefone,
    cep,
    logradouro,
    numero,
    complemento,
    bairro,
    cidade,
    estado,
    uf,
    tipo_conta,
    data_cadastro,
    data_fim_teste
  ) VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'company_name', 'Empresa'),
    COALESCE(NEW.raw_user_meta_data->>'company_name', NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'cpf_cnpj', ''),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'whatsapp', ''),
    COALESCE(NEW.raw_user_meta_data->>'cep', ''),
    COALESCE(NEW.raw_user_meta_data->>'street', ''),
    COALESCE(NEW.raw_user_meta_data->>'number', ''),
    COALESCE(NEW.raw_user_meta_data->>'complement', ''),
    COALESCE(NEW.raw_user_meta_data->>'neighborhood', ''),
    COALESCE(NEW.raw_user_meta_data->>'city', ''),
    COALESCE(NEW.raw_user_meta_data->>'state', ''),
    COALESCE(NEW.raw_user_meta_data->>'state', ''),
    'teste_ativo',
    NOW(),
    NOW() + INTERVAL '15 days'  -- ✅ CORRIGIDO: 15 dias de teste (era 7)
  )
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Logar erro mas não bloquear signup
    RAISE WARNING 'Erro ao criar empresa: %', SQLERRM;
    RETURN NEW;
END;
$$;

-- 6️⃣ Recriar trigger (se não existir)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 7️⃣ Verificar se funcionou
SELECT 
  'Trigger recriado com sucesso' as status,
  trigger_name,
  event_manipulation,
  action_timing
FROM information_schema.triggers
WHERE event_object_table = 'users'
  AND event_object_schema = 'auth'
  AND trigger_name = 'on_auth_user_created';
