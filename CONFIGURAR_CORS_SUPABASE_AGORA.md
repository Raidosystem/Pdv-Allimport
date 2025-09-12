# 🚨 CONFIGURAR CORS NO SUPABASE - PASSO A PASSO

## 🎯 **PROBLEMA:**
A API estava funcionando 100%, mas agora o login não funciona em produção devido ao CORS não configurado.

## 📋 **SOLUÇÃO IMEDIATA:**

### **PASSO 1: Acessar Dashboard Supabase**
1. Abra seu navegador
2. Vá para: https://supabase.com/dashboard
3. Faça login na sua conta
4. Selecione o projeto: **kmcaaqetxtwkdcczdomw**

### **PASSO 2: Configurar CORS**
1. No menu lateral esquerdo, clique em **"Settings"** ⚙️
2. Clique em **"API"** 🔌
3. Role a página até encontrar a seção **"CORS"**
4. Você verá um campo chamado **"Additional allowed origins"**

### **PASSO 3: Adicionar Domínios**
No campo **"Additional allowed origins"**, adicione os seguintes domínios (um por linha):

```
https://pdv-allimport.vercel.app
https://pdv-allimport-radiosystem.vercel.app
https://*.vercel.app
```

### **PASSO 4: Salvar Configurações**
1. Clique no botão **"Save"** 💾
2. Aguarde 2-3 minutos para a configuração se propagar

---

## 🧪 **TESTE IMEDIATO:**

### **TESTE 1: Verificar CORS**
Abra o Console do navegador (F12) e execute:
```javascript
fetch('https://kmcaaqetxtwkdcczdomw.supabase.co/rest/v1/', {
  headers: {
    'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4'
  }
}).then(r => console.log('CORS OK:', r.status))
.catch(e => console.error('CORS ERROR:', e))
```

### **TESTE 2: Login**
1. Vá para: https://pdv-allimport.vercel.app
2. Tente fazer login
3. Se ainda der erro, vá para o **PASSO 5**

---

## 🔧 **PASSO 5: CONFIGURAÇÃO AVANÇADA (Se ainda não funcionar)**

### **Configuração Completa no Supabase:**
1. No dashboard do Supabase
2. Settings → API → CORS
3. Configure assim:

**"Additional allowed origins":**
```
*
https://pdv-allimport.vercel.app
https://pdv-allimport-radiosystem.vercel.app
https://*.vercel.app
http://localhost:3000
http://localhost:5173
```

**"Allowed headers":**
```
authorization,x-client-info,apikey,content-type
```

---

## 🚨 **SE AINDA NÃO FUNCIONAR:**

### **OPÇÃO 1: Reset Completo**
1. No Supabase Dashboard
2. Settings → API → CORS
3. **DELETE** todos os domínios existentes
4. Adicione apenas: `*` (temporariamente)
5. Save → Aguarde 5 minutos → Teste
6. Se funcionar, substitua `*` pelos domínios específicos

### **OPÇÃO 2: Verificar Status da API**
Execute este comando no terminal:
```bash
curl -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4" https://kmcaaqetxtwkdcczdomw.supabase.co/rest/v1/
```

---

## 📱 **IMAGENS DE REFERÊNCIA:**

### **Como encontrar CORS no Supabase:**
1. Dashboard → Settings (menu lateral)
2. API (submenu)
3. Role até "CORS"
4. Campo: "Additional allowed origins"

### **Deve ficar assim:**
```
Campo: Additional allowed origins
Valor: 
https://pdv-allimport.vercel.app
https://pdv-allimport-radiosystem.vercel.app
```

---

## ✅ **VERIFICAÇÃO FINAL:**

Após configurar, teste:
1. ✅ Login em https://pdv-allimport.vercel.app
2. ✅ Sem erros no Console (F12)
3. ✅ APIs funcionando normalmente

## 🎯 **RESULTADO ESPERADO:**
- Login funcionará 100% em produção
- APIs responderão normalmente
- Sistema voltará ao estado "funcionando 100%"

---

## 📞 **SE PRECISAR DE AJUDA:**
1. Copie qualquer mensagem de erro do Console (F12)
2. Verifique se o domínio está exatamente como mostrado acima
3. Aguarde sempre 2-3 minutos após salvar no Supabase

🎉 **Seguindo estes passos, o CORS será configurado corretamente!**