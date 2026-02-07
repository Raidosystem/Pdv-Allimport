# 🎯 CONFIGURAÇÃO OFICIAL - PDV ALLIMPORT

> **📍 Esta é a ÚNICA fonte de verdade para configuração do sistema**

## 🌐 Domínio e URLs

- **Produção**: https://pdv.crmvsystem.com
- **API**: https://pdv.crmvsystem.com/api
- **Webhook**: https://pdv.crmvsystem.com/api/webhooks/mercadopago

## 🔑 Variáveis de Ambiente

### Frontend (Vite)
```bash
VITE_SUPABASE_URL=https://kmcaaqetxtwkdcczdomw.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
VITE_APP_NAME=PDV Allimport
VITE_APP_URL=https://pdv.crmvsystem.com
VITE_MP_ACCESS_TOKEN=APP_USR-3807636986700595-080418-...
VITE_MP_PUBLIC_KEY=APP_USR-4a8bfb6e-0ff5-47d1-be9c-...
```

### Backend (Vercel)
```bash
SUPABASE_URL=https://kmcaaqetxtwkdcczdomw.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... (SECRETO)
MP_ACCESS_TOKEN=APP_USR-3807636986700595-080418-... (SERVIDOR)
MP_WEBHOOK_SECRET=a7ca1966224cf9b475087c98142fec03c...
```

## 🏗️ Supabase - Configuração CORS

### Auth Settings
- **Site URL**: `https://pdv.crmvsystem.com`
- **Redirect URLs**: `https://pdv.crmvsystem.com/**`

### API Settings  
- **Allowed Origins**: `https://pdv.crmvsystem.com, http://localhost:5173`

## 🔗 Vercel - Configuração

### Production Environment
- **Domain**: `pdv.crmvsystem.com`
- **Environment Variables**: Apenas as listadas acima
- **Deployment**: Automático via Git

### Preview Environment  
- **Domain**: `*.vercel.app`
- **Environment Variables**: Sandbox quando disponível

## 🎣 MercadoPago - Webhook

### Configuração
- **URL**: `https://pdv.crmvsystem.com/api/webhooks/mercadopago`
- **Events**: `payment.updated`
- **Método**: `POST`

### Funcionamento
1. MercadoPago envia notificação
2. Sistema busca detalhes via API `/v1/payments/{id}`
3. Se `approved` ou `accredited`: credita dias
4. Usa `external_reference` como email do usuário

## 📁 Estrutura de Arquivos

### APIs Oficiais
- `api/webhooks/mercadopago.ts` - Webhook principal
- `api/payments/create-pix.ts` - Criar pagamento PIX  
- `api/payments/create-card.ts` - Criar pagamento cartão

### Frontend Principal
- `src/lib/supabase.ts` - Cliente Supabase
- `src/components/subscription/PaymentPage.tsx` - Interface pagamento

### Banco de Dados
- Função: `public.credit_days_simple(email, days)` - Crédito automático

## ✅ Status do Sistema

- ✅ **Webhook funcionando** - Testado e aprovado
- ✅ **Pagamentos PIX/Cartão** - Integração completa
- ✅ **Domínio configurado** - SSL e DNS corretos
- ✅ **Variáveis seguras** - SERVICE_ROLE_KEY apenas no servidor
- ✅ **Sistema comercial** - Pronto para uso

## 🚨 IMPORTANTE

**NUNCA use:**
- ❌ `NEXT_PUBLIC_*` em projeto Vite
- ❌ `SERVICE_ROLE_KEY` no frontend
- ❌ URLs hardcoded nos componentes
- ❌ Múltiplos webhooks para mesmo evento

**Para dúvidas, consulte APENAS este documento.**