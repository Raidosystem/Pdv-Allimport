# 🗂️ PLANO DE ORGANIZAÇÃO - SCRIPTS SQL DUPLICADOS
# ===================================================

## 🚨 PROBLEMAS CRÍTICOS IDENTIFICADOS

### 1. init_pdv_schema.sql - 3 VERSÕES
**Localização:** supabase/migrations/
- ✅ `20250731135300_init_pdv_schema.sql` (PRINCIPAL)
- ❌ `20250731_init_pdv_schema.sql` (DUPLICATA)
- ❌ `20250731_init_pdv_schema.sql.old` (BACKUP)

### 2. Scripts RLS Clientes - 5 VERSÕES
**Localização:** supabase/migrations/
- ✅ `20250803000004_disable_clientes_rls.sql` (FINAL)
- ❌ `20250803000001_fix_clientes_rls.sql` (ANTIGO)
- ❌ `20250803000002_fix_clientes_rls_auth.sql` (ANTIGO)
- ❌ `20250803000003_final_fix_clientes_rls.sql` (ANTIGO)
- ❌ `20250803_fix_clientes_rls.sql` (DUPLICATA)

### 3. Scripts Endereço Clientes - 2 VERSÕES
**Localização:** supabase/migrations/
- ✅ `20250802000000_add_endereco_fields_clientes.sql` (PRINCIPAL)
- ❌ `20250802_add_endereco_fields_clientes.sql` (DUPLICATA)

### 4. Scripts Histórico Caixa - 2 VERSÕES
**Localização:** supabase/migrations/
- ✅ `20250802000001_historico_caixa_deploy.sql` (PRINCIPAL)
- ❌ `20250802_historico_caixa_deploy.sql` (DUPLICATA)

## 📋 PLANO DE AÇÃO

### ✅ FAZER PRIMEIRO
1. **Mover duplicatas para /sql/archive/**
2. **Criar script master de migração**
3. **Documentar dependências entre scripts**
4. **Criar README com ordem de execução**

### 📁 ESTRUTURA FINAL
```
sql/
├── migrations/
│   ├── 001_init_pdv_schema.sql
│   ├── 002_add_endereco_clientes.sql
│   ├── 003_historico_caixa.sql
│   └── 004_disable_rls_clientes.sql
├── backups/          # Versões antigas com timestamp
├── debug/           # Scripts de diagnóstico
└── archive/         # Arquivos obsoletos
```

## ⚠️ RISCO ATUAL
**Ambiente de produção pode estar inconsistente** se nem todas as migrações forem executadas na ordem correta.

---
*Status: Aguardando execução do plano de limpeza*
