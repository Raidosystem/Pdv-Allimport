# 🗄️ GUIA RÁPIDO - BACKUP LOCAL

## ⚡ Comandos Rápidos

### Fazer Backup Agora
```powershell
python scripts/backup-automatico.py
```

### Ver Backups Existentes
```powershell
ls backups/
```

### Restaurar Backup (Interativo)
```powershell
python scripts/restaurar-backup.py
```

---

## 📋 Passo a Passo Completo

### 1. Primeira Configuração (Uma vez apenas)

```powershell
# 1. Instalar Python (se não tiver)
# Download: https://www.python.org/downloads/

# 2. Instalar dependências
pip install supabase schedule

# 3. Testar se funciona
python scripts/backup-automatico.py
```

---

### 2. Fazer Backup Manual

```powershell
# Navegar até a pasta
cd C:\Users\GrupoRaval\Desktop\Pdv-Allimport

# Executar backup
python scripts/backup-automatico.py
```

**Resultado:**
```
🚀 Iniciando backup completo...
✅ Diretório de backup: ./backups
📥 Backing up user_approvals...
   ✅ 15 registros salvos
...
✅ Backup concluído!
```

**Arquivos criados em:** `backups/`

---

### 3. Ver Conteúdo de um Backup

```powershell
# Listar arquivos
ls backups/

# Ver JSON (exemplo)
cat backups/user_approvals_20260116_153045.json | ConvertFrom-Json | Format-Table
```

---

### 4. Restaurar um Backup

```powershell
# Modo interativo (recomendado)
python scripts/restaurar-backup.py
```

**Menu interativo:**
```
🔄 SISTEMA DE RESTAURAÇÃO DE BACKUP

📋 Tabelas com backup disponível:
   1. user_approvals (5 backups)
   2. empresas (5 backups)
   3. produtos (5 backups)
   ...

Escolha a tabela (número) ou 'all' para todas: 1

📋 Backups disponíveis para user_approvals:
   1. 2026-01-16 15:30:45
   2. 2026-01-15 15:30:12
   3. 2026-01-14 15:29:58

Escolha o backup (número): 1

⚠️  Você vai restaurar: user_approvals
   Usando backup de: user_approvals_20260116_153045.json
Confirmar? (s/n): s

✅ Restauração concluída!
```

---

### 5. Agendar Backup Automático

#### Opção A: Script Python (Simples)

```powershell
# Roda backup a cada 24 horas
python scripts/agendador-backup.py
```

**Deixe o terminal aberto** ou configure como serviço.

#### Opção B: Agendador Windows (Recomendado)

1. **Criar arquivo** `C:\Users\GrupoRaval\Desktop\executar-backup.bat`:
   ```bat
   @echo off
   cd C:\Users\GrupoRaval\Desktop\Pdv-Allimport
   python scripts\backup-automatico.py >> backup-log.txt 2>&1
   ```

2. **Agendar:**
   - Pressione `Win + R`
   - Digite: `taskschd.msc`
   - Click **"Criar Tarefa Básica"**
   - Nome: `Backup PDV Diário`
   - Gatilho: **Diariamente** às **03:00**
   - Ação: Executar `C:\Users\GrupoRaval\Desktop\executar-backup.bat`
   - ✅ **"Executar independente do usuário estar conectado"**
   - Finalizar

---

## 📊 Estrutura dos Backups

```
backups/
├── user_approvals_20260116_153045.json      # 15 registros
├── empresas_20260116_153046.json            # 12 registros
├── funcionarios_20260116_153047.json        # 28 registros
├── subscriptions_20260116_153048.json       # 8 registros
├── produtos_20260116_153049.json            # 450 registros
├── clientes_20260116_153050.json            # 320 registros
├── vendas_20260116_153051.json              # 850 registros
└── backup_metadata_20260116_153052.json     # Info do backup
```

---

## ⚠️ Dicas Importantes

### ✅ Boas Práticas:

1. **Fazer backup antes de mudanças críticas**
   ```powershell
   python scripts/backup-automatico.py
   # Depois fazer as mudanças
   ```

2. **Backup automático diário (3AM)**
   - Configure no Agendador de Tarefas
   - Horário sem uso do sistema

3. **Armazenar backups em múltiplos locais**
   ```powershell
   # Copiar para nuvem (exemplo)
   xcopy backups\ "D:\OneDrive\Backups PDV\" /E /I /Y
   ```

4. **Limpar backups antigos (opcional)**
   ```powershell
   # Manter apenas últimos 30 dias
   Get-ChildItem backups\ -Recurse | 
     Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-30)} | 
     Remove-Item
   ```

### ⚠️ Cuidados:

- ❌ **NÃO** deletar pasta `backups/` inteira
- ❌ **NÃO** editar arquivos JSON manualmente
- ✅ **SEMPRE** testar restauração antes de precisar
- ✅ **CONFIRMAR** antes de restaurar dados

---

## 🆘 Solução de Problemas

### Erro: "ModuleNotFoundError: No module named 'supabase'"
```powershell
pip install supabase
```

### Erro: "VITE_SUPABASE_URL not found"
```powershell
# Verificar se .env existe
cat .env

# Ou definir manualmente no script
# Editar linha 13-14 do backup-automatico.py
```

### Backups não aparecem
```powershell
# Verificar se pasta existe
ls backups/

# Criar pasta manualmente se necessário
mkdir backups
```

### Restauração falha
```powershell
# Verificar conteúdo do JSON
cat backups/tabela_xxx.json

# Verificar se tabela existe no banco
# Supabase Dashboard → Table Editor
```

---

## 📞 Checklist Rápido

Antes de usar backup em produção:

- [ ] ✅ Dependências instaladas (`pip install supabase`)
- [ ] ✅ Fazer 1 backup manual de teste
- [ ] ✅ Verificar arquivos em `backups/`
- [ ] ✅ Testar restaurar 1 tabela pequena
- [ ] ✅ Agendar backup diário (03:00 AM)
- [ ] ✅ Configurar cópia para nuvem (OneDrive/Drive)
- [ ] ✅ Documentar senha do backup (se houver)

---

## 🎯 Resumo

```powershell
# 1. Instalar (primeira vez)
pip install supabase

# 2. Fazer backup
python scripts/backup-automatico.py

# 3. Ver backups
ls backups/

# 4. Restaurar
python scripts/restaurar-backup.py

# 5. Agendar (opcional)
# Use Agendador de Tarefas do Windows
```

**Pronto! Seus dados estão protegidos com backup local adicional.** 🔒
