# 🚀 COMANDOS PARA ATIVAR SISTEMA DE LOGIN LOCAL

## ✅ O QUE FOI CRIADO

1. **CRIAR_SISTEMA_LOGIN_LOCAL.sql** - Script SQL completo
2. **LocalLoginPage.tsx** - Tela de login com cards visuais
3. **ActivateUsersPage.tsx** - Página de ativação de usuários
4. **GUIA_SISTEMA_LOGIN_LOCAL.md** - Documentação completa

---

## 📋 PASSO A PASSO RÁPIDO

### **1️⃣ EXECUTAR SQL NO SUPABASE**

```bash
# Acesse: https://supabase.com/dashboard/project/SEU_PROJETO/sql

# Copie e cole TODO o conteúdo do arquivo:
CRIAR_SISTEMA_LOGIN_LOCAL.sql

# Clique em "RUN" ou pressione Ctrl+Enter

# Você verá:
✅ Estrutura do sistema de login local criada com sucesso!
```

**O que este SQL faz:**
- Adiciona colunas em `funcionarios` (senha_hash, senha_definida, foto_perfil, primeiro_acesso, usuario_ativo)
- Cria tabela `sessoes_locais`
- Cria 4 funções SQL (validar_senha_local, definir_senha_local, etc.)
- Ativa extensão pgcrypto (para criptografia bcrypt)
- Configura RLS policies

---

### **2️⃣ ATUALIZAR AuthContext.tsx**

Abra o arquivo: `src/modules/auth/AuthContext.tsx`

**Adicione ao tipo `AuthContextType` (linha ~10):**

```typescript
interface AuthContextType {
  user: User | null
  session: Session | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<{ data: unknown; error: AuthError | null }>
  signUp: (email: string, password: string, metadata?: Record<string, unknown>) => Promise<{ data: unknown; error: AuthError | null }>
  signUpEmployee: (email: string, password: string, metadata: Record<string, unknown>) => Promise<{ data: unknown; error: AuthError | null }>
  signOut: () => Promise<{ error: AuthError | null }>
  resendConfirmation: (email: string) => Promise<{ data: unknown; error: AuthError | null }>
  resetPassword: (email: string) => Promise<{ data: unknown; error: AuthError | null }>
  checkAccess: () => Promise<boolean>
  isAdmin: () => boolean
  sendWhatsAppCode: (userId: string, phone: string) => Promise<boolean>
  verifyWhatsAppCode: (userId: string, code: string) => Promise<boolean>
  resendWhatsAppCode: (userId: string, phone: string) => Promise<boolean>
  signInLocal?: (userData: any) => Promise<void>  // ← ADICIONE ESTA LINHA
}
```

**Adicione a função dentro do AuthProvider (antes do `const value`):**

```typescript
// Dentro da função AuthProvider, antes de const value
const signInLocal = async (userData: any) => {
  console.log('🔐 Login local iniciado:', userData)
  
  // Criar user simulado do Supabase com dados locais
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

  // Criar session simulada
  const localSession = {
    access_token: userData.token,
    token_type: 'bearer',
    user: localUser,
    expires_at: Math.floor(Date.now() / 1000) + 28800, // 8 horas
    expires_in: 28800
  } as Session

  setUser(localUser)
  setSession(localSession)
  
  console.log('✅ Login local completo:', localUser)
}
```

**Adicione ao value (linha ~380):**

```typescript
const value: AuthContextType = {
  user,
  session,
  loading,
  signIn,
  signUp,
  signUpEmployee,
  signOut,
  resendConfirmation,
  resetPassword,
  checkAccess,
  isAdmin,
  sendWhatsAppCode,
  verifyWhatsAppCode,
  resendWhatsAppCode,
  signInLocal,  // ← ADICIONE ESTA LINHA
}
```

---

### **3️⃣ ADICIONAR ROTAS**

Abra o arquivo onde você define as rotas (provavelmente `App.tsx` ou `routes.tsx`)

**Adicione os imports:**

```typescript
import { LocalLoginPage } from './modules/auth/LocalLoginPage'
import { ActivateUsersPage } from './modules/admin/pages/ActivateUsersPage'
```

**Adicione as rotas:**

```typescript
// Rota pública (login)
<Route path="/login-local" element={<LocalLoginPage />} />

// Rota protegida (admin)
<Route path="/admin/ativar-usuarios" element={<ActivateUsersPage />} />
```

**Exemplo completo:**

```typescript
<Routes>
  {/* Rotas públicas */}
  <Route path="/login" element={<LoginPage />} />
  <Route path="/login-local" element={<LocalLoginPage />} />  {/* ← NOVA */}
  <Route path="/signup" element={<SignupPage />} />
  
  {/* Rotas protegidas */}
  <Route element={<PrivateRoute />}>
    <Route path="/dashboard" element={<DashboardPage />} />
    
    {/* Rotas de admin */}
    <Route path="/admin/usuarios" element={<AdminUsersPage />} />
    <Route path="/admin/ativar-usuarios" element={<ActivateUsersPage />} />  {/* ← NOVA */}
    <Route path="/admin/funcoes" element={<RolesPage />} />
  </Route>
</Routes>
```

