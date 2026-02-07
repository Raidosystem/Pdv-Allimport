# 🚀 GUIA RÁPIDO - Configuração do Sistema de Permissões

## 📋 Passo a Passo

### **1️⃣ Configurar o Sistema (Uma vez)**
Execute no Supabase SQL Editor:
```sql
-- Arquivo: MELHORAR_SISTEMA_PERMISSOES.sql
```

**O que este script faz:**
- ✅ Cria templates de permissões no banco de dados
- ✅ Define permissões padrão para novos funcionários
- ✅ Cria função `aplicar_template_permissoes()` para uso fácil

---

### **2️⃣ Aplicar Templates aos Funcionários Existentes**
Execute no Supabase SQL Editor:
```sql
-- Arquivo: APLICAR_TEMPLATES_FUNCIONARIOS.sql
```

**Funcionários atuais identificados:**

| Nome | UUID | Template Recomendado |
|------|------|---------------------|
| Administrador Principal | `09dc2c9d-8cae-4e25-a889-6e98b03d1bf5` | 🔴 **admin** |
| assistenciaallimport10 | `ccdad2bc-3cc1-48a5-b447-be962b2956eb` | 🔴 **admin** |
| cris-ramos30 | `229271ef-567c-44c7-a996-dd738d3dd476` | 🔴 **admin** |
| Cristiano Ramos Mendes | `23f89969-3c78-4b1e-8131-d98c4b81facb` | 🔴 **admin** |
| novaradiosystem | `0e72a56a-d826-4731-bc82-59d9a28acba5` | 🔴 **admin** |
| Jennifer Sousa | `9d9fe570-7c09-4ee4-8c52-11b7969c00f3` | 🟢 **tecnico** |

**Comando rápido para aplicar:**
```sql
-- Aplicar ADMIN para todos os proprietários
SELECT aplicar_template_permissoes('09dc2c9d-8cae-4e25-a889-6e98b03d1bf5', 'admin');
SELECT aplicar_template_permissoes('ccdad2bc-3cc1-48a5-b447-be962b2956eb', 'admin');
SELECT aplicar_template_permissoes('229271ef-567c-44c7-a996-dd738d3dd476', 'admin');
SELECT aplicar_template_permissoes('23f89969-3c78-4b1e-8131-d98c4b81facb', 'admin');
SELECT aplicar_template_permissoes('0e72a56a-d826-4731-bc82-59d9a28acba5', 'admin');

-- Aplicar TÉCNICO para Jennifer
SELECT aplicar_template_permissoes('9d9fe570-7c09-4ee4-8c52-11b7969c00f3', 'tecnico');
```

---

### **3️⃣ Verificar Resultados**
```sql
SELECT 
  nome,
  cargo,
  CASE 
    WHEN permissoes->>'configuracoes' = 'true' THEN '🔴 ADMIN'
    WHEN permissoes->>'ordens_servico' = 'true' AND permissoes->>'vendas' = 'false' THEN '🟢 TÉCNICO'
    ELSE '⚪ OUTROS'
  END as perfil,
  permissoes->>'ordens_servico' as "Acessa OS",
  permissoes->>'configuracoes' as "Acessa Config"
FROM funcionarios
ORDER BY nome;
```

**Resultado esperado:**
- ✅ Proprietários: Perfil 🔴 ADMIN, Config = true
- ✅ Jennifer: Perfil 🟢 TÉCNICO, OS = true, Config = false

---

### **4️⃣ Testar no Sistema**

1. **Fazer logout**
2. **Login com Jennifer:**
   - ✅ Deve ver: Vendas, Produtos, Clientes, **Ordens de Serviço**
   - ❌ NÃO deve ver: Configurações, Caixa, Relatórios
   - ❌ Botões de deletar não devem aparecer

3. **Login com proprietário:**
   - ✅ Deve ver todos os módulos
   - ✅ Todos os botões habilitados

---

## 🎯 Templates Disponíveis

### 🔴 **ADMIN** - Acesso Total
```sql
SELECT aplicar_template_permissoes('UUID', 'admin');
```
- ✅ Todos os módulos
- ✅ Todas as permissões
- **Ideal para:** Proprietário, Gerente Geral

### 🟣 **GERENTE** - Gestão Completa
```sql
SELECT aplicar_template_permissoes('UUID', 'gerente');
```
- ✅ Vendas, Produtos, Clientes, Caixa, OS, Relatórios
- ❌ Sem acesso a Configurações e Backup
- **Ideal para:** Gerente de Loja, Supervisor

### 🔵 **VENDEDOR** - Vendas e Clientes
```sql
SELECT aplicar_template_permissoes('UUID', 'vendedor');
```
- ✅ Vendas, Produtos (view), Clientes
- ❌ Sem caixa, OS, relatórios
- **Ideal para:** Vendedor, Atendente

