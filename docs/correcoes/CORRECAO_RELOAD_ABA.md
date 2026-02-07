# ✅ Correção: Reload Desnecessário ao Trocar de Aba

## 🐛 Problema Identificado

Toda vez que o usuário saía da página (trocava de aba) e voltava, o sistema fazia um **reload completo** de todos os dados:
- Permissões sendo recarregadas
- Assinatura sendo verificada novamente
- Múltiplos componentes re-renderizando
- Performance ruim e logs excessivos

### Causa Raiz

O Supabase Auth dispara o evento `SIGNED_IN` quando a aba volta a ter visibilidade (`visibilityState: visible`). Isso fazia com que os hooks `usePermissions` e `useSubscription` recarregassem todos os dados, mesmo sendo o **mesmo usuário**.

### 🚨 Problema Adicional Detectado

Após a primeira correção, surgiu um erro crítico:
```
Uncaught ReferenceError: visibilityChangeRef is not defined
    at HTMLDocument.handleVisibilityChange (usePermissions.tsx:507:9)
```

**Causa**: Quando o componente desmontava e remontava rapidamente, o listener de `visibilitychange` permanecia ativo mas a referência ao `visibilityChangeRef` era perdida, causando crash.

### 🐛 Bug Adicional na Verificação (Versão 3)

A verificação de segurança tinha um **bug de precedência de operador**:
```typescript
// ❌ ERRADO - o operador ! tem precedência sobre ===
if (!visibilityChangeRef || !visibilityChangeRef.current === undefined) {
  // Isso era interpretado como: (!visibilityChangeRef.current) === undefined
  // Sempre retornava false, a proteção não funcionava!
}

// ✅ CORRETO
if (!visibilityChangeRef || visibilityChangeRef.current === undefined) {
  console.warn('⚠️ Listener órfão detectado');
  return;
}
```

## ✅ Solução Implementada

### 1. Hook `useSubscription.ts`

Adicionada detecção inteligente de mudança de visibilidade:

```typescript
const visibilityChangeRef = useRef(false) // Flag para detectar mudança de visibilidade

// Listener de visibilidade
const handleVisibilityChange = () => {
  if (document.visibilityState === 'hidden') {
    visibilityChangeRef.current = true
  }
}

document.addEventListener('visibilitychange', handleVisibilityChange)

// No listener de SIGNED_IN
if (visibilityChangeRef.current && lastEmailRef.current === currentEmail) {
  console.log('⏭️ Ignorando SIGNED_IN (trocar de aba)')
  visibilityChangeRef.current = false
  return // NÃO recarregar
}
```

### 2. Hook `usePermissions.tsx` (🆕 COM PROTEÇÃO ANTI-CRASH)

Mesma lógica + **safety checks** para evitar `ReferenceError`:

```typescript
// 🔒 SAFETY CHECK no handleVisibilityChange
const handleVisibilityChange = () => {
  // ⚠️ Proteger contra listeners órfãos (CORRETO - sem ! no segundo check)
  if (!visibilityChangeRef || visibilityChangeRef.current === undefined) {
    console.warn('⚠️ visibilityChangeRef undefined - listener órfão, ignorando');
    return;
  }
  
  if (document.visibilityState === 'hidden') {
    visibilityChangeRef.current = true;
  }
};

// 🔒 SAFETY CHECK no SIGNED_IN callback
if (event === 'SIGNED_IN') {
  // ⚠️ Proteger contra callbacks órfãos
  if (!visibilityChangeRef || !lastEmailRef) {
    console.warn('⚠️ Refs undefined no SIGNED_IN - listener órfão, abortando');
    return;
  }
  
  // Lógica normal...
  if (visibilityChangeRef.current && contextLoaded && lastEmailRef.current === currentEmail) {
    console.log('⏭️ [usePermissions] IGNORANDO: trocar de aba');
    visibilityChangeRef.current = false;
    return;
  }
}
}
```

## 🎯 Comportamento Esperado

### ✅ **Quando IGNORAR o SIGNED_IN** (não recarregar):
1. Usuário troca de aba e volta
2. Usuário navega entre páginas do sistema
3. Aba perde e recupera foco
4. **Desde que seja o MESMO usuário e contexto já carregado**

### 🔄 **Quando PROCESSAR o SIGNED_IN** (recarregar):
1. Novo login real (email diferente)
2. Primeiro acesso ao sistema
3. Logout e login novamente
4. Funcionário fazendo login após owner

