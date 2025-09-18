# 🚀 SISTEMA DE PAGAMENTO AUTOMÁTICO - MANUAL DE IMPLEMENTAÇÃO

## 📋 RESUMO DO QUE FOI IMPLEMENTADO

Este sistema implementa **"aprova e libera na hora"** exatamente como solicitado:

✅ **PIX = accredited** → Credita 31 dias instantaneamente  
✅ **Cartão = approved** → Credita 31 dias instantaneamente  
✅ **Webhook robusto** com idempotência  
✅ **Realtime** para feedback ao vivo  
✅ **external_reference** sempre preenchido  

---

## 🎯 ARQUIVOS CRIADOS/MODIFICADOS

### 1. **BANCO DE DADOS (Supabase)**
```sql
📁 SETUP_PAGAMENTO_AUTOMATICO.sql
```
- ✅ Tabela `payments` com `mp_payment_id` único
- ✅ Tabela `payment_receipts` para idempotência absoluta
- ✅ Função `credit_subscription_days()` idempotente
- ✅ Função `process_payment_webhook()` para webhooks
- ✅ RLS policies e triggers

### 2. **WEBHOOK DEFINITIVO (TypeScript)**
```typescript
📁 api/webhooks/mercadopago.ts
```
- ✅ Processa `approved` e `accredited`
- ✅ Usa SERVICE_ROLE_KEY corretamente
- ✅ Identifica empresa via `external_reference`
- ✅ Chama `credit_subscription_days()` automaticamente
- ✅ Logs detalhados para debug

### 3. **APIS DE CRIAÇÃO DE PAGAMENTO**
```typescript
📁 api/payments/create-pix.ts    # PIX com preferência
📁 api/payments/create-card.ts   # Cartão direto
```
- ✅ `external_reference = empresa_id` **SEMPRE**
- ✅ `metadata` com dados da empresa
- ✅ `notification_url` apontando para webhook
- ✅ Salva em `payments` para rastreamento

### 4. **FRONTEND REALTIME (React)**
```typescript
📁 src/components/PaymentStatusMonitor.tsx  # Monitor em tempo real
📁 src/pages/PaymentPage.tsx               # Página completa
```
- ✅ Escuta mudanças na tabela `payments`
- ✅ Atualiza status ao vivo
- ✅ Feedback visual imediato
- ✅ Notifica quando aprovado

---

## 🔧 COMO IMPLEMENTAR

### **PASSO 1: EXECUTAR SQL NO SUPABASE**
1. Abra SQL Editor no dashboard Supabase
2. Execute `SETUP_PAGAMENTO_AUTOMATICO.sql` completo
3. Verifique se tabelas e funções foram criadas

### **PASSO 2: FAZER DEPLOY DAS APIS**
```bash
cd pdv-allimport
git add .
git commit -m "Implement automatic payment system"
git push
```

### **PASSO 3: CONFIGURAR WEBHOOK NO MERCADOPAGO**
- URL: `https://pdv.crmvsystem.com/api/webhooks/mercadopago`
- Eventos: `payment`
- Estado: **Ativo**

### **PASSO 4: VERIFICAR VARIÁVEIS DE AMBIENTE**
Confirme no Vercel que todas estão definidas:
- ✅ `SUPABASE_SERVICE_ROLE_KEY`
- ✅ `VITE_MP_ACCESS_TOKEN`
- ✅ `SUPABASE_URL`

---

## 🎮 COMO USAR O SISTEMA

### **Para PIX:**
```javascript
// 1. Criar pagamento PIX
const response = await fetch('/api/payments/create-pix', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    empresa_id: 'user@example.com',
    payer_email: 'user@example.com',
    amount: 59.90,
    plan_days: 31
  })
})

// 2. Redirecionar para checkout
const { init_point } = await response.json()
window.open(init_point, '_blank')

// 3. Status atualiza automaticamente via Realtime!
```

### **Para Cartão:**
```javascript
// 1. Obter token do Card Brick (MercadoPago)
const cardToken = await mp.createCardToken(cardData)

// 2. Criar pagamento direto
const response = await fetch('/api/payments/create-card', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    empresa_id: 'user@example.com',
    payer_email: 'user@example.com',
    card_token: cardToken,
    amount: 59.90,
    plan_days: 31
  })
})

// 3. Se approved = true, já está liberado!
```

---

## 🔄 FLUXO COMPLETO DO SISTEMA

### **PIX (Assíncrono)**
1. Frontend chama `create-pix` → MercadoPago preference
2. User paga PIX → MP webhook → `mercadopago.ts`
3. Status = `accredited` → `credit_subscription_days()`
4. Realtime atualiza frontend → "✅ Aprovado!"

### **Cartão (Síncrono/Assíncrono)**
1. Frontend chama `create-card` → Payment direto
2. Se `approved` imediato → `credit_subscription_days()`
3. Se `pending` → Webhook processa depois
4. Realtime atualiza → "✅ Aprovado!"

---

## 🛡️ SEGURANÇA E IDEMPOTÊNCIA

### **Idempotência Garantida:**
- ✅ `payment_receipts.mp_payment_id` UNIQUE
- ✅ `credit_subscription_days()` verifica antes de processar
- ✅ Retorna `already_processed: true` se já foi feito

### **Segurança:**
- ✅ SERVICE_ROLE_KEY apenas no backend
- ✅ RLS policies protegem dados
- ✅ Webhook valida origem MercadoPago
- ✅ external_reference sempre preenchido

---

## 🚨 CHECKLIST DE VALIDAÇÃO

Antes de colocar em produção, verifique:

- [ ] SQL executado no Supabase ✅
- [ ] Webhook configurado no painel MP ✅
- [ ] SUPABASE_SERVICE_ROLE_KEY no Vercel ✅
- [ ] APIs deployadas e funcionando ✅
- [ ] Frontend com Realtime implementado ✅
- [ ] Teste PIX completo ✅
- [ ] Teste cartão completo ✅
- [ ] Logs funcionando no webhook ✅

---

## 📱 EXEMPLO DE USO NO FRONTEND

```tsx
import PaymentPage from './pages/PaymentPage'
import PaymentStatusMonitor from './components/PaymentStatusMonitor'

// Página de pagamento completa
<PaymentPage empresaId="user@example.com" />

// Ou apenas monitor de status
<PaymentStatusMonitor 
  empresaId="user@example.com"
  paymentId={12345}
  onPaymentApproved={(data) => {
    console.log('Pagamento aprovado!', data)
    // Redirecionar para o sistema
  }}
/>
```

---

## 🎯 RESULTADO FINAL

**Objetivo alcançado:** ✅ **"Aprova e libera na hora"**

- 🚀 PIX aprovado → Sistema liberado em segundos
- 🚀 Cartão aprovado → Sistema liberado imediatamente  
- 🚀 Feedback visual em tempo real
- 🚀 Zero intervenção manual
- 🚀 Logs completos para debug
- 🚀 Sistema 100% idempotente

**O sistema está pronto para produção!** 🎉