# 💾 Sistema de Backup Otimizado com Storage

## 🎯 O Que Mudou?

### ❌ ANTES (Problema)
```
Backup → Salvar JSON no banco (dados_json)
                ↓
         Banco cresce muito
         676 KB × 30 backups = 20 MB
         50 MB × 30 backups = 1.5 GB 🔴
```

### ✅ AGORA (Otimizado)
```
Backup → Salvar metadados no banco
      → Salvar arquivo no Storage
                ↓
         Banco: apenas ~2 KB por backup
         Storage: arquivos separados e gerenciáveis
```

## 📊 Economia de Espaço

| Componente | Antes | Agora | Economia |
|------------|-------|-------|----------|
| Banco de Dados | 1.5 GB | 60 KB | **99.9%** |
| Storage | 0 | 1.5 GB | - |
| Total Supabase | 1.5 GB | 1.5 GB | - |

**Vantagem**: Storage é mais barato e otimizado para arquivos!

## 🏗️ Arquitetura Nova

### 1️⃣ Tabela `backups` (Banco)
```sql
backups:
  - id
  - empresa_id
  - user_id
  - tipo
  - status
  - total_clientes
  - total_produtos
  - total_vendas
  - storage_path  ✅ NOVO: "user-id/empresa-id/backup_20251130.json"
  - file_size     ✅ NOVO: Tamanho do arquivo
  - dados_json    ⚠️  AGORA OPCIONAL (NULL)
```

### 2️⃣ Storage Bucket `backups`
```
storage/backups/
  └─ [user-id]/
      └─ [empresa-id]/
          ├─ backup_20251130_230000.zip
          ├─ backup_20251129_230000.zip
          └─ backup_20251128_230000.zip
```

## 🔐 Segurança (RLS)

Cada usuário só acessa seus próprios arquivos:
```sql
storage.objects
  WHERE bucket_id = 'backups'
    AND (foldername)[1] = auth.uid()::text
```

## 🚀 Fluxo de Backup

```
1. Script chama: criar_backup_automatico_individual()
   ↓
2. Função retorna:
   - backup_id
   - storage_path
   - dados (JSON completo)
   ↓
3. Script salva localmente (ZIP)
   ↓
4. Script faz upload para Storage
   ↓
5. Script chama: finalizar_backup_storage()
   ↓
6. Status atualizado: 'pendente' → 'concluido'
```

## 📦 Novas Funções SQL

### `criar_backup_automatico_individual()`
- Coleta dados da empresa
- Cria registro com status 'pendente'
- **Retorna dados** (não salva no banco)

### `finalizar_backup_storage(backup_id, file_size)`
- Atualiza status para 'concluido'
- Registra tamanho do arquivo
- Valida permissões do usuário

### `limpar_backups_antigos()`
- Remove backups com mais de 30 dias
- Retorna lista de arquivos para deletar do Storage

## 🛠️ Script PowerShell Atualizado

### Novas Funções

#### `Upload-ParaStorage`
```powershell
# Faz upload do arquivo ZIP para Supabase Storage
# Atualiza status do backup para 'concluido'
```

#### `Salvar-BackupLocal`
```powershell
# Salva backup localmente
# Faz upload para Storage
# Finaliza backup no banco
```

## 📋 Migração

### Passo 1: Aplicar SQL
```sql
-- Executar no Supabase SQL Editor:
\i BACKUP_OTIMIZADO_STORAGE.sql
```

Isso vai:
- ✅ Adicionar colunas `storage_path` e `file_size`
- ✅ Criar bucket `backups` no Storage
- ✅ Configurar políticas RLS
- ✅ Atualizar funções

### Passo 2: Scripts Já Atualizados
Os scripts PowerShell já foram atualizados automaticamente!

### Passo 3: Reconfigurar (se necessário)
```powershell
cd scripts
.\configurar-backup-automatico.ps1
```

## 🔍 Verificar Backups

### No Banco (Metadados)
```sql
SELECT 
    id,
    empresa_id,
    tipo,
    status,
    storage_path,
    file_size / 1024 / 1024 as size_mb,
    total_clientes,
    total_produtos,
    created_at
FROM backups
ORDER BY created_at DESC
LIMIT 10;
```

### No Storage (Arquivos)
```sql
SELECT 
    name,
    metadata->>'size' as size_bytes,
    created_at
FROM storage.objects
WHERE bucket_id = 'backups'
ORDER BY created_at DESC;
```

## 🧹 Limpeza Automática

### Manual (SQL)
```sql
SELECT limpar_backups_antigos();
```

### Automática (Agendar)
Configure no Supabase para rodar mensalmente:
```sql
-- Cron job (se disponível no seu plano)
SELECT cron.schedule(
    'limpar-backups-mensalmente',
    '0 0 1 * *',  -- Todo dia 1º às 00:00
    $$ SELECT limpar_backups_antigos() $$
);
```

## 📊 Monitoramento

### Espaço Usado no Storage
```sql
SELECT 
    bucket_id,
    COUNT(*) as total_arquivos,
    SUM((metadata->>'size')::bigint) / 1024 / 1024 as total_mb
FROM storage.objects
WHERE bucket_id = 'backups'
GROUP BY bucket_id;
```

### Backups por Empresa
```sql
SELECT 
    empresa_id,
    COUNT(*) as total_backups,
    SUM(file_size) / 1024 / 1024 as total_mb,
    MAX(created_at) as ultimo_backup
FROM backups
GROUP BY empresa_id
ORDER BY total_mb DESC;
```

## 🎯 Benefícios

| Benefício | Impacto |
|-----------|---------|
| 💾 **Economia de espaço no banco** | 99.9% menos dados |
| ⚡ **Queries mais rápidas** | Tabela `backups` muito menor |
| 💰 **Custo reduzido** | Storage é mais barato que banco |
| 🔒 **Isolamento melhor** | Cada empresa em sua pasta |
| 🗑️ **Limpeza mais fácil** | Deletar arquivos antigos |
| 📈 **Escalabilidade** | Suporta muito mais backups |

## ⚠️ Considerações

### Token JWT Expira
Se o backup falhar com erro de autenticação:
1. Obter novo token ([COMO-OBTER-TOKEN.md](COMO-OBTER-TOKEN.md))
2. Reconfigurar: `.\configurar-backup-automatico.ps1`

### Limite do Storage
- Free tier: **1 GB** total
- Pro tier: **100 GB** incluído
- Monitore espaço usado regularmente

### Backups Locais
Os backups continuam sendo salvos **localmente** também!
- Pasta local = backup principal
- Storage = backup na nuvem (redundância)

## 🆘 Troubleshooting

### Erro: "Failed to upload to Storage"
```powershell
# Verificar permissões do bucket
# Verificar se token JWT está válido
# Verificar espaço disponível no Storage
```

### Erro: "Backup not found"
```powershell
# Verificar se empresa_id está correto
# Verificar se RLS está permitindo acesso
```

### Storage cheio
```sql
-- Ver arquivos maiores
SELECT name, (metadata->>'size')::bigint / 1024 / 1024 as mb
FROM storage.objects
WHERE bucket_id = 'backups'
ORDER BY (metadata->>'size')::bigint DESC
LIMIT 20;

-- Deletar manualmente arquivos antigos
-- Via Dashboard → Storage → backups
```

---

✅ **Sistema otimizado e pronto para produção!**
