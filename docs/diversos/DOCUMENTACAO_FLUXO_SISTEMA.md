# 🎯 FLUXO COMPLETO DO SISTEMA PDV ALLIMPORT

## 📝 Especificação do Sistema

### Como o Sistema DEVE Funcionar

O sistema utiliza um **fluxo de login em 2 etapas** para garantir segurança e controle de permissões por funcionário.

---

## 🔐 ETAPA 1: Cadastro da Empresa (Email Principal)

### O que acontece:
1. **Cliente compra o sistema**
2. **Faz cadastro inicial** com:
   - Email principal: `empresa@dominio.com`
   - Senha principal: senha segura
   - Dados da empresa: Nome, CNPJ, etc.

### Resultado:
- ✅ Empresa criada na tabela `empresas`
- ✅ Email principal registrado no `auth.users` do Supabase
- ✅ Cliente pode fazer login com este email

**🚨 IMPORTANTE:** Este email é o "MASTER" da empresa. Só ele pode acessar o sistema inicialmente.

---

## 👤 ETAPA 2: Primeiro Acesso

### Cenário A: SEM Funcionários Cadastrados

**O que aparece:**
```
┌──────────────────────────────────────┐
│  ⚠️ CADASTRE O PRIMEIRO FUNCIONÁRIO  │
│                                      │
│  Para usar o sistema, você precisa  │
│  cadastrar pelo menos um funcionário.│
│                                      │
│  [Cadastrar Primeiro Funcionário]   │
└──────────────────────────────────────┘
```

### Cenário B: COM Funcionários Cadastrados

**O que aparece:**
```
┌──────────────────────────────────────┐
│  👥 SELECIONE SEU FUNCIONÁRIO         │
│                                      │
│  ○ João Silva (Admin)                │
│  ○ Maria Santos (Vendedora)          │
│  ○ Pedro Oliveira (Caixa)            │
│                                      │
│  [Continuar]                         │
└──────────────────────────────────────┘
```

---

## 🎯 ETAPA 3: Cadastrar Primeiro Funcionário (ADMIN AUTOMÁTICO)

### Regra de Ouro:
> **O PRIMEIRO funcionário cadastrado em uma empresa é AUTOMATICAMENTE definido como `admin_empresa` = ADMIN COMPLETO**

### Formulário de Cadastro:
```
┌──────────────────────────────────────┐
│  CADASTRAR PRIMEIRO FUNCIONÁRIO      │
│                                      │
│  Nome: _____________________________ │
│  Cargo: ____________________________ │
│  Email (opcional): _________________ │
│  Usuário: __________________________ │
│  Senha: ____________________________ │
│                                      │
│  [Cadastrar]                         │
└──────────────────────────────────────┘
```

### O que acontece no banco:
```sql
INSERT INTO funcionarios (
  empresa_id,
  nome,
  tipo_admin,  -- 🎯 AUTOMÁTICO: 'admin_empresa'
  funcao_id,   -- Administrador (todas as permissões)
  status
) VALUES (
  '[empresa_id]',
  'João Silva',
  'admin_empresa',  -- ⭐ DEFINIDO PELO TRIGGER
  '[funcao_admin_id]',
  'ativo'
);

INSERT INTO login_funcionarios (
  funcionario_id,
  usuario,
  senha
) VALUES (
  '[funcionario_id]',
  'joaosilva',
  '[senha_hash]'
);
```

### Trigger que faz a mágica:
```sql
CREATE TRIGGER trigger_first_user_admin
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION set_first_user_as_admin();
```

**Resultado:**
- ✅ João Silva = `tipo_admin: 'admin_empresa'`
- ✅ Tem TODAS as 77 permissões do sistema
- ✅ Pode criar novos funcionários
- ✅ Pode definir permissões de outros funcionários

---

## 👥 ETAPA 4: Cadastrar Outros Funcionários (FUNCIONÁRIOS LIMITADOS)

