# 🔑 PROBLEMA IDENTIFICADO: API KEY INCORRETA

## ❌ PROBLEMA:
```
Error: Invalid API key
Status: 401 Unauthorized
```

**A ANON_KEY do Supabase está incorreta!**

---

## 🎯 SOLUÇÃO:

### 1️⃣ BUSCAR ANON_KEY CORRETA:

Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/settings/api

**Copie exatamente:**
- **anon / public key** (NÃO a service_role)

### 2️⃣ ATUALIZAR .ENV:

Edite o arquivo `.env` e substitua:
```env
VITE_SUPABASE_ANON_KEY=SUA_CHAVE_ANON_CORRETA_AQUI
```

### 3️⃣ REBUILD E DEPLOY:

```bash
npm run build
npx vercel --prod
```

---

## 🔍 ONDE ENCONTRAR:

**Dashboard Supabase → Settings → API**

Você verá:
- ✅ **anon / public key** ← ESTA É A CORRETA
- ❌ **service_role key** ← NÃO USAR ESTA

---

## 📋 CHAVES ATUAIS CONHECIDAS:

- **URL**: `https://kmcaaqetxtwkdcczdomw.supabase.co` ✅
- **Service Role**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzkyNTcwOSwiZXhwIjoyMDY5NTAxNzA5fQ.J4gAQcV_rJiw1xAvXgo8kyiPvDIZN3HtKyuBR-i5jL4` ✅
- **Anon Key**: ❌ PRECISA BUSCAR NO DASHBOARD

---

## 🚀 APÓS CORRIGIR:

1. **Login deve funcionar** ✅
2. **Erro "Invalid API key" desaparece** ✅  
3. **PDV 100% operacional** ✅

**Busque a ANON_KEY correta no dashboard do Supabase!** 🔑
