# ✅ Correção Definitiva: Reloads em Troca de Aba

## 🚨 Problema Identificado

Ao trocar de aba (sair e voltar), o sistema estava:
- **Recarregando permissões** desnecessariamente
- **Fazendo reload** do contexto de assinatura
- **Perdendo dados** de formulários/editores em uso
- **Disparando múltiplos listeners** que forçavam recarga

### Causas Raiz

1. **Evento `SIGNED_IN` do Supabase** dispara ao voltar para aba (PKCE flow)
2. **Listeners de eventos customizados** (`pdv_permissions_reload`, `storage`, `pdv_storage_change`) estavam **sempre recarregando** sem verificar contexto
3. **Falta de proteção temporal** após `visibilitychange`

## 🔧 Solução Implementada

### 1. **Lock Temporal (500ms)**
Quando a aba fica oculta:
- ✅ Ativa `visibilityLockRef.current = true`
- 🔒 **Bloqueia QUALQUER reload** por 500ms após voltar
- 🔓 Libera automaticamente após o delay

```typescript
if (document.visibilityState === 'hidden') {
  visibilityLockRef.current = true;
  console.log('🔒 LOCK ATIVADO - bloqueando reloads');
}

setTimeout(() => {
  visibilityLockRef.current = false;
  console.log('🔓 LOCK DESATIVADO');
}, 500);
```

### 2. **Guardas em Todos os Listeners**

#### `handlePermissionsReload`
```typescript
if (contextLoadedRef.current && lastEmailRef.current) {
  console.log('⛔ IGNORANDO - contexto já carregado');
  return;
}
```

#### `handleStorageChange`
```typescript
if (contextLoadedRef.current && lastEmailRef.current) {
  console.log('⛔ IGNORANDO storage change');
  return;
}
```

#### `handleCustomStorageChange`
```typescript
if (contextLoadedRef.current && lastEmailRef.current) {
  console.log('⛔ IGNORANDO custom storage');
  return;
}
```

### 3. **Verificação no `loadPermissions()`**

```typescript
// 🚨 LOCK GLOBAL: Bloquear QUALQUER reload após visibilitychange
if (visibilityLockRef.current) {
  console.log('🔒 LOCK ATIVO - bloqueando reload');
  return;
}

// ✅ PREVENIR RELOAD SE JÁ TEM CONTEXTO VÁLIDO
if (contextRef.current !== null && contextLoadedRef.current) {
  console.log('✅ Contexto já carregado - ABORTANDO');
  return;
}
```

### 4. **Mesma Proteção no `useSubscription`**

Estado compartilhado entre instâncias:
```typescript
let sharedVisibilityLock = false

if (sharedVisibilityLock) {
  console.log('🔒 LOCK ATIVO - bloqueando reload');
  return;
}
```

## 📊 Fluxo Corrigido

### ❌ Antes (com reload)
1. Usuário edita formulário
2. Troca de aba para pesquisar
3. `visibilitychange` (hidden)
4. Volta para aba
5. `visibilitychange` (visible)
6. `SIGNED_IN` dispara
7. ❌ **`loadPermissions()` executa**
8. ❌ **Contexto recarrega**
9. ❌ **Editor perde foco/dados**

### ✅ Agora (sem reload)
1. Usuário edita formulário
2. Troca de aba para pesquisar
3. `visibilitychange` (hidden) → 🔒 **LOCK ATIVO**
4. Volta para aba
5. `visibilitychange` (visible) → ⏰ **Aguarda 500ms**
6. `SIGNED_IN` dispara → ⛔ **BLOQUEADO pelo lock**
7. ✅ **Nenhum reload**
8. ✅ **Editor mantém estado**
9. 🔓 **Lock desativa após 500ms**

## 🧪 Como Testar

1. **Abrir PDV em duas abas**
2. **Fazer login** em ambas
3. **Abrir um formulário de edição** (produto, cliente, etc)
4. **Preencher alguns campos**
5. **Trocar de aba** (pesquisar algo em outra aba)
6. **Voltar para aba do formulário**

### ✅ Comportamento Esperado
- ✅ Editor mantém todos os dados preenchidos
- ✅ Console mostra: `🔒 LOCK ATIVO - bloqueando reload`
- ✅ Nenhum log de `loadPermissions()` ou `loadSubscriptionData()`
- ✅ Após 500ms: `🔓 LOCK DESATIVADO`

### ❌ Se ainda houver problema
Verificar no console:
- Algum listener disparando `setContextLoaded(false)` 
- Chamadas a `loadPermissions()` após lock desativado
- Eventos que não foram capturados pelas guardas

## 📝 Arquivos Modificados

1. **[src/hooks/usePermissions.tsx](src/hooks/usePermissions.tsx)**
   - Adicionado `visibilityLockRef`
   - Lock de 500ms após `visibilitychange`
   - Guardas em `handlePermissionsReload`, `handleStorageChange`, `handleCustomStorageChange`

2. **[src/hooks/useSubscription.ts](src/hooks/useSubscription.ts)**
   - Adicionado `sharedVisibilityLock`
   - Lock de 500ms no `visibilityHandler`
   - Verificação de lock em `loadSubscriptionData`

## 🎯 Resultado Final

- ✅ **Zero reloads** em troca de aba
- ✅ **Formulários preservados**
- ✅ **Performance melhorada** (menos chamadas ao banco)
- ✅ **UX aprimorada** (sem interrupções)

---

**Data**: 21/12/2025  
**Status**: ✅ Refatoração RADICAL Aplicada - Zero Listeners

## 🚨 Mudança de Abordagem

Após análise, o problema era o **excesso de listeners**. A solução definitiva foi:

### ❌ Removido COMPLETAMENTE:
- ✂️ Listener `visibilitychange` 
- ✂️ Listener `SIGNED_IN` do `onAuthStateChange`
- ✂️ Todos os locks e flags de visibilidade
- ✂️ Verificações complexas de reload

### ✅ Mantido APENAS:
- ✅ Carregamento **UMA VEZ** no mount inicial
- ✅ Listener **MINIMAL** de `SIGNED_OUT` (para limpar ao fazer logout)
- ✅ Sistema singleton de listeners (1 por aba)

## 🎯 Comportamento Final

Como qualquer sistema de login moderno:
1. **Login** → Carrega permissões **UMA VEZ**
2. **Navega entre páginas** → ✅ Sem reloads
3. **Troca de aba** → ✅ Sem reloads
4. **Logout** → Limpa tudo e aguarda próximo login

**Resultado**: **ZERO reloads** desnecessários, exatamente como Gmail, Facebook, etc.
