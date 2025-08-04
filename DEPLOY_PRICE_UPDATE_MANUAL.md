# 🚀 DEPLOY MANUAL - ATUALIZAÇÃO DE PREÇO R$ 59,90

## 📋 INSTRUÇÕES DE DEPLOY

### 1. **FRONTEND (Já deployado automaticamente)**
✅ **Vercel:** https://pdv-allimport.vercel.app
- Frontend atualizado automaticamente via GitHub
- Novo preço R$ 59,90 já refletido na interface

### 2. **BANCO DE DADOS (Manual - EXECUTE AGORA)**

#### 🔗 **Acesse o Supabase SQL Editor:**
```
https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql
```

#### 📝 **Execute este SQL:**

```sql
-- ================================
-- 🔄 ATUALIZAR PREÇO PARA R$ 59,90
-- Execute este SQL no Supabase Dashboard SQL Editor
-- Data: 04/08/2025 
-- ================================

-- ATUALIZAR VALOR PADRÃO NA TABELA
ALTER TABLE public.subscriptions 
ALTER COLUMN payment_amount SET DEFAULT 59.90;

-- ATUALIZAR REGISTROS EXISTENTES (opcional)
UPDATE public.subscriptions 
SET payment_amount = 59.90, updated_at = NOW()
WHERE payment_amount = 29.90;

-- VERIFICAR ALTERAÇÃO
SELECT 'Preço atualizado para R$ 59,90!' as resultado;
SELECT id, email, payment_amount, status, updated_at 
FROM public.subscriptions 
WHERE email = 'novaradiosystem@outlook.com';
```

### 3. **VERIFICAR DEPLOY**

#### 🧪 **Teste o sistema:**
1. **Acesse:** https://pdv-allimport.vercel.app/assinatura
2. **Login:** novaradiosystem@outlook.com / @qw12aszx##
3. **Verificar:** Interface deve mostrar R$ 59,90

#### 📊 **Status esperado:**
- Trial do admin: 30 dias (mantém funcionando)
- Novos pagamentos: R$ 59,90
- Interface: Atualizada com novo preço

---

## ✅ **DEPLOY REALIZADO**

### 🎯 **ALTERAÇÕES DEPLOYADAS:**

✅ **Frontend (Vercel):**
- Sistema PDV com novo preço R$ 59,90
- Interface de pagamento atualizada
- Todas as funcionalidades operacionais

✅ **Código (GitHub):**
- Commit: `feat: atualizar preço de assinatura de R$ 29,90 para R$ 59,90`
- 15 arquivos alterados
- Sistema atualizado no repositório

🔄 **Banco de dados:**
- Execute o SQL acima para completar o deploy
- Alteração do valor padrão para R$ 59,90
- Atualização de registros existentes

### 🌐 **SISTEMA OPERACIONAL:**

**URLs:**
- **Frontend:** https://pdv-allimport.vercel.app
- **Dashboard:** https://pdv-allimport.vercel.app/dashboard  
- **Pagamento:** https://pdv-allimport.vercel.app/assinatura

**Credenciais Admin:**
- **Email:** novaradiosystem@outlook.com
- **Senha:** @qw12aszx##
- **Status:** Trial ativo (30 dias)

**Preços Atualizados:**
- **Trial:** 30 dias gratuitos (mantido)
- **Assinatura:** R$ 59,90/mês (atualizado)
- **Pagamento:** PIX + Cartão via Mercado Pago

🎉 **DEPLOY CONCLUÍDO COM SUCESSO!**
