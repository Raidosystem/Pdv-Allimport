# 📦 Sistema de Backup Automático Local

Este sistema permite fazer backup automático dos dados do Supabase diretamente em uma pasta do seu PC.

## 🚀 Como Configurar

### 1️⃣ Executar o Configurador (Uma vez apenas)

Abra o **PowerShell como Administrador** e execute:

```powershell
cd "C:\Users\crism\Desktop\Pdv-Allimport\scripts"
.\configurar-backup-automatico.ps1
```

O script irá solicitar:
- **URL do Supabase**: `https://seu-projeto.supabase.co`
- **Chave Anon**: Pegue no Dashboard do Supabase (Settings > API)
- **Token de Usuário**: Token JWT do usuário logado ([Como obter?](COMO-OBTER-TOKEN.md))
- **Pasta de Backup**: Onde salvar os backups (ex: `C:\Backups\PDV-Allimport`)
- **Horário**: Que horas fazer o backup diário (ex: `23:00`)

### 2️⃣ Pronto! ✅

O backup será executado automaticamente todos os dias no horário configurado.

## 📋 O Que é Feito no Backup

1. **Autentica com token do usuário** (identifica a empresa)
2. **Cria backup no Supabase** (via função RPC `criar_backup_automatico_individual`)
3. **Baixa APENAS dados da sua empresa**:
   - Clientes
   - Produtos
   - Vendas
   - Itens de Venda
   - Categorias
   - Caixa e Movimentos
   - Ordens de Serviço
   - Fornecedores
   - Configurações
4. **Salva em arquivo ZIP** com nome `backup_[empresa-id]_YYYYMMDD_HHMMSS.zip`
5. **Mantém últimos 30 backups** (remove os mais antigos automaticamente)
6. **Gera log** em `backup.log`

## 🧪 Testar Backup Manualmente

Para testar se está funcionando:

```powershell
# Abrir PowerShell como Administrador
Start-ScheduledTask -TaskName "PDV-Allimport-Backup-Automatico"
```

Depois verifique a pasta de backups e o arquivo `backup.log`.

## 🔍 Verificar Status da Tarefa Agendada

1. Pressione `Win + R`
2. Digite: `taskschd.msc`
3. Procure por: **PDV-Allimport-Backup-Automatico**
4. Clique com botão direito > **Executar** (para testar)

## 📁 Estrutura dos Arquivos de Backup

Cada backup é um arquivo ZIP contendo JSON com:

```json
{
  "metadata": {
    "id": "uuid-do-backup",
    "empresa_id": "uuid-da-empresa",
    "tipo": "automatico",
    "status": "concluido",
    "total_clientes": 142,
    "total_produtos": 813,
    "total_vendas": 6
  },
  "dados": {
    "empresa_id": "uuid-da-empresa",
    "backup_date": "2025-11-30 23:00:00",
    "clientes": [...],
    "produtos": [...],
    "vendas": [...],
    "itens_venda": [...],
    "categorias": [...],
    "caixa": [...],
    "movimentos_caixa": [...],
    "ordens_servico": [...],
    "fornecedores": [...],
    "configuracoes_impressao": {...},
    "user_settings": [...]
  },
  "backup_date": "2025-11-30 23:00:00"
}
```

## 🔧 Modificar Configurações

### Alterar Horário do Backup

1. Abra o **Agendador de Tarefas** (`taskschd.msc`)
2. Encontre: **PDV-Allimport-Backup-Automatico**
3. Clique com botão direito > **Propriedades**
4. Aba **Gatilhos** > **Editar**
5. Altere o horário e clique **OK**

### Alterar Pasta de Backup

Edite o arquivo `backup-automatico.ps1` e mude a linha:

```powershell
$BACKUP_FOLDER = "C:\Nova\Pasta\Backups"
```

### Alterar Quantidade de Backups Mantidos

No arquivo `backup-automatico.ps1`, mude:

```powershell
$MAX_BACKUPS = 30  # Altere para o número desejado
```

## 🗑️ Remover Backup Automático

Para desativar completamente:

```powershell
# Abrir PowerShell como Administrador
Unregister-ScheduledTask -TaskName "PDV-Allimport-Backup-Automatico" -Confirm:$false
```

## 📝 Logs

Todos os logs são salvos em: `[Pasta de Backup]\backup.log`

Exemplo:
```
[2025-11-30 23:00:00] =========================================
[2025-11-30 23:00:00] INICIANDO BACKUP AUTOMÁTICO
[2025-11-30 23:00:00] Pasta de backup criada: C:\Backups\PDV-Allimport
[2025-11-30 23:00:01] Iniciando backup no Supabase...
[2025-11-30 23:00:02] ✅ Backup criado no Supabase: uuid-123
[2025-11-30 23:00:03] Baixando dados do backup...
[2025-11-30 23:00:05] ✅ Backup salvo: backup_20251130_230005.zip (0.66 MB)
[2025-11-30 23:00:05]    - Clientes: 142
[2025-11-30 23:00:05]    - Produtos: 813
[2025-11-30 23:00:05]    - Vendas: 6
[2025-11-30 23:00:05] =========================================
[2025-11-30 23:00:05] BACKUP CONCLUÍDO COM SUCESSO! ✅
```

## ⚠️ Requisitos

- Windows 10/11
- PowerShell 5.1 ou superior
- Conexão com internet
- Permissões de administrador (apenas na configuração inicial)

## 🆘 Problemas Comuns

### "Não é possível executar scripts"
Execute no PowerShell como Administrador:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Erro ao conectar ao Supabase"
Verifique:
- URL do Supabase está correta
- Chave Anon está correta
- **Token de usuário está válido** (não expirou)
- Conexão com internet está ativa

### "Erro de autenticação" ou "JWT expired"
O token expirou! Veja [COMO-OBTER-TOKEN.md](COMO-OBTER-TOKEN.md) para obter um novo token e reconfigurar.

### "Backup não está sendo criado"
1. Verifique o log em `backup.log`
2. Teste manualmente: `Start-ScheduledTask -TaskName "PDV-Allimport-Backup-Automatico"`
3. Verifique se a tarefa está habilitada no Agendador de Tarefas

## 📞 Suporte

Em caso de dúvidas ou problemas, consulte os logs em `backup.log` para mais detalhes sobre o erro.
