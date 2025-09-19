# 🚀 CONFIGURAÇÃO VERCEL - VARIÁVEIS DE AMBIENTE

## 📋 **Como configurar no Vercel Dashboard:**

### 1. **Acesse as configurações:**
   - URL: https://vercel.com/raidosystem/pdv-allimport/settings/environment-variables
   - Ou: Dashboard → Project → Settings → Environment Variables

### 2. **Adicione estas variáveis:**

```bash
# Supabase
VITE_SUPABASE_URL=https://YOUR_SUPABASE_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY

# App
VITE_APP_NAME=PDV Allimport
VITE_APP_VERSION=1.0.0
VITE_APP_URL=https://pdv-allimport.vercel.app
VITE_API_URL=https://pdv-allimport.vercel.app
VITE_DEV_MODE=false

# Mercado Pago PRODUÇÃO
VITE_MP_PUBLIC_KEY=APP_USR-4a8bfb6e-0ff5-47d1-be9c-092fbcf7e022
VITE_MP_ACCESS_TOKEN=[MercadoPago Access Token_REMOVIDO]
VITE_MP_BASE_URL=https://api.mercadopago.com

# Backend API (para Vercel Functions)
MP_ACCESS_TOKEN=[MercadoPago Access Token_REMOVIDO]
MP_PUBLIC_KEY=APP_USR-4a8bfb6e-0ff5-47d1-be9c-092fbcf7e022
NODE_ENV=production
API_BASE_URL=https://pdv-allimport.vercel.app
SUPABASE_URL=https://YOUR_SUPABASE_PROJECT.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### 3. **Para cada variável:**
   - Name: [nome da variável]
   - Value: [valor da variável]
   - Environment: Production, Preview, Development (todas selecionadas)
   - Clique "Save"

---
**⚠️ IMPORTANTE:** Configure todas as variáveis antes do deploy!
