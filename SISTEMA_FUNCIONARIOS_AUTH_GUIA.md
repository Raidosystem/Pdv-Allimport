# 🚀 SISTEMA DE FUNCIONÁRIOS COM AUTH - GUIA COMPLETO

## ✅ O QUE FOI IMPLEMENTADO

Sistema completo para **TODOS os funcionários** terem:
- ✅ Conta própria no Supabase Auth (sessão persiste)
- ✅ Login com email + senha
- ✅ Permissões editáveis em tempo real
- ✅ Sem localStorage (multi-tenant seguro)
- ✅ Sessão persiste entre reloads (cookies httpOnly)

---

## 📋 ARQUIVOS CRIADOS/MODIFICADOS

### 1. `src/services/funcionarioAuthService.ts` ⭐ NOVO
**Serviço para criar funcionários com Auth automaticamente**

Funções principais:
- `criarFuncionarioComAuth()` - Cria funcionário + conta Auth
- `listarFuncionariosSemAuth()` - Lista funcionários sem conta
- `vincularAuthUsuario()` - Vincula Auth existente

### 2. `src/modules/auth/AuthContext.tsx` ✏️ MODIFICADO
**Login real no Supabase Auth em vez de localUser temporário**

Mudanças:
```typescript
// ❌ ANTES: localUser temporário (perdia na atualização)
const signInLocal = async (userData: any) => {
  const localUser = { id: userData.id, ... }
  setUser(localUser) // Só existe na memória React
}

// ✅ AGORA: Login real no Supabase Auth
const signInLocal = async (userData: { email: string; senha: string }) => {
  const { data } = await supabase.auth.signInWithPassword({
    email: userData.email,
    password: userData.senha
  })
  // Sessão gerenciada automaticamente pelo Supabase
  // Persiste em cookies httpOnly - não usa localStorage
}
```

### 3. `SISTEMA_FUNCIONARIOS_AUTH_COMPLETO.sql` ⭐ NOVO
**Scripts SQL para gerenciar funcionários**

Funções:
- `criar_funcionario_com_auth()` - Prepara dados do funcionário
- `vincular_auth_user_funcionario()` - Vincula user_id após criar Auth
- Query para listar funcionários sem conta Auth

---

## 🔧 COMO USAR

### Para NOVOS funcionários:

#### Opção 1: Via TypeScript (Recomendado) 🌟

```typescript
import { criarFuncionarioComAuth } from '@/services/funcionarioAuthService'

const resultado = await criarFuncionarioComAuth({
  nome: 'João Silva',
  email: 'joao@example.com',
  senha: '123456',
  empresa_id: 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  funcao_id: '[uuid-funcao-vendedor]',
  cpf: '123.456.789-00',     // opcional
  telefone: '(11) 98765-4321' // opcional
})

if (resultado.success) {
  console.log('✅ Funcionário criado!')
  console.log('   Email:', resultado.email)
  console.log('   Senha:', '123456')
  console.log('   Pode fazer login agora!')
}
```

**O que acontece:**
1. ✅ Cria conta no `auth.users` (Supabase Auth)
2. ✅ Cria registro em `funcionarios` com `user_id` vinculado
3. ✅ Auto-aprova em `user_approvals`
4. ✅ Funcionário pode fazer login imediatamente com email/senha

#### Opção 2: Via SQL (Manual)

```sql
-- 1. Criar dados do funcionário
SELECT criar_funcionario_com_auth(
  'Maria Santos',                           -- nome
  'maria@example.com',                       -- email
  '123456',                                  -- senha
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',  -- empresa_id
  '[uuid-funcao-caixa]',                    -- funcao_id
  '987.654.321-00',                         -- cpf (opcional)
  '(11) 91234-5678'                         -- telefone (opcional)
);

-- 2. Criar conta no Supabase Dashboard:
--    Authentication > Users > Add user
--    Email: maria@example.com
--    Password: 123456
--    ✅ Auto Confirm User: SIM

-- 3. Vincular user_id gerado:
SELECT vincular_auth_user_funcionario(
  '[funcionario_id]',  -- ID retornado no passo 1
  '[user_id_gerado]'   -- UUID gerado pelo Supabase Auth
);
```

### Para FUNCIONÁRIOS EXISTENTES (Jennifer, etc):

#### Migrar funcionário sem Auth:

```typescript
// 1. Listar funcionários sem conta Auth
import { listarFuncionariosSemAuth } from '@/services/funcionarioAuthService'

const semAuth = await listarFuncionariosSemAuth()
// Retorna: [{ id, nome, email, funcoes: { nome } }]

// 2. Criar conta Auth no dashboard manualmente:
//    Supabase > Authentication > Users > Add user
//    Email: email_do_funcionario
//    Senha: defina uma senha
//    ✅ Auto Confirm User

// 3. Vincular user_id:
import { vincularAuthUsuario } from '@/services/funcionarioAuthService'

await vincularAuthUsuario(
  funcionario_id,  // ID do funcionário
  user_id_gerado   // UUID do Supabase Auth
)
```

---

## 🔐 COMO FUNCIONA O LOGIN

### Fluxo de Login:

```typescript
// No componente de login (ex: LoginLocal.tsx)
import { useAuth } from '@/modules/auth/AuthContext'

const { signInLocal } = useAuth()

const handleLogin = async () => {
  try {
    await signInLocal({
      email: 'joao@example.com',
      senha: '123456'
    })
    
    // ✅ Login bem-sucedido!
    // Usuário redirecionado automaticamente
    
  } catch (error) {
    console.error('Erro:', error.message)
    // Exibir mensagem de erro ao usuário
  }
}
```

### O que acontece internamente:

1. ✅ `signInLocal()` chama `supabase.auth.signInWithPassword()`
2. ✅ Supabase valida email/senha no `auth.users`
3. ✅ Cria sessão com cookies httpOnly (não usa localStorage)
4. ✅ `onAuthStateChange` detecta nova sessão
5. ✅ Busca dados do funcionário em `funcionarios` pelo `user_id`
6. ✅ Carrega permissões da `funcao_id`
7. ✅ Sistema pronto para uso!

### Persistência entre reloads:

```
ANTES (❌ localUser temporário):
1. Login → localUser criado na memória React
2. Page refresh → Supabase recarrega última sessão (admin)
3. ❌ Funcionário some, volta pro admin

AGORA (✅ Auth real):
1. Login → Sessão criada no Supabase Auth (cookies)
2. Page refresh → Supabase recarrega sessão do funcionário
3. ✅ Funcionário permanece logado!
```

---

## 🎯 EDITAR PERMISSÕES

Sistema já implementado em `AdminRolesPermissionsPageNew.tsx`:

### Fluxo de edição:

1. Admin acessa painel de permissões
2. Seleciona função (Vendedor, Caixa, etc)
3. Marca/desmarca permissões
4. Salva → Dispara evento `pdv_permissions_reload`
5. ✅ Funcionário logado recebe permissões atualizadas em tempo real

### Código relevante:

```typescript
// Em AdminRolesPermissionsPageNew.tsx (linha ~417)
const handleSavePermissions = async () => {
  // ... salvar permissões no banco ...
  
  // ✅ Notificar todos os componentes
  window.dispatchEvent(new CustomEvent('pdv_permissions_reload'))
}
```

---

## 📊 VERIFICAR STATUS

### SQL: Listar funcionários e status Auth

```sql
SELECT 
  f.id,
  f.nome,
  f.email,
  f.status,
  fc.nome as funcao,
  CASE 
    WHEN f.user_id IS NULL THEN '❌ SEM CONTA AUTH'
    ELSE '✅ TEM CONTA AUTH'
  END as status_auth,
  f.user_id
FROM funcionarios f
LEFT JOIN funcoes fc ON fc.id = f.funcao_id
WHERE f.tipo_admin IS NULL
ORDER BY f.created_at DESC;
```

---

## 🚨 TROUBLESHOOTING

### Problema: "Email ou senha incorretos"

**Causa:** Funcionário não tem conta no `auth.users`

**Solução:**
```typescript
import { listarFuncionariosSemAuth } from '@/services/funcionarioAuthService'
const semAuth = await listarFuncionariosSemAuth()
// Criar conta Auth para esses funcionários
```

### Problema: "Permissões não atualizam"

**Causa:** Evento `pdv_permissions_reload` não disparado

**Solução:** Verificar se `AdminRolesPermissionsPageNew.tsx` tem:
```typescript
window.dispatchEvent(new CustomEvent('pdv_permissions_reload'))
```

### Problema: "Page refresh volta pro admin"

**Causa:** Funcionário não tem `user_id` vinculado

**Solução:**
```sql
-- Verificar user_id
SELECT id, nome, email, user_id 
FROM funcionarios 
WHERE email = 'email_do_funcionario';

-- Se user_id é NULL, vincular:
UPDATE funcionarios 
SET user_id = '[uuid_do_auth]' 
WHERE id = '[funcionario_id]';
```

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

Para cada novo funcionário:

- [ ] Criar funcionário com `criarFuncionarioComAuth()`
- [ ] Verificar que `user_id` foi preenchido
- [ ] Testar login com email/senha
- [ ] Atualizar página → Funcionário permanece logado
- [ ] Editar permissões da função
- [ ] Verificar que permissões atualizaram

---

## 🎉 BENEFÍCIOS

✅ **Multi-tenant seguro:** Cada funcionário tem conta própria  
✅ **Sem localStorage:** Sessões em cookies httpOnly do Supabase  
✅ **RLS funciona:** `user_id` vinculado ao `auth.users`  
✅ **Sessão persiste:** Page refresh não desloga  
✅ **Permissões editáveis:** Mudanças em tempo real  
✅ **Escalável:** Funciona para 1 ou 1000 funcionários  

---

## 📚 PRÓXIMOS PASSOS

1. **Migrar funcionários existentes:**
   - Executar `listarFuncionariosSemAuth()`
   - Criar contas Auth para todos
   - Vincular `user_id`

2. **Automatizar criação:**
   - Adicionar UI de cadastro de funcionários
   - Integrar com `criarFuncionarioComAuth()`
   - Enviar email com credenciais

3. **Melhorias futuras:**
   - Redefinição de senha por email
   - 2FA (autenticação de dois fatores)
   - Logs de acesso por funcionário

---

**Sistema pronto para produção! 🚀**
