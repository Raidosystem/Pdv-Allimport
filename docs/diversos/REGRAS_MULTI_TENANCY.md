# 🔒 REGRAS CRÍTICAS DE MULTI-TENANCY - PDV ALLIMPORT

## ⚠️ NUNCA VIOLAR ESTAS REGRAS

### 1. PRINCÍPIO FUNDAMENTAL
**Cada empresa APENAS vê e gerencia seus próprios dados. ZERO exceções.**

---

## 🚫 PROIBIÇÕES ABSOLUTAS

### ❌ NUNCA criar funcionários para empresa de outro usuário
```sql
-- ❌ ERRADO - Criar funcionário para qualquer empresa
INSERT INTO funcionarios (empresa_id, user_id, ...) 
VALUES ('qualquer-empresa-id', 'qualquer-user-id', ...);

-- ✅ CORRETO - Usar função segura
SELECT criar_funcionario_seguro('Nome', 'email@exemplo.com', funcao_id);
```

### ❌ NUNCA fazer queries sem filtrar por empresa_id
```sql
-- ❌ ERRADO
SELECT * FROM funcionarios;

-- ✅ CORRETO
SELECT * FROM funcionarios 
WHERE empresa_id = (SELECT id FROM empresas WHERE user_id = auth.uid());
```

### ❌ NUNCA criar scripts que iteram sobre TODOS os usuários do auth
```sql
-- ❌ ERRADO - Criar funcionário para cada usuário do auth
FOR v_user IN SELECT * FROM auth.users LOOP
    INSERT INTO funcionarios ...
END LOOP;

-- ✅ CORRETO - Apenas o proprietário cria seus funcionários via interface
```

---

## ✅ REGRAS OBRIGATÓRIAS

### 1. **SEMPRE validar empresa_id no backend**
```typescript
// ✅ CORRETO
const { data: empresaData } = await supabase
  .from('empresas')
  .select('id')
  .eq('user_id', user.id)
  .single();

const empresaId = empresaData.id; // SEMPRE usar este ID
```

### 2. **SEMPRE filtrar queries por empresa_id**
```typescript
// ✅ CORRETO
const { data } = await supabase
  .from('funcionarios')
  .select('*')
  .eq('empresa_id', empresaId); // SEMPRE adicionar este filtro
```

### 3. **SEMPRE usar RLS (Row Level Security)**
- Todas as tabelas com empresa_id DEVEM ter RLS habilitado
- Políticas DEVEM verificar empresa_id do usuário logado

### 4. **SEMPRE usar a função criar_funcionario_seguro()**
```sql
-- ✅ CORRETO - Usa validações internas
SELECT criar_funcionario_seguro(
    'João Silva',
    'joao@exemplo.com',
    'funcao-id-uuid',
    true,
    'ativo'
);
```

---

## 📋 CHECKLIST ANTES DE CRIAR QUALQUER SCRIPT SQL

- [ ] O script valida empresa_id do usuário logado?
- [ ] O script usa `auth.uid()` para identificar o usuário?
- [ ] O script filtra por `empresa_id IN (SELECT id FROM empresas WHERE user_id = auth.uid())`?
- [ ] O script NÃO itera sobre `auth.users`?
- [ ] O script NÃO insere dados em tabelas de outras empresas?
- [ ] O script respeita as políticas RLS existentes?

**Se qualquer resposta for NÃO, o script está ERRADO.**

---

## 🔧 ESTRUTURA CORRETA DO BANCO

### Tabela `funcionarios`
```sql
CREATE TABLE funcionarios (
    id UUID PRIMARY KEY,
    empresa_id UUID NOT NULL REFERENCES empresas(id),
    user_id UUID UNIQUE REFERENCES auth.users(id), -- UNIQUE!
    funcao_id UUID REFERENCES funcoes(id),
    nome TEXT NOT NULL,
    email TEXT NOT NULL,
    ativo BOOLEAN DEFAULT true,
    status TEXT DEFAULT 'ativo',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS obrigatório
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;
```

