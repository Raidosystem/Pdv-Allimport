# 🔄 Backup Automático com GitHub Actions

## ✅ Solução para Plano Free do Supabase

Esta solução funciona **gratuitamente** e executa backup automático diário usando GitHub Actions.

---

## 📋 Passo 1: Criar Workflow do GitHub

Crie o arquivo `.github/workflows/backup-diario.yml` no seu repositório:

```yaml
name: Backup Automático Diário

on:
  # Executa todos os dias às 2:00 AM UTC (23:00 Brasília)
  schedule:
    - cron: '0 2 * * *'
  
  # Permite execução manual
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest
    name: Criar Backup Diário
    
    steps:
      - name: Checkout código
        uses: actions/checkout@v4
      
      - name: Executar Backup no Supabase
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
        run: |
          echo "🔄 Iniciando backup automático..."
          
          RESPONSE=$(curl -X POST \
            "${SUPABASE_URL}/rest/v1/rpc/criar_backup_automatico_diario" \
            -H "apikey: ${SUPABASE_KEY}" \
            -H "Authorization: Bearer ${SUPABASE_KEY}" \
            -H "Content-Type: application/json" \
            -H "Prefer: return=representation")
          
          echo "📦 Resposta do backup:"
          echo "$RESPONSE" | jq '.'
          
          # Verificar se backup foi bem-sucedido
          if echo "$RESPONSE" | jq -e '.sucesso == true' > /dev/null; then
            echo "✅ Backup concluído com sucesso!"
          else
            echo "❌ Erro no backup!"
            echo "$RESPONSE"
            exit 1
          fi
      
      - name: Verificar backups criados
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
        run: |
          echo "📊 Verificando backups recentes..."
          
          curl -X GET \
            "${SUPABASE_URL}/rest/v1/backups?select=id,tipo,status,total_clientes,total_produtos,created_at&tipo=eq.automatico&order=created_at.desc&limit=5" \
            -H "apikey: ${SUPABASE_KEY}" \
            -H "Authorization: Bearer ${SUPABASE_KEY}" \
            | jq '.'
```

---

## 🔐 Passo 2: Configurar Secrets no GitHub

1. Vá para o seu repositório no GitHub
2. Clique em **Settings** > **Secrets and variables** > **Actions**
3. Adicione os seguintes secrets:

### Secret 1: SUPABASE_URL
- Nome: `SUPABASE_URL`
- Valor: `https://kmcaaqetxtwkdcczdomw.supabase.co`

### Secret 2: SUPABASE_ANON_KEY
- Nome: `SUPABASE_ANON_KEY`
- Valor: Sua chave anon do Supabase (encontre em Project Settings > API)

---

## ⚙️ Passo 3: Criar a Função RPC no Supabase

Execute este SQL no Supabase Dashboard > SQL Editor:

```sql
-- Esta função já deve estar criada pelo script anterior
-- Se não estiver, execute: CONFIGURAR_BACKUP_AUTOMATICO_DIARIO.sql
SELECT public.criar_backup_automatico_diario();
```

---

## 🧪 Passo 4: Testar Manualmente

1. No GitHub, vá para **Actions**
2. Clique em **Backup Automático Diário**
3. Clique em **Run workflow** > **Run workflow**
4. Aguarde a execução (leva ~30 segundos)
5. Verifique se apareceu ✅ verde

---

## 📅 Horários de Execução

O backup roda automaticamente:
- **Horário UTC**: 2:00 AM
- **Horário Brasília**: 23:00 (11:00 PM)

Para mudar o horário, edite a linha do cron:
```yaml
- cron: '0 3 * * *'  # 3:00 AM UTC = 00:00 Brasília
- cron: '0 6 * * *'  # 6:00 AM UTC = 03:00 Brasília
- cron: '30 8 * * *' # 8:30 AM UTC = 05:30 Brasília
```

---

## 🔍 Como Verificar se Está Funcionando

