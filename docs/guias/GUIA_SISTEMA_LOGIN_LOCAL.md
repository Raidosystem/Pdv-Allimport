# 🔐 Sistema de Login Local com Seleção Visual de Usuários

## 📋 Visão Geral

Este sistema permite que **o administrador crie funcionários localmente** no PDV, sem necessidade de enviar emails ou convites. Os usuários aparecem em **cards visuais** na tela de login, onde cada um seleciona seu nome e digita sua senha.

---

## 🎯 Fluxo Completo

### 1️⃣ **Primeiro Acesso do Admin**

Quando o admin acessa o sistema pela primeira vez:

1. É redirecionado para uma tela especial
2. Sistema pede para definir sua **senha pessoal de administrador**
3. Admin digita e confirma a senha (mínimo 6 caracteres)
4. Sistema salva a senha criptografada (bcrypt)
5. Admin é redirecionado para o dashboard

### 2️⃣ **Admin Ativa Novos Usuários**

Agora o admin pode criar funcionários:

1. Acessa **Administração → Ativar Usuários**
2. Clica em **"Novo Usuário"**
3. Preenche o formulário:
   - Nome completo (ex: João Silva)
   - Email (ex: joao@empresa.com)
   - Senha (ex: joao123 - mínimo 6 caracteres)
   - Função (seleciona: Vendedor, Caixa, etc.)
4. Clica em **"Criar e Ativar Usuário"**
5. Sistema:
   - Cria o funcionário no banco de dados
   - Associa a função selecionada
   - Criptografa e salva a senha
   - Ativa o usuário automaticamente
   - Mostra mensagem de sucesso

### 3️⃣ **Tela de Login Visual**

Quando alguém acessa o sistema:

1. Aparece uma tela com **cards de todos os usuários ativos**:
   - Cada card mostra:
     - **Foto** (ou iniciais do nome em um círculo colorido)
     - **Nome** do usuário
     - **Email**
     - **Badge** indicando "Administrador" ou "Funcionário"
     - Indicador de "Primeiro acesso" (se aplicável)

2. **Usuário clica no seu card**
3. Aparece tela pedindo apenas a **senha**
4. Usuário digita a senha
5. Clica em **"Entrar no Sistema"**
6. Sistema valida e:
   - Cria sessão local
   - Carrega permissões do usuário
   - Redireciona para o dashboard
   - Aplica restrições conforme função

### 4️⃣ **Gerenciamento de Usuários**

O admin pode:

- **Ver todos os usuários** cadastrados
- **Ativar/Desativar** usuários (exceto o próprio admin)
- Ver status de cada usuário:
  - ✅ "Senha OK" - senha foi definida
  - 🟢 "Ativo" - pode fazer login
  - 🔴 "Inativo" - não pode fazer login

---

## 🗄️ Estrutura do Banco de Dados

### **Tabela `funcionarios`** (novas colunas)

```sql
- senha_hash TEXT              -- Hash bcrypt da senha
- senha_definida BOOLEAN       -- Se a senha foi definida
- foto_perfil TEXT             -- URL da foto do usuário
- primeiro_acesso BOOLEAN      -- Se é o primeiro acesso
- usuario_ativo BOOLEAN        -- Se pode fazer login
```

### **Tabela `sessoes_locais`** (nova)

```sql
- id UUID PRIMARY KEY
- funcionario_id UUID          -- FK para funcionarios
- token TEXT UNIQUE            -- Token de sessão
- criado_em TIMESTAMP
- expira_em TIMESTAMP          -- Sessão de 8 horas
- ip_address TEXT
- user_agent TEXT
- ativo BOOLEAN
```

### **Funções SQL**

1. **`definir_senha_local(funcionario_id, senha)`**
   - Criptografa senha com bcrypt
   - Salva hash na tabela
   - Marca senha_definida = TRUE
   - Ativa o usuário

2. **`validar_senha_local(funcionario_id, senha)`**
   - Valida senha com bcrypt
   - Cria sessão se válida
   - Retorna dados do funcionário e token
   - Marca primeiro_acesso = FALSE

3. **`listar_usuarios_ativos(empresa_id)`**
   - Lista todos usuários ativos
   - Ordena por tipo (admin primeiro) e nome
   - Retorna dados para exibir nos cards

4. **`validar_sessao(token)`**
   - Verifica se token é válido
   - Verifica se não expirou
   - Retorna dados do funcionário

---

## 📁 Arquivos Criados

### 1. **SQL de Estrutura**
```
/CRIAR_SISTEMA_LOGIN_LOCAL.sql
```
- Cria todas as colunas necessárias
- Cria tabela sessoes_locais
- Cria funções de login/senha
- Configura RLS policies

