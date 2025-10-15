# 🔍 DEBUG - Por que o indicador de dias não aparece?

## Possíveis Causas:

1. **Cache do navegador/React Query**
2. **Hook useSubscription retornando dados incorretos**
3. **Componente verificando `isActive` que pode estar false**

---

## 📋 Checklist de Verificação:

### 1. Abra o Console do Navegador (F12)

Procure por mensagens de erro ou logs relacionados a subscription.

### 2. Execute este SQL para confirmar os dados:

```sql
-- Verificar seus dados
SELECT 
  u.email,
  s.status,
  s.plan_type,
  s.subscription_end_date,
  EXTRACT(DAY FROM (s.subscription_end_date - NOW()))::integer as dias_calculados,
  check_subscription_status(u.email) as status_api
FROM auth.users u
JOIN subscriptions s ON s.user_id = u.id
WHERE u.email = 'cris-ramos30@hotmail.com';
```

### 3. Teste a função RPC diretamente:

```sql
SELECT check_subscription_status('cris-ramos30@hotmail.com');
```

**Resultado esperado:**
```json
{
  "has_subscription": true,
  "status": "active",
  "access_allowed": true,
  "plan_type": "premium",
  "subscription_end_date": "2026-10-14...",
  "days_remaining": 365
}
```

---

## 🛠️ Solução Rápida:

Execute este SQL para adicionar logs de debug na função:

```sql
CREATE OR REPLACE FUNCTION check_subscription_status(user_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
  v_subscription record;
BEGIN
  RAISE NOTICE 'check_subscription_status: Buscando email %', user_email;
  
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email = user_email;

  IF v_user_id IS NULL THEN
    RAISE NOTICE 'check_subscription_status: Usuário não encontrado';
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_user',
      'access_allowed', false
    );
  END IF;

  SELECT * INTO v_subscription
  FROM subscriptions
  WHERE user_id = v_user_id;

  IF NOT FOUND THEN
    RAISE NOTICE 'check_subscription_status: Sem assinatura';
    RETURN json_build_object(
      'has_subscription', false,
      'status', 'no_subscription',
      'access_allowed', false
    );
  END IF;

  RAISE NOTICE 'check_subscription_status: Status=%, End=%, Now=%', 
    v_subscription.status, 
    v_subscription.subscription_end_date, 
    NOW();

  IF v_subscription.status = 'active' THEN
    IF v_subscription.subscription_end_date IS NULL OR v_subscription.subscription_end_date > NOW() THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'active',
        'access_allowed', true,
        'plan_type', v_subscription.plan_type,
        'subscription_end_date', v_subscription.subscription_end_date,
        'days_remaining', COALESCE(EXTRACT(DAY FROM (v_subscription.subscription_end_date - NOW()))::integer, 999)
      );
    END IF;
  ELSIF v_subscription.status = 'trial' THEN
    IF v_subscription.trial_end_date IS NULL OR v_subscription.trial_end_date > NOW() THEN
      RETURN json_build_object(
        'has_subscription', true,
        'status', 'trial',
        'access_allowed', true,
        'plan_type', 'free',
        'trial_end_date', v_subscription.trial_end_date,
        'days_remaining', COALESCE(EXTRACT(DAY FROM (v_subscription.trial_end_date - NOW()))::integer, 15)
      );
    END IF;
  END IF;

  RETURN json_build_object(
    'has_subscription', true,
    'status', 'expired',
    'access_allowed', false,
    'days_remaining', 0
  );
END;
$$;
```

---

## 🔧 Solução Alternativa (Imediata):

Se os dados estiverem corretos no banco mas o componente não aparecer, force a atualização:

1. **Logout completo**
2. **Limpe o cache** (Ctrl+Shift+Delete)
3. **Limpe o localStorage**: No console do navegador digite:
   ```javascript
   localStorage.clear()
   sessionStorage.clear()
   ```
4. **Recarregue** (Ctrl+F5)
5. **Faça login novamente**

---

## 📊 Me envie:

1. O resultado do SQL de verificação
2. Print ou texto do console do navegador (F12 → Console)
3. Confirme se aparece alguma informação de assinatura na tela (mesmo que não seja o badge verde)
