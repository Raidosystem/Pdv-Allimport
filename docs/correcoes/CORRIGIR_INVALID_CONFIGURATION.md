# 🚨 CORRIGIR "Invalid Configuration" - Vercel Domains

## 📋 SOLUÇÕES EM ORDEM DE PRIORIDADE

### **SOLUÇÃO 1: Verificar Registros DNS**
1. **Clique em "Learn more"** ao lado de "Invalid Configuration"
2. **Veja exatamente quais registros DNS** o Vercel está pedindo
3. **Copie os valores exatos** que aparecem

### **SOLUÇÃO 2: Configuração Manual DNS**
Se você comprou na Vercel, pode precisar de:

**Para pdv-crmvsystem.com:**
```
Tipo: A
Nome: @
Valor: 76.76.19.61
```

**Para www.pdv-crmvsystem.com:**
```
Tipo: CNAME
Nome: www
Valor: cname.vercel-dns.com
```

### **SOLUÇÃO 3: Remover e Readicionar**
1. **Delete** os domínios inválidos
2. **Aguarde 2 minutos**
3. **Adicione novamente**
4. **Um por vez** (primeiro sem www, depois com www)

### **SOLUÇÃO 4: Usar Apenas Um Domínio**
Por enquanto, use apenas:
- ✅ **pdv-crmvsystem.com** (sem www)
- ❌ Remover **www.pdv-crmvsystem.com** temporariamente

## 🎯 **AÇÃO IMEDIATA**

### **PASSO 1:** Clique em "Learn more"
Veja o que o Vercel está pedindo especificamente

## 🎯 **CONFIGURAÇÃO DNS EXATA DO VERCEL**

### **OPÇÃO 1: Registro DNS (Recomendado)**
No seu provedor de domínio, adicione:

```
Tipo: A
Nome: @ (ou deixe vazio)
Valor: 216.150.1.1
```

### **OPÇÃO 2: Nameservers Vercel (Mais Simples)**
Troque os nameservers do domínio para:

```
ns1.vercel-dns.com
ns2.vercel-dns.com
```

## 🔍 **ONDE CONFIGURAR**

### **Se comprou domínio na Vercel:**
1. Vercel Dashboard → Domains
2. Clique no domínio
3. DNS Records → Add Record

### **Se comprou em outro lugar:**
1. Acesse o painel onde comprou o domínio
2. DNS Management / Gerenciamento DNS
3. Adicione o registro A ou mude nameservers

### **PASSO 4:** Aguarde
- **Tempo:** 5-30 minutos para propagar
- **Status mudará:** Invalid → Valid

## 🔍 **DIAGNÓSTICO RÁPIDO**

Execute este comando para ver o status DNS atual:
