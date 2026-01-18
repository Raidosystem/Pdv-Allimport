# 🗄️ Guia de Backup Automático Multi-Projetos

## 📋 Visão Geral

Sistema de backup automático que:
- ✅ Faz backup de **múltiplos projetos Supabase**
- ✅ **Isolamento por empresa** (cada cliente separado)
- ✅ Salva em **pasta local sincronizada com nuvem** (Google Drive/OneDrive/Dropbox)
- ✅ **Execução automática diária** via Windows Task Scheduler
- ✅ **Mantém apenas últimos N backups** (limpeza automática)
- ✅ **Logs detalhados** de cada execução
- ✅ **Fácil adicionar novos projetos**

## 🚀 Configuração Inicial

### 1. Escolher Pasta de Backup (Sincronizada com Nuvem)

Edite o arquivo `config-backup-multiprojetos.json` e defina a pasta:

```json
{
  "pasta_backup_local": "C:\\Users\\GrupoRaval\\OneDrive\\Backups-Supabase",
  ...
}
```

**Opções comuns:**
- Google Drive: `C:\\Users\\[Usuario]\\Google Drive\\Backups-Supabase`
- OneDrive: `C:\\Users\\[Usuario]\\OneDrive\\Backups-Supabase`
- Dropbox: `C:\\Users\\[Usuario]\\Dropbox\\Backups-Supabase`
- iCloud Drive: `C:\\Users\\[Usuario]\\iCloudDrive\\Backups-Supabase`

### 2. Configurar SQL Functions no Supabase

**IMPORTANTE:** Execute primeiro o SQL `CRIAR_FUNCOES_BACKUP_RLS.sql` no Supabase Dashboard de cada projeto:

1. Acesse: https://supabase.com/dashboard
2. Selecione o projeto
3. Menu: SQL Editor → New query
4. Cole o conteúdo de `CRIAR_FUNCOES_BACKUP_RLS.sql`
5. Clique em **RUN**

### 3. Adicionar Projetos no Arquivo de Configuração

Edite `config-backup-multiprojetos.json`:

```json
{
  "projetos": [
    {
      "nome": "PDV-Allimport",
      "ativo": true,
      "supabase_url": "https://kmcaaqetxtwkdcczdomw.supabase.co",
      "service_role_key": "eyJhbGci...",
      "tabelas": [
        "user_approvals",
        "empresas",
        "subscriptions",
        "produtos",
        "clientes",
        "vendas",
        "vendas_itens",
        "caixa",
        "categorias",
        "fornecedores",
        "despesas",
        "ordens_servico",
        "funcionarios"
      ]
    },
    {
      "nome": "Outro-Projeto",
      "ativo": true,
      "supabase_url": "https://outro.supabase.co",
      "service_role_key": "eyJhbGci...",
      "tabelas": [
        "users",
        "orders",
        "products"
      ]
    }
  ]
}
```

**Como obter as credenciais:**
1. Supabase Dashboard → Project Settings → API
2. Copie: `Project URL` → `supabase_url`
3. Copie: `service_role key` → `service_role_key` (⚠️ ATENÇÃO: chave secreta!)

### 4. Testar Backup Manual

Antes de agendar, teste se está funcionando:

**Windows:**
```bash
# Clique duas vezes em:
TESTAR_BACKUP_AGORA.bat
```

**Ou via PowerShell:**
```powershell
C:/Users/GrupoRaval/Desktop/Pdv-Allimport/.venv/Scripts/python.exe scripts/backup-multiprojetos-automatico.py
```

