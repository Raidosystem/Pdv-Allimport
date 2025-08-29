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

Acesse: https://supabase.com/dashboard/project/your-project-ref/settings/api

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

- **URL**: `https://YOUR_SUPABASE_PROJECT.supabase.co` ✅
- **Service Role**: `YOUR_SUPABASE_ANON_KEY
- **Anon Key**: ❌ PRECISA BUSCAR NO DASHBOARD

---

## 🚀 APÓS CORRIGIR:

1. **Login deve funcionar** ✅
2. **Erro "Invalid API key" desaparece** ✅  
3. **PDV 100% operacional** ✅

**Busque a ANON_KEY correta no dashboard do Supabase!** 🔑
