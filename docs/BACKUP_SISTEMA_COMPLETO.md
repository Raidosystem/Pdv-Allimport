# 📦 Sistema de Backup e Restauração - PDV Allimport

Este documento explica o sistema completo de backup e restauração implementado no PDV, que oferece **privacidade total** e **múltiplas opções de backup**.

## 🔒 Características Principais

- **Privacidade Total**: Cada usuário vê apenas seus próprios dados
- **Backup Automático**: Backup diário às 2:00 AM (configurável)
- **Backup Manual**: Criação de backup a qualquer momento
- **Exportação JSON**: Download dos dados em formato JSON
- **Importação JSON**: Restauração de dados de arquivo JSON
- **Retenção**: Backups mantidos por 30 dias automaticamente

## 🗄️ Tabelas com Isolamento por Usuário

Todas as tabelas agora possuem coluna `user_id` e políticas RLS:

- `categorias` - Categorias de produtos
- `produtos` - Produtos do estoque
- `clientes` - Clientes cadastrados
- `vendas` - Vendas realizadas
- `itens_venda` - Itens das vendas
- `caixa` - Sessões de caixa
- `movimentacoes_caixa` - Movimentações do caixa
- `configuracoes` - Configurações do sistema
- `user_backups` - Backups salvos no banco

## 🛠️ Funções SQL Disponíveis

### 1. Backup no Banco de Dados

```sql
-- Criar backup manual
SELECT public.save_backup_to_database();

-- Backup diário automático (via cron)
SELECT public.daily_backup_all_users();
```

### 2. Exportação/Importação JSON

```sql
-- Exportar dados para JSON
SELECT public.export_user_data_json();

-- Importar dados de JSON
SELECT public.import_user_data_json(backup_json, clear_existing);
```

### 3. Gerenciamento de Backups

```sql
-- Listar backups do usuário
SELECT public.list_user_backups();

-- Restaurar backup específico
SELECT public.restore_from_database_backup(backup_id, clear_existing);
```

## 📱 Usando no Frontend

### Hook useBackup

```typescript
import { useBackup } from '../hooks/useBackup';

function MyComponent() {
  const {
    backups,           // Lista de backups
    loading,           // Estado de carregamento
    exporting,         // Estado de exportação
    importing,         // Estado de importação
    loadBackups,       // Carregar lista de backups
    createManualBackup,// Criar backup manual
    exportToJSON,      // Exportar para JSON
    importFromJSON,    // Importar de JSON
    restoreFromDatabase,// Restaurar de backup do banco
    formatSize,        // Formatar tamanho
    formatDate,        // Formatar data
  } = useBackup();
}
```

### Componente BackupManager

```typescript
import BackupManager from '../components/BackupManager';

// Usar no seu app
<BackupManager />
```

## 🔄 Tipos de Backup

### 1. Backup Automático Diário
- Executado às 2:00 AM via pg_cron
- Salva dados no banco (tabela `user_backups`)
- Limpa backups com mais de 30 dias
- Configurado automaticamente

### 2. Backup Manual
- Criado a qualquer momento pelo usuário
- Salva no banco de dados
- Substitui backup do mesmo dia se existir

### 3. Exportação JSON
- Gera arquivo JSON para download
- Contém todos os dados do usuário
- Pode ser usado como backup offline
- Formato legível e portável

### 4. Importação JSON
- Restaura dados de arquivo JSON
- Opção de limpar dados existentes
- Validação de estrutura do arquivo
- Suporte a dados de qualquer versão

## 📋 Estrutura do Backup JSON

```json
{
  "backup_info": {
    "user_id": "uuid",
    "user_email": "email@example.com",
    "backup_date": "2025-01-01T00:00:00Z",
    "backup_version": "1.0",
    "system": "PDV Allimport"
  },
  "data": {
    "clientes": [...],
    "categorias": [...],
    "produtos": [...],
    "vendas": [...],
    "itens_venda": [...],
    "caixa": [...],
    "movimentacoes_caixa": [...],
    "configuracoes": [...]
  }
}
```

## ⚙️ Configuração do Backup Automático

### 1. Habilitar extensão pg_cron no Supabase

```sql
-- Executar como superuser (no dashboard do Supabase)
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

### 2. Configurar job diário

```sql
-- Agendar backup às 2:00 AM todos os dias
SELECT cron.schedule(
  'daily-user-backup', 
  '0 2 * * *', 
  'SELECT public.daily_backup_all_users();'
);
```

### 3. Verificar jobs

```sql
-- Ver jobs agendados
SELECT * FROM cron.job;

-- Ver execuções
SELECT * FROM cron.job_run_details 
ORDER BY start_time DESC 
LIMIT 10;
```

## 🔧 Comandos Úteis

### Verificar backups de um usuário

```sql
SELECT 
  id,
  backup_date,
  created_at,
  pg_size_pretty(pg_column_size(backup_data)) as size
FROM user_backups 
WHERE user_id = auth.uid()
ORDER BY backup_date DESC;
```

### Executar backup manual via SQL

```sql
SELECT public.save_backup_to_database();
```

### Limpar backups antigos manualmente

```sql
DELETE FROM user_backups 
WHERE created_at < NOW() - INTERVAL '30 days';
```

## 🚨 Troubleshooting

### Problema: Backup não está sendo criado automaticamente
**Solução**: Verificar se pg_cron está habilitado e job está agendado

### Problema: Erro ao importar JSON
**Solução**: Verificar estrutura do arquivo JSON e permissões do usuário

### Problema: Backup muito grande
**Solução**: Considerar limpar dados antigos antes do backup

### Problema: Restauração não funcionando
**Solução**: Verificar se usuário tem permissões e backup existe

## 📊 Monitoramento

### Verificar tamanho dos backups

```sql
SELECT 
  COUNT(*) as total_backups,
  pg_size_pretty(SUM(pg_column_size(backup_data))) as total_size,
  AVG(pg_column_size(backup_data)) as avg_size
FROM user_backups;
```

### Verificar última execução do cron

```sql
SELECT 
  jobname,
  last_run,
  next_run,
  active
FROM cron.job 
WHERE jobname = 'daily-user-backup';
```

## 🎯 Melhores Práticas

1. **Backup Regular**: Configure backup automático
2. **Teste Restauração**: Teste periodicamente a restauração
3. **Backup Offline**: Faça exports JSON ocasionalmente
4. **Monitoramento**: Verifique logs de backup
5. **Limpeza**: Mantenha apenas backups necessários
6. **Segurança**: Proteja arquivos JSON exportados

## 📚 Exemplos de Uso

### Backup antes de operação crítica

```typescript
// Criar backup antes de operação
await createManualBackup();

// Fazer operação crítica
await operacaoCritica();

// Se der erro, restaurar backup se necessário
```

### Migração de dados

```typescript
// 1. Exportar dados do sistema antigo
await exportToJSON('migracao-dados.json');

// 2. Limpar dados atuais
// 3. Importar dados novos
await importFromJSON(arquivo, true);
```

### Backup periódico manual

```typescript
// Todo domingo, criar backup extra
if (isDomingo()) {
  await createManualBackup();
  await exportToJSON(`backup-semanal-${data}.json`);
}
```

---

## 🔐 Segurança

- **RLS Ativo**: Row Level Security em todas as tabelas
- **Isolamento Total**: Usuários não veem dados de outros
- **Triggers Automáticos**: user_id inserido automaticamente
- **Validação**: Estrutura de backup validada na importação
- **Permissões**: Apenas usuários autenticados podem fazer backup

**Sistema implementado com sucesso! ✅**
