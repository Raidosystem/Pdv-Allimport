# 🎯 Sistema de Permissões Moderno - PDV Allimport

## 📋 Visão Geral

O sistema de permissões foi completamente reformulado para oferecer uma **interface visual intuitiva**, **templates predefinidos** e **gerenciamento simplificado** de acesso dos funcionários.

---

## ✨ Principais Melhorias

### 1. **Interface Visual Moderna**
- ✅ **Toggle switches** para ativar/desativar permissões
- ✅ **Categorias organizadas** por módulos (Vendas, Produtos, Clientes, etc.)
- ✅ **Cores diferenciadas** para cada categoria
- ✅ **Ícones intuitivos** para cada permissão
- ✅ **Resumo visual** de permissões ativas

### 2. **Templates Predefinidos**
Cinco templates prontos para uso imediato:

#### 🔴 **Administrador**
- Acesso total ao sistema
- Todas as permissões habilitadas
- Ideal para: Proprietário, Gerente Geral

#### 🟣 **Gerente**
- Gerencia vendas, estoque e relatórios
- Sem acesso a configurações do sistema
- Ideal para: Gerente de Loja, Supervisor

#### 🔵 **Vendedor**
- Realiza vendas e atende clientes
- Acesso limitado a vendas e cadastro de clientes
- Ideal para: Vendedor, Atendente

#### 🟢 **Técnico**
- Gerencia ordens de serviço
- Acesso completo a OS e clientes
- Ideal para: Técnico, Assistência Técnica

#### 🟡 **Operador de Caixa**
- Opera caixa e realiza vendas
- Sem permissão para descontos ou edição
- Ideal para: Caixa, Operador

---

## 🎨 Estrutura de Permissões

### **Módulos Principais** (Controle de Acesso)
```typescript
{
  vendas: boolean,           // Acessa módulo Vendas
  produtos: boolean,          // Acessa módulo Produtos
  clientes: boolean,          // Acessa módulo Clientes
  caixa: boolean,             // Acessa módulo Caixa
  ordens_servico: boolean,    // Acessa módulo OS
  funcionarios: boolean,      // Acessa módulo Funcionários
  relatorios: boolean,        // Acessa módulo Relatórios
  configuracoes: boolean,     // Acessa Configurações
  backup: boolean             // Acessa Backup
}
```

### **Permissões Específicas de Vendas**
```typescript
{
  pode_criar_vendas: boolean,    // Criar nova venda
  pode_editar_vendas: boolean,   // Editar venda existente
  pode_cancelar_vendas: boolean, // Cancelar venda
  pode_aplicar_desconto: boolean // Aplicar desconto
}
```

### **Permissões Específicas de Produtos**
```typescript
{
  pode_criar_produtos: boolean,     // Cadastrar produto
  pode_editar_produtos: boolean,    // Editar produto
  pode_deletar_produtos: boolean,   // Excluir produto
  pode_gerenciar_estoque: boolean   // Ajustar estoque
}
```

### **Permissões Específicas de Clientes**
```typescript
{
  pode_criar_clientes: boolean,   // Cadastrar cliente
  pode_editar_clientes: boolean,  // Editar cliente
  pode_deletar_clientes: boolean  // Excluir cliente
}
```

### **Permissões Específicas de Caixa**
```typescript
{
  pode_abrir_caixa: boolean,          // Abrir caixa
  pode_fechar_caixa: boolean,         // Fechar caixa
  pode_gerenciar_movimentacoes: boolean // Adicionar/remover dinheiro
}
```

### **Permissões Específicas de OS**
```typescript
{
  pode_criar_os: boolean,      // Criar ordem de serviço
  pode_editar_os: boolean,     // Editar OS
  pode_finalizar_os: boolean   // Finalizar/entregar OS
}
```

### **Permissões de Administração**
```typescript
{
  pode_ver_todos_relatorios: boolean,    // Visualizar relatórios
  pode_exportar_dados: boolean,          // Exportar relatórios
  pode_alterar_configuracoes: boolean,   // Alterar configurações
  pode_gerenciar_funcionarios: boolean,  // Gerenciar equipe
  pode_fazer_backup: boolean             // Fazer backup
}
```

