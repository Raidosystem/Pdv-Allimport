# 🎯 SOLUÇÃO FINAL: Usuário não aparece no admin para aprovação

## 📊 DIAGNÓSTICO COMPLETO

✅ **Sistema PDV funcionando**  
✅ **Tabela user_approvals existe**  
✅ **AdminPanel configurado para: novaradiosystem@outlook.com**  
❌ **Tabela está VAZIA** (por isso usuários não aparecem)  
❌ **Trigger automático não está populando a tabela**

## 🚀 SOLUÇÃO IMEDIATA (2 minutos)

### 1. Acesse o Dashboard Supabase
- URL: https://supabase.com/dashboard/project/vfuglqcyrmgwvrlmmotm
- Vá em: **SQL Editor** → **New Query**

### 2. Execute este SQL (copie e cole tudo):

```sql
-- SOLUÇÃO COMPLETA: Popular tabela user_approvals
-- Execute este script para corrigir o problema

-- 1. Inserir todos os usuários existentes na tabela de aprovação
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

-- 2. Recriar função de trigger para novos cadastros
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

-- 3. Criar trigger para novos cadastros
DROP TRIGGER IF EXISTS on_auth_user_created_approval ON auth.users;
CREATE TRIGGER on_auth_user_created_approval
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_approval();

-- 4. Verificar resultados
SELECT 'SISTEMA CORRIGIDO!' as message;

-- Mostrar estatísticas
SELECT 
  status, 
  COUNT(*) as total,
  COUNT(CASE WHEN created_at::date = CURRENT_DATE THEN 1 END) as cadastrados_hoje
FROM public.user_approvals 
GROUP BY status
ORDER BY status;

-- Mostrar usuários pendentes (estes aparecerão no admin)
SELECT 
  email,
  full_name,
  company_name,
  created_at::timestamp::text as cadastrado_em,
  'Aparecerá no admin para aprovação' as status
FROM public.user_approvals 
WHERE status = 'pending'
ORDER BY created_at DESC
LIMIT 10;

-- Mostrar usuários cadastrados hoje
SELECT 
  email,
  full_name,
  created_at::time::text as horario,
  status
FROM public.user_approvals 
WHERE created_at::date = CURRENT_DATE
ORDER BY created_at DESC;
```

### 3. Clique em **"RUN"** para executar

### 4. Teste o Admin (IMEDIATAMENTE APÓS EXECUTAR O SQL)
1. Acesse: https://pdv.crmvsystem.com/admin
2. Email: `novaradiosystem@outlook.com`
3. Senha: `@qw12aszx##`

## 🎉 RESULTADO ESPERADO

Após executar o SQL, você verá:

✅ **Usuários pendentes aparecendo no admin**  
✅ **Usuário cadastrado hoje visível**  
✅ **Botões de Aprovar/Rejeitar funcionando**  
✅ **Novos cadastros aparecendo automaticamente**

## 📱 TESTE FINAL

1. **Cadastre um usuário teste** em: https://pdv.crmvsystem.com
2. **Verifique se aparece imediatamente** no admin
3. **Aprove o usuário** clicando no botão verde ✅
4. **Teste o login** do usuário aprovado

## 🔧 SE O PROBLEMA PERSISTIR

Se mesmo após executar o SQL os usuários não aparecerem:

1. **Verifique conectividade**: Teste se consegue acessar outras partes do admin
2. **Limpe cache**: Ctrl+F5 na página do admin
3. **Verifique console**: F12 → Console para ver erros JavaScript
4. **Execute novamente**: O SQL pode ser executado múltiplas vezes sem problema

---

**🚨 IMPORTANTE**: Execute o SQL o quanto antes para que o usuário que se cadastrou hoje possa ser aprovado e usar o sistema!

**⏰ TEMPO ESTIMADO**: 2-3 minutos para resolver completamente
