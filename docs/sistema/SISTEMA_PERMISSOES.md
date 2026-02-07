# 🔐 Sistema de Permissões e Tipos de Admin

## 📋 Tipos de Usuários no Sistema

### 1. Super Admin (`super_admin`)
**Único usuário:** `novaradiosystem@outlook.com`

**Características:**
- Desenvolvedor e mantenedor do sistema
- Acesso TOTAL a todos os dados de todas as empresas
- Pode ver painel administrativo do sistema (`AdminDashboard`)
- Pode realizar manutenção e configurações globais

**Permissões:**
- `super_admin:all` (acesso ilimitado)
- Todas as outras permissões automaticamente

---

### 2. Admin Empresa (`admin_empresa`)
**Quem é:** Dono da empresa que comprou o sistema

**Exemplos:**
- `assistenciaallimport10@gmail.com` (Cristiano - Allimport)
- Qualquer outro cliente que assinou o sistema

**Identificação no banco:**
```sql
-- Admin empresa é identificado por:
empresa_id = user_id  -- O dono é usuário da própria empresa
tipo_admin = 'admin_empresa'
```

**Características:**
- Acesso total aos dados **da própria empresa**
- Pode criar e gerenciar funcionários
- Pode configurar o sistema (aparência, integra ções, backup)
- Pode ver relatórios completos
- Pode gerenciar funções e permissões dos funcionários
- **NÃO** tem acesso ao painel administrativo do sistema

**Permissões automáticas:**
```typescript
'administracao.usuarios:create'
'administracao.usuarios:read'
'administracao.usuarios:update'
'administracao.usuarios:delete'
'administracao.funcoes:create'
'administracao.funcoes:read'
'administracao.funcoes:update'
'administracao.funcoes:delete'
'administracao.sistema:read'
'administracao.sistema:update'
'administracao.backup:create'
'administracao.backup:read'
'administracao.logs:read'
'admin.dashboard:read'
```

---

### 3. Funcionário (`funcionario`)
**Quem são:** Funcionários contratados pela empresa

**Exemplos:**
- Jennifer Sousa (Vendedora)
- João Silva (Caixa)
- Maria Santos (Gerente)

**Identificação no banco:**
```sql
-- Funcionário é identificado por:
empresa_id != user_id  -- Pertence a uma empresa, mas não é o dono
tipo_admin = 'funcionario'
funcao_id IS NOT NULL  -- Tem uma função atribuída
```

**Características:**
- Acesso **limitado** conforme função atribuída
- NÃO pode acessar administração
- NÃO pode criar outros usuários
- NÃO pode alterar configurações globais
- Pode fazer apenas o que sua função permite

**Permissões:**
- Definidas pela **função** atribuída (Vendedor, Caixa, Gerente, etc)
- Configuradas em `funcao_permissoes`

---

## 🔍 Como o Sistema Verifica Permissões

### 1. No Hook `usePermissions.tsx`

```typescript
// Ordem de verificação:
1. Verifica se tem funcionario_id no localStorage (login local)
2. Se sim, busca funcionário por ID
3. Se não, busca funcionário por user_id
4. Se não encontrar, verifica se é Super Admin
5. Se não, usuário SEM permissões
```

### 2. Determinação do `tipo_admin`

```typescript
// ✅ CORRETO - usa apenas o campo do banco
let tipo_admin = funcionarioData.tipo_admin || 'funcionario';

// ❌ ERRADO - não promover automaticamente por nome de função
// Removido: if (temFuncaoAdmin) { tipo_admin = 'admin_empresa' }
```

### 3. Verificação de Permissões

```typescript
// Admin empresa tem TODAS as permissões de sua empresa
if (is_admin_empresa) {
  // Adiciona permissões automáticas de administração
}

// Funcionários têm apenas suas permissões atribuídas
if (tipo_admin === 'funcionario') {
  // Usa apenas permissões de funcao_permissoes
}
```

---

## 🛠️ Scripts de Correção

### 1. Auditoria Completa
```bash
AUDITORIA_TIPO_ADMIN.sql
```
Verifica todos os funcionários e identifica tipos incorretos.

### 2. Correção da Jennifer
```bash
CORRIGIR_JENNIFER_VENDEDOR.sql
```
Corrige especificamente a Jennifer para ser funcionária vendedora.

---

## 🚨 Problemas Comuns e Soluções

### Problema 1: Funcionário com acesso de admin
**Sintoma:** Jennifer consegue acessar tudo

**Causa:** `tipo_admin = 'admin_empresa'` incorreto

**Solução:**
```sql
UPDATE funcionarios 
SET tipo_admin = 'funcionario'
WHERE email = 'jennifer_sousa@temp.local';
```

### Problema 2: Dono sem acesso de admin
**Sintoma:** Cristiano não consegue gerenciar funcionários

**Causa:** `tipo_admin = 'funcionario'` quando deveria ser `'admin_empresa'`

**Solução:**
```sql
UPDATE funcionarios 
SET tipo_admin = 'admin_empresa'
WHERE empresa_id = user_id
  AND email = 'assistenciaallimport10@gmail.com';
```

### Problema 3: Auto-promoção por nome de função
**Sintoma:** Qualquer funcionário com função "Administrador" vira admin

**Causa:** Lógica antiga no `usePermissions.tsx` (já corrigida)

**Solução:** Código já foi atualizado para usar apenas `tipo_admin` do banco

---

## ✅ Validação Correta

Execute este SQL para validar o sistema:

```sql
-- Todos os donos devem ser admin_empresa
SELECT 
  nome,
  email,
  tipo_admin,
  CASE 
    WHEN tipo_admin = 'admin_empresa' THEN '✅'
    ELSE '❌ ERRO'
  END
FROM funcionarios
WHERE empresa_id = user_id;

-- Todos os funcionários devem ser tipo funcionario
SELECT 
  nome,
  email,
  tipo_admin,
  CASE 
    WHEN tipo_admin = 'funcionario' THEN '✅'
    ELSE '❌ ERRO'
  END
FROM funcionarios
WHERE empresa_id != user_id
  AND email != 'novaradiosystem@outlook.com';

-- Super admin deve ser único
SELECT 
  COUNT(*),
  CASE 
    WHEN COUNT(*) = 1 THEN '✅'
    ELSE '❌ ERRO: Deve haver apenas 1 super admin'
  END
FROM funcionarios
WHERE tipo_admin = 'super_admin';
```

---

## 📝 Checklist de Correção

Para corrigir acessos incorretos:

- [ ] 1. Execute `AUDITORIA_TIPO_ADMIN.sql` para ver situação atual
- [ ] 2. Verifique quais funcionários têm `tipo_admin` errado
- [ ] 3. Execute as correções automáticas do script
- [ ] 4. Faça logout de todos os usuários afetados
- [ ] 5. Faça login novamente
- [ ] 6. Verifique se as permissões estão corretas
- [ ] 7. Teste acesso aos menus de administração

---

## 🎯 Resumo das Regras

| Tipo | Identificação | Acesso |
|------|--------------|--------|
| **super_admin** | `email = novaradiosystem@outlook.com` | Tudo, todas as empresas |
| **admin_empresa** | `empresa_id = user_id` | Tudo da própria empresa |
| **funcionario** | `empresa_id != user_id` | Conforme função atribuída |

**IMPORTANTE:** Nunca altere `tipo_admin` manualmente sem verificar `empresa_id` e `user_id`!