### 🟢 **TÉCNICO** - Ordens de Serviço
```sql
SELECT aplicar_template_permissoes('UUID', 'tecnico');
```
- ✅ OS (completo), Produtos (view), Clientes
- ❌ Sem vendas, caixa, configurações
- **Ideal para:** Técnico, Assistência Técnica (Jennifer)

### 🟡 **CAIXA** - Vendas e Caixa
```sql
SELECT aplicar_template_permissoes('UUID', 'caixa');
```
- ✅ Vendas, Caixa, Clientes (básico)
- ❌ Sem descontos, edição, relatórios
- **Ideal para:** Operador de Caixa

---

## 🆕 Criar Novo Funcionário

### **Via Interface (Recomendado)**
1. Acessar **Funcionários** no menu
2. Clicar em **"Novo Funcionário"**
3. Preencher dados básicos
4. Escolher template ou personalizar permissões
5. Criar funcionário

### **Via SQL (Manual)**
```sql
-- 1. Criar registro
INSERT INTO funcionarios (
  nome, email, cargo, empresa_id, ativo, permissoes
) VALUES (
  'Nome do Funcionário',
  'email@exemplo.com',
  'Vendedor',
  'UUID_DA_EMPRESA',
  true,
  jsonb_build_object(
    -- Permissões padrão serão aplicadas automaticamente
  )
);

-- 2. Aplicar template
SELECT aplicar_template_permissoes('UUID_DO_NOVO_FUNCIONARIO', 'vendedor');
```

---

## 🔧 Comandos Úteis

### **Ver permissões de um funcionário**
```sql
SELECT 
  nome,
  jsonb_pretty(permissoes::jsonb) as permissoes
FROM funcionarios 
WHERE nome LIKE '%jennifer%';
```

### **Listar todos com seus perfis**
```sql
SELECT 
  nome,
  cargo,
  CASE 
    WHEN permissoes->>'configuracoes' = 'true' THEN '🔴 ADMIN'
    WHEN permissoes->>'ordens_servico' = 'true' AND permissoes->>'vendas' = 'false' THEN '🟢 TÉCNICO'
    WHEN permissoes->>'caixa' = 'true' THEN '🟡 CAIXA'
    WHEN permissoes->>'vendas' = 'true' THEN '🔵 VENDEDOR'
    ELSE '⚪ OUTROS'
  END as perfil
FROM funcionarios
ORDER BY perfil, nome;
```

### **Personalizar permissão específica**
```sql
-- Dar permissão de aplicar desconto para um funcionário
UPDATE funcionarios
SET permissoes = permissoes::jsonb || '{"pode_aplicar_desconto": true}'::jsonb
WHERE id = 'UUID';
```

---

## ✅ Checklist Final

- [ ] Executar `MELHORAR_SISTEMA_PERMISSOES.sql`
- [ ] Executar comandos do `APLICAR_TEMPLATES_FUNCIONARIOS.sql`
- [ ] Verificar permissões de todos os funcionários
- [ ] Testar login com Jennifer (deve ver OS, não Config)
- [ ] Testar login com proprietário (deve ver tudo)
- [ ] Criar um funcionário teste via interface
- [ ] Verificar que novos funcionários recebem permissões padrão

---

## 🐛 Solução de Problemas

### **Problema: Funcionário não vê módulo mesmo com permissão**
```sql
-- Verificar permissões
SELECT nome, permissoes->>'ordens_servico', permissoes->>'configuracoes'
FROM funcionarios
WHERE id = 'UUID';

-- Limpar cache do navegador (Ctrl+Shift+Del)
-- Fazer logout/login
```

### **Problema: Template não aplicado**
```sql
-- Reaplicar template
SELECT aplicar_template_permissoes('UUID', 'tecnico');

-- Verificar resultado
SELECT nome, jsonb_pretty(permissoes)
FROM funcionarios
WHERE id = 'UUID';
```

### **Problema: Erro na função aplicar_template_permissoes**
```sql
-- Recriar a função executando novamente a seção 6️⃣ do script
-- MELHORAR_SISTEMA_PERMISSOES.sql
```

---

## 📞 Suporte

**Arquivos de referência:**
- `MELHORAR_SISTEMA_PERMISSOES.sql` - Configuração inicial
- `APLICAR_TEMPLATES_FUNCIONARIOS.sql` - Aplicar aos existentes
- `DOCUMENTACAO_SISTEMA_PERMISSOES.md` - Documentação completa
- `TESTE_RAPIDO_JENNIFER.sql` - Testes específicos

**Sistema pronto para uso! 🎉**
