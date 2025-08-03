# 🔧 CONFIGURAÇÃO DE EMAIL NO SUPABASE - URGENTE

## 📧 PROBLEMA IDENTIFICADO
Os emails de cadastro e recuperação de senha não estão chegando porque as configurações de email no Supabase Dashboard não estão corretas.

## 🚀 SOLUÇÃO RÁPIDA - SIGA ESTAS ETAPAS:

### 1️⃣ ACESSE O DASHBOARD
Abra: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/auth/settings

### 2️⃣ CONFIGURAR SITE URL
**Localização:** Authentication > Settings > General
```
Site URL: https://pdv-allimport.vercel.app
```

### 3️⃣ CONFIGURAR REDIRECT URLS
**Localização:** Authentication > Settings > Redirect URLs
**Adicione TODAS estas URLs:**
```
https://pdv-allimport.vercel.app/confirm-email
https://pdv-allimport.vercel.app/reset-password
https://pdv-allimport.vercel.app/dashboard
http://localhost:5174/confirm-email
http://localhost:5174/reset-password
http://localhost:5174/dashboard
```

### 4️⃣ HABILITAR CONFIRMAÇÕES DE EMAIL
**Localização:** Authentication > Settings > Email Auth
```
✅ Enable email confirmations: LIGADO
✅ Enable email change confirmations: LIGADO  
✅ Enable signups: LIGADO
```

### 5️⃣ CONFIGURAR TEMPLATES DE EMAIL

#### A) EMAIL DE CONFIRMAÇÃO:
**Localização:** Authentication > Settings > Email Templates > Confirm signup

**Subject:**
```
Confirme seu email - PDV Allimport
```

**Body (HTML):**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Confirme seu email - PDV Allimport</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
        <h1 style="color: white; margin: 0;">PDV Allimport</h1>
        <p style="color: white; margin: 10px 0 0 0;">Sistema de Vendas</p>
    </div>
    
    <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
        <h2 style="color: #333; margin-top: 0;">Confirme seu email</h2>
        <p>Clique no botão abaixo para confirmar seu email e ativar sua conta:</p>
        
        <div style="text-align: center; margin: 30px 0;">
            <a href="{{ .ConfirmationURL }}" 
               style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                      color: white; 
                      padding: 15px 30px; 
                      text-decoration: none; 
                      border-radius: 5px; 
                      font-weight: bold;
                      display: inline-block;">
                Confirmar Email
            </a>
        </div>
        
        <p style="font-size: 12px; color: #666; margin-top: 30px;">
            Se você não conseguir clicar no botão, copie e cole este link no seu navegador:<br>
            <span style="word-break: break-all;">{{ .ConfirmationURL }}</span>
        </p>
        
        <p style="font-size: 12px; color: #666;">
            Se você não solicitou esta confirmação, pode ignorar este email.
        </p>
    </div>
</body>
</html>
```

#### B) EMAIL DE RECUPERAÇÃO DE SENHA:
**Localização:** Authentication > Settings > Email Templates > Reset password

**Subject:**
```
Recuperação de senha - PDV Allimport
```

**Body (HTML):**
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Recuperação de senha - PDV Allimport</title>
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
        <h1 style="color: white; margin: 0;">PDV Allimport</h1>
        <p style="color: white; margin: 10px 0 0 0;">Sistema de Vendas</p>
    </div>
    
    <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px;">
        <h2 style="color: #333; margin-top: 0;">Recuperação de senha</h2>
        <p>Você solicitou a recuperação de senha para sua conta. Clique no botão abaixo para criar uma nova senha:</p>
        
        <div style="text-align: center; margin: 30px 0;">
            <a href="{{ .ConfirmationURL }}" 
               style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); 
                      color: white; 
                      padding: 15px 30px; 
                      text-decoration: none; 
                      border-radius: 5px; 
                      font-weight: bold;
                      display: inline-block;">
                Redefinir Senha
            </a>
        </div>
        
        <p style="font-size: 12px; color: #666; margin-top: 30px;">
            Se você não conseguir clicar no botão, copie e cole este link no seu navegador:<br>
            <span style="word-break: break-all;">{{ .ConfirmationURL }}</span>
        </p>
        
        <div style="background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <h4 style="color: #856404; margin: 0 0 10px 0;">⚠️ Importante:</h4>
            <p style="color: #856404; margin: 0; font-size: 14px;">
                Este link expira em 60 minutos por segurança. Se não foi você quem solicitou esta recuperação, ignore este email.
            </p>
        </div>
    </div>
</body>
</html>
```

## 🧪 COMO TESTAR APÓS A CONFIGURAÇÃO:

### Teste 1: Criar nova conta
1. Acesse: https://pdv-allimport.vercel.app/signup
2. Cadastre com um email real
3. ✅ Verifique se o email de confirmação chegou
4. ✅ Clique no link - deve levar para `/confirm-email`

### Teste 2: Recuperar senha
1. Acesse: https://pdv-allimport.vercel.app/forgot-password
2. Digite um email cadastrado
3. ✅ Verifique se o email de recuperação chegou
4. ✅ Clique no link - deve levar para `/reset-password`

## ❌ PROBLEMAS COMUNS:

1. **Emails vão para SPAM:** Verifique pasta de lixo eletrônico
2. **Link redireciona para localhost:** URLs de redirecionamento não configuradas
3. **Email não chega:** Confirmações de email desabilitadas
4. **Erro 404 ao clicar no link:** Site URL incorreta

## ✅ CHECKLIST FINAL:

- [ ] Site URL configurada: `https://pdv-allimport.vercel.app`
- [ ] Redirect URLs configuradas (todas as 6 URLs)
- [ ] Email confirmations: LIGADO
- [ ] Email change confirmations: LIGADO
- [ ] Enable signups: LIGADO
- [ ] Template de confirmação configurado
- [ ] Template de recuperação configurado
- [ ] Testado cadastro de nova conta
- [ ] Testado recuperação de senha

## 🆘 SE AINDA NÃO FUNCIONAR:

1. Verifique se tem configurações de SMTP customizadas
2. Teste com email diferente (Gmail, Outlook, etc.)
3. Aguarde até 5 minutos (pode haver delay)
4. Verifique logs no Supabase Dashboard > Logs > Auth

---

**⏰ ESTIMATIVA:** 10-15 minutos para configurar tudo
**🎯 RESULTADO:** Emails de cadastro e recuperação funcionando 100%
