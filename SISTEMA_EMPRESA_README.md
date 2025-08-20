# 🏢 Sistema de Configurações da Empresa

## 📋 **Funcionalidades Implementadas**

### ✅ **Configurações da Empresa:**
- Cadastro completo de dados da empresa (nome, CNPJ, telefone, email, endereço)
- Upload e gerenciamento de logo da empresa
- Storage seguro no Supabase
- Validações de formulário

### ✅ **Gestão de Funcionários:**
- Cadastro de funcionários com dados completos
- Sistema de login independente para funcionários
- Controle de ativação/desativação de funcionários
- Interface intuitiva para gerenciamento

### ✅ **Sistema de Permissões Granular:**
- **Módulos do Sistema**: Vendas, Produtos, Clientes, Caixa, Ordens de Serviço, Relatórios, Configurações, Backup
- **Permissões Específicas de Vendas**: Criar, editar, cancelar vendas, aplicar descontos
- **Permissões de Produtos**: Criar, editar, deletar produtos, gerenciar estoque
- **Permissões de Clientes**: Criar, editar, deletar clientes
- **Permissões de Caixa**: Abrir, fechar caixa, gerenciar movimentações
- **Permissões de OS**: Criar, editar, finalizar ordens de serviço
- **Permissões Administrativas**: Ver relatórios, exportar dados, alterar configurações

### ✅ **Segurança e Isolamento:**
- **Row Level Security (RLS)** completo para todas as tabelas
- Isolamento total de dados por empresa
- Funcionários só acessam dados da própria empresa
- Sistema de autenticação seguro

## 🚀 **Como Usar**

### **1. Execute o Script SQL no Supabase:**
```sql
-- Execute o arquivo: CRIAR_SISTEMA_EMPRESA.sql
```

### **2. Configure o Storage (Supabase Dashboard):**
1. Acesse o Supabase Dashboard
2. Vá em **Storage**
3. Crie um bucket chamado `empresas`
4. Marque como **público**
5. Configure as políticas de acesso

### **3. Acesse o Sistema:**
1. Faça login no sistema
2. Vá em **Configurações > Empresa**
3. Configure os dados da sua empresa
4. Adicione funcionários e configure permissões

## 📊 **Estrutura do Sistema**

### **Tabelas Criadas:**
- `empresas` - Dados das empresas
- `funcionarios` - Dados dos funcionários
- `login_funcionarios` - Credenciais de login dos funcionários

### **Componentes:**
- `ConfiguracoesEmpresa.tsx` - Interface principal
- `useEmpresa.ts` - Hook para gerenciamento de dados
- `PermissaoContext.tsx` - Contexto de permissões
- `empresa.ts` - Tipos TypeScript

## 🔐 **Permissões Disponíveis**

### **Módulos Principais:**
- ✅ **Vendas** - Acesso ao módulo de vendas
- ✅ **Produtos** - Gerenciar produtos e estoque
- ✅ **Clientes** - Cadastro e gestão de clientes
- ✅ **Caixa** - Controle de caixa e movimentações
- ✅ **Ordens de Serviço** - Gestão de OS
- ✅ **Relatórios** - Visualizar relatórios
- ✅ **Configurações** - Alterar configurações
- ✅ **Backup** - Fazer backup dos dados

### **Permissões Específicas:**
- **Vendas**: Criar, editar, cancelar, aplicar desconto
- **Produtos**: Criar, editar, deletar, gerenciar estoque
- **Clientes**: Criar, editar, deletar
- **Caixa**: Abrir, fechar, movimentar
- **OS**: Criar, editar, finalizar
- **Admin**: Ver relatórios, exportar, configurar

## 🎯 **Cards Condicionais**

O sistema permite que você **ative/desative cards** que os funcionários podem ver:

```tsx
// Exemplo de uso no código:
<ConditionalCard permissao="vendas">
  <CardVendas />
</ConditionalCard>

<ConditionalCard permissao="produtos">
  <CardProdutos />
</ConditionalCard>
```

## 🔧 **Configuração de Permissões**

### **Para o Patrão:**
- **Acesso total** a todos os módulos
- **Pode gerenciar funcionários** e suas permissões
- **Controle completo** sobre a empresa

### **Para Funcionários:**
- **Acesso limitado** conforme permissões definidas
- **Interface adaptada** às permissões concedidas
- **Login independente** do sistema principal

## 📝 **Exemplo de Uso Prático**

### **Cenário: Loja com 3 funcionários**

1. **João (Vendedor)**:
   - ✅ Vendas (criar vendas)
   - ✅ Clientes (criar/editar)
   - ❌ Produtos, Caixa, Relatórios

2. **Maria (Gerente)**:
   - ✅ Vendas (criar, editar, cancelar)
   - ✅ Produtos (criar, editar, estoque)
   - ✅ Clientes (todos)
   - ✅ Caixa (abrir, fechar)
   - ✅ Relatórios (visualizar)

3. **Pedro (Técnico)**:
   - ✅ Ordens de Serviço (criar, editar, finalizar)
   - ✅ Clientes (visualizar)
   - ❌ Vendas, Produtos, Caixa

## 🛡️ **Segurança**

- **RLS** ativo em todas as tabelas
- **Isolamento completo** de dados por empresa
- **Autenticação segura** para funcionários
- **Validações** no frontend e backend
- **Controle granular** de permissões

## 📱 **Interface Responsiva**

- **Design moderno** e intuitivo
- **Responsivo** para desktop e tablet
- **Feedback visual** para ações
- **Notificações** de sucesso/erro
- **Loading states** para melhor UX

---

## ✨ **Resultado Final**

Agora você tem um sistema completo para:
- ✅ Gerenciar dados da empresa
- ✅ Controlar funcionários
- ✅ Configurar permissões granulares
- ✅ Mostrar/ocultar funcionalidades por usuário
- ✅ Manter segurança total dos dados

**O patrão tem controle total, e cada funcionário vê apenas o que pode usar!** 🎯