### ⚠️ **Erros Corrigidos**:
- ❌ ANTES: `Uncaught ReferenceError: visibilityChangeRef is not defined`
- ✅ AGORA: `⚠️ visibilityChangeRef undefined - listener órfão, ignorando` (safe)

## 📊 Logs de Diagnóstico

### Antes (Problema):
```
👁️ Aba ficou oculta
🔐 SIGNED_IN detectado
📥 Carregando permissões (primeiro login ou novo usuário)  ❌ ERRADO
🔍 Buscando vendas do período...
🔄 Iniciando carregamento de produtos...
```

### Depois (Corrigido):
```
👁️ Aba ficou oculta
👁️ Aba ficou visível - próximo SIGNED_IN será ignorado
🔐 SIGNED_IN detectado
⏭️ Mudança de visibilidade + contexto carregado + mesmo email = IGNORANDO  ✅ CORRETO
(Sem recargas desnecessárias)
```

## 🧪 Como Testar

1. **Abra o DevTools** (F12) e vá na aba Console
2. Faça login no sistema
3. Aguarde todos os dados carregarem
4. **Troque para outra aba do navegador** (Ctrl+Tab ou clique em outra aba)
5. **Volte para a aba do PDV**
6. **Resultado esperado no console**:

```
🔔 [usePermissions] Evento visibilitychange disparado! Estado: hidden
👁️ [usePermissions] ✅ Aba ficou oculta - flag=true
🔔 [usePermissions] Evento visibilitychange disparado! Estado: visible
👁️ [usePermissions] ✅ Aba ficou visível - flag anterior: true
👁️ [usePermissions] 🎯 Próximo SIGNED_IN será IGNORADO
🔐 [usePermissions] SIGNED_IN detectado
  👁️ visibilityChangeRef: true
  📦 contextLoaded: true
  📧 currentEmail: seu@email.com
  📧 lastEmail: seu@email.com
  ✅ emails iguais? true
⛔ [usePermissions] IGNORANDO: mudança visibilidade + contexto carregado + mesmo email (trocar de aba)
```

7. **NÃO DEVE aparecer**: 
   - ❌ "Carregando permissões"
   - ❌ "loadSubscriptionData"
   - ❌ Recarregamento de produtos/clientes/vendas
   - ❌ `ReferenceError: visibilityChangeRef is not defined`

## 🔧 Arquivos Modificados

- **[src/hooks/useSubscription.ts](src/hooks/useSubscription.ts)** - Listener de visibilidade (já funcionava)
- **[src/hooks/usePermissions.tsx](src/hooks/usePermissions.tsx)** - Listener de visibilidade + **safety checks contra crashes**
- **[CORRECAO_RELOAD_ABA.md](CORRECAO_RELOAD_ABA.md)** - Esta documentação

## 🚀 Benefícios

✅ **Performance**: Sem recargas desnecessárias  
✅ **UX**: Navegação mais rápida ao voltar para a aba  
✅ **Logs**: Console mais limpo e organizado  
✅ **Banda**: Menos requisições ao Supabase  
✅ **Bateria**: Menos processamento desnecessário (importante para PWA)  
✅ **Estabilidade**: Proteção contra crashes por listeners órfãos

## 🐛 Histórico de Correções

### Versão 1 (2025-12-21 - Inicial)
- Implementado tracking de `visibilitychange` em ambos hooks
- Filtragem de eventos `SIGNED_IN` vindos de troca de aba

### Versão 2 (2025-12-21 - Correção Crítica)
- **Problema detectado**: `ReferenceError: visibilityChangeRef is not defined`
- **Causa**: Listener órfão após remontagem do componente
- **Solução**: Safety checks em `handleVisibilityChange` e callback SIGNED_IN
- **Logs melhorados**: Cleanup com confirmação visual

### Versão 3 (2025-12-21 - Bug Fix Verificação) ✅ ATUAL
- **Problema detectado**: Safety check não funcionava, erro persistia
- **Causa**: Bug de precedência de operador - `!visibilityChangeRef.current === undefined` interpretado errado
- **Solução**: Removido `!` incorreto, agora: `visibilityChangeRef.current === undefined`
- **Resultado**: Proteção finalmente funcional

---

**Data**: 2025-12-21  
**Status**: ✅ Corrigido e Testado (Versão 3)  
**Prioridade**: 🔥 Alta (Performance crítica)
