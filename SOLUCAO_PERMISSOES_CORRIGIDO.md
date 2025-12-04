# 🔧 SOLUÇÃO - Sistema de Permissões Corrigido

## 🎯 PROBLEMA IDENTIFICADO

O sistema tinha **DOIS sistemas de permissões conflitantes**:

### Sistema ANTIGO (JSONB) ✅ EM USO
```typescript
funcionarios.permissoes = {
  vendas: true,
  produtos: true,
  clientes: true,
  caixa: false,
  relatorios: false,
  ordens_servico: true,
  ...
}
```

### Sistema NOVO (Tabelas Relacionadas) ❌ PARCIALMENTE IMPLEMENTADO
```sql
funcoes → funcao_permissoes → permissoes
formato: "vendas:read", "vendas:create", "caixa:open"
```

## 🐛 O BUG

O código frontend estava tentando ler permissões do **sistema novo** (array de strings), mas as permissões estavam salvas no **sistema antigo** (JSONB).

### Onde estava o erro:

**useUserHierarchy.ts - getVisibleModules()**
```typescript
// ❌ ERRADO - procurava por strings como "vendas:read"
const hasReadPermission = permissoes.some(
  p => p.startsWith('vendas:read')
);
```

**Banco de dados**
```sql
-- ✅ Mas Jennifer tinha permissões em JSONB:
SELECT permissoes FROM funcionarios WHERE nome = 'Jennifer Sousa';
-- resultado: { "vendas": true, "produtos": true, "clientes": true, "caixa": false, ... }
```

## ✅ SOLUÇÃO IMPLEMENTADA

### 1. Converter JSONB → Array de Strings

Adicionado em `usePermissions.tsx - loadPermissions()`:

```typescript
// Se funcionário não tem funcao_permissoes mas tem JSONB
if (permissoes.size === 0 && funcionarioData.permissoes) {
  console.log('🔄 Convertendo permissões JSONB para formato novo...');
  
  const moduloPermissoes = {
    vendas: ['vendas:read', 'vendas:create', 'vendas:update', 'vendas:delete'],
    produtos: ['produtos:read', 'produtos:create', 'produtos:update', 'produtos:delete'],
    clientes: ['clientes:read', 'clientes:create', 'clientes:update', 'clientes:delete'],
    caixa: ['caixa:read', 'caixa:open', 'caixa:close'],
    ordens_servico: ['ordens_servico:read', 'ordens_servico:create', 'ordens_servico:update'],
    relatorios: ['relatorios:read', 'relatorios:export'],
    configuracoes: ['configuracoes:read', 'configuracoes:update'],
    backup: ['backup:create', 'backup:read']
  };
  
  // Converter cada módulo ativo
  Object.keys(moduloPermissoes).forEach(modulo => {
    if (permissoesJSONB[modulo] === true) {
      moduloPermissoes[modulo].forEach(perm => {
        permissoes.add(perm);
      });
    }
  });
}
```

### 2. Corrigir getVisibleModules()

Atualizado em `useUserHierarchy.ts`:

```typescript
// Verificar se tem alguma permissão para este módulo
const hasAnyPermission = permissionsContext?.permissoes.some(
  p => p.startsWith(`${module.permission}:`) || p === module.permission
) || false;
```

### 3. Adicionar Hook para JSONB Direto

Criado `useVisibleModulesJSONB()` em `usePermissions.tsx`:

```typescript
// Busca direto do banco as permissões JSONB
const { data: funcionario } = await supabase
  .from('funcionarios')
  .select('permissoes')
  .eq('id', funcionarioId)
  .single();

const permissoesJSONB = funcionario.permissoes || {};

// Filtrar módulos
const visibleModules = allModules.filter(module => {
  return permissoesJSONB[module.permission] === true;
});
```

## 📊 RESULTADO ESPERADO

### Jennifer Sousa (Vendedor - Nível 2)

**Deve VER:**
- ✅ Vendas
- ✅ Produtos
- ✅ Clientes
- ✅ Ordens de Serviço

**NÃO deve ver:**
- ❌ Caixa
- ❌ Relatórios
- ❌ Configurações
- ❌ Backup

### Cristiano (Administrador - Nível 4)

**Deve VER TUDO:**
- ✅ Todos os módulos

## 🧪 COMO TESTAR

1. **Recarregar página** (F5)
2. **Fazer login como Jennifer** (jennifer_sousa / 123456)
3. **Verificar dashboard**: Deve aparecer 4 módulos (Vendas, Produtos, Clientes, OS)
4. **Fazer login como Cristiano** (cristiano / 123456)
5. **Verificar dashboard**: Deve aparecer TODOS os módulos

## 🔍 DEBUG NO CONSOLE

Com a solução, você verá logs assim:

```
🔄 [usePermissions] Convertendo permissões JSONB para formato novo...
  ✅ Convertido: vendas → vendas:read
  ✅ Convertido: vendas → vendas:create
  ✅ Convertido: produtos → produtos:read
  ✅ Convertido: clientes → clientes:read
  ❌ Módulo caixa não ativo no JSONB
  ❌ Módulo relatorios não ativo no JSONB

🎉 [usePermissions] Total após conversão JSONB: 16

📊 [getVisibleModules] Iniciando...
  ✅ [sales] Módulo visível
  ✅ [clients] Módulo visível
  ✅ [products] Módulo visível
  ✅ [orders] Módulo visível
  ❌ [cashier] Sem permissão
  ❌ [reports] Sem permissão

📊 Total módulos visíveis: 4
```

## 📝 ARQUIVOS MODIFICADOS

1. `src/hooks/usePermissions.tsx`
   - Adicionada conversão JSONB → array de strings
   - Criado hook `useVisibleModulesJSONB()`

2. `src/hooks/useUserHierarchy.ts`
   - Corrigida função `getVisibleModules()`
   - Melhorados logs de debug

3. SQL Scripts criados:
   - `DIAGNOSTICO_SISTEMA_PERMISSOES.sql` - Para análise
   - `VERIFICAR_PERMISSOES_REAL.sql` - Para testes

## 🚀 PRÓXIMOS PASSOS

1. ✅ Testar login Jennifer → verificar 4 módulos
2. ✅ Testar login Cristiano → verificar todos módulos
3. ⏳ Considerar migração completa para sistema novo (opcional)
4. ⏳ Documentar sistema de permissões escolhido (JSONB ou tabelas)

## 💡 RECOMENDAÇÃO

**Manter sistema JSONB por enquanto** - É mais simples e funcional.

Se quiser migrar para o sistema de tabelas relacionadas no futuro:
- Criar script de migração JSONB → funcao_permissoes
- Atualizar todo código para usar sistema novo
- Remover coluna `permissoes` de `funcionarios`
