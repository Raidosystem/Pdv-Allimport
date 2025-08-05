# 🚀 DEPLOY COMPLETO - CHECKLIST FINAL

## ✅ **1. GIT DEPLOY (Concluído)**
- [x] Commit com integração Mercado Pago completa
- [x] Push para GitHub repository
- [x] Configurações de produção aplicadas

## ⏳ **2. SUPABASE DEPLOY (Execute agora)**

### **📋 Passos:**
1. **Acesse:** https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql
2. **Copie:** Todo conteúdo do arquivo `DEPLOY_BASICO.sql`
3. **Cole:** No SQL Editor do Supabase
4. **Execute:** Clique em RUN (▶️)
5. **Verifique:** Mensagem "DEPLOY CONCLUÍDO!"

### **🎯 O que será atualizado:**
- ✅ Preços: R$ 29,90 → R$ 59,90
- ✅ Tabela `payments` criada
- ✅ Função `activate_subscription_after_payment`
- ✅ Políticas RLS configuradas

## ⏳ **3. VERCEL DEPLOY (Configure ENV vars)**

### **📋 Passos:**
1. **Acesse:** https://vercel.com/raidosystem/pdv-allimport/settings/environment-variables
2. **Adicione** todas as variáveis do arquivo `VERCEL_ENV_CONFIG.md`
3. **Aguarde** redeploy automático (triggered pelo Git push)

### **🔧 Variáveis principais:**
```bash
VITE_MP_PUBLIC_KEY=APP_USR-4a8bfb6e-0ff5-47d1-be9c-092fbcf7e022
VITE_MP_ACCESS_TOKEN=APP_USR-3807636986700595-080418-...
MP_ACCESS_TOKEN=APP_USR-3807636986700595-080418-...
VITE_API_URL=https://pdv-allimport.vercel.app
```

## 🎯 **URLs de Produção:**
- **Frontend:** https://pdv-allimport.vercel.app
- **API Backend:** https://pdv-allimport.vercel.app/api/*
- **Health Check:** https://pdv-allimport.vercel.app/api/health

## 🧪 **Como testar após deploy:**
1. **Acesse:** https://pdv-allimport.vercel.app/assinatura
2. **Login:** novaradiosystem@outlook.com / @qw12aszx##
3. **Teste PIX:** Deve gerar QR Code real (R$ 59,90)
4. **Teste Cartão:** Deve abrir checkout Mercado Pago

## ⚠️ **Status Atual:**
- ✅ Git: Deploy completo
- ⏳ Supabase: **Execute DEPLOY_BASICO.sql**
- ⏳ Vercel: **Configure variáveis de ambiente**

---
**🎉 Sistema estará 100% funcional após completar passos 2 e 3!**
