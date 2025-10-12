# 📧 CONFIGURAR EMAIL NO SUPABASE

## ✅ SISTEMA SIMPLIFICADO - APENAS SUPABASE

Agora o sistema usa **apenas o Supabase** para enviar códigos de verificação por email. Sem Resend, sem configurações complexas!

---

## 🔧 CONFIGURAÇÃO NO SUPABASE

### Passo 1: Acessar Supabase Dashboard

1. Acesse: https://kmcaaqetxtwkdcczdomw.supabase.co
2. Faça login com sua conta

### Passo 2: Configurar Templates de Email

1. No menu lateral, clique em: **Authentication**
2. Clique em: **Email Templates**
3. Selecione: **Magic Link** (ou **Confirm signup**)

### Passo 3: Personalizar Template (Opcional)

Você pode personalizar o email que será enviado. Exemplo:

```html
<h2>Código de Verificação - Allimport</h2>

<p>Olá!</p>

<p>Seu código de verificação é:</p>

<h1 style="font-size: 32px; letter-spacing: 5px; color: #667eea;">
  {{ .Token }}
</h1>

<p><strong>Este código expira em 10 minutos.</strong></p>

<p>Se você não solicitou este código, ignore este email.</p>
```

### Passo 4: Configurar Rate Limits (Importante!)

1. Vá em: **Authentication** → **Rate Limits**
2. Ajuste conforme necessário:
   - **Email OTP**: 1 request por 60 segundos por IP
   - Isso evita spam e abuso

---

## 📊 COMO FUNCIONA

### Fluxo Completo:

1. **Usuário se cadastra** → Preenche formulário com email
2. **Sistema usa Supabase OTP** → `supabase.auth.signInWithOtp()`
3. **Supabase envia email automaticamente** → Com código de 6 dígitos
4. **Usuário recebe email** → Verifica caixa de entrada (ou spam)
5. **Usuário digita código** → Na tela de verificação
6. **Sistema verifica** → `supabase.auth.verifyOtp()`
7. **Conta ativada** → Usuário pode fazer login

---

## ⚙️ VANTAGENS DESSA SOLUÇÃO

- ✅ **Simples**: Sem dependências externas
- ✅ **Grátis**: Incluído no plano gratuito do Supabase
- ✅ **Rápido**: Email enviado em segundos
- ✅ **Seguro**: Sistema de OTP nativo do Supabase
- ✅ **Sem configuração**: Funciona out-of-the-box

---

## 📧 LIMITES DO SUPABASE (Plano Gratuito)

- **50.000 MAU** (Monthly Active Users)
- **2 GB banco de dados**
- **1 GB transferência**
- **Emails ilimitados** (com rate limiting)

---

## ⚠️ CONFIGURAÇÕES IMPORTANTES

### 1. Email Provider (Opcional - Para Produção)

Por padrão, o Supabase usa seu próprio servidor SMTP. Para produção profissional, você pode configurar um provedor customizado:

1. **Authentication** → **Providers** → **Email**
2. Configure SMTP customizado (SendGrid, AWS SES, etc)

### 2. Confirm Email

Certifique-se que está **DESABILITADO**:

1. **Authentication** → **Providers** → **Email**
2. **Confirm email**: ❌ DESABILITADO

(Porque estamos usando OTP manual, não confirmação automática)

### 3. Site URL

Configure a URL do seu site:

1. **Authentication** → **URL Configuration**
2. **Site URL**: `https://pdv-allimport.vercel.app`
3. **Redirect URLs**: `https://pdv-allimport.vercel.app/**`

---

## 🧪 TESTAR LOCALMENTE

```bash
# 1. Iniciar servidor local
npm run dev

# 2. Acessar: http://localhost:5174

# 3. Fazer cadastro

# 4. Verificar email (caixa de entrada ou spam)

# 5. Digitar código recebido

# 6. Conta ativada! ✅
```

---

## 🚀 DEPLOY

```bash
# Build e deploy
npm run deploy

# Aguardar deploy finalizar

# Testar em produção
```

---

## 🔍 VERIFICAR LOGS DE EMAIL

### No Supabase Dashboard:

1. **Authentication** → **Users**
2. Veja usuários cadastrados
3. Status de verificação

### Logs do Sistema:

1. Abra o console (F12)
2. Veja mensagens:
   - `📧 Enviando código de verificação...`
   - `✅ Código enviado com sucesso`
   - `🔍 Verificando código...`
   - `✅ Código verificado!`

---

## ❓ PROBLEMAS COMUNS

### Problema 1: Email não chega

**Soluções:**
- Verificar pasta de SPAM
- Aguardar 1-2 minutos
- Verificar rate limit (1 email por minuto)
- Tentar outro email

### Problema 2: Código inválido

**Soluções:**
- Verificar se digitou corretamente
- Código expira em 10 minutos
- Solicitar novo código

### Problema 3: "Email rate limit exceeded"

**Soluções:**
- Aguardar 60 segundos
- Não enviar múltiplos códigos seguidos

---

## 📝 RESUMO

✅ **Sistema configurado com:**
- Supabase Auth OTP
- Código de 6 dígitos
- Email automático
- Verificação manual
- Sem dependências externas

✅ **Nada mais para configurar!**

✅ **Funciona imediatamente após deploy!**

---

## 🎯 PRÓXIMOS PASSOS

1. ✅ Sistema está pronto
2. ✅ Fazer deploy
3. ✅ Testar cadastro
4. ✅ Verificar email
5. ✅ Ativar conta

**Pronto! Sistema 100% funcional com Supabase! 🚀**
