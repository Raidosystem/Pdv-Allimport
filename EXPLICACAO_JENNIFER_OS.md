# 🔍 DIAGNÓSTICO: Jennifer e Permissões de Ordens de Serviço

## ❌ PROBLEMA RELATADO
A seção de **Ordens de Serviço (OS)** está marcada nas permissões de Jennifer, mas **não aparece no login dela**.

## 🎯 CAUSA RAIZ IDENTIFICADA

O sistema tem **DUAS formas** de controlar permissões:

### 1️⃣ **Sistema JSONB** (Antigo - ainda em uso)
- Armazenado em `funcionarios.permissoes` (campo JSONB)
- Exemplo: `{"ordens_servico": true, "vendas": true, "produtos": true}`
- **Usado pelo `useVisibleModules` no frontend**

### 2️⃣ **Sistema Novo** (Tabelas relacionadas)
- Tabela `funcoes` → Tabela `funcao_permissoes` → Tabela `permissoes`
- Mais estruturado, permite controle granular (read, create, update, delete)
- **Usado pelo `usePermissions` para verificações individuais**

## 🐛 PROBLEMAS POSSÍVEIS

### Problema A: Jennifer não aparece no login
**Causa**: Campos de ativação incorretos na tabela `funcionarios`

**Verificar**:
- `usuario_ativo` = `true` ✅
- `senha_definida` = `true` ✅
- `status` = `'ativo'` ✅
- `ativo` = `true` ✅

**RPC afetada**: `listar_usuarios_ativos()` - só retorna funcionários com esses flags ativos

### Problema B: OS não aparece no menu de Jennifer
**Causa**: Permissão JSONB não está configurada

**Verificar**:
- `funcionarios.permissoes->>'ordens_servico'` deve ser `'true'` ✅
- Se for `null` ou `false`, o módulo não aparece

### Problema C: Botões/ações de OS não funcionam
**Causa**: Permissões da função não incluem `ordens_servico`

**Verificar**:
- `funcao_id` de Jennifer deve ter registros em `funcao_permissoes`
- Com `permissao_id` apontando para permissões de recurso `'ordens_servico'`

## 🔧 SOLUÇÃO

### **Passo 1**: Executar diagnóstico
```sql
\i DIAGNOSTICO_JENNIFER_OS.sql
```

Este script mostra:
- ✅ Dados básicos de Jennifer
- ✅ Permissões JSONB atuais
- ✅ Função atribuída
- ✅ Permissões da função
- ✅ Status da empresa

### **Passo 2**: Aplicar correção
```sql
\i CORRIGIR_JENNIFER_OS.sql
```

Este script:
1. ✅ Ativa Jennifer no sistema (`usuario_ativo`, `status`, etc.)
2. ✅ Adiciona `"ordens_servico": true` no JSONB `permissoes`
3. ✅ Vincula permissões de OS à função de Jennifer
4. ✅ Testa se Jennifer aparece na RPC `listar_usuarios_ativos`

### **Passo 3**: Testar no frontend
1. Faça logout completo
2. Login com `assistenciaallimport10@gmail.com`
3. Selecione Jennifer na tela de login local
4. Digite a senha
5. **Resultado esperado**:
   - ✅ Card "Ordens de Serviço" visível no dashboard
   - ✅ Menu "OS" no menu lateral
   - ✅ Pode criar/editar ordens de serviço

## 📊 FLUXO DE PERMISSÕES NO SISTEMA

