# 🔧 Configuração de URLs do Supabase - URGENTE

## 🚨 PROBLEMA IDENTIFICADO
Os emails de confirmação estão redirecionando para `localhost:3000` porque as URLs não estão configuradas corretamente no painel do Supabase.

## 📝 SOLUÇÃO PASSO A PASSO

### 1. Acesse o Painel do Supabase
🔗 **Link direto:** https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/auth/settings

### 2. Configure Site URL
Na seção **"Site URL"**, altere de:
```
❌ http://127.0.0.1:3000
```
Para:
```
✅ https://pdv-allimport.vercel.app
```

### 3. Configure Redirect URLs
Na seção **"Redirect URLs"**, adicione TODAS estas URLs (uma por linha):

```
https://pdv-allimport.vercel.app
https://pdv-allimport.vercel.app/confirm-email
https://pdv-allimport.vercel.app/auth/callback
https://pdv-allimport.vercel.app/reset-password
http://localhost:5174
http://localhost:5174/confirm-email
http://localhost:5174/auth/callback
http://localhost:5174/reset-password
```

### 4. Configurações de Email
Certifique-se que em **"Email Auth"**:
- ✅ **Enable email confirmations** está LIGADO
- ✅ **Enable email change confirmations** está LIGADO

### 5. Salvar Configurações
Clique em **"Save"** para aplicar todas as mudanças.

## 🧪 TESTANDO A CORREÇÃO

### Página de Teste
Acesse: https://pdv-allimport.vercel.app/auth-config-test

### Teste Manual
1. Crie uma nova conta em: https://pdv-allimport.vercel.app/signup
2. Verifique se o email de confirmação chega
3. Clique no link de confirmação
4. ✅ Deve redirecionar para: `https://pdv-allimport.vercel.app/confirm-email`
5. ❌ NÃO deve redirecionar para: `localhost:3000`

## 📧 URLs Corretas que devem aparecer nos emails

### Email de Confirmação:
```
https://pdv-allimport.vercel.app/confirm-email?token_hash=...
```

### Email de Recuperação de Senha:
```
https://pdv-allimport.vercel.app/reset-password?token_hash=...
```

## 🔍 Verificação Adicional

Execute no navegador para verificar:
```javascript
console.log('Site atual:', window.location.origin);
// Deve mostrar: https://pdv-allimport.vercel.app
```

## ⚡ AÇÕES IMEDIATAS NECESSÁRIAS

1. **URGENTE:** Corrigir Site URL no Supabase Dashboard
2. **URGENTE:** Adicionar todas as Redirect URLs
3. **TESTAR:** Criar nova conta e verificar redirecionamento
4. **CONFIRMAR:** Email de confirmação funcionando

---

💡 **Nota:** Estas configurações afetam TODOS os emails de autenticação (confirmação, recuperação de senha, etc.)