### Agora o admin pode criar funcionários com permissões limitadas:

```
┌──────────────────────────────────────┐
│  CADASTRAR NOVO FUNCIONÁRIO          │
│                                      │
│  Nome: _____________________________ │
│  Cargo: ____________________________ │
│  Função: [Vendedor ▼]                │
│  Usuário: __________________________ │
│  Senha: ____________________________ │
│                                      │
│  [Cadastrar]                         │
└──────────────────────────────────────┘
```

### Funções Disponíveis:
- **Administrador** → 72 permissões (acesso quase total)
- **Vendedor** → 16 permissões (vendas, produtos, clientes)
- **Caixa** → 8 permissões (caixa, vendas)
- **Estoquista** → 6 permissões (produtos, estoque)

### O que acontece no banco:
```sql
INSERT INTO funcionarios (
  empresa_id,
  nome,
  tipo_admin,  -- 🎯 'funcionario' (NÃO é admin)
  funcao_id,   -- Vendedor, Caixa, etc.
  status
) VALUES (
  '[empresa_id]',
  'Maria Santos',
  'funcionario',  -- ⭐ FUNCIONÁRIO COMUM
  '[funcao_vendedor_id]',
  'ativo'
);
```

**Resultado:**
- ✅ Maria Santos = `tipo_admin: 'funcionario'`
- ✅ Tem apenas 16 permissões (definidas pela função "Vendedor")
- ✅ Não pode criar outros funcionários
- ✅ Não vê configurações administrativas

---

## 🔐 ETAPA 5: Login Final (2 Passos)

### Passo 1: Email Principal da Empresa

```
┌──────────────────────────────────────┐
│  🔐 LOGIN EMPRESA                     │
│                                      │
│  Email: empresa@dominio.com          │
│  Senha: **********************       │
│                                      │
│  [Entrar]                            │
└──────────────────────────────────────┘
```

**Validação:** Sistema verifica se email existe na tabela `empresas`

### Passo 2: Selecionar Funcionário + Senha

```
┌──────────────────────────────────────┐
│  👤 SELECIONE SEU USUÁRIO            │
│                                      │
│  ○ João Silva (Admin) 👑             │
│  ○ Maria Santos (Vendedora)          │
│  ○ Pedro Oliveira (Caixa)            │
│                                      │
│  Senha: **********************       │
│                                      │
│  [Entrar]                            │
└──────────────────────────────────────┘
```

**Validação:**
1. Busca `login_funcionarios` WHERE `usuario = 'joaosilva'`
2. Compara senha com hash armazenado
3. Retorna dados do funcionário + empresa

---

## 🔑 ETAPA 6: Permissões Isoladas (SEM CONFLITO)

### Como funciona o sistema de permissões:

#### Admin Empresa (João Silva):
```typescript
{
  tipo_admin: 'admin_empresa',
  is_admin: true,
  is_admin_empresa: true,
  permissoes: [
    'administracao:full_access',
    'vendas:create',
    'vendas:delete',
    'produtos:create',
    'produtos:delete',
    'clientes:create',
    'clientes:delete',
    // ... mais 70 permissões
  ]
}
```

**Vê no sistema:**
- ✅ Dashboard completo
- ✅ Vendas
- ✅ Produtos
- ✅ Clientes
- ✅ Caixa
- ✅ Relatórios
- ✅ **Administração** (usuários, funções, permissões)
- ✅ Configurações

#### Funcionário Vendedor (Maria Santos):
```typescript
{
  tipo_admin: 'funcionario',
  is_admin: false,
  is_admin_empresa: false,
  permissoes: [
    'vendas:create',
    'vendas:read',
    'vendas:print',
    'produtos:read',
    'clientes:create',
    'clientes:read',
    'clientes:update',
    // ... 9 permissões adicionais
  ]
}
```