Verifique:
- ✅ Pastas criadas em `C:\Users\...\OneDrive\Backups-Supabase\`
- ✅ Arquivos JSON salvos
- ✅ Log gerado sem erros

### 5. Agendar Execução Automática

**Windows (Agendador de Tarefas):**

1. **Clique com botão direito** em `AGENDAR_BACKUP_WINDOWS.bat`
2. Selecione **"Executar como administrador"**
3. Confirme a criação da tarefa

Ou configure manualmente:
1. Abra "Agendador de Tarefas" (`taskschd.msc`)
2. Criar Tarefa Básica
3. Nome: `Backup-Supabase-Automatico`
4. Gatilho: Diariamente às 03:00
5. Ação: Iniciar programa
   - Programa: `C:\Users\GrupoRaval\Desktop\Pdv-Allimport\.venv\Scripts\python.exe`
   - Argumentos: `scripts\backup-multiprojetos-automatico.py`
   - Iniciar em: `C:\Users\GrupoRaval\Desktop\Pdv-Allimport`

## 📁 Estrutura de Backup

```
C:\Users\[Usuario]\OneDrive\Backups-Supabase\
├── PDV-Allimport\
│   ├── 20260116_030000\           # Backup do dia 16/01/2026 às 03:00
│   │   ├── empresa_f7fdf4cf\      # Allimport
│   │   │   ├── user_approvals_20260116_030001.json
│   │   │   ├── empresas_20260116_030002.json
│   │   │   ├── produtos_20260116_030003.json
│   │   │   ├── clientes_20260116_030004.json
│   │   │   └── _metadata_20260116_030010.json
│   │   ├── empresa_23be9919\      # Victor
│   │   └── empresa_8adef71b\      # Cristiane Ramos
│   ├── 20260117_030000\           # Backup do dia 17/01/2026
│   └── 20260118_030000\           # Backup do dia 18/01/2026
├── Outro-Projeto\
│   ├── 20260116_030000\
│   └── 20260117_030000\
└── logs\
    ├── backup_20260116_030000.log
    ├── backup_20260117_030000.log
    └── backup_20260118_030000.log
