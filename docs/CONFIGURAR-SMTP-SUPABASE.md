# 🔧 CONFIGURAR EMAIL NO SUPABASE - PASSO A PASSO

## ❌ ERRO ATUAL

```
AuthApiError: Error sending magic link email
```

**Causa:** O Supabase precisa de configuração de SMTP para enviar emails.

---

## ✅ SOLUÇÃO: CONFIGURAR SMTP NO SUPABASE

### Passo 1: Acessar Supabase Dashboard

1. Acesse: https://kmcaaqetxtwkdcczdomw.supabase.co
2. Faça login

### Passo 2: Ir em Settings → Authentication

1. No menu lateral, clique em: **Project Settings** (ícone de engrenagem)
2. Clique em: **Authentication**

### Passo 3: Configurar SMTP Customizado

Role até a seção: **SMTP Settings**

#### Opção A: Usar Gmail (Mais Fácil para Teste)

```
SMTP Host: smtp.gmail.com
SMTP Port: 587
SMTP Username: seu@gmail.com
SMTP Password: [Senha de App do Gmail]
Sender Email: seu@gmail.com
Sender Name: Allimport PDV
```

**Como criar Senha de App no Gmail:**
1. Acesse: https://myaccount.google.com/apppasswords
2. Crie uma senha de app
3. Use essa senha (não sua senha normal)

#### Opção B: Usar Outlook/Hotmail

```
SMTP Host: smtp-mail.outlook.com
SMTP Port: 587
SMTP Username: seu@outlook.com
SMTP Password: sua_senha
Sender Email: seu@outlook.com
Sender Name: Allimport PDV
```

#### Opção C: Usar SendGrid (Recomendado para Produção)

1. Crie conta grátis: https://sendgrid.com (100 emails/dia grátis)
2. Crie uma API Key
3. Configure:

```
SMTP Host: smtp.sendgrid.net
SMTP Port: 587
SMTP Username: apikey
SMTP Password: [Sua API Key do SendGrid]
Sender Email: noreply@allimport.com.br
Sender Name: Allimport PDV
```

### Passo 4: Testar Configuração

1. Clique em: **Save**
2. Vá em: **Authentication** → **Users**
3. Clique em: **Invite User**
4. Digite um email de teste
5. Verifique se o email chegou

---

## 🎯 CONFIGURAÇÃO RECOMENDADA (Gmail para Teste)

### 1. Criar Senha de App do Gmail

1. Vá em: https://myaccount.google.com/security
2. Ative **Verificação em duas etapas** (se ainda não tiver)
3. Vá em: https://myaccount.google.com/apppasswords
4. Selecione: **App**: Mail / **Dispositivo**: Outro (nome customizado)
5. Digite: "Supabase Allimport"
6. Copie a senha gerada (16 caracteres)

### 2. Configurar no Supabase

```
SMTP Host: smtp.gmail.com
SMTP Port: 587
SMTP Username: assistenciaallimport10@gmail.com
SMTP Password: [Senha de 16 caracteres do passo anterior]
Sender Email: assistenciaallimport10@gmail.com
Sender Name: Allimport PDV
```

### 3. Salvar e Testar

1. Clique em **Save**
2. Aguarde 1 minuto
3. Teste o cadastro no site

---

## 🚀 DEPOIS DE CONFIGURAR

### O sistema funcionará assim:

1. **Usuário se cadastra** → Preenche formulário
2. **Supabase envia email automaticamente** → Via SMTP configurado
3. **Email chega com código de 6 dígitos** → Magic Link do Supabase
4. **Usuário digita código** → Na tela de verificação
5. **Conta ativada** → Acesso liberado

---

## ⚠️ IMPORTANTE

### Rate Limiting

O Supabase tem rate limit para emails:
- **1 email por minuto** por IP
- **Emails ilimitados** no total

### Verificação de Email

Certifique-se que:
- **Confirm email**: ❌ DESABILITADO
- Vá em: **Authentication** → **Providers** → **Email**
- Desmarque: "Confirm email"

---

## 🔍 VERIFICAR SE FUNCIONOU

### No Console do Navegador (F12):

✅ **Sucesso:**
```
📧 Enviando código de verificação para: email@exemplo.com
✅ Código enviado com sucesso para: email@exemplo.com
```

❌ **Erro:**
```
❌ Erro ao enviar código: AuthApiError: Error sending magic link email
```

Se ainda aparecer erro, verifique:
1. SMTP configurado corretamente
2. Senha de App (não senha normal)
3. Porta 587 (não 465)
4. Aguarde 1-2 minutos após salvar

---

## 📧 LIMITES DOS PROVEDORES

### Gmail:
- ✅ Grátis
- ⚠️ 500 emails/dia
- ⚠️ Requer senha de app

### SendGrid:
- ✅ 100 emails/dia grátis
- ✅ Profissional
- ✅ Estatísticas completas

### Outlook:
- ✅ Grátis
- ⚠️ 300 emails/dia
- ⚠️ Pode bloquear

---

## 🆘 AINDA NÃO FUNCIONOU?

### Opção Alternativa: Usar Resend

Se o SMTP do Supabase não funcionar, podemos:
1. Voltar a usar Resend
2. Configurar API Key no Vercel
3. Enviar emails via Resend API

**Quer tentar esta opção?**

---

## 📝 CHECKLIST

Para o sistema funcionar, você precisa:

- [ ] Configurar SMTP no Supabase
- [ ] Criar senha de app (Gmail) ou API key (SendGrid)
- [ ] Salvar configurações
- [ ] Desabilitar "Confirm email"
- [ ] Aguardar 1-2 minutos
- [ ] Testar cadastro
- [ ] Verificar email recebido

---

## 🎯 RECOMENDAÇÃO

**Use Gmail com Senha de App para começar:**
1. Mais fácil de configurar
2. Funciona imediatamente
3. Grátis
4. 500 emails/dia é suficiente para teste

**Depois migre para SendGrid:**
1. Mais profissional
2. Melhor deliverability
3. Estatísticas completas
4. 100 emails/dia grátis

---

**Vou te ajudar a configurar! Me avise quando terminar o Passo 1 (criar senha de app do Gmail).**
