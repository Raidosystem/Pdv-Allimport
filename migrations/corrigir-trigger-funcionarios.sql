-- ✅ CORRIGIR TRIGGER DE CRIAÇÃO AUTOMÁTICA DE FUNCIONÁRIOS

-- 1. Recriar a trigger function corrigida
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Inserir na user_approvals quando um novo usuário for criado
  INSERT INTO public.user_approvals (
    user_id,
    email,
    full_name,
    company_name,
    status,
    user_role,
    parent_user_id,
    created_by,
    approved_at,
    approved_by
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Usuário'),
    COALESCE(NEW.raw_user_meta_data->>'company_name', 'Empresa'),
    CASE 
      WHEN NEW.raw_user_meta_data->>'role' = 'employee' THEN 'approved'
      ELSE 'pending'
    END,
    COALESCE(NEW.raw_user_meta_data->>'role', 'owner'),
    CASE 
      WHEN NEW.raw_user_meta_data->>'parent_user_id' IS NOT NULL 
      THEN (NEW.raw_user_meta_data->>'parent_user_id')::uuid
      ELSE NULL
    END,
    CASE 
      WHEN NEW.raw_user_meta_data->>'parent_user_id' IS NOT NULL 
      THEN (NEW.raw_user_meta_data->>'parent_user_id')::uuid
      ELSE NULL
    END,
    CASE 
      WHEN NEW.raw_user_meta_data->>'role' = 'employee' THEN NOW()
      ELSE NULL
    END,
    CASE 
      WHEN NEW.raw_user_meta_data->>'role' = 'employee' 
      AND NEW.raw_user_meta_data->>'parent_user_id' IS NOT NULL 
      THEN (NEW.raw_user_meta_data->>'parent_user_id')::uuid
      ELSE NULL
    END
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Recriar a trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 3. Testar com um usuário de teste
-- (Execute isso após rodar o script acima)
/*
SELECT auth.sign_up(
  'teste-funcionario@exemplo.com',
  '123456',
  json_build_object(
    'full_name', 'Funcionário Teste',
    'company_name', 'Assistencia All-import',
    'role', 'employee',
    'parent_user_id', 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  )
);
*/

-- 4. Verificar se funcionou
-- SELECT * FROM user_approvals WHERE email = 'teste-funcionario@exemplo.com';