```
┌─────────────────────────────────────────────────────┐
│ 1. LOGIN (AuthContext + LocalLoginPage)            │
│    - Email/senha → Supabase Auth                    │
│    - Selecionar funcionário → RPC listar_usuarios  │
│    - Validar senha local → RPC validar_senha       │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│ 2. CARREGAR PERMISSÕES (usePermissions.tsx)        │
│    - Buscar funcionario por user_id                 │
│    - Extrair permissoes JSONB                       │
│    - Converter JSONB → Array de strings             │
│    - Exemplo: ordens_servico:read, ordens_servico:  │
│               create, ordens_servico:update         │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│ 3. FILTRAR MÓDULOS VISÍVEIS (useVisibleModules)    │
│    - Verificar permissoes JSONB                     │
│    - Se permissoes.ordens_servico === true:         │
│      → Mostrar card "OS" no dashboard               │
│      → Adicionar "OS" ao menu lateral               │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│ 4. VERIFICAR AÇÕES (usePermissions.can())           │
│    - can('ordens_servico', 'read') → Ver listagem  │
│    - can('ordens_servico', 'create') → Botão Nova  │
│    - can('ordens_servico', 'update') → Editar      │
│    - can('ordens_servico', 'delete') → Excluir     │
└─────────────────────────────────────────────────────┘
```

## 🎯 COMO O SISTEMA DECIDE O QUE MOSTRAR

### Para MÓDULOS (cards do dashboard):
```typescript
// src/hooks/usePermissions.tsx - linha ~760
const allModules = [
  { name: 'orders', display_name: 'OS', permission: 'ordens_servico', ... }
];

// Filtro:
permissoesJSONB['ordens_servico'] === true
```

### Para AÇÕES (botões, links):
```typescript
// src/hooks/usePermissions.tsx - linha ~430
const can = (recurso: string, acao: string) => {
  const permissaoCompleta = `${recurso}:${acao}`;
  return context.permissoes.includes(permissaoCompleta);
}

// Exemplo de uso:
{can('ordens_servico', 'create') && <button>Nova OS</button>}
```

## ⚠️ NOTAS IMPORTANTES

1. **Sistema híbrido**: O sistema está em transição entre JSONB e tabelas relacionadas. Por isso, **ambos precisam estar corretos**.

2. **Prioridade do JSONB**: Para módulos visíveis, o JSONB tem prioridade. Se `permissoes.ordens_servico` não for `true`, o módulo não aparece.

3. **Conversão automática**: O `usePermissions` converte JSONB para o formato novo:
   ```typescript
   if (permissoesJSONB.ordens_servico === true) {
     permissoes.add('ordens_servico:read');
     permissoes.add('ordens_servico:create');
     permissoes.add('ordens_servico:update');
     permissoes.add('ordens_servico:delete');
   }
   ```

4. **Cache de permissões**: Após alterar no banco, pode ser necessário:
   - Fazer logout/login
   - Limpar localStorage: `localStorage.clear()`
   - Recarregar a página (Ctrl+F5)

## 🔍 COMANDOS DE VERIFICAÇÃO RÁPIDA

### Ver permissões JSONB de Jennifer:
```sql
SELECT nome, permissoes 
FROM funcionarios 
WHERE LOWER(nome) LIKE '%jennifer%';
```

### Ver se Jennifer aparece no login:
```sql
SELECT * FROM listar_usuarios_ativos(
  (SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com')
)
WHERE LOWER(nome) LIKE '%jennifer%';
```

### Ver permissões da função de Jennifer:
```sql
SELECT 
  f.nome as funcionario,
  func.nome as funcao,
  p.recurso,
  p.acao
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON func.id = fp.funcao_id
JOIN permissoes p ON fp.permissao_id = p.id
WHERE LOWER(f.nome) LIKE '%jennifer%'
  AND p.recurso = 'ordens_servico';
```

## 📞 SUPORTE

Se após executar `CORRIGIR_JENNIFER_OS.sql` o problema persistir:

1. ✅ Execute `DIAGNOSTICO_JENNIFER_OS.sql` novamente
2. ✅ Copie os resultados
3. ✅ Verifique no console do navegador (F12):
   - Logs de `[usePermissions]`
   - Logs de `[useVisibleModules]`
   - Erros de requisição
4. ✅ Limpe o cache e localStorage
5. ✅ Teste em modo anônimo/privado do navegador
