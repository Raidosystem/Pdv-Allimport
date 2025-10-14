# 🚨 CORREÇÃO URGENTE: 15 DIAS GRATUITOS NÃO ESTÃO SENDO APLICADOS

## ❌ Problema Identificado

Após o cadastro e verificação do código, o usuário é redirecionado para a **página de pagamento** em vez de receber **15 dias de teste gratuito**.

**Causa:** A função `activate_user_after_email_verification` pode não estar funcionando corretamente ou não está sendo executada.

---

## ✅ SOLUÇÃO - PASSO A PASSO

### **Passo 1: Acessar o Supabase SQL Editor**

1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql
2. Faça login

### **Passo 2: Executar o SQL de Correção**

Copie e cole o SQL abaixo no **SQL Editor** do Supabase:

```sql
-- ========================================
-- RECRIAR FUNÇÃO DE ATIVAÇÃO COM 15 DIAS
-- ========================================

CREATE OR REPLACE FUNCTION activate_user_after_email_verification(
  user_email TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  subscription_record public.subscriptions%ROWTYPE;
  trial_end_date TIMESTAMPTZ;
  result_data JSONB;
BEGIN
  RAISE NOTICE '🎯 Ativando usuário: %', user_email;

  -- Calcular 15 dias de teste a partir de AGORA
  trial_end_date := NOW() + INTERVAL '15 days';
  
  RAISE NOTICE '📅 Data de fim do teste: %', trial_end_date;

  -- Buscar assinatura existente
  SELECT * INTO subscription_record 
  FROM public.subscriptions 
  WHERE email = user_email;

  IF NOT FOUND THEN
    -- Criar nova assinatura com 15 dias de teste
    RAISE NOTICE '✨ Criando nova assinatura com 15 dias de teste';
    
    INSERT INTO public.subscriptions (
      email,
      status,
      subscription_start_date,
      subscription_end_date,
      trial_start_date,
      trial_end_date,
      email_verified,
      created_at,
      updated_at
    ) VALUES (
      user_email,
      'trial',
      NOW(),
      trial_end_date,
      NOW(),
      trial_end_date,
      TRUE,
      NOW(),
      NOW()
    ) RETURNING * INTO subscription_record;
    
    RAISE NOTICE '✅ Assinatura criada! ID: %', subscription_record.id;
  ELSE
    -- Atualizar assinatura existente para ativar teste
    RAISE NOTICE '🔄 Atualizando assinatura existente: %', subscription_record.id;
    
    UPDATE public.subscriptions 
    SET 
      email_verified = TRUE,
      status = 'trial',
      subscription_start_date = NOW(),
      subscription_end_date = trial_end_date,
      trial_start_date = NOW(),
      trial_end_date = trial_end_date,
      updated_at = NOW()
    WHERE id = subscription_record.id
    RETURNING * INTO subscription_record;
    
    RAISE NOTICE '✅ Assinatura atualizada!';
  END IF;

  -- Preparar resposta
  result_data := jsonb_build_object(
    'success', TRUE,
    'message', 'Email verificado e 15 dias de teste ativados!',
    'subscription', jsonb_build_object(
      'id', subscription_record.id,
      'email', subscription_record.email,
      'status', subscription_record.status,
      'trial_end_date', subscription_record.subscription_end_date,
      'subscription_end_date', subscription_record.subscription_end_date,
      'days_remaining', EXTRACT(DAY FROM (subscription_record.subscription_end_date - NOW()))
    )
  );

  RAISE NOTICE '📊 Resultado: %', result_data;

  RETURN result_data;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro: %', SQLERRM;
    RETURN jsonb_build_object(
      'success', FALSE,
      'error', SQLERRM
    );
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION activate_user_after_email_verification(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION activate_user_after_email_verification(TEXT) TO anon;

COMMENT ON FUNCTION activate_user_after_email_verification(TEXT) IS 
'Ativa usuário após verificação de email, concedendo 15 dias de teste gratuito';
```

3. Clique em **RUN** para executar

### **Passo 3: Corrigir Usuário Atual (se já cadastrou)**

Se você já fez um cadastro e não recebeu os 15 dias, execute este SQL (substitua o email):

