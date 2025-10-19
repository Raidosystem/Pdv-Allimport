# 🔧 CORREÇÃO SISTEMA DE PERMISSÕES - RESUMO COMPLETO

## ❌ PROBLEMAS IDENTIFICADOS:

### 1. **Ordem de Serviço sumiu do menu**
**Causa:** `useUserHierarchy.ts` está usando `permission: 'ordens'` mas no banco é `'ordens_servico'`
**Linha:** `src/hooks/useUserHierarchy.ts:151`
**Status:** ✅ CORRIGIDO

### 2. **Permissões de Ordem de Serviço não existem no banco**
**Causa:** Tabela `permissoes` não tem registros para `ordens_servico`
**Solução:** SQL `CRIAR_PERMISSOES_ORDEM_SERVICO.sql`
**Status:** ⚠️ PRECISA EXECUTAR SQL

### 3. **Botões de Excluir aparecem sem verificar permissão**
**Causa:** Falta `can('produtos:delete')` e `can('clientes:delete')` nos botões
**Arquivos afetados:**
- `src/pages/ProductsPage.tsx:417-432`
- `src/components/cliente/ClienteTable.tsx:336-343`
**Status:** 🔴 PRECISA CORRIGIR

## ✅ SOLUÇÕES APLICADAS:

### 1. Corrigido `useUserHierarchy.ts`
```typescript
// ANTES (ERRADO):
{
  name: 'orders',
  permission: 'ordens'  // ❌ ERRADO
}

// DEPOIS (CORRETO):
{
  name: 'orders',
  permission: 'ordens_servico'  // ✅ CORRETO
}
```

## 🔄 PRÓXIMOS PASSOS:

### 1. Executar SQL no Supabase
```sql
-- Arquivo: CRIAR_PERMISSOES_ORDEM_SERVICO.sql
-- Cria as 4 permissões de ordens_servico no banco
```

### 2. Adicionar verificação nos botões de excluir

**ProductsPage.tsx:**
```tsx
{can('produtos', 'delete') && (
  <button 
    className="p-1 text-red-600 hover:text-red-800"
    title="Excluir produto"
    onClick={() => handleExcluirProduto(product.id)}
  >
    <Trash2 className="w-4 h-4" />
  </button>
)}
```

**ClienteTable.tsx:**
```tsx
{can('clientes', 'delete') && (
  <Button
    variant="outline"
    size="sm"
    onClick={() => confirmarExclusao(cliente.id, cliente.nome)}
    className="text-red-600 hover:text-red-800"
  >
    <Trash2 className="w-4 h-4" />
  </Button>
)}
```

## 📊 ESTRUTURA DE PERMISSÕES NO BANCO:

```sql
-- Exemplo de como ficam as permissões:
recurso          | acao    | descricao
-----------------|---------|---------------------------
vendas           | read    | Visualizar vendas
vendas           | create  | Criar vendas
vendas           | update  | Editar vendas
vendas           | delete  | Excluir vendas
produtos         | read    | Visualizar produtos
produtos         | create  | Criar produtos
produtos         | update  | Editar produtos
produtos         | delete  | Excluir produtos  ← CONTROLA BOTÃO
clientes         | read    | Visualizar clientes
clientes         | create  | Criar clientes
clientes         | update  | Editar clientes
clientes         | delete  | Excluir clientes  ← CONTROLA BOTÃO
ordens_servico   | read    | Visualizar OS     ← CRIAR NO BANCO
ordens_servico   | create  | Criar OS          ← CRIAR NO BANCO
ordens_servico   | update  | Editar OS         ← CRIAR NO BANCO
ordens_servico   | delete  | Excluir OS        ← CRIAR NO BANCO
```

## 🎯 TESTE DEPOIS DAS CORREÇÕES:

1. ✅ Menu "OS - Ordem de Serviço" aparece para vendedora?
2. ✅ Vendedora pode criar OS?
3. ✅ Botão Excluir Produto está oculto para vendedora?
4. ✅ Botão Excluir Cliente está oculto para vendedora?
5. ✅ Admin vê todos os botões?

## 🔐 COMO FUNCIONAM AS PERMISSÕES:

```typescript
// Uso correto da função can()
import { usePermissions } from '@/hooks/usePermissions'

const { can } = usePermissions()

// Verificar permissão antes de mostrar botão:
{can('produtos', 'delete') && <BotãoExcluir />}

// Verificar permissão antes de executar ação:
const handleExcluir = () => {
  if (!can('produtos', 'delete')) {
    toast.error('Sem permissão para excluir')
    return
  }
  // ... código de exclusão
}
```

## 📝 RESUMO FINAL:

- ✅ Código TypeScript corrigido (`ordens` → `ordens_servico`)
- ⏳ SQL criado (precisa executar no Supabase)
- ⏳ Botões de excluir precisam de verificação `can()`

**Ordem de execução:**
1. Execute `CRIAR_PERMISSOES_ORDEM_SERVICO.sql` no Supabase
2. Corrija botões de excluir com `can()`
3. Faça deploy do código
4. Teste com funcionária (vendedora/técnica)
