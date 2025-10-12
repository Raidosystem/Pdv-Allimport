# 📧 GUIA COMPLETO - CONFIGURAR RESEND PARA ENVIAR EMAILS

## ✅ O QUE VOCÊ JÁ TEM

- ✅ Conta no Resend criada
- ✅ API Key: `re_HVHmZts1_JdnYg9mqspzRPCcahN5gA8oz`
- ✅ Código implementado no projeto
- ✅ Pacote `resend` instalado

---

## 🔧 CONFIGURAÇÃO NO VERCEL (PRODUÇÃO)

### Passo 1: Acessar Vercel Dashboard

1. Acesse: https://vercel.com
2. Entre na sua conta
3. Clique no projeto: **pdv-allimport**

### Passo 2: Adicionar Variáveis de Ambiente

1. Vá em: **Settings** → **Environment Variables**
2. Adicione as seguintes variáveis:

```
Nome: VITE_RESEND_API_KEY
Valor: re_HVHmZts1_JdnYg9mqspzRPCcahN5gA8oz
Environment: Production, Preview, Development
```

```
Nome: VITE_FROM_EMAIL
Valor: onboarding@resend.dev
Environment: Production, Preview, Development
```

### Passo 3: Salvar e Redesenhar

1. Clique em **Save**
2. Vá em **Deployments**
3. Clique nos **três pontos** no último deploy
4. Clique em **Redeploy**
5. Aguarde o deploy finalizar

---

## 🏠 CONFIGURAÇÃO LOCAL (DESENVOLVIMENTO)

### Arquivo `.env.local`

Verifique se o arquivo `.env.local` tem essas linhas:

```bash
# === RESEND (ENVIO DE EMAILS) ===
VITE_RESEND_API_KEY=re_HVHmZts1_JdnYg9mqspzRPCcahN5gA8oz
VITE_FROM_EMAIL=onboarding@resend.dev
```

---

## 📨 DOMÍNIO PRÓPRIO (OPCIONAL - RECOMENDADO)

### Por que configurar domínio próprio?

- ✅ Emails mais profissionais: `noreply@allimport.com.br`
- ✅ Maior taxa de entrega
- ✅ Melhor reputação do sender

### Como configurar:

#### Passo 1: Adicionar Domínio no Resend

1. Acesse: https://resend.com/domains
2. Clique em: **Add Domain**
3. Digite: `allimport.com.br`
4. Clique em: **Add**

#### Passo 2: Configurar DNS

O Resend vai te dar 3 registros DNS. Você precisa adicionar eles no seu provedor de domínio (Registro.br, Hostinger, GoDaddy, etc).

**Exemplo dos registros:**

```
Tipo: TXT
Nome: resend._domainkey
Valor: p=MIGfMA0GCSqGSIb3DQEBAQUAA4GN...
TTL: 3600

Tipo: TXT  
Nome: @
Valor: v=spf1 include:_spf.resend.com ~all
TTL: 3600

Tipo: CNAME
Nome: resend
Valor: feedback.resend.com
TTL: 3600
```

#### Passo 3: Verificar Domínio

1. Aguarde 5-10 minutos (propagação DNS)
2. No Resend, clique em: **Verify DNS Records**
3. Se tudo estiver OK: ✅ **Verified**

#### Passo 4: Atualizar Email no Projeto

Depois que o domínio estiver verificado, atualize o `.env.local`:

```bash
VITE_FROM_EMAIL=noreply@allimport.com.br
```

E também no Vercel (Settings → Environment Variables).

---

## 🧪 TESTAR SE ESTÁ FUNCIONANDO

### Teste 1: Local (Desenvolvimento)

```bash
# Iniciar servidor local
npm run dev

# Abrir: http://localhost:5174
# Fazer cadastro
# Verificar console: deve aparecer "✅ Email enviado via Resend!"
```

### Teste 2: Produção (Vercel)

```bash
# Fazer deploy
npm run deploy

# Acessar URL de produção
# Fazer cadastro
# Verificar email (caixa de entrada ou SPAM)
```

---

## 🔍 VERIFICAR LOGS DE EMAIL

### No Resend Dashboard:

1. Acesse: https://resend.com/emails
2. Veja todos os emails enviados
3. Status:
   - ✅ **Delivered**: Email entregue
   - 🟡 **Sent**: Email enviado (aguardando entrega)
   - ❌ **Failed**: Email falhou

---

## ⚠️ PROBLEMAS COMUNS

### Problema 1: "Missing API key"

**Solução:**
- Verifique se `VITE_RESEND_API_KEY` está no Vercel
- Redesenhar (Redeploy) o projeto
- Limpar cache do navegador (Ctrl+Shift+R)

### Problema 2: Email não chega

**Solução:**
- Verificar pasta de SPAM
- Verificar logs no Resend Dashboard
- Se usar domínio próprio, verificar se DNS está correto

### Problema 3: "Domain not verified"

**Solução:**
- Aguardar propagação DNS (até 24h)
- Verificar registros DNS no provedor
- Por enquanto, usar: `onboarding@resend.dev`

---

## 📊 LIMITES DO RESEND (Plano Gratuito)

- ✅ **3.000 emails/mês** grátis
- ✅ **1 domínio verificado**
- ✅ **API completa**
- ✅ **Logs e analytics**

---

## 🚀 CHECKLIST COMPLETO

### Para funcionar AGORA (sem domínio próprio):

- [ ] Adicionar `VITE_RESEND_API_KEY` no Vercel
- [ ] Adicionar `VITE_FROM_EMAIL=onboarding@resend.dev` no Vercel
- [ ] Redesenhar (Redeploy) no Vercel
- [ ] Testar cadastro
- [ ] Verificar email

### Para produção PROFISSIONAL (com domínio):

- [ ] Adicionar domínio no Resend
- [ ] Configurar DNS no provedor
- [ ] Aguardar verificação
- [ ] Atualizar `VITE_FROM_EMAIL=noreply@allimport.com.br`
- [ ] Redesenhar no Vercel
- [ ] Testar

---

## 🆘 PRECISA DE AJUDA?

### Links úteis:

- **Resend Dashboard**: https://resend.com/emails
- **Domínios**: https://resend.com/domains
- **API Keys**: https://resend.com/api-keys
- **Documentação**: https://resend.com/docs

### Suporte Resend:

- Email: support@resend.com
- Discord: https://discord.gg/resend

---

## 📝 RESUMO RÁPIDO

**Para testar AGORA:**

1. Vá em: https://vercel.com/radiosystem/pdv-allimport/settings/environment-variables
2. Adicione: `VITE_RESEND_API_KEY` = `re_HVHmZts1_JdnYg9mqspzRPCcahN5gA8oz`
3. Adicione: `VITE_FROM_EMAIL` = `onboarding@resend.dev`
4. Clique em **Save**
5. Vá em **Deployments** → **Redeploy**
6. Aguarde deploy finalizar
7. Teste o cadastro!

**Pronto! Emails devem começar a chegar! 📧✨**
