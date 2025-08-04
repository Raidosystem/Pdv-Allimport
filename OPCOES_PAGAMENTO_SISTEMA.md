# 📋 SISTEMA DE ASSINATURA - ONDE APARECE A OPÇÃO DE COMPRA

## 🚀 **LOCAIS ONDE A OPÇÃO DE PAGAMENTO APARECE:**

### 1. **🛡️ SubscriptionGuard (Bloqueio Automático)**
- **Arquivo:** `src/components/SubscriptionGuard.tsx`
- **Quando aparece:** Sempre que o usuário tenta acessar qualquer página protegida sem assinatura válida
- **Comportamento:** 
  - Bloqueia completamente o acesso ao sistema
  - Mostra automaticamente a tela de pagamento
  - Aplica-se a todas as rotas: `/dashboard`, `/vendas`, `/produtos`, `/clientes`, etc.

### 2. **🔔 SubscriptionBanner (Banner de Aviso)**
- **Arquivo:** `src/components/subscription/SubscriptionBanner.tsx`
- **Onde aparece:** Topo de todas as páginas do dashboard
- **Quando aparece:**
  - Trial com 7 dias ou menos restantes
  - Trial expirado
- **Funcionalidades:**
  - Banner amarelo/laranja para avisos
  - Banner vermelho para expirado
  - Botão "Assinar Agora" que abre modal de pagamento
  - Opção de dispensar (apenas para avisos, não para expirados)

### 3. **👤 SubscriptionStatus (Indicador no Header)**
- **Arquivo:** `src/components/subscription/SubscriptionStatus.tsx`
- **Onde aparece:** Header do dashboard, próximo aos dados do usuário
- **Funcionalidades:**
  - Mostra status atual: "Trial: X dias", "Ativo", "Expirado"
  - Cores diferentes por status (verde=ativo, azul=trial, vermelho=expirado)
  - Clicável quando restam 7 dias ou menos (leva para página de assinatura)

### 4. **👑 Botão "Assinatura" no Header**
- **Arquivo:** `src/modules/dashboard/DashboardPage.tsx`
- **Onde aparece:** Header do dashboard, ao lado do botão "Sair"
- **Funcionalidades:**
  - Sempre visível para usuários normais
  - Leva direto para a página de assinatura `/assinatura`
  - Ícone de coroa para destacar

### 5. **💳 Página de Assinatura Dedicada**
- **Arquivo:** `src/components/subscription/PaymentPage.tsx`
- **URL:** `/assinatura`
- **Quando acessível:** Sempre para usuários logados
- **Funcionalidades:**
  - Interface completa de pagamento
  - Opções PIX e Cartão
  - QR Code para PIX
  - Checkout do Mercado Pago para cartão

---

## 🎯 **FLUXO PARA DIFERENTES TIPOS DE USUÁRIO:**

### **👤 NOVOS USUÁRIOS (Sem Trial):**
1. Fazem cadastro
2. Tentam acessar qualquer página protegida
3. **SubscriptionGuard** bloqueia e mostra PaymentPage
4. Devem pagar para usar o sistema

### **🆓 USUÁRIOS EM TRIAL (Mais de 7 dias):**
1. Acessam normalmente o sistema
2. Veem **SubscriptionStatus** azul no header: "Trial: X dias"
3. Veem botão **"Assinatura"** no header (opcional)
4. Podem usar todas as funcionalidades

### **⚠️ USUÁRIOS EM TRIAL (7 dias ou menos):**
1. Veem **SubscriptionBanner** amarelo/laranja no topo
2. **SubscriptionStatus** vira clicável e leva para `/assinatura`
3. Banner tem botão "Assinar Agora"
4. Múltiplas formas de acessar pagamento

### **🚫 USUÁRIOS COM TRIAL EXPIRADO:**
1. **SubscriptionGuard** bloqueia acesso total
2. Mostra automaticamente **PaymentPage**
3. **SubscriptionBanner** vermelho (se não bloqueado)
4. Não podem usar nenhuma funcionalidade até pagar

### **👑 ADMINS:**
- Nunca veem opções de pagamento
- Têm acesso total sempre
- Sistema reconhece via `isAdmin()`

---

## 💰 **SISTEMA DE PAGAMENTO:**

### **💳 Mercado Pago Integration:**
- **PIX:** QR Code instantâneo (R$ 59,90)
- **Cartão:** Checkout completo com parcelamento
- **Verificação:** Automática a cada 5 segundos para PIX
- **Ativação:** Automática após confirmação do pagamento

### **📊 Preços e Planos:**
- **Trial:** 30 dias gratuitos
- **Assinatura:** R$ 59,90/mês
- **Renovação:** Automática via Mercado Pago

---

## 🔧 **COMO TESTAR O SISTEMA:**

### **🧪 Para Ver as Opções de Pagamento:**

1. **Acesse com usuário normal:** `novaradiosystem@outlook.com`
2. **Simule diferentes cenários:**
   - Trial com muitos dias: só SubscriptionStatus azul
   - Trial com poucos dias: Banner + SubscriptionStatus clicável  
   - Trial expirado: Bloqueio total + PaymentPage

3. **URLs para testar:**
   - `https://pdv-allimport.vercel.app/dashboard` - Dashboard principal
   - `https://pdv-allimport.vercel.app/assinatura` - Página de pagamento direta
   - `https://pdv-allimport.vercel.app/vendas` - Qualquer página protegida

### **⏰ Para Simular Trial Expirando:**
Execute no Supabase SQL Editor:
```sql
-- Simular 2 dias restantes
UPDATE public.subscriptions 
SET trial_end_date = NOW() + INTERVAL '2 days'
WHERE email = 'novaradiosystem@outlook.com';

-- Simular trial expirado
UPDATE public.subscriptions 
SET trial_end_date = NOW() - INTERVAL '1 day',
    status = 'expired'
WHERE email = 'novaradiosystem@outlook.com';
```

---

## ✅ **FUNCIONALIDADES IMPLEMENTADAS:**

- ✅ Bloqueio automático de acesso
- ✅ Banner de aviso persistente  
- ✅ Indicador visual de status
- ✅ Múltiplos pontos de acesso ao pagamento
- ✅ Interface completa de pagamento
- ✅ Integração Mercado Pago (PIX + Cartão)
- ✅ Verificação automática de pagamentos
- ✅ Ativação automática após pagamento
- ✅ Sistema responsivo e user-friendly

🎉 **O sistema está 100% funcional e pronto para uso comercial!**
