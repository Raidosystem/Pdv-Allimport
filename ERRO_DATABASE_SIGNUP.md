# 🔧 Erro: Database error saving new user

## 🎯 Problema
**Erro ao cadastrar novo usuário:**
```
AuthApiError: Database error saving new user
Status: 500
Code: unexpected_failure
```

## 🔍 Causa Provável

O erro 500 indica que há um **trigger ou função** no banco de dados que executa após criar o usuário em `auth.users`, e está falhando.

**Possíveis causas:**
1. **Trigger `on_auth_user_created`** com erro
2. **Função `handle_new_user()`** com problema
3. **Constraint violation** (chave única, NOT NULL, etc.)
4. **Permissões insuficientes** (SECURITY DEFINER)

## 🛠️ Soluções

### Opção 1: Verificar Logs do Supabase (Recomendado)

1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/logs/postgres-logs
2. Filtre por "error" ou "500"
3. Veja a mensagem de erro detalhada
4. Identifique qual coluna/constraint está causando o problema

### Opção 2: Executar Script de Correção

**Arquivo:** `corrigir-trigger-signup.sql`

1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql/new
2. Cole o conteúdo do arquivo
3. Execute **PASSO A PASSO** (não tudo de uma vez):
   - Primeiro: Seção 1 (verificar triggers)
   - Segundo: Seção 2 (verificar funções)
   - Terceiro: Seções 5 e 6 (recriar trigger simplificado)

### Opção 3: Desabilitar Trigger Temporariamente

**⚠️ USO TEMPORÁRIO - Apenas para testar**

```sql
-- Desabilitar trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Testar cadastro (deve funcionar)

-- Reabilitar depois
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

## 📋 Checklist de Diagnóstico

Execute no SQL Editor para identificar o problema:

```sql
-- 1. Verificar estrutura da tabela empresas
\d empresas

-- 2. Verificar constraints
SELECT 
  conname as constraint_name,
  contype as constraint_type,
  pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'empresas'::regclass;

-- 3. Verificar triggers ativos
SELECT * FROM information_schema.triggers
WHERE event_object_table = 'users'
  AND event_object_schema = 'auth';

-- 4. Testar função manualmente
SELECT public.handle_new_user();
```

## 🔍 Erros Comuns

### 1. Coluna NOT NULL sem valor default
```
ERROR: null value in column "X" violates not-null constraint
```
**Solução:** Adicionar valor default na função ou tornar coluna nullable

### 2. Constraint de chave única
```
ERROR: duplicate key value violates unique constraint "empresas_user_id_key"
```
**Solução:** Adicionar `ON CONFLICT DO NOTHING` ou `DO UPDATE`

### 3. Permissão negada
```
ERROR: permission denied for table empresas
```
**Solução:** Adicionar `SECURITY DEFINER` na função

### 4. Coluna não existe
```
ERROR: column "X" does not exist
```
**Solução:** Verificar se a coluna existe na tabela

## ✅ Solução Aplicada

O script `corrigir-trigger-signup.sql` cria uma versão **simplificada e segura** da função `handle_new_user()` que:

1. ✅ Usa `COALESCE` para valores opcionais
2. ✅ Define valores default seguros
3. ✅ Usa `ON CONFLICT DO NOTHING` para evitar duplicatas
4. ✅ Captura exceções sem bloquear o signup
5. ✅ Loga warnings mas retorna sucesso

## 🎯 Próximos Passos

1. **Verifique os logs do Supabase** primeiro
2. **Execute o script de correção** passo a passo
3. **Teste o cadastro novamente**
4. **Reporte aqui** o que encontrou nos logs

---

## 📞 Se o Problema Persistir

Me informe:
1. ✅ Mensagem de erro dos logs do Supabase
2. ✅ Resultado da query de verificação de triggers
3. ✅ Estrutura da tabela `empresas` (se mudou)