---

## 🚀 Como Usar

### **1. Criar Novo Funcionário**
1. Acesse **Funcionários** no menu
2. Clique em **"Novo Funcionário"**
3. Preencha os dados básicos (nome, cargo, e-mail, telefone)
4. Escolha um **template rápido** ou personalize as permissões
5. Clique em **"Criar Funcionário"**

### **2. Editar Permissões**
1. Na lista de funcionários, clique no ícone de **editar** (✏️)
2. Role até **"Permissões de Acesso"**
3. Use os **toggle switches** para ativar/desativar permissões
4. Ou escolha um **template predefinido**
5. Clique em **"Salvar Alterações"**

### **3. Visualizar Permissões**
1. Na lista de funcionários, clique em **"Ver Permissões"**
2. Veja todas as permissões organizadas por categoria
3. Permissões ativas são destacadas com cores

### **4. Aplicar Template via SQL**
```sql
-- Aplicar template a um funcionário
SELECT aplicar_template_permissoes(
  'UUID_DO_FUNCIONARIO', 
  'vendedor'  -- Opções: admin, gerente, vendedor, tecnico, caixa
);
```

---

## 📊 Componentes Criados

### **1. PermissionsManager.tsx**
- Componente visual de gerenciamento de permissões
- Templates predefinidos
- Categorias expansíveis
- Toggle switches
- Resumo de permissões

**Localização:** `/src/components/admin/PermissionsManager.tsx`

### **2. FuncionariosPage.tsx**
- Página completa de gerenciamento de funcionários
- Integração com PermissionsManager
- Criação, edição e visualização
- Ativação/desativação de funcionários

**Localização:** `/src/pages/admin/FuncionariosPage.tsx`

### **3. useEmpresa Hook**
- Hook atualizado com novo sistema de permissões
- Cria funcionários com permissões JSON padronizadas
- Suporta atualização de permissões

**Localização:** `/src/hooks/useEmpresa.ts`

---

## 🗃️ Banco de Dados

### **Estrutura da Tabela `funcionarios`**
```sql
CREATE TABLE funcionarios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  empresa_id UUID REFERENCES empresas(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  nome VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  telefone VARCHAR(20),
  cargo VARCHAR(100) NOT NULL,
  ativo BOOLEAN DEFAULT true,
  permissoes JSONB NOT NULL DEFAULT '{}', -- ✅ Campo JSON para permissões
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### **Funções SQL Disponíveis**
```sql
-- Aplicar template de permissões
SELECT aplicar_template_permissoes('uuid_funcionario', 'template_nome');

-- Verificar permissões de todos funcionários
SELECT 
  nome,
  cargo,
  permissoes->>'ordens_servico' as acesso_os,
  permissoes->>'configuracoes' as acesso_config
FROM funcionarios;
```

---

## 🎯 Casos de Uso

### **Caso 1: Jennifer (Técnica)**
**Problema:** Jennifer não via OS e tinha acesso a Configurações

**Solução:**
```sql
UPDATE funcionarios
SET permissoes = jsonb_build_object(
  'ordens_servico', true,        -- ✅ Acesso a OS
  'pode_criar_os', true,
  'pode_editar_os', true,
  'pode_finalizar_os', true,
  'configuracoes', false,        -- ❌ Sem acesso a Config
  'pode_deletar_clientes', false, -- ❌ Sem deletar clientes
  'pode_deletar_produtos', false  -- ❌ Sem deletar produtos
  -- ... outras permissões
)
WHERE LOWER(nome) LIKE '%jennifer%';
```

### **Caso 2: Novo Vendedor**
1. Acessar **Funcionários**
2. Clicar em **"Novo Funcionário"**
3. Escolher template **"Vendedor"** 🔵
4. Criar funcionário - permissões aplicadas automaticamente

### **Caso 3: Promover Vendedor a Gerente**
1. Editar funcionário vendedor
2. Clicar em **"Ver templates"**
3. Selecionar template **"Gerente"** 🟣
4. Salvar alterações

---

## 🔒 Segurança

### **Regras de Negócio**
- ✅ Todo novo funcionário recebe permissões básicas (vendas, clientes, produtos - apenas visualização)
- ✅ Permissões críticas (deletar, configurações, backup) desabilitadas por padrão
- ✅ Somente Admin pode gerenciar funcionários
- ✅ Permissões são validadas no frontend e backend
- ✅ Logs de auditoria para mudanças de permissões

### **Validação de Acesso**
```typescript
// No componente
const { can } = usePermissions();

