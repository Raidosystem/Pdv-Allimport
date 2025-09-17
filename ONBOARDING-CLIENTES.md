# Onboarding de Clientes - PDV Allimport

## 🎯 Fluxo do Cliente (Comprador do Sistema)

### 1. **Cliente Compra o Sistema**
```
Cliente → Cadastro → Primeiro Login → Automático Admin da Empresa
```

**O que acontece automaticamente:**
- ✅ Cliente recebe acesso ao sistema
- ✅ Primeiro usuário da empresa = `admin_empresa` (automático)
- ✅ Acesso total às funcionalidades administrativas
- ✅ Pode gerenciar funcionários e permissões

### 2. **Acesso do Admin da Empresa**
**Caminho:** `Dashboard → Administração → Administração do Sistema`

**Permissões Automáticas:**
- ✅ **Criar/Editar/Excluir** funcionários
- ✅ **Configurar** funções e permissões
- ✅ **Acessar** relatórios e dashboard
- ✅ **Configurar** sistema da empresa
- ✅ **Fazer backup** e restauração
- ✅ **Visualizar** logs de auditoria

---

## 👥 Gestão de Funcionários

### **Admin da Empresa pode:**

#### 1. **Convidar Funcionários**
- Enviar convites por email
- Definir função/cargo inicial
- Configurar permissões específicas
- Definir lojas de acesso (multi-loja)

#### 2. **Gerenciar Permissões**
- Criar funções personalizadas
- Definir matriz de permissões
- Controlar acesso por módulo
- Configurar limites (desconto, cancelamento)

#### 3. **Monitorar Atividade**
- Ver quem está online
- Histórico de login
- Ações realizadas
- Sessões ativas

---

## 🔐 Níveis de Acesso

### **Admin da Empresa** (Cliente)
```
✅ Acesso TOTAL à sua empresa
✅ Gerenciar funcionários
✅ Configurar permissões
✅ Relatórios e dashboard
✅ Configurações do sistema
✅ Backup e restauração
❌ NÃO vê outras empresas
```

### **Funcionário**
```
✅ Usar PDV conforme permissões
✅ Acessar módulos liberados
✅ Ver relatórios permitidos
❌ NÃO acessa administração
❌ NÃO gerencia usuários
```

### **Super Admin** (Desenvolvedor)
```
✅ Acesso a TODAS as empresas
✅ Gerenciar sistema global
✅ Estatísticas de todas empresas
✅ Configurações avançadas
```

---

## 🚀 Configuração Inicial (Cliente)

### **Passo 1: Primeiro Login**
1. Cliente acessa o sistema
2. Sistema automaticamente define como `admin_empresa`
3. Acesso liberado para área administrativa

### **Passo 2: Configurar Empresa**
1. **Dados da Empresa:** Nome, CNPJ, logo
2. **Configurações:** Tema, moeda, fuso horário
3. **Integração:** Mercado Pago, email, WhatsApp
4. **Fiscal:** Regime tributário, inscrições

### **Passo 3: Criar Funcionários**
1. **Definir Funções:** Vendedor, Gerente, Caixa, etc.
2. **Configurar Permissões:** Por módulo e ação
3. **Convidar Funcionários:** Email com link de ativação
4. **Definir Limites:** Desconto, cancelamento, etc.

### **Passo 4: Configurar PDV**
1. **Produtos:** Importar ou cadastrar
2. **Formas de Pagamento:** Dinheiro, cartão, PIX
3. **Impressoras:** Configurar cupom fiscal
4. **Estoque:** Definir controle e alertas

---

## 📋 Checklist do Cliente

### ✅ **Configuração Básica**
- [ ] Dados da empresa completos
- [ ] Logo/tema personalizado
- [ ] Configurações fiscais
- [ ] Formas de pagamento

### ✅ **Equipe**
- [ ] Funções criadas (Vendedor, Gerente, etc.)
- [ ] Permissões configuradas
- [ ] Funcionários convidados
- [ ] Limites definidos

### ✅ **Produtos**
- [ ] Categorias criadas
- [ ] Produtos cadastrados
- [ ] Preços configurados
- [ ] Estoque inicial

### ✅ **Operação**
- [ ] Primeiro teste de venda
- [ ] Impressão de cupom
- [ ] Fechamento de caixa
- [ ] Backup configurado

---

## 💡 Mensagens para o Cliente

### **Bem-vindo!**
```
"Parabéns! Você agora é o administrador da sua empresa no PDV Allimport.
Como administrador, você tem controle total sobre:
- Funcionários e suas permissões
- Configurações do sistema
- Relatórios e dashboard
- Backup e segurança

Comece criando suas primeiras funções e convidando sua equipe!"
```

### **Área Administrativa**
```
"Como administrador da empresa, você pode gerenciar todos os funcionários e configurações.
Use esta área para:
- Convidar novos funcionários
- Configurar permissões
- Monitorar atividades
- Fazer backup dos dados"
```

---

## 🔧 Configuração Técnica

### **Database Trigger**
```sql
-- Primeiro usuário da empresa = admin_empresa automático
CREATE TRIGGER trigger_first_user_admin
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION set_first_user_as_admin();
```

### **Permissões Automáticas**
```typescript
// Admin da empresa recebe permissões automáticas
if (is_admin_empresa) {
  permissoes.add('administracao.usuarios:create');
  permissoes.add('administracao.usuarios:read');
  // ... todas as permissões administrativas
}
```

### **Verificação de Acesso**
```typescript
// Admin da empresa pode acessar recursos administrativos
if (context.is_admin_empresa) {
  const adminResources = ['administracao.usuarios', 'administracao.funcoes'];
  if (adminResources.some(resource => recurso.startsWith(resource))) {
    return true;
  }
}
```

---

## ✅ **Sistema Pronto para Vendas Nacionais!**

**Vantagens para o Cliente:**
- ✅ **Simplicidade:** Comprou → É admin automático
- ✅ **Controle Total:** Gerencia sua equipe
- ✅ **Segurança:** Dados isolados de outras empresas
- ✅ **Flexibilidade:** Permissões personalizáveis
- ✅ **Escalabilidade:** Suporta crescimento da empresa