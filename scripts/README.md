# 📁 Estrutura de Arquivos SQL

## 🏗️ `/migrations/` - Arquivos Permanentes
Migrations oficiais que devem ser aplicadas em sequência na produção:

- `001_sistema_assinaturas.sql` - Função principal `credit_days_simple()`
- `002_[futuro]_tabelas_principais.sql` - Estrutura de tabelas
- `003_[futuro]_policies_rls.sql` - Políticas de segurança

## 🔧 `/scripts/oneoff/` - Scripts Pontuais  
Scripts de correção única, com data no nome:

- `2025-09-18_processar_pagamento_126596009978.sql` - Crédito manual específico
- `2025-09-18_corrigir_assinatura_usuario.sql` - Correção específica

## 📋 Regras

### ✅ **Para Produção:**
- Use APENAS arquivos em `/migrations/`
- Execute em ordem numérica
- Teste primeiro em desenvolvimento

### ⚠️ **Scripts OneOff:**
- Use apenas quando necessário
- Documente o motivo no cabeçalho
- Inclua data no nome do arquivo

### ❌ **Evite:**
- Múltiplos arquivos para mesma funcionalidade
- Scripts soltos na raiz do projeto
- Aplicar correções direto na produção

## 🎯 **Migration Atual Funcionando:**
A função `credit_days_simple()` está implementada e testada:
- ✅ Webhook processando automaticamente
- ✅ Sistema comercial funcionando
- ✅ Banco de dados consistente