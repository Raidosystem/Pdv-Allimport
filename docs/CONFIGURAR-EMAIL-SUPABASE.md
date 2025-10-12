# 📧 CONFIGURAR ENVIO DE EMAIL NO SUPABASE

## Opção 1: Email Integrado do Supabase (RECOMENDADO PARA INÍCIO)

### Vantagens:
- ✅ Já está configurado
- ✅ Funciona imediatamente
- ✅ Grátis
- ⚠️ Limitado a 4 emails/hora em desenvolvimento

### Como Usar:

O Supabase já envia emails automaticamente quando você cria um usuário. Mas para nosso caso (código de verificação customizado), vamos usar **Email Templates**.

#### Passo 1: Configurar Template de Email

1. Acesse: https://kmcaaqetxtwkdcczdomw.supabase.co
2. Vá em: **Authentication** → **Email Templates**
3. Selecione: **Magic Link** (ou crie um template customizado)
4. Edite o template para incluir o código:

```html
<h2>Código de Verificação - Allimport</h2>
<p>Seu código de verificação é:</p>
<h1 style="font-size: 32px; letter-spacing: 5px;">{{ .Token }}</h1>
<p>Este código expira em 10 minutos.</p>
```

#### Passo 2: Limitações em Desenvolvimento

- **4 emails por hora** (limite do Supabase grátis)
- Para produção, configure um serviço de email profissional

---

## Opção 2: Resend (RECOMENDADO PARA PRODUÇÃO) 🚀

### Vantagens:
- ✅ 3.000 emails grátis/mês
- ✅ Templates profissionais
- ✅ Rastreamento de entregas
- ✅ API simples

### Configuração:

#### Passo 1: Criar Conta no Resend

1. Acesse: https://resend.com
2. Crie uma conta (grátis)
3. Vá em: **API Keys**
4. Copie sua chave: `re_xxxxxxxxxxxx`

#### Passo 2: Adicionar Variável de Ambiente

Crie arquivo `.env.local`:

```env
VITE_RESEND_API_KEY=re_xxxxxxxxxxxx
VITE_FROM_EMAIL=noreply@seudominio.com
```

#### Passo 3: Instalar Dependência

```bash
npm install resend
```

#### Passo 4: Atualizar emailService.ts

Descomente o código do Resend no final do arquivo `src/services/emailService.ts`.

---

## Opção 3: SendGrid

### Vantagens:
- ✅ 100 emails grátis/dia
- ✅ Muito confiável
- ✅ Dashboard completo

### Configuração:

1. Acesse: https://sendgrid.com
2. Crie conta e obtenha API Key
3. Instale: `npm install @sendgrid/mail`
4. Configure no `.env.local`:

```env
VITE_SENDGRID_API_KEY=SG.xxxxxxxxxxxx
VITE_FROM_EMAIL=noreply@seudominio.com
```

---

## Opção 4: SMTP Personalizado

Você pode usar qualquer serviço SMTP (Gmail, Outlook, etc):

```env
VITE_SMTP_HOST=smtp.gmail.com
VITE_SMTP_PORT=587
VITE_SMTP_USER=seu@email.com
VITE_SMTP_PASS=sua_senha_app
```

**⚠️ Atenção:** Gmail tem limite de 500 emails/dia.

---

## 🎯 RECOMENDAÇÃO PARA VOCÊ

### Para Desenvolvimento (AGORA):

**Use o Email Integrado do Supabase**
- Já está funcionando
- Não precisa configurar nada
- 4 emails/hora é suficiente para testar

### Para Produção (DEPOIS):

**Use Resend**
- 3.000 emails grátis/mês
- Profissional e confiável
- Fácil de integrar

---

## 🚀 PRÓXIMOS PASSOS

### 1. Testar com Email Integrado do Supabase

Não precisa fazer nada! O sistema já vai funcionar. O código será impresso no console por enquanto.

### 2. Quando Quiser Emails Reais

Escolha Resend e siga os passos acima.

---

## ❓ FAQ

### O código vai aparecer no email automaticamente?

Por enquanto **NÃO**. O código será impresso no **console do navegador** para você testar.

Para receber no email de verdade, você precisa:
1. Integrar com Resend (recomendado)
2. Ou configurar SMTP
3. Ou usar Supabase Edge Functions

### Posso usar meu Gmail pessoal?

Sim, mas com limitações:
- Máximo 500 emails/dia
- Precisa criar "Senha de App" (não usa sua senha normal)
- Pode ser bloqueado pelo Google

### Qual é o mais barato?

Todos têm planos grátis:
- **Supabase**: 4 emails/hora (grátis)
- **Resend**: 3.000 emails/mês (grátis)
- **SendGrid**: 100 emails/dia (grátis)

---

## 📝 NOTA IMPORTANTE

O arquivo `emailService.ts` que criei está configurado para **imprimir o código no console** durante desenvolvimento.

Quando você quiser enviar emails de verdade, basta descomentar o código do Resend e configurar a API Key.

```typescript
// DESENVOLVIMENTO (atual)
console.log('Código:', code)

// PRODUÇÃO (descomentar)
await resend.emails.send({...})
```
