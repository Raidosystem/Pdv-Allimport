# 🚨 CONFIGURAR REDIRECT URLs NO SUPABASE

## Problema
O link de recuperação de senha está redirecionando para a página inicial (`/`) ao invés de `/reset-password`.

## Causa
As URLs de redirecionamento não estão configuradas no Supabase.

## Solução

### 1. Acesse o Dashboard do Supabase
- https://supabase.com/dashboard
- Selecione seu projeto: **kmcaaqetxtwkdcczdomw**

### 2. Configure as Redirect URLs

1. No menu lateral, clique em **Authentication** (🔐)
2. Clique em **URL Configuration**
3. Na seção **Redirect URLs**, adicione estas URLs:

```
https://pdv.gruporaval.com.br/reset-password
https://www.pdv.gruporaval.com.br/reset-password
https://pdv.gruporaval.com.br/confirm-email
https://www.pdv.gruporaval.com.br/confirm-email
http://localhost:5174/reset-password
http://localhost:5174/confirm-email
```

4. Clique em **Save** (Salvar)

### 3. Configure o Site URL

Na mesma página, encontre **Site URL** e configure:

```
https://pdv.gruporaval.com.br
```

### 4. Teste

1. Vá em https://pdv.gruporaval.com.br/forgot-password
2. Digite um email cadastrado
3. Clique no link do email
4. Deve abrir `/reset-password` corretamente

## URLs que devem estar configuradas

### Redirect URLs (permitidas para redirecionamento):
- ✅ `https://pdv.gruporaval.com.br/reset-password`
- ✅ `https://www.pdv.gruporaval.com.br/reset-password`
- ✅ `https://pdv.gruporaval.com.br/confirm-email`
- ✅ `https://www.pdv.gruporaval.com.br/confirm-email`
- ✅ `http://localhost:5174/*` (desenvolvimento)

### Site URL (URL principal):
- ✅ `https://pdv.gruporaval.com.br`

## Verificação

Após configurar, faça um teste:

1. Solicite recuperação de senha
2. Verifique o link no email - deve conter `/reset-password` na URL
3. Clique no link - deve abrir a página de redefinição de senha

## Observação

Se ainda redirecionar para `/`, limpe o cache do navegador ou teste em aba anônima.
