# ⚡ CONFIGURAR SUBDOMÍNIO - crmvsystem.com (Principal)

## 🎯 **SITUAÇÃO:**
- **Domínio principal:** crmvsystem.com (comprado na Vercel)
- **Subdomínio desejado:** pdv-crmvsystem.com
- **Projeto:** Pdv-Allimport

## 📋 **PASSO A PASSO - SUBDOMÍNIO:**

### **1. Configurar DNS no Domínio Principal**
1. **Vercel Dashboard → Domains → crmvsystem.com**
2. **Clique no domínio** crmvsystem.com
3. **DNS Records → Add Record**
4. **Configure:**
   - **Type:** A
   - **Name:** pdv (para criar pdv-crmvsystem.com)
   - **Value:** 216.150.1.1
   - **TTL:** 300
5. **Save/Add**

### **2. Conectar ao Projeto**
1. **Dashboard → Projeto Pdv-Allimport**
2. **Settings → Domains**
3. **Add Domain:** pdv-crmvsystem.com
4. **Add** → Deve aparecer "Valid" após alguns minutos

### **3. Alternativa: CNAME Record**
Se o registro A não funcionar, use CNAME:
- **Type:** CNAME
- **Name:** pdv
- **Value:** cname.vercel-dns.com
- **TTL:** 300

### **2. Configurar DNS Records**
1. **Na página do domínio**, procure **"DNS Records"** ou **"DNS"**
2. **Clique em "Add Record"** ou **"+"**
3. **Configure:**
   - **Type:** A
   - **Name:** @ (ou deixe vazio)
   - **Value:** 216.150.1.1
   - **TTL:** 300 (padrão)
4. **Clique "Save"** ou **"Add"**

### **3. Conectar ao Projeto**
1. **Volte para:** Vercel Dashboard
2. **Clique no projeto:** Pdv-Allimport  
3. **Settings → Domains**
4. **Se ainda aparecer Invalid:** Clique **"Refresh"** ou aguarde 5 min

## 🔄 **ALTERNATIVA MAIS SIMPLES:**

### **Opção: Usar Vercel DNS (Recomendado)**
1. **Na página do domínio** pdv-crmvsystem.com
2. **Procure por "Use Vercel DNS"** ou **"Enable Vercel DNS"**
3. **Clique em "Enable"** ou **"Switch to Vercel DNS"**
4. **Confirme** a mudança

**Isso configura TUDO automaticamente! ✨**

## ⏱️ **TEMPO ESPERADO:**
- **Configuração:** 1-2 minutos
- **Propagação:** 2-10 minutos (muito rápido na Vercel)
- **Status:** Invalid → Valid

## 🎯 **RESULTADO:**
✅ pdv-crmvsystem.com → Valid Configuration  
✅ https://pdv-crmvsystem.com → PDV funcionando  
✅ PWA instalável

---

## 🚨 **SE NÃO ENCONTRAR "Domains" NO MENU:**
Pode estar em:
- **Account Settings → Domains**
- **Billing → Domains** 
- **Menu do perfil → Domains**

**Procure por uma seção específica de gerenciamento de domínios comprados!**
