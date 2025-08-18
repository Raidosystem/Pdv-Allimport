# 🚀 GUIA RÁPIDO: CONFIGURAR SUPABASE PARA NOVO DOMÍNIO

## ✅ STATUS ATUAL
- **Domínio**: https://pdv.crmvsystem.com/ ✅ FUNCIONANDO
- **PWA**: ✅ PRONTO PARA INSTALAÇÃO  
- **Aplicação**: ✅ CARREGANDO CORRETAMENTE
- **Problema**: ❌ LOGIN NÃO FUNCIONA (Supabase não configurado)

---

## 🎯 SOLUÇÃO EM 3 PASSOS

### PASSO 1: ACESSAR SUPABASE
```
1. Vá para: https://supabase.com/dashboard
2. Faça login na sua conta
3. Selecione seu projeto do PDV
```

### PASSO 2: CONFIGURAR AUTHENTICATION
```
Navigation: Authentication > Settings > URL Configuration

🎯 Site URL:
https://pdv.crmvsystem.com/

🎯 Redirect URLs (adicione cada uma em uma linha):
https://pdv.crmvsystem.com/
https://pdv.crmvsystem.com/auth/callback
https://pdv.crmvsystem.com/login  
https://pdv.crmvsystem.com/dashboard
```

### PASSO 3: CRIAR USUÁRIO ADMIN
```
Navigation: Authentication > Users > Add user

📧 Email: novaradiosystem@outlook.com
🔐 Password: Admin123!@#
✅ Marcar: Auto Confirm User
```

---

## 🧪 TESTE FINAL

1. **Salve as configurações** no Supabase
2. **Acesse**: https://pdv.crmvsystem.com/
3. **Faça login** com:
   - Email: `novaradiosystem@outlook.com`
   - Senha: `Admin123!@#`

---

## 🆘 SE DER ERRO

**"Invalid login credentials"**
- ✅ Verifique se salvou as configurações
- ✅ Aguarde 1-2 minutos para propagação
- ✅ Tente criar o usuário novamente

**"CORS Error"**
- ✅ Adicione o domínio em Settings > API > CORS:
  ```
  https://pdv.crmvsystem.com
  ```

---

## 📱 APÓS CONFIGURAR

1. **Login funcionando** ✅
2. **PWA pode ser instalado** ✅  
3. **Sistema operacional** ✅

🎉 **Seu PDV estará 100% funcional no novo domínio!**

---

## 📞 SUPORTE

Se precisar de ajuda:
1. Compartilhe print da tela de erro
2. Confirme se seguiu todos os passos
3. Verifique se o projeto Supabase está correto
