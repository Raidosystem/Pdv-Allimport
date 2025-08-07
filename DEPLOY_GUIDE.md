# 🚀 Guia de Deploy - Sistema PDV com Backup e Privacidade

## 📋 Ordem de Execução no Supabase

### **PASSO 1: Executar Tabelas Obrigatórias**
Execute primeiro o arquivo: `create-missing-tables-required.sql`

**Por que primeiro?**
- Cria tabelas que são referenciadas no script principal
- Configura a função `set_user_id()` necessária para os triggers
- Garante que todas as dependências existam

**Tabelas criadas:**
- ✅ `caixa` - Controle de sessões de caixa
- ✅ `movimentacoes_caixa` - Movimentações financeiras
- ✅ `configuracoes` - Configurações do sistema
- ✅ `clientes` - Cadastro de clientes (se não existir)

### **PASSO 2: Executar Script Principal**
Execute depois o arquivo: `create-missing-tables.sql`

**O que faz:**
- Cria demais tabelas do sistema
- Configura sistema completo de backup
- Implementa privacidade total com RLS
- Adiciona funções de exportação/importação JSON

**Tabelas criadas:**
- ✅ `categorias` - Categorias de produtos
- ✅ `produtos` - Produtos do estoque
- ✅ `vendas` - Vendas realizadas
- ✅ `itens_venda` - Itens das vendas
- ✅ `user_backups` - Backups dos usuários

### **PASSO 3: Configurar Backup Automático (Opcional)**
Execute para ativar backup diário automático:

```sql
-- Habilitar extensão pg_cron (se necessário)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Agendar backup diário às 2:00 AM
SELECT cron.schedule(
    'daily-user-backup', 
    '0 2 * * *', 
    'SELECT public.daily_backup_all_users();'
);
```

## 🔍 Verificação do Deploy

### Verificar se todas as tabelas foram criadas:
```sql
SELECT 
    table_name,
    CASE WHEN table_name IN (
        'categorias', 'produtos', 'vendas', 'itens_venda', 
        'clientes', 'caixa', 'movimentacoes_caixa', 
        'configuracoes', 'user_backups'
    ) THEN '✅ OK' ELSE '❌ FALTANDO' END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'categorias', 'produtos', 'vendas', 'itens_venda', 
    'clientes', 'caixa', 'movimentacoes_caixa', 
    'configuracoes', 'user_backups'
)
ORDER BY table_name;
```

### Verificar RLS ativo:
```sql
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public'
AND tablename IN (
    'categorias', 'produtos', 'vendas', 'itens_venda', 
    'clientes', 'caixa', 'movimentacoes_caixa', 
    'configuracoes', 'user_backups'
);
```

### Verificar funções de backup:
```sql
SELECT 
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name LIKE '%backup%'
OR routine_name LIKE '%export%'
OR routine_name LIKE '%import%'
ORDER BY routine_name;
```

### Testar sistema de backup:
```sql
-- Criar backup manual (teste)
SELECT public.save_backup_to_database();

-- Listar backups
SELECT public.list_user_backups();

-- Exportar dados JSON (teste)
SELECT public.export_user_data_json();
```

## 🚨 Possíveis Problemas e Soluções

### Erro: "function set_user_id() does not exist"
**Solução:** Execute primeiro o `create-missing-tables-required.sql`

### Erro: "relation caixa does not exist"
**Solução:** Execute primeiro o `create-missing-tables-required.sql`

### Erro: "extension pg_cron does not exist"
**Solução:** 
```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

### Backup automático não funciona
**Verificar:**
```sql
-- Ver jobs agendados
SELECT * FROM cron.job;

-- Ver execuções
SELECT * FROM cron.job_run_details 
ORDER BY start_time DESC LIMIT 5;
```

## 📊 Resultado Esperado

Após executar tudo corretamente, você deve ter:

### ✅ **9 Tabelas Criadas:**
1. `categorias` - Categorias de produtos
2. `produtos` - Produtos do estoque  
3. `vendas` - Vendas realizadas
4. `itens_venda` - Itens das vendas
5. `clientes` - Cadastro de clientes
6. `caixa` - Sessões de caixa
7. `movimentacoes_caixa` - Movimentações financeiras
8. `configuracoes` - Configurações do sistema
9. `user_backups` - Backups dos usuários

### ✅ **Funcionalidades Ativas:**
- 🔒 **Privacidade total** - RLS em todas as tabelas
- 📦 **Backup automático** - Diário às 2:00 AM
- 💾 **Export/Import JSON** - Via funções SQL
- 🔄 **Triggers automáticos** - user_id inserido automaticamente
- 🛡️ **Segurança** - Apenas usuários autenticados

### ✅ **8 Funções SQL Criadas:**
1. `create_user_backup_data()` - Criar dados de backup
2. `save_backup_to_database()` - Salvar backup no banco
3. `restore_from_backup_data()` - Restaurar de backup
4. `export_user_data_json()` - Exportar para JSON
5. `import_user_data_json()` - Importar de JSON
6. `list_user_backups()` - Listar backups
7. `restore_from_database_backup()` - Restaurar backup específico
8. `daily_backup_all_users()` - Backup diário automático

## 🎯 Próximos Passos

1. **Testar no Frontend:**
   - Adicionar `<BackupManager />` na aplicação
   - Testar login e verificar isolamento de dados
   - Testar funções de backup

2. **Configurar Monitoramento:**
   - Verificar logs de backup diário
   - Monitorar tamanho dos backups
   - Configurar alertas se necessário

3. **Documentar para Usuários:**
   - Como fazer backup manual
   - Como restaurar dados
   - Como exportar/importar JSON

**Sistema pronto para produção! 🚀**