### 2. **Tela de Login Visual**
```
/src/modules/auth/LocalLoginPage.tsx
```
- Exibe cards de usuários
- Permite seleção visual
- Valida senha
- Gerencia sessão local

### 3. **Página de Ativação de Usuários**
```
/src/modules/admin/pages/ActivateUsersPage.tsx
```
- Modal para definir senha do admin (primeira vez)
- Formulário de criação de funcionários
- Lista de usuários com toggle ativo/inativo
- Indicadores de status

---

## 🚀 Como Implementar

### **Passo 1: Executar SQL no Supabase**

```bash
# Copie e execute no SQL Editor do Supabase:
/CRIAR_SISTEMA_LOGIN_LOCAL.sql
```

Isso irá criar:
- ✅ Novas colunas em `funcionarios`
- ✅ Tabela `sessoes_locais`
- ✅ 4 funções SQL
- ✅ Extensão pgcrypto (para bcrypt)
- ✅ RLS policies

### **Passo 2: Atualizar AuthContext**

Adicione a função `signInLocal` ao `AuthContext.tsx`:

```typescript
// No tipo AuthContextType
interface AuthContextType {
  // ... outras propriedades existentes
  signInLocal?: (userData: any) => Promise<void>
}

// No componente AuthProvider
const signInLocal = async (userData: any) => {
  // Simular user do Supabase com dados locais
  const localUser = {
    id: userData.funcionario_id,
    email: userData.email || 'local@user.com',
    user_metadata: {
      nome: userData.nome,
      tipo_admin: userData.tipo_admin,
      empresa_id: userData.empresa_id
    },
    app_metadata: {},
    aud: 'authenticated',
    created_at: new Date().toISOString()
  } as User

  setUser(localUser)
  setSession({
    access_token: userData.token,
    token_type: 'bearer',
    user: localUser
  } as Session)
}

// No value
const value: AuthContextType = {
  // ... outras propriedades
  signInLocal,
}
```

### **Passo 3: Adicionar Rota de Login Local**

Em seu arquivo de rotas:

```typescript
import { LocalLoginPage } from './modules/auth/LocalLoginPage'

// Adicionar rota
<Route path="/login-local" element={<LocalLoginPage />} />
```

### **Passo 4: Adicionar Página de Ativação**

No menu de administração:

```typescript
import { ActivateUsersPage } from './modules/admin/pages/ActivateUsersPage'

// Adicionar rota protegida (apenas admin)
<Route path="/admin/ativar-usuarios" element={<ActivateUsersPage />} />
```

### **Passo 5: Ajustar Button Component**

Se o componente `Button` não tiver a prop `icon`, você tem duas opções:

**Opção A: Adicionar prop icon**
```typescript
// Em Button.tsx
interface ButtonProps {
  // ... outras props
  icon?: React.ComponentType<{ className?: string }>
}

// No render
{icon && <Icon className="w-5 h-5 mr-2" />}
```

**Opção B: Remover prop icon dos botões**
```typescript
// Em ActivateUsersPage.tsx e LocalLoginPage.tsx
// Trocar:
<Button icon={UserPlus}>Novo Usuário</Button>

// Por:
<Button>
  <UserPlus className="w-5 h-5 mr-2" />
  Novo Usuário
</Button>
```

---

## 🎨 Funcionalidades Visuais

### **Cards de Usuário**

- **Avatar circular** com foto ou iniciais
- **Badge** de tipo (Administrador / Funcionário)
- **Indicador** de primeiro acesso (bolinha pulsante)
- **Hover effect** com borda colorida
- **Responsivo** (1 coluna mobile, 3 colunas desktop)

### **Formulário de Novo Usuário**

- **Grid responsivo** (2 colunas desktop)
- **Toggle** para mostrar/ocultar senha
- **Select** de funções disponíveis
- **Validações** em tempo real
- **Feedback visual** claro

### **Lista de Usuários**

- **Cards** com background colorido
- **Badges** de status
- **Botão toggle** ativar/desativar
- **Ícones** indicadores
- **Admin protegido** (não pode desativar)

---

## 🔒 Segurança

### **Criptografia**

- **Senhas**: bcrypt com salt 10 rounds
- **Sessões**: tokens aleatórios de 32 bytes (base64)
- **Nunca** armazena senhas em texto plano

### **RLS (Row Level Security)**

- Cada empresa vê apenas seus funcionários
- Verificação via `auth.uid()` e JOIN com `empresas`
- Políticas separadas para SELECT, INSERT, UPDATE, DELETE

