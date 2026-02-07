# 🌐 ATIVAR PERMISSÕES PARA TODOS OS USUÁRIOS

## 🎯 Objetivo

Configurar automaticamente permissões completas de Administrador para:
- ✅ **TODOS os usuários existentes**
- ✅ **TODOS os novos usuários** (automático via trigger)

## ✨ O que este script faz?

### **Para Usuários Existentes:**
1. ✅ Cria registro de funcionário (se não existir)
2. ✅ Cria função "Administrador" por empresa
3. ✅ Atribui 35 permissões completas
4. ✅ Vincula usuário à função de Administrador

### **Para Novos Usuários:**
1. ✅ **TRIGGER automático** ao criar empresa
2. ✅ Configura tudo automaticamente
3. ✅ Sem necessidade de intervenção manual
4. ✅ Usuário já entra com permissões completas

## 📋 Executar Script

### **PASSO 1: Abrir Supabase SQL Editor**

No seu projeto Supabase:
1. Acesse **SQL Editor**
2. Clique em **New Query**

### **PASSO 2: Colar e Executar**

Copie TODO o conteúdo do arquivo:
```
ATIVAR_PERMISSOES_TODOS_USUARIOS.sql
```

E execute (clique em RUN ou pressione Ctrl+Enter)

### **PASSO 3: Aguardar Conclusão**

O script irá:
```
🚀 Iniciando configuração de permissões para todos os usuários...
✅ Permissões configuradas para usuário: user1@email.com
✅ Permissões configuradas para usuário: user2@email.com
✅ Permissões configuradas para usuário: user3@email.com
...
✅ Configuração concluída!
   Total de usuários processados: 10
   Configurados com sucesso: 10
   Falhas: 0
```

### **PASSO 4: Verificar Resultado**

Você verá uma tabela com todos os usuários:

```
| usuario_email            | empresa                | funcao        | total_permissoes | status      |
|--------------------------|------------------------|---------------|------------------|-------------|
| cris-ramos30@hotmail.com | Assistência All-Import | Administrador | 35               | ✅ COMPLETO |
| outro@email.com          | Outra Empresa          | Administrador | 35               | ✅ COMPLETO |
```

## 🔮 Como Funciona o Trigger Automático

Quando um **novo usuário se cadastrar**:

```
1. Usuário cria conta → auth.users
2. Trigger cria empresa → empresas
3. TRIGGER AUTOMÁTICO dispara!
4. Cria funcionário → funcionarios
5. Cria função "Administrador" → funcoes
6. Atribui 35 permissões → funcao_permissoes
7. Vincula usuário → funcionario_funcoes
✅ PRONTO! Usuário tem acesso completo
```

**Tudo automático!** Nenhuma ação manual necessária! 🎉

## 📊 O que Cada Usuário Recebe

### **35 Permissões Completas:**

#### **Administração (14 permissões)**
- `administracao.dashboard:read`
- `administracao.usuarios:create/read/update/delete/invite`
- `administracao.funcoes:create/read/update/delete`
- `administracao.permissoes:read/update`
- `administracao.backups:read/create`
- `administracao.sistema:read/update`

#### **Vendas (4 permissões)**
- `vendas:create/read/update/delete`

#### **Produtos (4 permissões)**
- `produtos:create/read/update/delete`

#### **Clientes (4 permissões)**
- `clientes:create/read/update/delete`

#### **Caixa (4 permissões)**
- `caixa:abrir/fechar/sangria/suprimento`

#### **Relatórios (3 permissões)**
- `relatorios:vendas/financeiro/estoque`

## ✅ Verificar Funcionamento

### **Teste 1: Usuários Existentes**

```sql
-- Ver todos os usuários configurados
SELECT 
  u.email,
  COUNT(DISTINCT fp.id) as permissoes
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
JOIN funcionarios f ON f.user_id = u.id
JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
JOIN funcoes func ON func.id = ff.funcao_id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
GROUP BY u.email
HAVING COUNT(DISTINCT fp.id) = 35;
```

**Esperado:** Todos os usuários devem aparecer com 35 permissões.

### **Teste 2: Criar Novo Usuário**

1. Cadastre um novo usuário no sistema
2. Aguarde 2-3 segundos
3. Execute:

```sql
SELECT 
  u.email,
  f.nome,
  func.nome as funcao,
  COUNT(fp.id) as permissoes
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
JOIN funcionarios f ON f.user_id = u.id
JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
JOIN funcoes func ON func.id = ff.funcao_id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE u.email = 'email-do-novo-usuario@teste.com'
GROUP BY u.email, f.nome, func.nome;
```

**Esperado:** Novo usuário já deve ter 35 permissões automaticamente!

### **Teste 3: Acessar o Sistema**

1. Faça login com qualquer usuário
2. Acesse **Administração do Sistema**
3. Clique em **Usuários**
4. Deve abrir sem erros e mostrar dados

## 🔧 Funções Criadas

O script cria 2 funções permanentes no banco:

### **1. `setup_admin_permissions_for_user(user_id)`**
- Configura permissões para UM usuário específico
- Pode ser chamada manualmente se necessário
- Idempotente (pode executar várias vezes)

### **2. `auto_setup_admin_on_empresa_created()`**
- Trigger automático
- Dispara quando empresa é criada
- Configura tudo automaticamente

## 🆘 Diagnóstico

### **Problema: "Usuário sem permissões"**

```sql
-- Executar manualmente para um usuário específico
SELECT setup_admin_permissions_for_user(
  (SELECT id FROM auth.users WHERE email = 'usuario@email.com')
);
```

### **Problema: "Trigger não funcionando"**

```sql
-- Verificar se trigger existe
SELECT 
  trigger_name,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'trigger_auto_setup_admin';
```

Se não aparecer, execute novamente a parte 2 do script.

### **Problema: "Erro ao criar funcionário"**

```sql
-- Verificar estrutura da tabela
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'funcionarios'
ORDER BY ordinal_position;
```

## 📝 Resumo

### **O que foi instalado:**

✅ Função `setup_admin_permissions_for_user()` - Configuração manual
✅ Função `auto_setup_admin_on_empresa_created()` - Trigger automático  
✅ Trigger `trigger_auto_setup_admin` - Ativa em INSERT de empresas
✅ Permissões configuradas para TODOS os 10 usuários existentes
✅ Sistema pronto para novos usuários automáticos

### **Benefícios:**

🎯 **Zero manutenção** - Novos usuários já entram com permissões
🔒 **Seguro** - Cada empresa tem suas próprias funções isoladas
⚡ **Rápido** - Configuração instantânea via trigger
🎨 **Escalável** - Funciona para 10, 100, 1000+ usuários

## 🎉 Resultado Final

Após executar este script:

✅ Todos os 10 usuários existentes → **35 permissões cada**
✅ Novos usuários → **Permissões automáticas**
✅ Seções funcionando:
   - 👥 Usuários
   - ✉️ Convites
   - 🛡️ Funções & Permissões
   - 💾 Backups
   - ⚙️ Configurações

**Sem necessidade de scripts manuais nunca mais!** 🚀