**Vê no sistema:**
- ✅ Dashboard (limitado)
- ✅ Vendas (criar, visualizar, imprimir)
- ✅ Produtos (apenas visualizar)
- ✅ Clientes (criar, editar, visualizar)
- ❌ **Administração** (não aparece no menu)
- ❌ Caixa (não tem permissão)
- ❌ Relatórios financeiros (não tem permissão)

### Como o código verifica:

```typescript
// usePermissions.tsx
const { checkPermission, is_admin, is_admin_empresa } = usePermissions()

// Verificar se pode criar venda
if (checkPermission('vendas', 'create')) {
  // ✅ PODE CRIAR VENDA
}

// Verificar se é admin
if (is_admin_empresa) {
  // ✅ MOSTRAR PAINEL ADMINISTRATIVO
}
```

---

## 🚨 PROBLEMAS COMUNS E SOLUÇÕES

### Problema 1: Funcionário comum aparecendo como admin

**Causa:** Jennifer (Vendedora) está acessando com o email principal da empresa

**Solução:**
1. Fazer LOGOUT da conta do email principal
2. Fazer LOGIN novamente com email principal
3. Selecionar "Jennifer Sousa" na tela de funcionários
4. Digitar a senha de Jennifer (não a senha do email principal)

### Problema 2: Primeiro funcionário não é admin

**Causa:** Trigger `set_first_user_as_admin` não existe ou não está funcionando

**Solução:** Execute o script `FLUXO_SISTEMA_CORRETO.sql` que recria o trigger

### Problema 3: Erro "campo usuario não existe"

**Causa:** Função `listar_usuarios_ativos()` está desatualizada

**Solução:** Execute o script `FLUXO_SISTEMA_CORRETO.sql` que atualiza a função

---

## ✅ CHECKLIST DE VALIDAÇÃO

Execute o script `FLUXO_SISTEMA_CORRETO.sql` e verifique:

- [ ] ✅ Trigger `set_first_user_as_admin` existe e está ativo
- [ ] ✅ Primeiro funcionário de cada empresa é `admin_empresa`
- [ ] ✅ Função `listar_usuarios_ativos` retorna campo `usuario`
- [ ] ✅ Tabela `login_funcionarios` existe e tem dados
- [ ] ✅ Login funciona em 2 passos (email empresa → funcionário)
- [ ] ✅ Admin empresa tem `is_admin_empresa = true`
- [ ] ✅ Funcionários normais têm `is_admin = false`
- [ ] ✅ Não há conflito de permissões entre funcionários

---

## 🎯 RESUMO VISUAL DO FLUXO

```
1. CADASTRO EMPRESA
   email@empresa.com + senha
   ↓
2. PRIMEIRO LOGIN
   email@empresa.com
   ↓
   Tem funcionários?
   ├─ NÃO → "Cadastre o primeiro funcionário"
   └─ SIM → Vai para passo 3
   ↓
3. SELECIONAR FUNCIONÁRIO
   [João Silva (Admin)] + senha_joao
   [Maria Santos (Vendedora)] + senha_maria
   ↓
4. ENTRAR NO SISTEMA
   - João: Vê tudo (admin_empresa)
   - Maria: Vê apenas vendas, produtos, clientes
```

---

## 🔧 SCRIPTS DE CORREÇÃO

- **`FLUXO_SISTEMA_CORRETO.sql`** - Valida e corrige todo o fluxo
- **`DIAGNOSTICAR_E_CORRIGIR_JENNIFER.sql`** - Corrige problema da Jennifer especificamente
- **`GERAR_LOGIN_JENNIFER.sql`** - Verifica se Jennifer tem credenciais de login

---

## 📞 Suporte

Se algum problema persistir:
1. Execute `FLUXO_SISTEMA_CORRETO.sql`
2. Verifique os logs do console (F12)
3. Verifique as permissões no Supabase

**Email de suporte:** novaradiosystem@outlook.com