---

### **4️⃣ ADICIONAR LINK NO MENU ADMIN**

Encontre onde você define o menu de administração (pode ser `Sidebar.tsx`, `AdminLayout.tsx`, ou similar)

**Adicione o link:**

```typescript
{
  label: 'Ativar Usuários',
  path: '/admin/ativar-usuarios',
  icon: UserPlus,  // ou outro ícone de sua preferência
  description: 'Criar e gerenciar usuários do sistema'
}
```

---

### **5️⃣ AJUSTAR COMPONENTE BUTTON (OPCIONAL)**

Se você vir erros de compilação sobre `icon` prop no Button:

**Opção A: Adicionar suporte a icon no Button.tsx**

```typescript
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
  icon?: React.ComponentType<{ className?: string }>  // ← ADICIONE
}

export function Button({ 
  children, 
  variant = 'primary', 
  size = 'md', 
  loading, 
  icon: Icon,  // ← ADICIONE
  ...props 
}: ButtonProps) {
  return (
    <button {...props}>
      {loading ? (
        <Spinner />
      ) : (
        <>
          {Icon && <Icon className="w-5 h-5 mr-2" />}  {/* ← ADICIONE */}
          {children}
        </>
      )}
    </button>
  )
}
```

**Opção B: Remover prop icon dos botões** (mais rápido)

Nas linhas que dão erro, remova a prop `icon`:

```typescript
// ANTES:
<Button icon={UserPlus} variant="primary">
  Novo Usuário
</Button>

// DEPOIS:
<Button variant="primary">
  <UserPlus className="w-5 h-5 mr-2" />
  Novo Usuário
</Button>
```

---

### **6️⃣ CONFIGURAR REDIRECT PADRÃO (OPCIONAL)**

Para usar o login local como padrão:

**Em App.tsx ou routes.tsx:**

```typescript
// Redirecionar / para /login-local
<Route path="/" element={<Navigate to="/login-local" replace />} />
```

Ou manter ambos e adicionar um botão na tela de login normal:

```typescript
// Em LoginPage.tsx
<Link 
  to="/login-local" 
  className="text-primary-600 hover:text-primary-700"
>
  Login com seleção visual de usuário →
</Link>
```

---

## 🧪 TESTAR O SISTEMA

### **Teste 1: Primeiro Acesso do Admin**

```bash
1. Abra o navegador em: http://localhost:5173/admin/ativar-usuarios
2. Deve aparecer um modal: "Defina sua senha de administrador"
3. Digite uma senha (mínimo 6 caracteres)
4. Clique em "Definir Senha e Continuar"
5. ✅ Deve salvar e mostrar a página de ativação
```

### **Teste 2: Criar Funcionário**

```bash
1. Na página "Ativar Usuários", clique em "Novo Usuário"
2. Preencha:
   Nome: João Silva
   Email: joao@teste.com
   Senha: joao123
   Função: Vendedor (ou outra disponível)
3. Clique em "Criar e Ativar Usuário"
4. ✅ Deve aparecer mensagem de sucesso
5. ✅ João deve aparecer na lista abaixo
```

### **Teste 3: Login Visual**

```bash
1. Abra: http://localhost:5173/login-local
2. ✅ Deve aparecer cards com:
   - Admin (você)
   - João Silva
3. Clique no card do João
4. Digite a senha: joao123
5. Clique em "Entrar no Sistema"
6. ✅ Deve logar e ir para o dashboard
7. ✅ Deve aplicar permissões de Vendedor
```

### **Teste 4: Ativar/Desativar**

```bash
1. Como admin, vá em: /admin/ativar-usuarios
2. Na lista de usuários, clique no botão ❌ (desativar) do João
3. ✅ João fica "Inativo"
4. Tente fazer login como João em /login-local
5. ✅ Não deve permitir (usuário inativo)
6. Ative novamente clicando em ✅
7. ✅ João pode fazer login novamente
```

---

## 🐛 PROBLEMAS COMUNS

### ❌ Erro: "Extension pgcrypto not found"

**Solução:**
```sql
-- Execute no Supabase SQL Editor:
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

### ❌ Erro: "Property signInLocal does not exist"

**Solução:** Verifique se você adicionou `signInLocal` no tipo `AuthContextType` E na função `AuthProvider` E no `value`.

### ❌ Cards não aparecem no login

**Diagnóstico SQL:**
```sql
-- Verificar usuários ativos
SELECT id, nome, email, usuario_ativo, senha_definida 
FROM funcionarios;

-- Se nenhum ativo, ativar admin manualmente:
UPDATE funcionarios
SET usuario_ativo = TRUE,
    senha_definida = TRUE
