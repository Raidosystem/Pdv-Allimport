# 🔧 Guia Completo: Configurar Domínio pdv.crmvsystem.com

## 📋 **PASSO 1: Configurar na Vercel**

### 1.1 Acessar Dashboard da Vercel
1. Acesse: https://vercel.com/radiosystem/pdv-allimport
2. Faça login na conta

### 1.2 Adicionar Domínio Personalizado
1. Clique em **"Settings"** no topo
2. Clique em **"Domains"** no menu lateral
3. Clique em **"Add Domain"**
4. Digite: `pdv.crmvsystem.com`
5. Clique em **"Add"**

### 1.3 Configurar DNS
A Vercel vai mostrar as configurações de DNS necessárias:
```
Type: CNAME
Name: pdv
Value: cname.vercel-dns.com
```

## 📋 **PASSO 2: Configurar no Supabase**

### 2.1 Acessar Dashboard do Supabase
1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw
2. Faça login na conta

### 2.2 Configurar Site URL
1. Vá em **"Authentication"** no menu lateral
2. Clique em **"Settings"**
3. Na seção **"Site URL"**, altere para:
   ```
   https://pdv.crmvsystem.com
   ```
4. Clique em **"Save"**

### 2.3 Configurar Redirect URLs
1. Na mesma página, na seção **"Redirect URLs"**
2. Adicione as seguintes URLs (uma por linha):
   ```
   https://pdv.crmvsystem.com
   https://pdv.crmvsystem.com/auth/callback
   https://pdv-allimport.vercel.app
   https://pdv-allimport.vercel.app/auth/callback
   ```
3. Clique em **"Save"**

### 2.4 Configurar CORS
1. Vá em **"Settings"** > **"API"**
2. Na seção **"CORS Origins"**
3. Adicione:
   ```
   https://pdv.crmvsystem.com
   ```
4. Clique em **"Save"**

## 📋 **PASSO 3: Configurar DNS**

### 3.1 No Provedor de DNS (onde está registrado crmvsystem.com)
1. Acesse o painel do seu provedor DNS
2. Adicione um registro CNAME:
   ```
   Type: CNAME
   Name: pdv
   Value: cname.vercel-dns.com
   TTL: 3600 (ou automático)
   ```
3. Salve as alterações

### 3.2 Aguardar Propagação
- DNS pode levar de 5 minutos a 48 horas para propagar
- Use https://whatsmydns.net para verificar

## 📋 **PASSO 4: Verificar Funcionamento**

### 4.1 Testar URLs
1. Acesse: https://pdv.crmvsystem.com
2. Deve carregar o sistema PDV
3. Teste o login com usuário existente

### 4.2 Verificar SSL
1. O certificado SSL deve ser automático via Vercel
2. Verifique se não há erros de certificado

## 🚨 **Possíveis Problemas e Soluções**

### Problema: "Site não encontrado"
**Solução**: Verificar se DNS está configurado corretamente

### Problema: "Erro de login"
**Solução**: Verificar se Site URL e Redirect URLs estão corretos no Supabase

### Problema: "CORS Error"
**Solução**: Adicionar domínio aos CORS Origins no Supabase

## ✅ **Status Atual**
- ✅ Código preparado para domínio personalizado
- ✅ Deploy na Vercel realizado
- ⏳ **Configurar domínio na Vercel** (Passo 1)
- ⏳ **Configurar autenticação no Supabase** (Passo 2)  
- ⏳ **Configurar DNS** (Passo 3)

---
*Após completar todos os passos, o login funcionará em https://pdv.crmvsystem.com*
