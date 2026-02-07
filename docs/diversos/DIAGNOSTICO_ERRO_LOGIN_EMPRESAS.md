# 🔍 DIAGNÓSTICO: Erro de Login para Clientes/Donos de Empresa

**Data:** 07/01/2026  
**Problema:** Alguns clientes que compraram o sistema estão recebendo erro de senha ao fazer login

---

## 🎯 IDENTIFICAÇÃO DO PROBLEMA

### ❌ O QUE NÃO É
- ✅ Não é problema no login local de funcionários
- ✅ Não é problema na função `validar_senha_local`
- ✅ Não é problema no login de funcionários (LocalLoginPage)

### ⚠️ O QUE É
- **Login principal** (LoginPage.tsx)
- **Autenticação Supabase Auth** (auth.users)
- **Clientes/Donos** que compraram o sistema
- Erro: "Invalid login credentials" ou "Email ou senha incorretos"

---

## 🔍 POSSÍVEIS CAUSAS

### 1. Problema com Configuração do Supabase

#### A) Site URL com barra no final
```
❌ ERRADO: https://pdv.gruporaval.com.br/
✅ CORRETO: https://pdv.gruporaval.com.br
```

**Como verificar:**
1. Acessar Supabase Dashboard
2. Authentication > URL Configuration
3. Verificar o campo **Site URL**

#### B) Emails não confirmados
```sql
-- Verificar usuários sem confirmação
SELECT 
    email,
    email_confirmed_at,
    created_at,
    last_sign_in_at
FROM auth.users
WHERE email_confirmed_at IS NULL
ORDER BY created_at DESC;
```

**Solução rápida:**
```sql
-- Confirmar todos os emails pendentes
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;
```

---

### 2. Problema com Senhas Alteradas/Resetadas

#### Verificar se senhas foram modificadas por trigger ou migration:
```sql
-- Ver logs de modificações recentes em auth.users
SELECT 
    email,
    encrypted_password,
    updated_at,
    last_sign_in_at
FROM auth.users
ORDER BY updated_at DESC
LIMIT 20;
```

**⚠️ IMPORTANTE:** Nunca deve haver migrations modificando `encrypted_password` diretamente!

---

### 3. Problema com Sessões Antigas/Corrompidas

```sql
-- Limpar sessões antigas (SEGURO)
DELETE FROM auth.sessions 
WHERE created_at < NOW() - INTERVAL '7 days';

DELETE FROM auth.refresh_tokens
WHERE created_at < NOW() - INTERVAL '7 days';
```

---

### 4. Problema com RLS em auth.users

**⚠️ CRÍTICO:** Policies RLS NÃO devem estar habilitadas em `auth.users`

```sql
-- Verificar se RLS está habilitado (NÃO DEVE ESTAR!)
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'auth' 
  AND tablename = 'users';
```

Se `rowsecurity = true`, **DESABILITAR IMEDIATAMENTE**:
```sql
-- DESABILITAR RLS em auth.users (crítico!)
ALTER TABLE auth.users DISABLE ROW LEVEL SECURITY;
```

---

## 🧪 TESTES DE DIAGNÓSTICO

### Teste 1: Verificar se problema é generalizado ou específico
```sql
-- Listar todos os usuários e última tentativa de login
SELECT 
    email,
    CASE 
        WHEN email_confirmed_at IS NULL THEN '❌ Email não confirmado'
        WHEN last_sign_in_at IS NULL THEN '⚠️ Nunca fez login'
        WHEN last_sign_in_at < NOW() - INTERVAL '30 days' THEN '⏰ Login antigo (30+ dias)'
        ELSE '✅ Login recente'
    END as status,
    created_at,
    last_sign_in_at,
    email_confirmed_at
FROM auth.users
ORDER BY created_at DESC;
```

---

### Teste 2: Testar login via SQL (simular autenticação)
```sql
-- Testar se usuário existe e está ativo
SELECT 
    id,
    email,
    email_confirmed_at,
    banned_until,
    CASE 
        WHEN email_confirmed_at IS NULL THEN 'Email não confirmado'
        WHEN banned_until IS NOT NULL AND banned_until > NOW() THEN 'Usuário banido'
        ELSE 'Usuário OK'
    END as status_autenticacao
FROM auth.users
WHERE email = 'email_do_cliente@example.com'; -- SUBSTITUIR
```

---

### Teste 3: Verificar tabela empresas (correlação)
```sql
-- Verificar se empresa existe para o usuário
SELECT 
    u.email as email_auth,
    e.id as empresa_id,
    e.nome_fantasia,
    e.email as email_empresa,
    e.created_at,
    ua.status as status_aprovacao
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
LEFT JOIN user_approvals ua ON ua.user_id = u.id
WHERE u.email = 'email_do_cliente@example.com' -- SUBSTITUIR
ORDER BY u.created_at DESC;
```

---

## 🔧 SOLUÇÕES RÁPIDAS

### Solução 1: Resetar senha do cliente (mais seguro)
```sql
-- Forçar reset de senha
-- Executar e pedir para o cliente clicar no link que chegará no email
SELECT 
    email,
    'Executar no frontend: supabase.auth.resetPasswordForEmail("' || email || '")' as comando
FROM auth.users
WHERE email = 'email_do_cliente@example.com'; -- SUBSTITUIR
```

**No código do sistema (Admin):**
```typescript
// Enviar email de reset de senha
const { error } = await supabase.auth.resetPasswordForEmail(
  'email_do_cliente@example.com',
  {
    redirectTo: `${window.location.origin}/reset-password`
  }
)
```

---

### Solução 2: Confirmar email manualmente
```sql
-- Confirmar email de um cliente específico
UPDATE auth.users 
SET 
    email_confirmed_at = NOW(),
    confirmation_sent_at = NOW()
WHERE email = 'email_do_cliente@example.com' -- SUBSTITUIR
  AND email_confirmed_at IS NULL;
```

---

### Solução 3: Criar usuário de emergência (caso extremo)
```typescript
// Usar no Admin Dashboard - código Node.js
const { createClient } = require('@supabase/supabase-js')

const supabaseAdmin = createClient(
  'https://[PROJECT_REF].supabase.co',
  '[SERVICE_ROLE_KEY]', // Usar SERVICE ROLE KEY!
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
)

// Criar usuário com email confirmado
const { data, error } = await supabaseAdmin.auth.admin.createUser({
  email: 'email_do_cliente@example.com',
  password: 'SenhaTemporaria@123',
  email_confirm: true // Confirma email automaticamente
})
```

---

## 📋 CHECKLIST DE DIAGNÓSTICO

Execute na ordem:

- [ ] **1. Verificar Site URL no Supabase** (sem barra no final)
- [ ] **2. Verificar RLS em auth.users** (deve estar DESABILITADO)
- [ ] **3. Verificar emails não confirmados** (confirmar se necessário)
- [ ] **4. Limpar sessões antigas** (> 7 dias)
- [ ] **5. Testar com usuário específico** (SQL queries acima)
- [ ] **6. Verificar correlação com tabela empresas**
- [ ] **7. Se necessário, resetar senha do cliente**

---

## 🚨 ERROS COMUNS A EVITAR

### ❌ NÃO FAZER:
- ❌ Modificar `encrypted_password` diretamente no banco
- ❌ Deletar usuários de `auth.users` sem necessidade
- ❌ Habilitar RLS em tabelas do schema `auth`
- ❌ Criar triggers que modifiquem `auth.users`

### ✅ FAZER:
- ✅ Usar `supabase.auth.resetPasswordForEmail()` para trocar senhas
- ✅ Confirmar emails via `UPDATE auth.users SET email_confirmed_at = NOW()`
- ✅ Limpar cache do navegador do cliente
- ✅ Testar em aba privada/anônima

---

## 📞 COMO AJUDAR O CLIENTE

### Passo 1: Confirmar o problema
```
❓ Qual mensagem de erro aparece exatamente?
   - "Email ou senha incorretos"
   - "Email not confirmed"
   - "Invalid login credentials"
   - Outro erro?

❓ O login funcionou alguma vez?
   - Nunca conseguiu logar
   - Funcionava antes e parou
   - Funciona em outro navegador/dispositivo
```

### Passo 2: Soluções imediatas
```
1️⃣ Limpar cache do navegador:
   - Chrome: Ctrl + Shift + Delete
   - Marcar: Cookies, Cache, Dados de sites

2️⃣ Testar em aba privada/anônima

3️⃣ Tentar recuperar senha:
   - Clicar em "Esqueci minha senha"
   - Verificar caixa de entrada (e SPAM)
   - Clicar no link e criar nova senha
```

### Passo 3: Suporte técnico
Se nada funcionar, executar diagnóstico completo:

```sql
-- Script de diagnóstico completo
SELECT 
    '1️⃣ VERIFICAÇÃO DO USUÁRIO' as secao,
    u.email,
    u.email_confirmed_at,
    u.last_sign_in_at,
    u.created_at,
    CASE 
        WHEN u.email_confirmed_at IS NULL THEN '❌ Email não confirmado'
        WHEN u.banned_until IS NOT NULL THEN '❌ Usuário bloqueado'
        WHEN u.last_sign_in_at IS NULL THEN '⚠️ Nunca fez login'
        ELSE '✅ Usuário OK'
    END as diagnostico
FROM auth.users u
WHERE u.email = 'email_do_cliente@example.com' -- SUBSTITUIR

UNION ALL

SELECT 
    '2️⃣ VERIFICAÇÃO DA EMPRESA' as secao,
    e.nome_fantasia,
    e.created_at::text,
    e.updated_at::text,
    CASE 
        WHEN e.id IS NULL THEN '❌ Empresa não encontrada'
        ELSE '✅ Empresa existe'
    END
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
WHERE u.email = 'email_do_cliente@example.com'; -- SUBSTITUIR
```

---

## 📚 DOCUMENTAÇÃO ADICIONAL

- [Configurar Site URL](./CORRIGIR_SITE_URL_SUPABASE.md)
- [Configurar Email SMTP](./CONFIGURAR_EMAIL_SUPABASE.md)
- [Reset de Senha](./src/modules/auth/ForgotPasswordPage.tsx)

---

## ✅ PRÓXIMOS PASSOS

1. **Identificar o cliente afetado** (email)
2. **Executar checklist de diagnóstico**
3. **Aplicar solução apropriada**
4. **Testar login**
5. **Documentar caso específico**
