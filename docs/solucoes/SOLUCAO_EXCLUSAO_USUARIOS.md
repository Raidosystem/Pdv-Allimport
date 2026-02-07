# 🗑️ SOLUÇÃO COMPLETA: Exclusão de Usuários no Admin

## 📋 Problema Identificado

1. ❌ Usuários não aparecem no painel `/admin`
2. ❌ Não existe botão de exclusão no admin
3. ❌ Usuários conseguem fazer login mesmo "excluídos"

## ✅ Solução Implementada

### 1️⃣ **Botão de Exclusão no Admin Dashboard**

**O que foi adicionado:**
- ✅ Botão **"Excluir"** vermelho ao lado de "+ Dias"
- ✅ Confirmação dupla (precisa digitar o email do usuário)
- ✅ Exclusão COMPLETA de todas as tabelas
- ✅ Remove também da tabela `auth.users` (impede login)

**Ícone adicionado:**
```tsx
import { Trash2 } from 'lucide-react'
```

**Função criada:**
```tsx
const deleteUser = async (subscriber: Subscriber) => {
  // 1. Confirmação dupla
  // 2. Remove de todas as tabelas:
  //    - produtos, clientes, vendas
  //    - ordens_servico, caixas
  //    - funcionarios, empresas
  //    - subscriptions, user_approvals
  //    - auth.users (impede login!)
}
```

---

## 🔧 Como Usar

### **Passo 1: Verificar por que usuários não aparecem**

Execute no **SQL Editor do Supabase**:
```sql
-- Arquivo: VERIFICAR_USUARIOS_OCULTOS.sql
```

Este script vai:
1. ✅ Listar TODOS os usuários
2. ✅ Identificar quem NÃO tem subscription
3. ✅ Criar subscriptions automáticas para quem não tem
4. ✅ Depois disso, TODOS vão aparecer no admin

**Causa raiz:** O admin busca dados da tabela `subscriptions`. Se um usuário não tem registro lá, ele não aparece!

---

### **Passo 2: Excluir usuários específicos (teste123@teste.com, etc)**

**Opção A - Usar o Painel Admin (RECOMENDADO):**
1. Acesse `/admin`
2. Agora todos os usuários devem aparecer (após executar o SQL do Passo 1)
3. Clique no botão **"Excluir"** vermelho
4. Digite o email do usuário para confirmar
5. ✅ Usuário excluído completamente!

**Opção B - SQL Direto (para múltiplos usuários):**
Execute no **SQL Editor do Supabase**:
```sql
-- Arquivo: EXCLUIR_USUARIOS_ESPECIFICOS.sql
```

Este script exclui os 5 usuários de uma vez:
- teste123@teste.com
- silviobritoempreendedor@gmail.com
- admin@pdv.com
- marcovalentim04@gmail.com
- smartcellinova@gmail.com

---

## 📂 Arquivos Criados

| Arquivo | Descrição |
|---------|-----------|
| `VERIFICAR_USUARIOS_OCULTOS.sql` | Identifica e corrige usuários que não aparecem no admin |
| `EXCLUIR_USUARIOS_ESPECIFICOS.sql` | Exclui os 5 usuários problemáticos de uma vez |
| `AdminDashboard.tsx` | Adicionado botão e função de exclusão |

---

## 🎯 Checklist de Execução

### **Para corrigir os usuários ocultos:**
- [ ] 1. Abrir Supabase Dashboard
- [ ] 2. Ir em **SQL Editor** > **New Query**
- [ ] 3. Colar conteúdo de `VERIFICAR_USUARIOS_OCULTOS.sql`
- [ ] 4. Executar (F5 ou botão Run)
- [ ] 5. Verificar mensagens: "✅ Subscription criada para..."
- [ ] 6. Acessar `/admin` e confirmar que TODOS aparecem

### **Para excluir os 5 usuários específicos:**
- [ ] 1. Abrir Supabase Dashboard
- [ ] 2. Ir em **SQL Editor** > **New Query**
- [ ] 3. Colar conteúdo de `EXCLUIR_USUARIOS_ESPECIFICOS.sql`
- [ ] 4. Executar (F5 ou botão Run)
- [ ] 5. Verificar mensagens: "✅ Usuário ... excluído completamente!"
- [ ] 6. Tentar fazer login com esses emails → deve dar erro 400

### **Para usar o botão de exclusão no admin:**
- [ ] 1. Commit e push das alterações no `AdminDashboard.tsx`
- [ ] 2. Deploy no Vercel
- [ ] 3. Acessar `/admin`
- [ ] 4. Clicar em **"Excluir"** no usuário desejado
- [ ] 5. Digitar o email para confirmar
- [ ] 6. ✅ Usuário removido!

---

## 🔒 Segurança

### **Confirmação Dupla**
O botão exige que você digite o **email exato** do usuário antes de excluir. Isso evita exclusões acidentais.

### **Exclusão Completa**
Quando você exclui um usuário:
1. ✅ Remove de **10 tabelas diferentes**
2. ✅ Remove da tabela `auth.users`
3. ✅ **O usuário NÃO consegue mais fazer login**
4. ⚠️ **Ação IRREVERSÍVEL** - não tem como recuperar

---

## 🐛 Troubleshooting

### ❌ "Erro: Could not find the 'email' column"
**Solução:** Execute este SQL para adicionar coluna email na subscriptions:
```sql
ALTER TABLE public.subscriptions 
ADD COLUMN IF NOT EXISTS email TEXT;

-- Preencher emails vazios
UPDATE public.subscriptions s
SET email = au.email
FROM auth.users au
WHERE s.user_id = au.id 
AND s.email IS NULL;
```

### ❌ "Erro: access denied to table auth.users"
**Solução:** Use a função `supabase.auth.admin.deleteUser()` que já está implementada no código.

### ❌ Usuário ainda consegue fazer login após exclusão
**Causa:** A exclusão não removeu da tabela `auth.users`.
**Solução:** Execute manualmente:
```sql
DELETE FROM auth.users WHERE email = 'usuario@email.com';
```

---

## 📊 Verificação Final

Após executar tudo:

```sql
-- Deve retornar 0 usuários
SELECT * FROM auth.users 
WHERE email IN (
  'teste123@teste.com',
  'silviobritoempreendedor@gmail.com',
  'admin@pdv.com',
  'marcovalentim04@gmail.com',
  'smartcellinova@gmail.com'
);

-- Todos os outros devem aparecer
SELECT COUNT(*) as usuarios_restantes 
FROM auth.users 
WHERE deleted_at IS NULL;
```

---

## 🎉 Resultado Esperado

✅ Todos os usuários com subscription aparecem no `/admin`  
✅ Botão "Excluir" vermelho disponível para cada usuário  
✅ Exclusão remove completamente do banco (10 tabelas)  
✅ Usuário excluído NÃO consegue mais fazer login  
✅ Confirmação dupla evita exclusões acidentais  

---

## 📞 Suporte

Se algo não funcionar:
1. Verifique os logs do console (F12)
2. Verifique as mensagens do SQL Editor
3. Confirme que tem permissão de admin no Supabase
4. Tente executar os SQLs manualmente primeiro

---

**Data de criação:** 27/10/2025  
**Versão do sistema:** PDV Allimport v2.2.3  
**Status:** ✅ Pronto para uso
