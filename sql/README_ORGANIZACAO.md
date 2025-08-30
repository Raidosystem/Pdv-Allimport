# 🗂️ ORGANIZAÇÃO DE SCRIPTS SQL - PDV ALLIMPORT
# ===================================================

## 📋 VISÃO GERAL
Este diretó## 📞 SUPORTE

- **Para novos ambientes:** Use `001_MIGRACAO_RAPIDA.sql`
- **Para ambiente completo:** Use `000_MASTER_MIGRATION.sql`
- **Para troubleshooting:** Use scripts em `/sql/debug/`
- **Para backup:** Arquivos em `/sql/backups/` têm timestamps

---
**Status:** ✅ Organização concluída - Ambiente limpo e compatível com Supabaseém **todos os scripts SQL organizados** para o Sistema PDV Allimport, resolvendo o problema de múltiplas versões e duplicatas que existiam anteriormente.

## 📁 ESTRUTURA DE PASTAS

```
sql/
├── migrations/           # 🟢 SCRIPTS PRINCIPAIS (use estes)
│   ├── 000_MASTER_MIGRATION.sql          # 🚀 Script completo (consolidado)
│   ├── 001_MIGRACAO_RAPIDA.sql           # ⚡ Script simplificado (CORRIGIDO v1.0.1)
│   └── 001_VERIFICATION_POST_MIGRATION.sql # 🔍 Verificação completa
├── debug/                # � Scripts de diagnóstico
│   └── 000_DIAGNOSTICO_PRE_MIGRACAO.sql  # 🔍 Diagnóstico pré-migração
├── backups/              # � Versões antigas (backup)
└── archive/             # 🔴 Arquivos obsoletos (não usar)
```

## 🚀 COMO USAR - GUIA RÁPIDO

### ✅ **RECOMENDAÇÃO: Execute nesta ordem:**

**1. Primeiro, faça o diagnóstico:**
```sql
-- Execute ANTES de qualquer migração:
sql/debug/000_DIAGNOSTICO_PRE_MIGRACAO.sql
```

**2. Depois, execute a migração:**
```sql
-- Para começar rápido (recomendado):
sql/migrations/001_MIGRACAO_RAPIDA.sql
```

**3. Por fim, verifique:**
```sql
-- Confirme que tudo funcionou:
sql/migrations/001_VERIFICATION_POST_MIGRATION.sql
```

### Para ambientes COMPLETOS:
```sql
-- Para migração completa com todas as funcionalidades:
sql/migrations/000_MASTER_MIGRATION.sql
```

## ⚠️ IMPORTANTE: ERRO DO `\i` RESOLVIDO

### ❌ **Problema Anterior:**
```sql
-- Este comando NÃO funciona no Supabase SQL Editor:
\i supabase/migrations/20250731135300_init_pdv_schema.sql
-- ERRO: syntax error at or near "\"
```

### ✅ **Solução:**
- **Scripts consolidados**: Todo o conteúdo dos arquivos foi **incorporado diretamente** nos scripts principais
- **Compatível com Supabase**: Funciona perfeitamente no SQL Editor do Supabase
- **Sem dependências externas**: Não precisa de arquivos separados

## 🛠️ **CORREÇÃO DO ERRO "column 'ativo' does not exist"**

### ❌ **Problema Identificado:**
```sql
-- ERRO: column "ativo" does not exist
CREATE INDEX idx_produtos_ativo ON public.produtos(ativo);
```

### ✅ **Solução Implementada:**
- **Verificação automática**: O script agora verifica se as colunas existem antes de criar índices
- **Adição condicional**: Colunas faltantes são adicionadas automaticamente
- **Robustez total**: Funciona mesmo com estruturas de tabelas diferentes

### 🔧 **O que o script corrigido faz:**
1. **Verifica estrutura existente** das tabelas
2. **Adiciona colunas faltantes** (como `ativo`) se necessário
3. **Cria índices apenas** se as colunas existirem
4. **Trata conflitos** de forma elegante
5. **Funciona em qualquer estado** do banco de dados