if (can('vendas', 'criar')) {
  // Permitir criar venda
}

if (can('produtos', 'deletar')) {
  // Mostrar botão de deletar
}
```

---

## 🎨 Interface Visual

### **Características**
- **Responsiva:** Funciona em desktop e tablet
- **Intuitiva:** Toggle switches visuais
- **Organizada:** Categorias expansíveis
- **Informativa:** Resumo de permissões ativas
- **Moderna:** Design com TailwindCSS
- **Acessível:** Cores e ícones para identificação rápida

### **Cores por Categoria**
- 🔵 Azul: Vendas
- 🟢 Verde: Produtos
- 🟣 Roxo: Clientes
- 🟡 Amarelo: Caixa
- 🟠 Laranja: Ordens de Serviço
- 🔵 Índigo: Relatórios
- 🔴 Vermelho: Administração

---

## 📚 Arquivo de Instalação

Execute o script SQL para configurar o sistema:

**Arquivo:** `MELHORAR_SISTEMA_PERMISSOES.sql`

```bash
# Execute no Supabase SQL Editor
# Ou via CLI:
psql -U postgres -d seu_banco -f MELHORAR_SISTEMA_PERMISSOES.sql
```

---

## ✅ Checklist de Implementação

- [x] Criar componente PermissionsManager
- [x] Criar página FuncionariosPage
- [x] Atualizar hook useEmpresa
- [x] Criar script SQL de migração
- [x] Definir templates predefinidos
- [x] Criar função SQL aplicar_template_permissoes
- [x] Documentar sistema
- [x] Aplicar permissões da Jennifer
- [ ] Testar criação de novo funcionário
- [ ] Testar aplicação de templates
- [ ] Validar UI responsiva
- [ ] Testar validação de acesso no frontend

---

## 🐛 Solução de Problemas

### **Problema: Permissões não aparecem no sistema**
```sql
-- Verificar estrutura da tabela
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'funcionarios';

-- Verificar se campo é JSONB
ALTER TABLE funcionarios 
ALTER COLUMN permissoes TYPE jsonb USING permissoes::jsonb;
```

### **Problema: Funcionário não vê módulo mesmo com permissão**
1. Verificar se permissão do módulo principal está ativa
2. Limpar cache do navegador
3. Fazer logout/login
4. Verificar no SQL:
```sql
SELECT nome, permissoes->>'ordens_servico' 
FROM funcionarios 
WHERE nome LIKE '%nome%';
```

### **Problema: Template não aplicado corretamente**
```sql
-- Reexecutar função
SELECT aplicar_template_permissoes('uuid', 'template_nome');

-- Verificar resultado
SELECT nome, jsonb_pretty(permissoes) 
FROM funcionarios 
WHERE id = 'uuid';
```

---

## 🎉 Resultado Final

Agora você tem:
- ✅ **Interface visual moderna** e intuitiva
- ✅ **5 templates predefinidos** prontos para uso
- ✅ **Sistema granular** de permissões
- ✅ **Fácil manutenção** via UI ou SQL
- ✅ **Segurança aprimorada** com validações
- ✅ **Documentação completa**

---

## 📞 Suporte

Para dúvidas ou problemas:
1. Consulte esta documentação
2. Verifique o arquivo `MELHORAR_SISTEMA_PERMISSOES.sql`
3. Execute queries de diagnóstico fornecidas
4. Verifique logs do console do navegador

---

**Desenvolvido para PDV Allimport v2.2.3** 🚀