```

## 🔧 Configurações Avançadas

### Alterar Horário de Backup

Edite `config-backup-multiprojetos.json`:

```json
{
  "horario_backup": "03:00",  // Horário desejado (formato 24h)
  ...
}
```

Depois atualize a tarefa agendada:
```bash
schtasks /Change /TN "Backup-Supabase-Automatico" /ST 03:00
```

### Alterar Retenção de Backups

Por padrão mantém 7 dias. Para alterar:

```json
{
  "manter_ultimos_backups": 30,  // Manter últimos 30 dias
  ...
}
```

### Desabilitar Projeto Temporariamente

Altere `"ativo": false` no projeto:

```json
{
  "projetos": [
    {
      "nome": "Projeto-Temporariamente-Desabilitado",
      "ativo": false,  // Não fará backup
      ...
    }
  ]
}
```

### Ativar Notificações por Email (Futuro)

```json
{
  "notificacoes": {
    "email_notificar": true,
    "email_destino": "admin@empresa.com",
    "apenas_erros": true  // Notifica apenas se houver erro
  }
}
```

## 🔐 Segurança

### ⚠️ IMPORTANTE: Proteção das Credenciais

O arquivo `config-backup-multiprojetos.json` contém **chaves secretas** (SERVICE_ROLE_KEY):

1. **NÃO comitar** em repositórios Git
2. **NÃO compartilhar** publicamente
3. **Fazer backup seguro** do arquivo de configuração
4. **Permissões**: Apenas você deve ter acesso

### Adicionar ao .gitignore

Adicione no `.gitignore`:

```
config-backup-multiprojetos.json
backups/
```

## 🛠️ Comandos Úteis

### Verificar se Tarefa Está Agendada
```bash
schtasks /Query /TN "Backup-Supabase-Automatico"
```

### Executar Backup Manualmente Agora
```bash
schtasks /Run /TN "Backup-Supabase-Automatico"
```

### Desabilitar Backup Automático
```bash
schtasks /Change /TN "Backup-Supabase-Automatico" /DISABLE
```

### Habilitar Novamente
```bash
schtasks /Change /TN "Backup-Supabase-Automatico" /ENABLE
```

### Remover Tarefa Agendada
```bash
schtasks /Delete /TN "Backup-Supabase-Automatico" /F
```

### Ver Último Log
```bash
# PowerShell
Get-Content "C:\Users\[Usuario]\OneDrive\Backups-Supabase\logs\backup_*.log" -Tail 50
```

## 📊 Monitoramento

### Verificar se Backup Rodou Hoje

1. Abra "Agendador de Tarefas"
2. Localize "Backup-Supabase-Automatico"
3. Aba "Histórico" → Verificar última execução

### Ver Logs de Execução

Os logs são salvos em: `[pasta_backup]\logs\backup_[data].log`

**Ou via PowerShell:**
```powershell
Get-ChildItem "C:\Users\[Usuario]\OneDrive\Backups-Supabase\logs\" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content
```

## 🆘 Resolução de Problemas

### Backup Não Está Executando

1. **Verificar tarefa agendada:**
   - Abrir "Agendador de Tarefas"
   - Localizar "Backup-Supabase-Automatico"
   - Status deve ser "Pronto"

2. **Executar manualmente para ver erro:**
   ```bash
   TESTAR_BACKUP_AGORA.bat
   ```

3. **Verificar se funções SQL estão instaladas:**
   - Dashboard Supabase → SQL Editor
   - Executar:
     ```sql
     SELECT proname FROM pg_proc 
     WHERE proname IN ('backup_listar_empresas', 'backup_tabela_por_user');
     ```
   - Devem aparecer 2 funções

### Erro 403 (Permission Denied)

- **Causa:** Funções SQL não instaladas ou SERVICE_ROLE_KEY inválida
- **Solução:** Execute `CRIAR_FUNCOES_BACKUP_RLS.sql` no Supabase Dashboard

### Pasta de Nuvem Não Sincroniza

1. Verificar se Google Drive/OneDrive está rodando
2. Verificar espaço disponível na nuvem
3. Verificar se pasta está marcada para sincronização

### Logs Não Aparecem

- Verificar se pasta de logs existe
- Verificar permissões de escrita
- Ver `config-backup-multiprojetos.json` → `"salvar_logs": true`

## 📝 Adicionar Novo Projeto

1. Execute `CRIAR_FUNCOES_BACKUP_RLS.sql` no novo projeto Supabase
2. Obtenha `supabase_url` e `service_role_key`
3. Adicione em `config-backup-multiprojetos.json`:

```json
{
  "projetos": [
    ...projetos existentes...,
    {
      "nome": "Nome-Do-Novo-Projeto",
      "ativo": true,
      "supabase_url": "https://[ref].supabase.co",
      "service_role_key": "[service_role_key]",
      "tabelas": [
        "tabela1",
        "tabela2",
        "tabela3"
      ]
    }
  ]
}
```

4. Teste: `TESTAR_BACKUP_AGORA.bat`

## ✅ Checklist de Configuração

- [ ] Escolheu pasta sincronizada com nuvem
- [ ] Executou `CRIAR_FUNCOES_BACKUP_RLS.sql` em todos os projetos
- [ ] Configurou `config-backup-multiprojetos.json` com credenciais
- [ ] Testou backup manual (`TESTAR_BACKUP_AGORA.bat`)
- [ ] Verificou arquivos salvos na pasta de nuvem
- [ ] Agendou execução automática (`AGENDAR_BACKUP_WINDOWS.bat`)
- [ ] Adicionou `config-backup-multiprojetos.json` ao `.gitignore`
- [ ] Verificou que pasta está sincronizando com nuvem
- [ ] Testou restauração de um backup

## 🎉 Pronto!

Seu sistema está protegido com:
- ✅ Backups diários automáticos às 03:00
- ✅ Isolamento por empresa (restauração seletiva)
- ✅ Sincronização com nuvem (acesso de qualquer lugar)
- ✅ Limpeza automática (mantém últimos 7 dias)
- ✅ Logs detalhados de cada execução
- ✅ Suporte para múltiplos projetos

**Qualquer dúvida, consulte os logs ou execute manualmente para diagnóstico!**