```sql
-- Substituir 'seu-email@exemplo.com' pelo seu email real
UPDATE public.subscriptions
SET 
  status = 'trial',
  subscription_start_date = NOW(),
  subscription_end_date = NOW() + INTERVAL '15 days',
  trial_start_date = NOW(),
  trial_end_date = NOW() + INTERVAL '15 days',
  email_verified = TRUE,
  updated_at = NOW()
WHERE email = 'seu-email@exemplo.com';

-- Verificar se foi atualizado
SELECT 
  email,
  status,
  EXTRACT(DAY FROM (subscription_end_date - NOW())) as dias_restantes,
  subscription_start_date,
  subscription_end_date
FROM public.subscriptions
WHERE email = 'seu-email@exemplo.com';
```

### **Passo 4: Verificar Estrutura da Tabela**

Execute este SQL para garantir que a tabela tem todas as colunas necessárias:

```sql
-- Verificar colunas da tabela subscriptions
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'subscriptions'
ORDER BY ordinal_position;
```

**Colunas necessárias:**
- `email` (text)
- `status` (text)
- `subscription_start_date` (timestamptz)
- `subscription_end_date` (timestamptz)
- `trial_start_date` (timestamptz)
- `trial_end_date` (timestamptz)
- `email_verified` (boolean)

**Se faltar alguma coluna**, execute:

```sql
-- Adicionar colunas se não existirem
ALTER TABLE public.subscriptions 
ADD COLUMN IF NOT EXISTS trial_start_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS trial_end_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE;
```

---

## 🧪 TESTAR A CORREÇÃO

### **Teste 1: Testar a função diretamente**

```sql
-- Testar com um email de teste
SELECT activate_user_after_email_verification('teste@exemplo.com');
```

**Resultado esperado:**
```json
{
  "success": true,
  "message": "Email verificado e 15 dias de teste ativados!",
  "subscription": {
    "id": "...",
    "email": "teste@exemplo.com",
    "status": "trial",
    "days_remaining": 15
  }
}
```

### **Teste 2: Verificar assinatura criada**

```sql
SELECT 
  email,
  status,
  email_verified,
  EXTRACT(DAY FROM (subscription_end_date - NOW())) as dias_restantes,
  subscription_start_date,
  subscription_end_date
FROM public.subscriptions
WHERE email = 'teste@exemplo.com';
```

---

## 🔄 TESTAR NO FRONTEND

Após aplicar as correções SQL:

1. **Recarregue a página** no navegador (Ctrl+F5)
2. **Faça logout** se estiver logado
3. **Faça um novo cadastro** com email diferente
4. **Verifique o código** que chegar no email
5. **Resultado esperado:**
   - ✅ "Bem-vindo! Você tem 15 dias de teste gratuito!"
   - ✅ Acesso ao dashboard
   - ✅ Contador mostrando 15 dias restantes

---

## 📊 MONITORAR LOGS

Para ver os logs da função sendo executada:

```sql
-- Ver logs recentes (se configurado)
SELECT * FROM pg_stat_statements
WHERE query LIKE '%activate_user_after_email_verification%'
ORDER BY calls DESC
LIMIT 10;
```

---

## 🆘 SE O PROBLEMA PERSISTIR

Se mesmo após aplicar as correções o erro continuar:

1. **Verificar se a função existe:**
```sql
SELECT routine_name 
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'activate_user_after_email_verification';
```

2. **Verificar chamadas da função no console do navegador:**
   - Abra DevTools (F12)
   - Vá para Console
   - Procure por logs: `"🎯 Ativando usuário"`

3. **Verificar se a tabela subscriptions existe:**
```sql
SELECT * FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'subscriptions';
```

---

## ✅ CHECKLIST

- [ ] Acessei o Supabase SQL Editor
- [ ] Executei o SQL de criação da função
- [ ] Testei a função com email de teste
- [ ] Verifiquei que retornou success = true
- [ ] Corrigi meu usuário atual (se necessário)
- [ ] Recarreguei a página no navegador
- [ ] Testei novo cadastro
- [ ] Recebi os 15 dias de teste!

---

**Após seguir esses passos, o sistema estará funcionando corretamente e todos os novos usuários receberão 15 dias de teste gratuito automaticamente!** 🎉
