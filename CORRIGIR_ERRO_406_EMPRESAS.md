# 🔧 CORREÇÃO DO ERRO 406 - EMPRESAS

## 🎯 Problema Identificado

O erro **406 (Not Acceptable)** ao buscar empresas indica que:
1. As políticas RLS (Row Level Security) estão bloqueando o acesso
2. O usuário admin pode não ter um registro na tabela `empresas`
3. As políticas podem estar mal configuradas

## 📋 Solução Passo a Passo

### **PASSO 1: Verificar se a empresa existe**

No **Supabase SQL Editor**, execute:

```sql
-- Substituir pelo seu user_id real (c6864d69-a55c-4aca-8fe4-87841ac1084a)
SELECT 
  id,
  nome,
  user_id,
  created_at
FROM empresas
WHERE user_id = 'c6864d69-a55c-4aca-8fe4-87841ac1084a';
```

**Resultado esperado:**
- ✅ Se retornar dados: A empresa existe, passe para o PASSO 2
- ❌ Se retornar vazio: A empresa não existe, passe para o PASSO 3

---

### **PASSO 2: Verificar políticas RLS**

Execute no SQL Editor:

```sql
SELECT 
  policyname,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'empresas';
```

**Se não houver políticas ou estiverem incorretas**, execute o arquivo **`VERIFICAR_RLS_EMPRESAS.sql`** completo.

---

### **PASSO 3: Criar empresa para o admin (se não existir)**

```sql
-- IMPORTANTE: Substitua o user_id pelo seu ID real
INSERT INTO empresas (
  user_id,
  nome,
  cnpj,
  telefone,
  email,
  endereco,
  cidade,
  estado,
  cep
) VALUES (
  'c6864d69-a55c-4aca-8fe4-87841ac1084a', -- SUBSTITUA AQUI
  'Assistência All-Import',
  '00.000.000/0000-00',
  '(11) 99999-9999',
  'contato@allimport.com.br',
  'Rua Exemplo, 123',
  'São Paulo',
  'SP',
  '00000-000'
);
```

---

### **PASSO 4: Verificar subscription**

```sql
-- Verificar se existe subscription para o admin
SELECT 
  id,
  user_id,
  plan_type,
  status,
  subscription_end_date
FROM subscriptions
WHERE user_id = 'c6864d69-a55c-4aca-8fe4-87841ac1084a'; -- SUBSTITUA AQUI
```

**Se não existir**, crie uma:

```sql
INSERT INTO subscriptions (
  user_id,
  plan_type,
  status,
  subscription_start_date,
  subscription_end_date
) VALUES (
  'c6864d69-a55c-4aca-8fe4-87841ac1084a', -- SUBSTITUA AQUI
  'yearly',
  'active',
  NOW(),
  NOW() + INTERVAL '1 year'
);
```

---

### **PASSO 5: Testar no navegador**

Após executar os passos acima:

1. **Recarregue** a página do Admin Dashboard
2. Verifique o console do navegador
3. Deve aparecer: ✅ **Empresa encontrada**

---

## 🔍 Logs Detalhados

O código agora mostra logs detalhados:

```
🔍 Buscando empresa para user_id: c6864d69-a55c-4aca-8fe4-87841ac1084a
📦 Resposta da query empresa: { empresa: {...}, empErr: null }
✅ Empresa encontrada: { nome: 'Assistência All-Import' }
📦 Resposta da query subscription: { sub: {...}, subErr: null }
```

---

## ⚠️ Se o erro persistir

1. **Verifique se o RLS está ativo:**
   ```sql
   SELECT tablename, rowsecurity
   FROM pg_tables 
   WHERE tablename = 'empresas';
   ```

2. **Temporariamente desabilite o RLS para testar:**
   ```sql
   ALTER TABLE empresas DISABLE ROW LEVEL SECURITY;
   ```
   
   ⚠️ **ATENÇÃO:** Reabilite após o teste!
   ```sql
   ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;
   ```

3. **Verifique permissões do usuário:**
   ```sql
   SELECT 
     auth.uid() as current_user_id,
     auth.role() as current_role;
   ```

---

## 📝 Resumo das Alterações no Código

1. ✅ Mudado `.single()` para `.maybeSingle()` (evita erro quando não encontra)
2. ✅ Adicionados logs detalhados com emojis (📦, ✅, ❌)
3. ✅ Tratamento de erro melhorado com detalhes completos
4. ✅ Fallback robusto para casos de erro

---

## 🎯 Próximos Passos

Após corrigir:
1. Teste o Admin Dashboard
2. Verifique se aparece: "Assistência All-Import", "Yearly", "Active"
3. Faça commit das alterações