### No GitHub:
1. Vá para **Actions** no repositório
2. Veja o histórico de execuções
3. Clique em uma execução para ver os logs

### No Supabase:
Execute este SQL para ver os backups:

```sql
SELECT 
    id,
    tipo,
    status,
    total_clientes,
    total_produtos,
    ROUND(tamanho_bytes / 1024.0 / 1024.0, 2) as tamanho_mb,
    created_at
FROM public.backups
WHERE tipo = 'automatico'
ORDER BY created_at DESC
LIMIT 10;
```

---

## 📧 Notificações (Opcional)

Para receber email quando o backup falhar, adicione este step ao workflow:

```yaml
      - name: Notificar erro
        if: failure()
        uses: dawidd6/action-send-mail@v3
        with:
          server_address: smtp.gmail.com
          server_port: 587
          username: ${{ secrets.EMAIL_USERNAME }}
          password: ${{ secrets.EMAIL_PASSWORD }}
          subject: ❌ Falha no Backup Automático
          body: O backup automático do PDV falhou. Verifique os logs.
          to: seu-email@gmail.com
          from: GitHub Actions
```

---

## 💾 Onde os Backups São Salvos?

Os backups são salvos na tabela `backups` do Supabase.

Para **baixar** um backup:

```sql
-- Pegar o JSON do backup mais recente
SELECT data FROM public.backups 
WHERE tipo = 'automatico' 
ORDER BY created_at DESC 
LIMIT 1;
```

Ou use a interface do AdminBackupsPage para baixar como arquivo JSON.

---

## 🗑️ Limpeza Automática

Backups automáticos **mais antigos que 7 dias** são automaticamente deletados pela função.

Para mudar o período de retenção, edite a função:

```sql
-- Manter últimos 30 dias:
DELETE FROM public.backups
WHERE tipo = 'automatico'
AND created_at < NOW() - INTERVAL '30 days';
```

---

## 🆘 Solução de Problemas

### Erro: "Function criar_backup_automatico_diario does not exist"
**Solução**: Execute o script `CONFIGURAR_BACKUP_AUTOMATICO_DIARIO.sql` no Supabase

### Erro: "JWT expired"
**Solução**: Verifique se a chave SUPABASE_ANON_KEY está correta

### Erro: "Permission denied"
**Solução**: Verifique as RLS policies da tabela `backups`

### Backup não aparece
**Solução**: Execute manualmente no Supabase:
```sql
SELECT public.criar_backup_automatico_diario();
```

---

## ✅ Checklist de Configuração

- [ ] Arquivo `.github/workflows/backup-diario.yml` criado
- [ ] Secret `SUPABASE_URL` configurado no GitHub
- [ ] Secret `SUPABASE_ANON_KEY` configurado no GitHub
- [ ] Função `criar_backup_automatico_diario()` criada no Supabase
- [ ] Tabela `backups` criada e com RLS configurado
- [ ] Teste manual executado com sucesso
- [ ] Primeiro backup automático verificado

---

## 🎯 Vantagens desta Solução

✅ **Gratuito** - Funciona no plano Free do Supabase e GitHub  
✅ **Confiável** - GitHub Actions tem 99.9% de uptime  
✅ **Automático** - Não depende do usuário estar online  
✅ **Histórico** - Logs completos de todas as execuções  
✅ **Flexível** - Fácil de mudar horários e configurações  
✅ **Notificações** - Pode enviar email em caso de falha  

---

## 📚 Recursos Adicionais

- [Documentação GitHub Actions](https://docs.github.com/pt/actions)
- [Expressões Cron](https://crontab.guru/)
- [Supabase RPC Functions](https://supabase.com/docs/guides/database/functions)

---

## 🚀 Pronto!

Seu sistema agora tem backup automático diário funcionando 24/7!

Para verificar: Execute `SELECT * FROM backups ORDER BY created_at DESC;` no Supabase.
