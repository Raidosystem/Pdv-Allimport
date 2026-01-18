# 🚀 DEPLOY BACKEND API - PDV ALLIMPORT

## 📋 Status do Deploy

✅ **Frontend**: Deployado no Vercel (https://pdv-allimport.vercel.app)  
🔄 **Backend**: Pronto para deploy  
✅ **Database**: Supabase configurado  
✅ **Pagamentos**: Mercado Pago integrado  

## 🛠️ Estrutura do Backend

```
api/
├── index.js          # Servidor Express com todos os endpoints
├── package.json      # Dependências do Node.js
├── .env.example      # Exemplo de variáveis de ambiente
└── README.md         # Este arquivo
```

## 🚀 Deploy do Backend

### Opção 1: Vercel (Recomendado)

1. **Instalar Vercel CLI**:
```bash
npm i -g vercel
```

2. **Deploy direto da pasta api**:
```bash
cd api/
vercel --prod
```

3. **Configurar variáveis de ambiente no Vercel**:
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_KEY`
   - `MP_ACCESS_TOKEN`
   - `MP_PUBLIC_KEY`
   - `FRONTEND_URL`
   - `API_BASE_URL`

### Opção 2: Railway

1. **Conectar repositório**: https://railway.app
2. **Configurar root directory**: `/api`
3. **Adicionar variáveis de ambiente**

### Opção 3: Render

1. **Criar Web Service**: https://render.com
2. **Root Directory**: `api`
3. **Build Command**: `npm install`
4. **Start Command**: `node index.js`

## 🔧 Configuração Local

1. **Instalar dependências**:
```bash
cd api/
npm install
```

2. **Configurar variáveis**:
```bash
cp .env.example .env
# Editar .env com suas credenciais
```

3. **Iniciar servidor**:
```bash
npm start
# ou
node index.js
```

## 🌐 Endpoints da API

### Health Check
- `GET /api/health` - Status da API

### Pagamentos
- `POST /api/payments/pix` - Criar pagamento PIX
- `POST /api/payments/preference` - Criar checkout cartão
- `GET /api/payments/:id/status` - Verificar status

### Webhooks
- `POST /api/webhook/mercadopago` - Webhook do MP

### Configuração
- `GET /api/config` - Configurações públicas

## 🔑 Variáveis de Ambiente

```env
# Servidor
PORT=3333
NODE_ENV=production

# Supabase
SUPABASE_URL=sua_url_supabase
SUPABASE_SERVICE_KEY=sua_service_key

# Mercado Pago
MP_ACCESS_TOKEN=seu_access_token
MP_PUBLIC_KEY=sua_public_key
MP_WEBHOOK_SECRET=sua_webhook_secret

# URLs
FRONTEND_URL=https://pdv-allimport.vercel.app
API_BASE_URL=https://sua-api.vercel.app
```

## 📊 Monitoramento

- Logs disponíveis via console do provedor
- Health check em `/api/health`
- Webhook logs no Supabase

## 🔄 Atualizações de Preço

Execute no Supabase SQL Editor:
```sql
-- Atualizar preço para R$ 59,90
ALTER TABLE public.subscriptions 
ALTER COLUMN payment_amount SET DEFAULT 59.90;

UPDATE public.subscriptions 
SET payment_amount = 59.90, updated_at = NOW()
WHERE payment_amount = 59.90;
```

## ✅ Checklist de Deploy

- [ ] Backend deployado e funcionando
- [ ] Webhooks configurados no Mercado Pago
- [ ] Variáveis de ambiente configuradas
- [ ] Frontend atualizado com URL da API
- [ ] Preços atualizados no Supabase
- [ ] Testes de pagamento realizados

## 🆘 Troubleshooting

### API não responde
- Verificar logs do provedor
- Conferir variáveis de ambiente
- Testar endpoint `/api/health`

### Pagamentos não funcionam
- Verificar credenciais MP
- Conferir modo sandbox/production
- Validar webhooks configurados

### Frontend não conecta
- Verificar CORS configurado
- Conferir URL da API no frontend
- Testar conectividade

---

**🎉 Sistema PDV Allimport - Completo e Funcional!**
