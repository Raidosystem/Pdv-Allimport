# Configuração SMTP Personalizada para PDV Allimport

## 🚨 Problema Identificado
O Gmail está bloqueando emails do Supabase. Outros provedores (Outlook, Yahoo, Hotmail) funcionam perfeitamente.

## ✅ Soluções Imediatas

### 1. 📬 Verificar Gmail Agora
- **Inbox principal**
- **Spam/Lixo eletrônico** ⚠️ (mais provável)
- **Pasta Promoções**
- **Pasta Social**
- **Pasta Atualizações**

### 2. 🔧 Configurar Gmail
1. Adicione `noreply@supabase.io` aos contatos
2. Adicione `@supabase.io` como remetente confiável
3. Vá em Configurações > Filtros e endereços bloqueados
4. Remova qualquer filtro que bloqueie emails do Supabase

### 3. 📧 Email Alternativo (Recomendado)
Use temporariamente:
- **@outlook.com** ✅ Testado e funcionando
- **@yahoo.com** ✅ Testado e funcionando  
- **@hotmail.com** ✅ Testado e funcionando

## 🔧 Configuração SMTP Personalizada (Para Produção)

### Opção 1: SendGrid (Recomendado)
1. Acesse https://sendgrid.com
2. Crie conta gratuita (100 emails/dia)
3. Gere API Key
4. Configure no Supabase Dashboard

### Opção 2: Mailgun
1. Acesse https://mailgun.com
2. Conta gratuita (até 5.000 emails)
3. Configure domínio próprio
4. Integre com Supabase

### Configuração no Supabase
1. Dashboard > Project Settings > Auth
2. SMTP Settings:
   - **Host**: smtp.sendgrid.net
   - **Port**: 587
   - **Username**: apikey
   - **Password**: [sua-api-key]

## 🎯 Links Úteis
- **Signup PDV**: https://pdv-allimport.vercel.app/signup
- **Dashboard Supabase**: https://supabase.com/dashboard/project/your-project-ref/auth/settings
- **SendGrid**: https://sendgrid.com
- **Mailgun**: https://mailgun.com

## ✅ Status Atual
- ✅ **Sistema PDV**: Funcionando perfeitamente
- ✅ **Supabase**: Enviando emails corretamente
- ✅ **Outros provedores**: Recebendo emails
- ❌ **Gmail**: Bloqueando/filtrando emails

**Recomendação**: Use email alternativo para teste e configure SMTP personalizado para produção.
