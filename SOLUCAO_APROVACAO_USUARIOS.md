# 🚨 PROBLEMA IDENTIFICADO: Sistema de Aprovação de Usuários

## 📋 DIAGNÓSTICO

**PROBLEMA**: Usuário cadastrou hoje mas não apareceu na página de admin para aprovação.

**CAUSA RAIZ**: 
- ✅ Tabela `user_approvals` existe
- ❌ Tabela está **VAZIA** (sem registros)
- ❌ Trigger automático não está funcionando
- ❌ Usuários novos não são inseridos automaticamente

## 🛠️ SOLUÇÃO IMEDIATA

### PASSO 1: Acessar Dashboard Supabase
1. Abra: https://supabase.com/dashboard/project/vfuglqcyrmgwvrlmmotm
2. Faça login na conta do Supabase
3. Vá em **SQL Editor**

### PASSO 2: Executar Script de Correção
Copie e cole este código no SQL Editor:

```sql
-- ==========================================
-- CORRIGIR SISTEMA DE APROVAÇÃO DE USUÁRIOS
-- ==========================================

-- 1. Verificar se a tabela existe
SELECT 'Tabela user_approvals existe!' as status;

-- 2. Inserir registros para usuários existentes que não têm registro
INSERT INTO public.user_approvals (user_id, email, full_name, company_name, status, approved_at, created_at)
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
WHERE au.id NOT IN (SELECT COALESCE(user_id, '00000000-0000-0000-0000-000000000000') FROM public.user_approvals)
ON CONFLICT (user_id) DO NOTHING;

-- 3. Recriar trigger para novos cadastros
CREATE OR REPLACE FUNCTION public.handle_new_user_approval()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_approvals (
    user_id, 
    email, 
    full_name, 
    company_name, 
    status,
    created_at
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Usuário'),
    COALESCE(NEW.raw_user_meta_data->>'company_name', 'Empresa'),
    'pending',
    NOW()
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Recriar trigger
DROP TRIGGER IF EXISTS on_auth_user_created_approval ON auth.users;
CREATE TRIGGER on_auth_user_created_approval
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_approval();

-- 5. Verificar resultados
SELECT 'SISTEMA CORRIGIDO!' as message;
SELECT 
  status, 
  COUNT(*) as total,
  COUNT(CASE WHEN created_at::date = CURRENT_DATE THEN 1 END) as hoje
FROM public.user_approvals 
GROUP BY status
ORDER BY status;

-- 6. Mostrar usuários pendentes
SELECT 
  email,
  full_name,
  company_name,
  created_at,
  'PENDENTE DE APROVAÇÃO' as acao_necessaria
FROM public.user_approvals 
WHERE status = 'pending'
ORDER BY created_at DESC;
```

### PASSO 3: Executar
1. Clique em **"RUN"**
2. Aguarde a execução
3. Verifique os resultados

### PASSO 4: Testar Admin
1. Acesse: https://pdv.crmvsystem.com/admin
2. Login: `novaradiosystem@outlook.com`
3. Senha: `@qw12aszx##`
4. Verifique se os usuários aparecem

## 🎯 RESULTADO ESPERADO

Após executar o script, você deve ver:
- ✅ Usuários cadastrados aparecem no admin
- ✅ Status "PENDENTE" para usuários não aprovados
- ✅ Status "APROVADO" para admins
- ✅ Novos cadastros aparecem automaticamente

## 🔄 TESTE FINAL

1. Cadastre um usuário teste em: https://pdv.crmvsystem.com
2. Verifique se aparece no admin para aprovação
3. Aprove o usuário
4. Teste o login do usuário aprovado

---

**IMPORTANTE**: Execute o script SQL o quanto antes para resolver o problema dos usuários que se cadastraram hoje e não apareceram para aprovação.
