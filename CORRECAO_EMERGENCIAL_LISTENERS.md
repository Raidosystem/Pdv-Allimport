# 🚨 CORREÇÃO EMERGENCIAL

## Problema CRÍTICO Identificado

O código **AINDA TEM** listeners de `visibilitychange` rodando!

### Prova nos Logs:
```
usePermissions.tsx:547 🔔 [usePermissions] Evento visibilitychange disparado!
usePermissions.tsx:557 👁️ [usePermissions] ✅ Aba ficou oculta - flag=true
usePermissions.tsx:561 🔒 [usePermissions] LOCK ATIVADO - bloqueando reloads
```

**Isso NÃO DEVERIA EXISTIR!**

## ✂️ O que DEVE ser removido URGENTE:

### 1. Em `usePermissions.tsx` (linhas ~546-583):
```typescript
// ❌ DELETAR TODO ESTE BLOCO:
globalVisibilityHandler = () => {
  console.log('🔔 [usePermissions] Evento visibilitychange disparado!');
  // ... TODO o código de lock/flags
};
document.addEventListener('visibilitychange', globalVisibilityHandler);
```

### 2. Em `usePermissions.tsx` (linhas ~586-665):
```typescript
// ❌ DELETAR TODO ESTE BLOCO DE SIGNED_IN:
if (event === 'SIGNED_IN') {
  // ... TUDO relacionado a SIGNED_IN
}
```

### 3. Em `useSubscription.ts` (linhas ~159-188):
```typescript
// ❌ DELETAR TODO ESTE BLOCO:
visibilityHandler = () => {
  console.log('🔔 [useSubscription] Evento visibilitychange disparado!');
  // ... TODO o código de lock/flags
};
document.addEventListener('visibilitychange', visibilityHandler);
```

### 4. Em `useSubscription.ts` (linhas ~190-232):
```typescript
// ❌ DELETAR TODO ESTE BLOCO DE SIGNED_IN:
if (event === 'SIGNED_IN') {
  // ... TUDO relacionado a SIGNED_IN
}
```

## ✅ O que DEVE ficar:

### Em ambos os arquivos - APENAS isto:
```typescript
// ✅ MANTER APENAS SIGNED_OUT:
const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
  if (event === 'SIGNED_OUT') {
    console.log('🚪 SIGNED_OUT - limpando dados');
    // limpar estado
  }
});
```

## 🎯 Comportamento Final Esperado:

**Console ao trocar de aba:**
- ✅ Silêncio TOTAL (zero logs!)
- ✅ Nenhum "visibilitychange"
- ✅ Nenhum "SIGNED_IN"  
- ✅ Nenhum "LOCK ATIVADO"

**Console ao fazer logout:**
- ✅ "SIGNED_OUT - limpando dados"

---

**URGENTE**: Edite manualmente ou use ferramenta de busca/substituição para remover TODO o código mencionado acima.

**Status**: 🔴 **CRÍTICO** - Sistema ainda recarregando desnecessariamente
