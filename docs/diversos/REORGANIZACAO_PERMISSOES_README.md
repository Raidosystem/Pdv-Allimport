# 📋 Reorganização de Permissões - Sistema PDV Allimport

## 🎯 Objetivo
Eliminar permissões duplicadas e reorganizar em seções lógicas e consistentes.

## ❌ Problemas Identificados

### Duplicatas Encontradas:
- **produtos**: `edit` e `Editar`, `view` e `Visualizar`
- **clientes**: `edit` e `Editar`, `view` e `Visualizar`
- **financeiro**: `view` aparece duas vezes
- **Permissões soltas** em "Outros" que deveriam estar em suas seções

### Inconsistências:
- Nomes em inglês misturados com português
- Ações genéricas (Visualizar, Editar, Criar, Excluir) sem padrão
- Permissões de subseções (`administracao.funcoes`) misturadas com principais

## ✅ Solução Implementada

### Padrão CRUD Unificado:
```
create  → Criar/Cadastrar
read    → Visualizar
update  → Editar/Alterar
delete  → Excluir
```

### Organização por Seções:

#### 📊 **DASHBOARD** (3 permissões)
- `dashboard.view` - Visualizar dashboard principal
- `dashboard.metrics` - Visualizar métricas
- `dashboard.charts` - Visualizar gráficos

#### 🛒 **VENDAS** (8 permissões)
- `vendas.create` - Criar nova venda
- `vendas.read` - Visualizar vendas
- `vendas.update` - Editar vendas
- `vendas.delete` - Excluir vendas
- `vendas.cancel` - Cancelar vendas
- `vendas.discount` - Aplicar descontos
- `vendas.print` - Imprimir cupom
- `vendas.refund` - Fazer estorno

#### 📦 **PRODUTOS** (9 permissões)
- `produtos.create` - Cadastrar novos produtos
- `produtos.read` - Visualizar produtos
- `produtos.update` - Editar produtos
- `produtos.delete` - Excluir produtos
- `produtos.import` - Importar produtos
- `produtos.export` - Exportar produtos
- `produtos.manage_stock` - Gerenciar estoque
- `produtos.adjust_price` - Alterar preços
- `produtos.manage_categories` - Gerenciar categorias

#### 👥 **CLIENTES** (8 permissões)
- `clientes.create` - Cadastrar novos clientes
- `clientes.read` - Visualizar clientes
- `clientes.update` - Editar clientes
- `clientes.delete` - Excluir clientes
- `clientes.export` - Exportar clientes
- `clientes.import` - Importar clientes
- `clientes.view_history` - Ver histórico de compras
- `clientes.manage_debt` - Gerenciar crédito/débito

#### 💰 **FINANCEIRO** (12 permissões)
**Caixa:**
- `caixa.open` - Abrir caixa
- `caixa.close` - Fechar caixa
- `caixa.view` - Visualizar caixa
- `caixa.view_history` - Ver histórico de caixa
- `caixa.sangria` - Fazer sangria
- `caixa.suprimento` - Fazer suprimento

**Financeiro Geral:**
- `financeiro.read` - Visualizar informações financeiras
- `financeiro.create` - Criar movimentações financeiras
- `financeiro.update` - Editar movimentações
- `financeiro.delete` - Excluir movimentações
- `financeiro.manage_payments` - Gerenciar formas de pagamento
- `financeiro.view_reports` - Ver relatórios financeiros

#### 🔧 **ORDENS DE SERVIÇO** (6 permissões)
- `ordens.create` - Criar ordem de serviço
- `ordens.read` - Visualizar ordens
- `ordens.update` - Editar ordem
- `ordens.delete` - Excluir ordem
- `ordens.change_status` - Alterar status da ordem
- `ordens.print` - Imprimir ordem

#### 📊 **RELATÓRIOS** (7 permissões)
- `relatorios.read` - Visualizar relatórios
- `relatorios.export` - Exportar relatórios
- `relatorios.sales` - Relatórios de vendas
- `relatorios.financial` - Relatórios financeiros
- `relatorios.products` - Relatórios de produtos
- `relatorios.customers` - Relatórios de clientes
- `relatorios.inventory` - Relatórios de estoque

#### ⚙️ **CONFIGURAÇÕES** (7 permissões)
- `configuracoes.read` - Visualizar configurações
- `configuracoes.update` - Alterar configurações
- `configuracoes.company_info` - Editar informações da empresa
- `configuracoes.print_settings` - Configurar impressão
- `configuracoes.appearance` - Configurar aparência
- `configuracoes.integrations` - Gerenciar integrações
- `configuracoes.backup` - Fazer backup de dados

#### 👑 **ADMINISTRAÇÃO** (16 permissões)
**Administração Geral:**
- `administracao.read` - Visualizar área administrativa
- `administracao.full_access` - Acesso total administrativo

**Usuários:**
- `administracao.usuarios.create` - Cadastrar usuário
- `administracao.usuarios.read` - Visualizar usuários
- `administracao.usuarios.update` - Editar usuário
- `administracao.usuarios.delete` - Excluir usuário

**Funções:**
- `administracao.funcoes.create` - Criar novas funções
- `administracao.funcoes.read` - Visualizar funções
- `administracao.funcoes.update` - Editar funções
- `administracao.funcoes.delete` - Excluir funções

**Permissões:**
- `administracao.permissoes.read` - Visualizar permissões
- `administracao.permissoes.update` - Gerenciar permissões

**Logs:**
- `administracao.logs.read` - Visualizar logs do sistema

**Assinatura:**
- `administracao.assinatura.read` - Ver assinatura
- `administracao.assinatura.update` - Gerenciar assinatura

## 📈 Resumo

### Antes:
- ❌ ~50+ permissões desorganizadas
- ❌ Duplicatas: produtos (3), clientes (3), financeiro (2)
- ❌ Nomenclatura inconsistente
- ❌ Seção "Outros" com 35 permissões

### Depois:
- ✅ **76 permissões organizadas**
- ✅ **Zero duplicatas**
- ✅ **Padrão CRUD consistente**
- ✅ **9 seções lógicas**
- ✅ **Subseções em Administração**

## 🚀 Como Executar

1. **Backup**: O script cria backup automático em `permissoes_backup`
2. **Execute**: Copie e cole `REORGANIZAR_PERMISSOES_COMPLETO.sql` no SQL Editor do Supabase
3. **Verifique**: O script mostra relatório de verificação ao final
4. **Teste**: Faça login e verifique se as permissões funcionam

## ⚠️ IMPORTANTE

- ✅ Script é **transacional** (usa BEGIN/COMMIT)
- ✅ Cria **backup temporário** antes de limpar
- ✅ Recria permissões para função **Administrador**
- ✅ Mantém **RLS habilitado**
- ✅ Usa **ON CONFLICT DO NOTHING** para segurança

## 🔍 Verificação

Após executar, verifique:

```sql
-- Total por categoria
SELECT categoria, COUNT(*) as total
FROM permissoes
GROUP BY categoria;

-- Verificar duplicatas (deve retornar 0)
SELECT recurso, acao, COUNT(*) as duplicatas
FROM permissoes
GROUP BY recurso, acao
HAVING COUNT(*) > 1;
```

## 📝 Notas

- **Constraint UNIQUE** em `(recurso, acao)` previne duplicatas futuras
- **Categoria** adicionada para facilitar filtros no frontend
- **Nomenclatura padronizada** em português
- **Hierarquia clara** com subseções usando ponto (`.`)