WHERE tipo_admin = 'admin_empresa'
LIMIT 1;
```

### ❌ Senha sempre incorreta

**Diagnóstico SQL:**
```sql
-- Ver hash da senha
SELECT id, nome, senha_hash, senha_definida 
FROM funcionarios 
WHERE email = 'joao@teste.com';

-- Redefinir senha manualmente:
SELECT definir_senha_local(
  (SELECT id FROM funcionarios WHERE email = 'joao@teste.com'),
  'joao123'
);
```

### ❌ Erro 403 / RLS blocking

**Solução:**
```sql
-- Verificar se RLS está configurado
SELECT tablename, policies 
FROM pg_policies 
WHERE schemaname = 'public';

-- Reexecutar o script SQL completo se necessário
```

---

## 📊 QUERIES ÚTEIS

### Ver todos os funcionários e status

```sql
SELECT 
  id,
  nome,
  email,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  created_at
FROM funcionarios
ORDER BY 
  CASE WHEN tipo_admin = 'admin_empresa' THEN 0 ELSE 1 END,
  nome;
```

### Ver sessões ativas

```sql
SELECT 
  f.nome,
  f.email,
  s.criado_em,
  s.expira_em,
  s.ativo,
  CASE 
    WHEN s.expira_em > NOW() THEN 'Válida'
    ELSE 'Expirada'
  END as status
FROM sessoes_locais s
JOIN funcionarios f ON s.funcionario_id = f.id
WHERE s.ativo = TRUE
ORDER BY s.criado_em DESC;
```

### Ver permissões de um funcionário

```sql
SELECT 
  f.nome as funcionario,
  func.nome as funcao,
  fp.permissao
FROM funcionarios f
JOIN funcionario_funcoes ff ON f.id = ff.funcionario_id
JOIN funcoes func ON ff.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
WHERE f.email = 'joao@teste.com'
ORDER BY fp.permissao;
```

### Resetar tudo (cuidado!)

```sql
-- APENAS PARA DESENVOLVIMENTO/TESTES
-- Limpar sessões
DELETE FROM sessoes_locais;

-- Resetar senhas
UPDATE funcionarios
SET senha_hash = NULL,
    senha_definida = FALSE,
    primeiro_acesso = TRUE,
    usuario_ativo = FALSE;
```

---

## ✅ CHECKLIST FINAL

Antes de considerar pronto:

```
🗄️ Banco de Dados
  [ ] SQL executado sem erros
  [ ] Extension pgcrypto ativada
  [ ] Funções criadas (4 funções)
  [ ] Tabela sessoes_locais criada
  [ ] RLS policies ativas

💻 Código
  [ ] LocalLoginPage.tsx criado
  [ ] ActivateUsersPage.tsx criado
  [ ] AuthContext.tsx atualizado (signInLocal)
  [ ] Rotas adicionadas
  [ ] Link no menu admin

🧪 Testes
  [ ] Admin define senha (primeira vez)
  [ ] Admin cria funcionário
  [ ] Cards aparecem no /login-local
  [ ] Login funciona com senha
  [ ] Ativar/desativar funciona
  [ ] Permissões aplicadas corretamente
  [ ] Sessão persiste (F5 não desloga)

📱 UX
  [ ] Cards visuais bonitos
  [ ] Avatar com iniciais funciona
  [ ] Badges de tipo aparecem
  [ ] Feedback de loading
  [ ] Mensagens de erro claras
  [ ] Responsivo (mobile + desktop)
```

---

## 🎯 RESULTADO FINAL

Ao completar todos os passos, você terá:

✅ **Tela de login visual** com cards de usuários
✅ **Admin cria funcionários** sem enviar emails
✅ **Cada usuário escolhe** clicando no seu card
✅ **Senhas criptografadas** com bcrypt
✅ **Sessões seguras** com token e expiração
✅ **Permissões aplicadas** automaticamente por função
✅ **Gerenciamento fácil** de ativar/desativar usuários

---

## 📞 PRECISA DE AJUDA?

Se algo não funcionar:

1. **Verifique os logs** do navegador (F12 → Console)
2. **Veja os erros** do Supabase (Dashboard → Logs)
3. **Execute as queries** de diagnóstico acima
4. **Confira** se todos os arquivos foram criados
5. **Reexecute** o SQL se necessário (é idempotente)

**Arquivos criados neste projeto:**
- `CRIAR_SISTEMA_LOGIN_LOCAL.sql` (SQL completo)
- `src/modules/auth/LocalLoginPage.tsx` (Login visual)
- `src/modules/admin/pages/ActivateUsersPage.tsx` (Ativação)
- `GUIA_SISTEMA_LOGIN_LOCAL.md` (Documentação)
- `COMANDOS_IMPLEMENTACAO.md` (Este arquivo)

---

**🚀 Pronto! Agora é só seguir os passos e testar!**