## 📋 O QUE FOI ORGANIZADO

### ✅ PROBLEMAS RESOLVIDOS

#### 1. **init_pdv_schema.sql** - 3 versões → 1 versão
- **Antes:** `20250731135300_init_pdv_schema.sql` + `20250731_init_pdv_schema.sql` + `.old`
- **Agora:** Apenas `20250731135300_init_pdv_schema.sql` (mantido na pasta original)

#### 2. **Scripts RLS Clientes** - 5 versões → 1 versão
- **Antes:** 5 arquivos diferentes tentando corrigir RLS
- **Agora:** Apenas `20250803000004_disable_clientes_rls.sql` (versão final)

#### 3. **Scripts Endereço** - 2 versões → 1 versão
- **Antes:** `20250802000000_add_endereco_fields_clientes.sql` + duplicata
- **Agora:** Apenas a versão principal

#### 4. **Scripts Histórico Caixa** - 2 versões → 1 versão
- **Antes:** Duas versões do mesmo script
- **Agora:** Apenas a versão principal

### 🗂️ ARQUIVOS MOVIDOS PARA `/archive/`
- `20250731_init_pdv_schema.sql` (duplicata)
- `20250731_init_pdv_schema.sql.old` (backup antigo)
- `20250803000001_fix_clientes_rls.sql` (versão antiga)
- `20250803000002_fix_clientes_rls_auth.sql` (versão antiga)
- `20250803000003_final_fix_clientes_rls.sql` (pré-final)
- `20250803_fix_clientes_rls.sql` (duplicata)
- `20250802_add_endereco_fields_clientes.sql` (duplicata)
- `20250802_historico_caixa_deploy.sql` (duplicata)

## 🔄 ORDEM DE EXECUÇÃO DAS MIGRAÇÕES

O script master executa na seguinte ordem:

1. **Schema Inicial** → Cria todas as tabelas principais
2. **Correção de Nomes** → Ajusta nomes de tabelas
3. **Ordens de Serviço** → Adiciona tabela de OS
4. **Dados Iniciais** → Insere dados de seed
5. **Endereço Clientes** → Adiciona campos de endereço
6. **Histórico Caixa** → Sistema de caixa
7. **RLS Clientes** → Políticas de segurança (FINAL)
8. **Garantia OS** → Campos de garantia
9. **Configuração Email** → Templates e confirmação
10. **Checklist OS** → Sistema de checklist
11. **Função Caixa** → Lógica de caixa

## ⚠️ IMPORTANTE

### **NÃO EXECUTE** scripts da pasta `/archive/`!
Estes arquivos são versões antigas e podem causar conflitos.

### **SOMENTE USE** scripts da pasta `/migrations/`!

### **PARA PRODUÇÃO:**
1. Execute `000_MASTER_MIGRATION.sql` uma única vez
2. Execute `001_VERIFICATION_POST_MIGRATION.sql` para confirmar
3. Use `VERIFICACAO_FINAL.sql` (na raiz) para checagem rápida

## 🔍 DIAGNÓSTICO

Se encontrar problemas, use os scripts em `/debug/`:
- Scripts de diagnóstico estão sendo organizados nesta pasta
- Use para investigar problemas específicos

## 🎯 SCRIPTS RECOMENDADOS:

### 🚀 **Para começar rápido:**
```sql
-- Use este para testar rapidamente:
sql/migrations/001_MIGRACAO_RAPIDA.sql
```

### 🏗️ **Para ambiente completo:**
```sql
-- Use este para produção:
sql/migrations/000_MASTER_MIGRATION.sql
```

### 🔍 **Para verificar:**
```sql
-- Sempre execute após a migração:
sql/migrations/001_VERIFICATION_POST_MIGRATION.sql
```

## 📞 SUPORTE

- **Para novos ambientes:** Use `000_MASTER_MIGRATION.sql`
- **Para troubleshooting:** Use scripts em `/debug/`
- **Para backup:** Arquivos em `/backups/` têm timestamps

---
**Status:** ✅ Organização concluída - Ambiente limpo e consistente
