# 🔧 PROBLEMA IDENTIFICADO: Check Constraint Violation

## ❌ Erro Encontrado

```
❌ Erro ao adicionar dias: {
  "code": "23514",
  "message": "new row for relation \"subscriptions\" violates check constraint \"subscriptions_plan_type_check\""
}
```

## 🔍 Causa Raiz

A tabela `subscriptions` no banco de dados tem uma **constraint CHECK** que define quais valores são permitidos para `plan_type` e `status`.

O erro ocorre porque:
1. A constraint atual pode estar configurada **diferentemente** do esperado
2. Pode haver valores **maiúsculos** vs **minúsculos** (ex: "Premium" vs "premium")
3. Pode haver valores **antigos** que não estão na lista permitida

## 📋 Constraint Esperada

```sql
plan_type TEXT CHECK (plan_type IN ('free', 'trial', 'basic', 'premium', 'enterprise'))
status TEXT CHECK (status IN ('pending', 'trial', 'active', 'expired', 'cancelled'))
```

## ✅ Solução Implementada

Foram criados 2 scripts SQL:

### 1️⃣ `DIAGNOSTICAR_SUBSCRIPTIONS.sql`
- Verifica a estrutura atual da tabela
- Lista todas as constraints existentes
- Mostra valores atuais em plan_type e status
- Exibe todos os registros

### 2️⃣ `CORRIGIR_CONSTRAINT_SUBSCRIPTIONS.sql`
- **Remove constraints antigas** (que podem estar incorretas)
- **Recria constraints corretas** com valores em minúsculas
- **Atualiza valores inválidos** nos registros existentes
- **Verifica** se a correção funcionou

## 🚀 Próximos Passos

### Passo 1: Executar Diagnóstico (Opcional)
No Supabase SQL Editor, execute:
```sql
-- Conteúdo de DIAGNOSTICAR_SUBSCRIPTIONS.sql
```
Isso vai mostrar qual é o problema exato.

### Passo 2: Executar Correção (OBRIGATÓRIO)
No Supabase SQL Editor, execute:
```sql
-- Conteúdo de CORRIGIR_CONSTRAINT_SUBSCRIPTIONS.sql
```

### Passo 3: Testar no Admin Dashboard
1. Acesse o Admin Dashboard
2. Selecione um assinante
3. Clique em "Adicionar Dias"
4. Insira o número de dias e o tipo de plano
5. Confirme

## 🎯 Resultado Esperado

Após executar `CORRIGIR_CONSTRAINT_SUBSCRIPTIONS.sql`:

✅ Constraint antiga removida
✅ Constraint nova criada com valores corretos
✅ Valores inválidos atualizados
✅ "Adicionar Dias" funcionando perfeitamente

## 📌 Observação Importante

**Todos os valores devem estar em MINÚSCULAS:**
- ✅ `premium` (correto)
- ❌ `Premium` (errado)
- ✅ `active` (correto)
- ❌ `Active` (errado)

## 🔄 Se o Problema Persistir

Execute este comando para ver os detalhes exatos da constraint:

```sql
SELECT 
  conname as constraint_name,
  pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'subscriptions'::regclass
  AND contype = 'c';
```

Envie o resultado e poderei ajustar o script de correção.
