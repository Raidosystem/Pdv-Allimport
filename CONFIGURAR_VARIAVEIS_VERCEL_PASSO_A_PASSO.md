# ⚙️ CONFIGURAR VARIÁVEIS NO VERCEL - PASSO A PASSO

## 🎯 **OBJETIVO:**
Configurar todas as variáveis de ambiente no dashboard do Vercel para garantir que a API funcione 100%.

## 📋 **PASSO A PASSO:**

### **PASSO 1: Acessar Dashboard Vercel**
1. Abra seu navegador
2. Vá para: https://vercel.com/dashboard
3. Faça login na sua conta
4. Clique no projeto: **pdv-allimport**

### **PASSO 2: Acessar Configurações**
1. No projeto, clique na aba **"Settings"** ⚙️
2. No menu lateral, clique em **"Environment Variables"** 🔐

### **PASSO 3: Adicionar Variáveis**
Clique em **"Add New"** para cada variável abaixo:

---

## 📝 **VARIÁVEIS OBRIGATÓRIAS:**

### **🔐 SUPABASE (Frontend)**
```
Name: VITE_SUPABASE_URL
Value: https://kmcaaqetxtwkdcczdomw.supabase.co
Environment: Production, Preview, Development
```

```
Name: VITE_SUPABASE_ANON_KEY
Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4
Environment: Production, Preview, Development
```

### **🔐 SUPABASE (Backend APIs)**
```
Name: SUPABASE_URL
Value: https://kmcaaqetxtwkdcczdomw.supabase.co
Environment: Production, Preview, Development
```

```
Name: SUPABASE_SERVICE_KEY
Value: [OBTER DO SUPABASE - VER INSTRUÇÕES ABAIXO]
Environment: Production, Preview, Development
```

### **💳 MERCADO PAGO**
```
Name: VITE_MP_ACCESS_TOKEN
Value: APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193
Environment: Production, Preview, Development
```

```
Name: MP_ACCESS_TOKEN
Value: APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193
Environment: Production, Preview, Development
```

```
Name: VITE_MP_PUBLIC_KEY
Value: APP_USR-2de8bb58-e0b6-43ab-a87b-ee56e47b0a1c
Environment: Production, Preview, Development
```

```
Name: MP_PUBLIC_KEY
Value: APP_USR-2de8bb58-e0b6-43ab-a87b-ee56e47b0a1c
Environment: Production, Preview, Development
```

### **🌐 URLs DA APLICAÇÃO**
```
Name: VITE_APP_URL
Value: https://pdv-allimport.vercel.app
Environment: Production, Preview, Development
```

```
Name: API_BASE_URL
Value: https://pdv-allimport.vercel.app
Environment: Production, Preview, Development
```

```
Name: FRONTEND_URL
Value: https://pdv-allimport.vercel.app
Environment: Production, Preview, Development
```

### **🔧 CONFIGURAÇÕES GERAIS**
```
Name: VITE_APP_NAME
Value: PDV Allimport
Environment: Production, Preview, Development
```

```
Name: VITE_NODE_ENV
Value: production
Environment: Production, Preview, Development
```

---

## 🔑 **COMO OBTER SUPABASE_SERVICE_KEY:**

### **PASSO 1: Acessar Supabase**
1. Vá para: https://supabase.com/dashboard
2. Faça login na sua conta
3. Selecione o projeto: **kmcaaqetxtwkdcczdomw**

### **PASSO 2: Obter Service Key**
1. Clique em **"Settings"** (menu lateral)
2. Clique em **"API"**
3. Role até **"Project API keys"**
4. Procure pela linha **"service_role"**
5. Clique no ícone de **👁️ "olho"** para revelar
6. **COPIE A CHAVE COMPLETA**

### **PASSO 3: Adicionar no Vercel**
1. Volte para o Vercel
2. Adicione variável: `SUPABASE_SERVICE_KEY`
3. Cole a chave copiada
4. Selecione todos os ambientes

---

## ⚠️ **IMPORTANTE:**

### **AMBIENTES:**
Para **CADA** variável, selecione **TODOS** os ambientes:
- ✅ **Production**
- ✅ **Preview**
- ✅ **Development**

### **APÓS ADICIONAR CADA VARIÁVEL:**
1. Clique em **"Save"** 💾
2. Continue com a próxima variável

---

## 🎬 **SEQUÊNCIA COMPLETA:**

### **1. Adicionar todas as variáveis** (uma por vez)
### **2. Verificar se estão todas salvas**
### **3. Fazer novo deploy (opcional)**

Para fazer novo deploy:
1. Vá para a aba **"Deployments"**
2. Clique nos **"..."** do último deploy
3. Clique em **"Redeploy"**

---

## 🧪 **TESTE APÓS CONFIGURAÇÃO:**

### **TESTE 1: Verificar Variáveis**
1. Vá para: https://pdv-allimport.vercel.app/
2. Abra F12 → Console
3. Digite: `console.log(import.meta.env)`
4. Verifique se todas as variáveis VITE_ aparecem

### **TESTE 2: API Test**
```
URL: https://pdv-allimport.vercel.app/api/test
Resultado esperado: {"status":"ok"}
```

### **TESTE 3: Login**
```
URL: https://pdv-allimport.vercel.app/
Ação: Tentar fazer login
Resultado esperado: ✅ Deve funcionar
```

---

## 📋 **CHECKLIST DE VERIFICAÇÃO:**

### **VARIÁVEIS FRONTEND (VITE_):**
- [ ] VITE_SUPABASE_URL
- [ ] VITE_SUPABASE_ANON_KEY
- [ ] VITE_MP_ACCESS_TOKEN
- [ ] VITE_MP_PUBLIC_KEY
- [ ] VITE_APP_URL
- [ ] VITE_APP_NAME
- [ ] VITE_NODE_ENV

### **VARIÁVEIS BACKEND:**
- [ ] SUPABASE_URL
- [ ] SUPABASE_SERVICE_KEY
- [ ] MP_ACCESS_TOKEN
- [ ] MP_PUBLIC_KEY
- [ ] API_BASE_URL
- [ ] FRONTEND_URL

### **VERIFICAÇÕES FINAIS:**
- [ ] Todas as variáveis em todos os ambientes
- [ ] Service key copiada corretamente do Supabase
- [ ] URLs usando pdv-allimport.vercel.app
- [ ] Login funcionando
- [ ] APIs respondendo

---

## 🚨 **SE ALGUMA VARIÁVEL NÃO APARECER:**

### **PROBLEMA COMUM:**
Às vezes o Vercel demora para aplicar as variáveis.

### **SOLUÇÃO:**
1. Aguarde 2-3 minutos
2. Faça um novo deploy
3. Limpe cache do navegador (Ctrl+Shift+R)

---

## 🎉 **RESULTADO ESPERADO:**

Após configurar todas as variáveis:
- ✅ Login funcionará perfeitamente
- ✅ APIs responderão corretamente
- ✅ PIX funcionará 100%
- ✅ Sistema estará 100% operacional

**🎯 Seguindo este guia, todas as variáveis estarão configuradas corretamente!**