### **Sessões**

- **Expiração**: 8 horas
- **Token único** por sessão
- **Validação** em cada request
- **IP e User-Agent** registrados (auditoria)

### **Validações**

- Senha mínimo 6 caracteres
- Email válido obrigatório
- Função obrigatória
- Apenas admin pode criar usuários
- Admin não pode desativar a si mesmo

---

## 🧪 Como Testar

### **1. Testar Primeiro Acesso do Admin**

```sql
-- No Supabase SQL Editor, verificar admin sem senha
SELECT id, nome, email, senha_definida, usuario_ativo
FROM funcionarios
WHERE tipo_admin = 'admin_empresa';

-- Se senha_definida = false, ao acessar /admin/ativar-usuarios
-- verá o modal pedindo senha
```

### **2. Criar Funcionário de Teste**

1. Acesse `/admin/ativar-usuarios`
2. Clique em "Novo Usuário"
3. Preencha:
   - Nome: "João Teste"
   - Email: "joao@teste.com"
   - Senha: "joao123"
   - Função: "Vendedor"
4. Clique em "Criar e Ativar"

### **3. Testar Login Visual**

1. Acesse `/login-local`
2. Deve aparecer card do Admin e do João
3. Clique no card do João
4. Digite senha "joao123"
5. Deve logar e redirecionar para dashboard

### **4. Validar Permissões**

```sql
-- Verificar funcionário e suas funções
SELECT 
  f.nome,
  f.email,
  f.usuario_ativo,
  func.nome as funcao,
  array_agg(fp.permissao) as permissoes
FROM funcionarios f
JOIN funcionario_funcoes ff ON f.id = ff.funcionario_id
JOIN funcoes func ON ff.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
WHERE f.email = 'joao@teste.com'
GROUP BY f.id, func.id;
```

---

## 🐛 Troubleshooting

### **Erro: "Extension pgcrypto not found"**

```sql
-- Execute no SQL Editor do Supabase
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

### **Erro: "Cannot read property signInLocal"**

Certifique-se de adicionar `signInLocal` ao AuthContext conforme Passo 2.

### **Cards não aparecem na tela de login**

```sql
-- Verificar se há usuários ativos
SELECT * FROM funcionarios WHERE usuario_ativo = TRUE;

-- Se vazio, ativar manualmente:
UPDATE funcionarios
SET usuario_ativo = TRUE, senha_definida = TRUE
WHERE tipo_admin = 'admin_empresa';
```

### **Senha não valida (sempre incorreta)**

```sql
-- Verificar se hash foi criado
SELECT senha_hash, senha_definida FROM funcionarios WHERE email = 'teste@teste.com';

-- Se NULL, redefinir:
SELECT definir_senha_local(
  (SELECT id FROM funcionarios WHERE email = 'teste@teste.com'),
  'nova_senha_123'
);
```

### **Sessão expira muito rápido**

```sql
-- Alterar tempo de expiração (padrão 8 horas)
ALTER TABLE sessoes_locais 
ALTER COLUMN expira_em 
SET DEFAULT NOW() + INTERVAL '24 hours'; -- Exemplo: 24 horas
```

---

## 📊 Diagrama de Fluxo

```
┌─────────────────────────────────────────────────────────────────┐
│                    SISTEMA DE LOGIN LOCAL                       │
└─────────────────────────────────────────────────────────────────┘

1. PRIMEIRO ACESSO DO ADMIN
   ┌──────────────┐
   │ Admin acessa │
   │   sistema    │
   └──────┬───────┘
          │
          ▼
   ┌──────────────────────┐
   │ Sistema verifica:    │
   │ senha_definida?      │
   └──────┬───────────────┘
          │
          ├─── FALSE ───► [Modal: Defina sua senha]
          │                      │
          │                      ▼
          │               [Salva hash bcrypt]
          │                      │
          └─── TRUE ─────────────┴──► [Dashboard]

2. ADMIN CRIA FUNCIONÁRIOS
   ┌──────────────────────┐
   │ Admin clica em       │
   │ "Novo Usuário"       │
   └──────┬───────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ Preenche formulário:     │
   │ - Nome                   │
   │ - Email                  │
   │ - Senha                  │
   │ - Função                 │
   └──────┬───────────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ Sistema:                 │
   │ 1. Cria funcionário      │
   │ 2. Associa função        │
   │ 3. Criptografa senha     │
   │ 4. Ativa usuário         │
   └──────┬───────────────────┘
          │
          ▼
   ┌──────────────────────────┐
   │ ✅ Usuário criado e      │
   │    pronto para login     │
   └──────────────────────────┘

