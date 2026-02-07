# 🔧 CORREÇÃO DE PROBLEMAS DE LOGIN - INSTRUÇÕES

## 📋 PROBLEMAS IDENTIFICADOS

### 1. **Row Level Security (RLS) bloqueando acesso**
   - As políticas RLS nas tabelas `subscriptions` e `user_approvals` estavam muito restritivas
   - Usuários não conseguiam acessar seus próprios dados
   - Super admin não tinha política específica para acesso total

### 2. **Usuários não registrados em user_approvals**
   - Alguns usuários existem em `auth.users` mas não em `user_approvals`
   - Isso quebra o fluxo de autenticação

### 3. **Funções RPC ausentes ou incorretas**
   - As funções que fazem bypass de RLS não existiam ou estavam mal configuradas
   - AdminDashboard depende dessas funções

### 4. **Código do LoginPage com formulário duplicado**
   - Havia dois blocos `<form>` causando confusão
   - ✅ **CORRIGIDO** automaticamente

---

## ✅ SOLUÇÕES APLICADAS

### Arquivos Modificados:
1. ✅ **LoginPage.tsx** - Formulário duplicado removido
2. ✅ **CORRIGIR_LOGIN_COMPLETO.sql** - Script SQL completo criado

---

## 🚀 COMO EXECUTAR A CORREÇÃO

### PASSO 1: Executar o SQL no Supabase

1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw
2. Vá em: **SQL Editor** (menu lateral esquerdo)
3. Clique em: **New Query**
4. Copie TODO o conteúdo do arquivo: `migrations/CORRIGIR_LOGIN_COMPLETO.sql`
5. Cole no editor SQL
6. Clique em **RUN** (ou pressione Ctrl+Enter)
7. Aguarde a conclusão (10-30 segundos)

### PASSO 2: Verificar os Resultados

Após executar o SQL, você deve ver:

```
✅ RLS habilitado em subscriptions (true)
✅ RLS habilitado em user_approvals (true)
✅ 3 políticas em subscriptions
✅ 3 políticas em user_approvals
✅ Funções RPC criadas:
   - check_subscription_status
   - get_admin_subscribers
   - get_all_empresas_admin
   - get_all_subscriptions_admin
```

### PASSO 3: Testar o Frontend

1. **No terminal**, execute:
   ```bash
   npm run dev
   ```

2. Acesse: http://localhost:5174/login

3. **Teste com diferentes usuários:**

   #### A) Super Admin (tem acesso total ao sistema):
   - Email: `novaradiosystem@outlook.com`
   - Senha: [sua senha]
   - ✅ Deve logar e acessar `/admin` sem erros

   #### B) Usuários que compraram o sistema:
   - Email: `gruporaval1001@gmail.com`
   - Email: `marcellocattani@gmail.com`
   - Email: `josefernando@grupocattanisl.com.br`
   - Email: `geraldo.silveira@gmail.com`
   - Email: `jennifer.ramos.ferreira@hotmail.com`
   - ✅ Devem logar e acessar `/dashboard` normalmente

---

## 🔍 VERIFICAÇÕES EXTRAS (SE AINDA HOUVER PROBLEMAS)

### 1. Verificar se RLS está habilitado:

```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('subscriptions', 'user_approvals');
```

**Resultado esperado:**
```
subscriptions    | true
user_approvals   | true
```

### 2. Verificar políticas RLS:

```sql
SELECT tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('subscriptions', 'user_approvals')
ORDER BY tablename, policyname;
```

**Resultado esperado:**
```
subscriptions    | admins_all_access_subscriptions
subscriptions    | users_insert_own_subscriptions
subscriptions    | users_view_own_subscriptions
user_approvals   | admins_all_access_approvals
user_approvals   | users_insert_own_approvals
user_approvals   | users_view_own_approvals
```

### 3. Verificar se usuários estão em user_approvals:

```sql
SELECT 
    u.email,
    ua.status,
    ua.user_role
FROM auth.users u
LEFT JOIN user_approvals ua ON ua.user_id = u.id
WHERE u.email = 'SEU_EMAIL_AQUI';
```

**Resultado esperado:**
- status: `approved`
- user_role: `owner` (ou `admin` para super admin)

### 4. Verificar funções RPC:

```sql
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name LIKE '%admin%'
ORDER BY routine_name;
```

**Resultado esperado:**
```
check_subscription_status
get_admin_subscribers
get_all_empresas_admin
get_all_subscriptions_admin
```

---

## 🔐 SEGURANÇA

O script garante:

✅ **RLS habilitado** - Dados isolados por usuário
✅ **Políticas corretas** - Cada usuário vê apenas seus dados
✅ **Super admin protegido** - Apenas `novaradiosystem@outlook.com` tem acesso total
✅ **Funções RPC seguras** - Usam `SECURITY DEFINER` com controle de acesso
✅ **Aprovação automática** - Usuários existentes são auto-aprovados

---

## 🆘 SE AINDA HOUVER PROBLEMAS

### Erro: "403 Forbidden" ao acessar admin
**Causa:** RLS bloqueando ou email não é super admin  
**Solução:**
1. Verifique se está logado com `novaradiosystem@outlook.com`
2. Execute novamente o SQL completo
3. Limpe o cache do navegador (Ctrl+Shift+Delete)
4. Faça logout e login novamente

### Erro: "Invalid login credentials"
**Causa:** Senha incorreta ou usuário não existe  
**Solução:**
1. Verifique a senha (case-sensitive)
2. Use "Esqueci minha senha" na tela de login
3. Verifique se o email está cadastrado:
   ```sql
   SELECT email FROM auth.users WHERE email = 'seu@email.com';
   ```

### Erro: "Email not confirmed"
**Causa:** Email não confirmado no Supabase  
**Solução:**
1. Acesse Supabase → Authentication → Users
2. Encontre o usuário
3. Clique nos "..." → "Confirm email"
4. Tente logar novamente

### Dados não aparecem após login
**Causa:** RLS bloqueando queries  
**Solução:**
1. Abra Console do navegador (F12)
2. Veja erros no console
3. Se houver erro 403, execute o SQL novamente
4. Verifique se as políticas estão corretas

---

## 📞 SUPORTE

Se os problemas persistirem, forneça:
1. Screenshot do erro
2. Email do usuário tentando logar
3. Resultado da query:
   ```sql
   SELECT * FROM user_approvals WHERE email = 'seu@email.com';
   ```
4. Console do navegador (F12 → Console)

---

## ✅ CHECKLIST FINAL

- [ ] SQL executado sem erros no Supabase
- [ ] RLS habilitado em subscriptions e user_approvals
- [ ] 6 políticas criadas (3 em cada tabela)
- [ ] 4 funções RPC criadas
- [ ] Super admin consegue acessar `/admin`
- [ ] Usuários normais conseguem acessar `/dashboard`
- [ ] LoginPage sem erros visuais (formulário único)
- [ ] Cache do navegador limpo

---

**🎉 Sistema pronto para uso!**
