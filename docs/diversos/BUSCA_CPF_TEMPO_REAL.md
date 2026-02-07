# 🚀 Sistema de Busca de Clientes por CPF em Tempo Real

## ✨ Funcionalidades Implementadas

### 📋 **O que foi criado:**

1. **🔍 Busca Automática por CPF/CNPJ**
   - Detecção em tempo real conforme o usuário digita
   - Busca a partir de 8 dígitos digitados
   - Debounce de 500ms para otimizar performance
   - Busca parcial e exata automática

2. **🎯 Prevenção de Duplicatas**
   - Detecta clientes existentes automaticamente
   - Mostra opções "Usar este cliente" ou "Editar dados"
   - Interface visual clara com códigos de cores
   - Feedback instantâneo ao usuário

3. **⚡ Busca Inteligente**
   - **8-10 dígitos**: Busca parcial (CPFs que começam com os dígitos)
   - **11 dígitos**: Busca exata de CPF
   - **12-13 dígitos**: Busca parcial (CNPJs que começam com os dígitos)
   - **14 dígitos**: Busca exata de CNPJ

4. **🎨 Interface Intuitiva**
   - 🔵 Campo azul com spinner durante verificação
   - 🟠 Campo laranja quando duplicata é encontrada
   - 🟢 Campo verde quando cliente é selecionado
   - ⚡ Notificações automáticas informativas

---

## 🏗️ **Componentes Criados:**

### 1. **useClienteCpfSearch** (Hook)
- **Arquivo**: `src/hooks/useClienteCpfSearch.ts`
- **Função**: Gerencia busca em tempo real por CPF
- **Retorna**: loading, clientes, clienteExato, temDuplicatas, erro

### 2. **CpfSearchInput** (Componente)
- **Arquivo**: `src/components/ui/CpfSearchInput.tsx`  
- **Função**: Campo inteligente de CPF com busca automática
- **Props**: value, onChange, onClienteEncontrado, onEditarCliente

### 3. **ClienteSelectorComBusca** (Componente)
- **Arquivo**: `src/components/ui/ClienteSelectorComBusca.tsx`
- **Função**: Seletor completo com busca por nome e CPF
- **Uso**: Ordem de Serviço e Vendas

### 4. **ClienteService.buscarPorCpf** (Método)
- **Arquivo**: `src/services/clienteService.ts`
- **Função**: Busca clientes por CPF no Supabase e backup
- **Parâmetros**: cpf (string)

---

## 🎯 **Como Usar:**

### **No Cadastro de Clientes:**
1. Acesse **Clientes** → **Novo Cliente**
2. No campo **CPF/CNPJ**, comece digitando
3. A partir de 8 dígitos, a busca automática inicia
4. Se encontrar duplicata:
   - ✅ **"Usar este cliente"**: Seleciona o cliente existente
   - ✏️ **"Editar dados"**: Carrega dados para edição

### **Na Ordem de Serviço:**
1. Acesse **Nova Ordem de Serviço**
2. Na seção **Dados do Cliente**
3. Digite o CPF/CNPJ no campo
4. Sistema detecta automaticamente clientes existentes
5. Opção de usar cliente encontrado ou editar

### **Nas Vendas:**
1. Acesse **Vendas** → **Nova Venda**
2. Selecione **Cliente**
3. Use o campo de CPF inteligente
4. Evita cadastros duplicados automaticamente

---

## 🔧 **Configuração Técnica:**

### **Busca no Banco de Dados:**
```sql
-- Busca exata (CPF completo - 11 dígitos)
SELECT * FROM clientes WHERE cpf_cnpj = '12345678901'

-- Busca parcial (primeiros dígitos)
SELECT * FROM clientes WHERE cpf_cnpj LIKE '123456%'
```

### **Busca no Backup (Fallback):**
```javascript
// Se não encontrar no Supabase, busca no backup
const clientesFiltrados = clients.filter(client => {
  const cpfClient = String(client.cpf_cnpj || '').replace(/\D/g, '')
  return cpfClient.startsWith(cpfLimpo)
})
```

---

## 📊 **Dados de Teste Disponíveis:**

O sistema possui **140 clientes** com CPF/CNPJ no backup:

### **Exemplos para testar:**
1. **333937328** → ANTONIO CLAUDIO FIGUEIRA
2. **375117738** → EDVANIA DA SILVA  
3. **328701839** → SAULO DE TARSO
4. **377845148** → ALINE CRISTINA CAMARGO
5. **235101338** → WINDERSON RODRIGUES LELIS

---

## ✅ **Benefícios:**

✅ **Prevenção de duplicatas** - Evita cadastros duplicados automaticamente  
✅ **Experiência fluida** - Detecção instantânea sem botões extras  
✅ **Feedback claro** - Usuário sabe imediatamente se cliente existe  
✅ **Ação rápida** - Pode usar cliente existente ou editá-lo na hora  
✅ **Performance otimizada** - Busca inteligente com debounce  
✅ **Multiplataforma** - Funciona em clientes, OS e vendas  

---

## 🚀 **Status:**

- ✅ **Hook de busca**: Implementado e testado
- ✅ **Componente CPF**: Funcional com validação
- ✅ **Busca em tempo real**: Operacional
- ✅ **Prevenção duplicatas**: Ativa
- ✅ **Interface visual**: Implementada
- ✅ **Integração OS**: Pronta para uso
- ✅ **Deploy produção**: Realizado

---

## 🌐 **URLs para Testar:**

- **Clientes**: https://pdv.crmvsystem.com/clientes
- **Nova OS**: https://pdv.crmvsystem.com/ordem-servico/nova
- **Vendas**: https://pdv.crmvsystem.com/vendas

**🎉 Sistema de busca por CPF 100% funcional e integrado!**