### Políticas RLS Corretas
```sql
-- SELECT: Apenas minha empresa
CREATE POLICY "funcionarios_select_policy" ON funcionarios
FOR SELECT USING (
    empresa_id IN (
        SELECT id FROM empresas WHERE user_id = auth.uid()
    )
);

-- INSERT: Apenas para minha empresa
CREATE POLICY "funcionarios_insert_policy" ON funcionarios
FOR INSERT WITH CHECK (
    empresa_id IN (
        SELECT id FROM empresas WHERE user_id = auth.uid()
    )
);
```

---

## 🎯 FLUXO CORRETO DE CRIAÇÃO DE FUNCIONÁRIO

### Frontend (React/TypeScript)
```typescript
// 1. Buscar empresa_id do usuário logado
const { data: empresaData } = await supabase
  .from('empresas')
  .select('id')
  .eq('user_id', user.id)
  .single();

// 2. Criar funcionário APENAS para SUA empresa
const { data: funcionario } = await supabase
  .rpc('criar_funcionario_seguro', {
    p_nome: 'Nome do Funcionário',
    p_email: 'funcionario@email.com',
    p_funcao_id: funcaoId // funcao deve pertencer à mesma empresa
  });
```

### Backend (PostgreSQL)
```sql
-- A função criar_funcionario_seguro() já faz todas as validações:
-- 1. Valida auth.uid()
-- 2. Busca empresa_id do usuário
-- 3. Valida que funcao_id pertence à empresa
-- 4. Insere funcionário APENAS para empresa correta
```

---

## ❗ CASOS DE USO CORRETOS

### ✅ Proprietário cria funcionário para SUA empresa
```typescript
// User: joao@allimport.com (proprietário da Allimport)
// Cria: funcionario@allimport.com (funcionário da Allimport)
✅ CORRETO - Mesma empresa
```

### ❌ Proprietário NÃO pode criar funcionário para outra empresa
```typescript
// User: joao@allimport.com (proprietário da Allimport)
// Tenta criar: funcionario@outraempresa.com (funcionário de Outra Empresa)
❌ BLOQUEADO - Empresas diferentes
```

### ✅ Cada empresa gerencia apenas seus dados
```typescript
// Allimport vê: clientes, produtos, vendas, funcionários da Allimport
// Outra Empresa vê: clientes, produtos, vendas, funcionários da Outra Empresa
// ZERO intersecção de dados
✅ CORRETO - Isolamento total
```

---

## 🛡️ PROTEÇÕES IMPLEMENTADAS

1. **UNIQUE constraint** em `funcionarios.user_id`
2. **RLS ultra-restritivo** em todas as tabelas
3. **Trigger de validação** no INSERT de funcionarios
4. **Função criar_funcionario_seguro()** com validações internas
5. **Frontend filtra** por empresa_id em todas as queries

---

## 📖 DOCUMENTAÇÃO DE REFERÊNCIA

### Arquivos Importantes
- `PROTECOES_MULTI_TENANCY_DEFINITIVAS.sql` - Script de proteção
- `AdminUsersPage.tsx` - Implementação correta no frontend
- `useAuth.tsx` - Context de autenticação

### SQL Seguro
- `criar_funcionario_seguro()` - Função para criar funcionários
- `validar_empresa_funcionario()` - Trigger de validação

---

## 🚨 SE HOUVER VIOLAÇÃO

1. **Executar imediatamente**: `DELETAR_TODOS_FUNCIONARIOS_URGENTE.sql`
2. **Aplicar proteções**: `PROTECOES_MULTI_TENANCY_DEFINITIVAS.sql`
3. **Revisar código** que causou a violação
4. **Atualizar esta documentação** se necessário

---

## 💡 LEMBRETE FINAL

**MULTI-TENANCY NÃO É OPCIONAL.**

Cada linha de código, cada query SQL, cada função deve respeitar o isolamento de dados entre empresas.

**NUNCA criar dados para empresa de outro usuário.**
**SEMPRE validar empresa_id antes de qualquer operação.**

---

*Última atualização: 2025-11-24*
*Desenvolvido para: PDV Allimport System*
