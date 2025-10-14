# 🚀 CORREÇÃO RÁPIDA - 15 DIAS GRATUITOS

## ❌ ERRO QUE VOCÊ VIU:
```
column "email_verified" does not exist
```

## ✅ SOLUÇÃO (2 MINUTOS):

### **Passo 1: Acessar Supabase**
Vá para: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql

### **Passo 2: Copiar e Colar o SQL**

Abra o arquivo `SOLUCAO_COMPLETA_15_DIAS.sql` que acabei de criar e:
1. Copie TODO o conteúdo
2. Cole no SQL Editor do Supabase
3. Clique em **RUN**

### **Passo 3: Corrigir Seu Usuário Atual**

Após executar o SQL acima, execute este (substitua o email):

```sql
-- Substituir 'seu-email@exemplo.com' pelo email que você usou no cadastro
SELECT activate_user_after_email_verification('seu-email@exemplo.com');
```

### **Passo 4: Verificar**

```sql
SELECT 
  email,
  status,
  EXTRACT(DAY FROM (subscription_end_date - NOW())) as dias_restantes
FROM public.subscriptions
WHERE email = 'seu-email@exemplo.com';
```

**Resultado esperado:**
- status: `trial`
- dias_restantes: `15`

### **Passo 5: Fazer Logout e Login Novamente**

1. No sistema, faça **logout**
2. Faça **login** novamente
3. Você verá: **"15 dias restantes"** 🎉

---

## 🎯 RESUMO DO QUE O SQL FAZ:

1. ✅ Adiciona a coluna `email_verified` (que estava faltando)
2. ✅ Adiciona as colunas `trial_start_date` e `trial_end_date`
3. ✅ Cria a função `activate_user_after_email_verification`
4. ✅ Testa a função automaticamente
5. ✅ Deixa tudo pronto para funcionar

---

## 📝 PARA NOVOS CADASTROS:

Depois de executar o SQL, **todos os novos usuários** que se cadastrarem receberão automaticamente **15 dias de teste gratuito** após verificar o email!

---

## 🆘 AINDA COM PROBLEMAS?

Se o erro persistir, me envie o resultado deste SQL:

```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'subscriptions';
```
