# 🌐 CONFIGURAÇÃO DOMÍNIO pdv-crmvsystem.com

## 📋 INSTRUÇÕES PASSO A PASSO

### 1. **Configurar no Vercel Dashboard**
1. Acesse: https://vercel.com/dashboard
2. Selecione o projeto **Pdv-Allimport**
3. Vá em **Settings** → **Domains**
4. Clique **"Add Domain"**
5. Digite: **pdv-crmvsystem.com**
6. Clique **"Add"**

### 2. **Configurar DNS (no seu provedor de domínio)**
Adicione estes registros DNS:

**Tipo A:**
```
Nome: pdv-crmvsystem.com
Tipo: A
Valor: 76.76.19.61
```

**Tipo CNAME (alternativo):**
```
Nome: pdv-crmvsystem.com
Tipo: CNAME  
Valor: cname.vercel-dns.com
```

### 3. **Aguardar Propagação**
- **Tempo:** 5-30 minutos
- **Verificar:** https://pdv-crmvsystem.com

### 4. **Deploy Automático**
O Vercel vai fazer deploy automático quando você adicionar o domínio.

### 5. **Certificado SSL**
✅ **Automático** - Vercel gera certificado Let's Encrypt

## 🔧 ARQUIVOS JÁ CONFIGURADOS

### ✅ manifest.json
- start_url: https://pdv-crmvsystem.com/
- scope: https://pdv-crmvsystem.com/

### ✅ vercel.json  
- Configuração completa para PWA
- Headers corretos para manifest.json e Service Worker

### ✅ Service Worker
- Cache configurado
- Offline support

## 🚀 PRÓXIMOS PASSOS

1. **VOCÊ:** Configurar domínio no Vercel Dashboard
2. **VOCÊ:** Configurar DNS 
3. **AUTOMÁTICO:** Deploy no novo domínio
4. **TESTAR:** PWA installation em https://pdv-crmvsystem.com

## ✅ RESULTADO FINAL
- **URL:** https://pdv-crmvsystem.com
- **PWA:** Instalável no Chrome
- **SSL:** Certificado automático
- **Profissional:** Domínio próprio

---

**🎯 AÇÃO:** Configure o domínio no Vercel Dashboard agora!
