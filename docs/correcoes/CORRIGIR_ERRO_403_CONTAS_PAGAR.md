# 🔧 CORREÇÃO: Erro 403 ao Salvar Contas a Pagar

## 🐛 Problema Identificado

**Erro**: `403 Forbidden` ao tentar salvar em `contas_pagar`

**Causa**: As políticas RLS (Row Level Security) da tabela `contas_pagar` estão usando `auth.uid()` direto, mas quando um **funcionário** faz login, o `auth.uid()` retorna o ID do funcionário, não do proprietário da empresa.

**Resultado**: O sistema tenta inserir com `user_id` do proprietário mas o RLS compara com `auth.uid()` do funcionário → **403 Forbidden**

## ✅ Solução

Execute o SQL `CORRIGIR_RLS_CONTAS_PAGAR.sql` no Supabase Dashboard → SQL Editor

### O que o SQL faz:

1. **Remove políticas antigas** que usam `auth.uid()` direto
2. **Cria função `get_current_user_id()`** que:
   - Verifica se usuário é funcionário (tem `parent_user_id` no metadata)
   - Se for funcionário: retorna ID do proprietário
   - Se for proprietário: retorna próprio ID
3. **Cria novas políticas** usando `get_current_user_id()` para acesso correto

## 📋 Passo a Passo

### 1. Abrir Supabase Dashboard
```
https://supabase.com/dashboard/project/[seu-projeto]
```

### 2. Ir para SQL Editor
- Menu lateral → **SQL Editor**
- Clicar em **"New Query"**

### 3. Executar SQL de Correção
- Copiar TODO o conteúdo de `CORRIGIR_RLS_CONTAS_PAGAR.sql`
- Colar no editor
- Clicar em **"Run"** (▶️)

### 4. Verificar Resultado
Deve aparecer uma tabela mostrando as 4 políticas criadas:
- `users_select_own_contas_pagar`
- `users_insert_own_contas_pagar`
- `users_update_own_contas_pagar`
- `users_delete_own_contas_pagar`

### 5. Testar no Sistema
- Voltar para o PDV
- Recarregar a página (F5)
- Tentar salvar uma conta a pagar novamente
- Deve funcionar! ✅

## 🔍 Como Funciona

### Antes (❌ QUEBRADO):
```sql
-- Política antiga
CREATE POLICY "Usuários podem inserir suas contas"
  ON contas_pagar
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Cenário:
-- - Funcionário logado: auth.uid() = ID_FUNCIONARIO
-- - Inserindo conta com: user_id = ID_PROPRIETARIO
-- - Resultado: ID_FUNCIONARIO ≠ ID_PROPRIETARIO → 403 Forbidden
```

### Depois (✅ CORRIGIDO):
```sql
-- Política nova
CREATE POLICY "users_insert_own_contas_pagar"
  ON contas_pagar
  FOR INSERT
  WITH CHECK (user_id = get_current_user_id());

-- Função get_current_user_id():
-- - Se funcionário: retorna parent_user_id (ID do proprietário)
-- - Se proprietário: retorna auth.uid() (próprio ID)

-- Cenário:
-- - Funcionário logado: get_current_user_id() = ID_PROPRIETARIO
-- - Inserindo conta com: user_id = ID_PROPRIETARIO
-- - Resultado: ID_PROPRIETARIO = ID_PROPRIETARIO → ✅ Permitido
```

## 🎯 Outras Tabelas Afetadas

Esse mesmo problema pode ocorrer em TODAS as tabelas que usam `auth.uid()` nas políticas RLS. Tabelas que precisam da mesma correção:

- ✅ `contas_pagar` - CORRIGIDO neste SQL
- ⚠️ `produtos` - Verificar se tem problema
- ⚠️ `clientes` - Verificar se tem problema
- ⚠️ `vendas` - Verificar se tem problema
- ⚠️ `ordens_servico` - Verificar se tem problema
- ⚠️ `caixa` - Verificar se tem problema

## 🔧 Diagnóstico Rápido

Para verificar se outras tabelas têm o mesmo problema:

```sql
-- Ver todas as políticas que usam auth.uid() direto
SELECT 
    schemaname,
    tablename,
    policyname,
    qual,
    with_check
FROM pg_policies
WHERE 
    qual LIKE '%auth.uid()%' 
    OR with_check LIKE '%auth.uid()%'
ORDER BY tablename, policyname;
```

Se aparecerem outras tabelas, crie SQL similar substituindo `auth.uid()` por `get_current_user_id()`.

## 📚 Referências

- **Arquivo SQL**: `CORRIGIR_RLS_CONTAS_PAGAR.sql`
- **Tabela original**: `migrations/CRIAR_TABELA_CONTAS_PAGAR.sql`
- **Função helper**: `get_current_user_id()` (criada no SQL de correção)

---

**Status**: ⚠️ **AGUARDANDO EXECUÇÃO DO SQL**  
**Após executar**: Sistema deve funcionar normalmente para funcionários