3. TELA DE LOGIN VISUAL
   ┌──────────────────────┐
   │ Usuário acessa       │
   │ /login-local         │
   └──────┬───────────────┘
          │
          ▼
   ┌──────────────────────────────────────┐
   │ Exibe cards de TODOS os usuários:    │
   │                                      │
   │  ┌─────────┐  ┌─────────┐  ┌──────┐│
   │  │  ADMIN  │  │  JOÃO   │  │MARIA ││
   │  │  🔵👤  │  │  🟢👤  │  │🟢👤 ││
   │  └─────────┘  └─────────┘  └──────┘│
   └──────┬───────────────────────────────┘
          │
          ▼ (clica no card)
   ┌──────────────────────┐
   │ Tela de senha:       │
   │                      │
   │  👤 João Silva       │
   │  🔒 [__________]     │
   │  [Entrar]            │
   └──────┬───────────────┘
          │
          ▼
   ┌────────────────────────────┐
   │ Sistema valida:            │
   │ - Usuário ativo?           │
   │ - Senha correta?           │
   └──────┬─────────────────────┘
          │
          ├─── ✅ OK ──────► [Cria sessão]
          │                       │
          │                       ▼
          │                 [Carrega permissões]
          │                       │
          │                       ▼
          │                 [Redireciona dashboard]
          │
          └─── ❌ ERRO ───► [Mensagem: Senha incorreta]

4. GERENCIAMENTO
   ┌──────────────────────────┐
   │ Admin pode:              │
   │ - Ativar usuário   🟢    │
   │ - Desativar usuário  🔴  │
   │ - Ver status         👁   │
   └──────────────────────────┘
```

---

## 🎯 Próximos Passos

- [ ] **Executar SQL** no Supabase
- [ ] **Atualizar AuthContext** com signInLocal
- [ ] **Adicionar rotas** LocalLoginPage e ActivateUsersPage
- [ ] **Ajustar componente Button** (prop icon)
- [ ] **Testar fluxo completo**
- [ ] **Adicionar no menu** link para "Ativar Usuários"
- [ ] **Configurar redirect** para /login-local como padrão

---

## ✅ Checklist de Implementação

```
🗄️ Banco de Dados
  [ ] Executar CRIAR_SISTEMA_LOGIN_LOCAL.sql
  [ ] Verificar extensão pgcrypto ativada
  [ ] Testar funções SQL manualmente
  [ ] Verificar RLS policies criadas

💻 Frontend
  [ ] Criar LocalLoginPage.tsx
  [ ] Criar ActivateUsersPage.tsx
  [ ] Atualizar AuthContext.tsx (signInLocal)
  [ ] Adicionar rotas no App.tsx
  [ ] Ajustar Button component (opcional)

🔗 Integrações
  [ ] Adicionar link no menu admin
  [ ] Configurar redirect padrão
  [ ] Testar com múltiplos usuários
  [ ] Validar permissões por função

🧪 Testes
  [ ] Primeiro acesso admin
  [ ] Criar funcionário
  [ ] Login com card visual
  [ ] Ativar/desativar usuário
  [ ] Validar sessão
  [ ] Testar expiração (8h)

🚀 Produção
  [ ] Backup do banco antes de executar
  [ ] Executar SQL em produção
  [ ] Deploy do frontend
  [ ] Testar em ambiente real
  [ ] Documentar para usuários
```

---

## 📞 Suporte

Caso encontre problemas:

1. Verifique os logs do navegador (F12 → Console)
2. Verifique logs do Supabase (Dashboard → Logs)
3. Execute queries de diagnóstico SQL
4. Confira se todas as etapas foram executadas

**Logs úteis:**
```sql
-- Ver todos os funcionários e status
SELECT id, nome, email, usuario_ativo, senha_definida, tipo_admin
FROM funcionarios;

-- Ver sessões ativas
SELECT f.nome, s.token, s.criado_em, s.expira_em
FROM sessoes_locais s
JOIN funcionarios f ON s.funcionario_id = f.id
WHERE s.ativo = TRUE AND s.expira_em > NOW();

-- Ver permissões de um funcionário
SELECT f.nome, func.nome as funcao, fp.permissao
FROM funcionarios f
JOIN funcionario_funcoes ff ON f.id = ff.funcionario_id
JOIN funcoes func ON ff.funcao_id = func.id
JOIN funcao_permissoes fp ON func.id = fp.funcao_id
WHERE f.email = 'email@teste.com';
```

---

**🎉 Sistema de Login Local Completo!**

Agora você tem um sistema profissional onde o admin controla totalmente os acessos, sem depender de emails ou convites externos.
