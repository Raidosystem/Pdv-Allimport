# 🏢 Backup Isolado Por Empresa

Sistema de backup com **isolamento completo** por empresa/usuário.

## 🎯 Diferença Entre os Backups

### 1️⃣ Backup Geral (`backup-direto-api.py`)
- ✅ Backup de **TODAS** as tabelas em arquivos separados
- ✅ Útil para **restauração completa do sistema**
- ✅ Horário: **3h da manhã**
- 📁 Estrutura: `backups/[tabela]_timestamp.json`

### 2️⃣ Backup Por Empresa (`backup-por-empresa-api.py`)
- ✅ Backup **ISOLADO** de cada empresa
- ✅ Cada empresa em **pasta separada**
- ✅ Útil para **restaurar dados de UMA empresa específica**
- ✅ Horário: **4h da manhã** (1h depois do backup geral)
- 📁 Estrutura: `backups/empresa_[user_id]/[tabela]_timestamp.json`

---

## 📦 Estrutura de Pastas

```
backups/
├── backup_metadata_20260118.json      # Metadata backup geral
├── user_approvals_20260118.json       # Backup geral
├── produtos_20260118.json             # Backup geral
├── ...
│
├── empresa_f7fdf4cf/                  # Empresa: Allimport
│   ├── backup_metadata_20260118.json
│   ├── user_approvals_20260118.json
│   ├── produtos_20260118.json         # 819 produtos desta empresa
│   ├── clientes_20260118.json         # 149 clientes desta empresa
│   └── ...
│
├── empresa_23be9919/                  # Empresa: Victor
│   ├── backup_metadata_20260118.json
│   ├── user_approvals_20260118.json
│   ├── subscriptions_20260118.json
│   └── ...
│
└── empresa_8adef71b/                  # Empresa: Cristiane Ramos
    ├── backup_metadata_20260118.json
    ├── produtos_20260118.json         # 2 produtos desta empresa
    └── ...
```

---

## 🚀 Instalação

### Instalar Backup Por Empresa:

```bash
cd ~/Documents/Pdv-Allimport
chmod +x instalar-backup-por-empresa.sh
bash instalar-backup-por-empresa.sh
```

---

## 🖱️ Uso Manual

### Atalho no Desktop:

```bash
# Já criado automaticamente:
Duplo-clique em: Backup-Por-Empresa.command
```

### Via Terminal:

```bash
cd ~/Documents/Pdv-Allimport
python3 scripts/backup-por-empresa-api.py
```

---

## 📊 Ver Status

```bash
cd ~/Documents/Pdv-Allimport

# Ver todas as pastas de empresas
ls -lh backups/empresa_*

# Ver arquivos de uma empresa específica
ls -lh backups/empresa_f7fdf4cf/

# Ver metadata de uma empresa
cat backups/empresa_f7fdf4cf/backup_metadata_*.json | python3 -m json.tool
```

---

## 🔄 Horários dos Backups

| Tipo | Horário | Descrição |
|------|---------|-----------|
| **Backup Geral** | 3h | Todas as tabelas juntas |
| **Backup Por Empresa** | 4h | Cada empresa em pasta separada |

---

## 💡 Quando Usar Cada Um?

### Use Backup Geral quando:
- ✅ Restaurar o sistema completo
- ✅ Migrar para novo servidor
- ✅ Análise de dados globais

### Use Backup Por Empresa quando:
- ✅ Restaurar dados de UM cliente específico
- ✅ Cliente perdeu dados e precisa recuperar
- ✅ Exportar dados de uma empresa
- ✅ Cliente cancelou e quer seus dados

---

## 🔍 Exemplo de Uso

### Cenário 1: Cliente Allimport perdeu produtos

```bash
# Ver backup da empresa
ls backups/empresa_f7fdf4cf/

# Restaurar produtos desta empresa
python3 scripts/restaurar-backup.py backups/empresa_f7fdf4cf/produtos_20260118.json
```

### Cenário 2: Cliente quer exportar seus dados

```bash
# Copiar pasta inteira da empresa
cp -r backups/empresa_f7fdf4cf/ ~/Desktop/Backup-Allimport/

# Ou criar ZIP
zip -r Backup-Allimport.zip backups/empresa_f7fdf4cf/
```

---

## 🗑️ Limpeza Automática

### Manter últimos 60 dias por empresa:

```bash
# Criar script de limpeza
cat > scripts/limpar-backups-empresas.sh << 'EOF'
#!/bin/bash
cd /Users/gruporaval/Documents/Pdv-Allimport
find backups/empresa_*/*.json -mtime +60 -delete
echo "✅ Backups antigos removidos (mantidos últimos 60 dias)"
EOF

chmod +x scripts/limpar-backups-empresas.sh
```

---

## 📋 Comandos Úteis

### Ver serviços ativos:

```bash
launchctl list | grep allimport
```

### Testar backup agora:

```bash
# Backup geral
launchctl start com.allimport.backup

# Backup por empresa
launchctl start com.allimport.backup.empresas
```

### Ver logs:

```bash
# Log backup geral
tail -f backups/backup.log

# Log backup por empresa
tail -f backups/backup_empresas.log
```

### Parar backups automáticos:

```bash
# Parar backup geral
launchctl unload ~/Library/LaunchAgents/com.allimport.backup.plist

# Parar backup por empresa
launchctl unload ~/Library/LaunchAgents/com.allimport.backup.empresas.plist
```

### Reativar backups:

```bash
# Reativar backup geral
launchctl load ~/Library/LaunchAgents/com.allimport.backup.plist

# Reativar backup por empresa
launchctl load ~/Library/LaunchAgents/com.allimport.backup.empresas.plist
```

---

## ✅ Checklist de Instalação

- [ ] `.env` configurado com `SUPABASE_SERVICE_ROLE_KEY`
- [ ] Backup geral instalado (3h da manhã)
- [ ] Backup por empresa instalado (4h da manhã)
- [ ] Atalhos criados no Desktop
- [ ] Testado manualmente
- [ ] Verificado logs

---

## 🆘 Troubleshooting

### Problema: Backup não encontra empresas

```bash
# Verificar se SERVICE_ROLE_KEY está correta
python3 scripts/backup-por-empresa-api.py
```

### Problema: Permissão negada

```bash
# Garantir permissões
chmod -R 755 backups/
chmod +x scripts/*.sh
```

---

## 📈 Exemplo de Saída

```
╔════════════════════════════════════════╗
║  🔒 BACKUP ISOLADO POR EMPRESA        ║
╚════════════════════════════════════════╝
📅 2026-01-18 16:04:33

🔍 Buscando empresas...
✅ 6 empresa(s) encontrada(s)

============================================================
🏢 Allimport
🆔 f7fdf4cf-7101-45ab-86db-5248a7ac58c1
============================================================
   ✅ user_approvals: 1 registros
   ✅ produtos: 819 registros
   ✅ clientes: 149 registros
   ✅ vendas: 7 registros
   ...

📊 Resumo:
   ✅ Sucesso: 13/13 tabelas
   ❌ Falhas: 0
   📝 Total: 1065 registros
   📁 Pasta: backups/empresa_f7fdf4cf
```

---

## 🎯 Recomendação

**Configure AMBOS os backups:**
1. ✅ Backup geral às 3h (sistema completo)
2. ✅ Backup por empresa às 4h (recuperação granular)

Isso garante **máxima segurança** e **flexibilidade na restauração**! 🛡️
