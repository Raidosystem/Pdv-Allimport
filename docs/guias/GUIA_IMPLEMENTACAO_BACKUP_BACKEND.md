# 🚀 Guia de Implementação: Backup Automático no Backend

Sistema de backup automático que roda **no servidor Supabase**, sem necessidade de configuração no computador do cliente.

## ✅ Passo a Passo Completo

### **1. Instalar Supabase CLI**

```bash
# Windows (PowerShell como Administrador)
npm install -g supabase

# Verificar instalação
supabase --version
```

### **2. Login no Supabase**

```bash
# Fazer login com sua conta
supabase login

# Vincular ao projeto
supabase link --project-ref kmcaaqetxtwkdcczdomw
```

Quando pedir senha, use a **Database Password** do projeto (encontre em: Project Settings → Database → Database Password).

### **3. Fazer Deploy da Edge Function**

```bash
# Na pasta raiz do projeto
cd C:\Users\GrupoRaval\Desktop\Pdv-Allimport

# Deploy da função de backup
supabase functions deploy backup-automatico
```

**Saída esperada:**
```
✓ Function deployed successfully
Function URL: https://kmcaaqetxtwkdcczdomw.supabase.co/functions/v1/backup-automatico
```

### **4. Configurar Variáveis de Ambiente da Edge Function**

```bash
# Definir SERVICE_ROLE_KEY para a função
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQyNjUxMywiZXhwIjoyMDcyMDAyNTEzfQ.Lgiq5fY-XMQyqhZYof4cvYMNkw4DTGikvAk56im-Hks

# Definir SUPABASE_URL
supabase secrets set SUPABASE_URL=https://kmcaaqetxtwkdcczdomw.supabase.co
```

### **5. Executar SQL de Configuração**

1. Abra o **Supabase Dashboard**: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw
2. Menu: **SQL Editor** → **New query**
3. Copie todo o conteúdo de `CONFIGURAR_BACKUP_AUTOMATICO_BACKEND.sql`
4. Cole no editor e clique em **RUN**

**O que esse SQL faz:**
- ✅ Cria bucket `backups` no Storage
- ✅ Configura políticas de acesso (RLS)
- ✅ Habilita `pg_cron` (agendamento)
- ✅ Agenda backup diário às 03:00
- ✅ Cria função para backup manual

### **6. Testar Backup Manual**

No **SQL Editor**, execute:

```sql
-- Testar função de backup
SELECT executar_backup_manual();
```

**Ou via Edge Function diretamente:**

```bash
# PowerShell
curl -X POST https://kmcaaqetxtwkdcczdomw.supabase.co/functions/v1/backup-automatico `
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.Zd4CKd0yoMk0Mv-T9AkN7j0bP3XlE9LjLZ5P0WpuJ0E" `
  -H "Content-Type: application/json" `
  -d "{}"
```

**Saída esperada:**
```json
{
  "success": true,
  "resumo": {
    "total_empresas": 6,
    "empresas_sucesso": 6,
    "total_registros": 1097
  }
}
```

### **7. Verificar Backups no Storage**

1. Dashboard → **Storage** → Bucket `backups`
2. Deve aparecer pastas: `empresa_f7fdf4cf`, `empresa_23be9919`, etc.
3. Dentro de cada pasta: arquivos `backup_2026-01-16T...json`

### **8. Adicionar Componente no Dashboard**

Edite `src/modules/dashboard/Dashboard.tsx`:

```tsx
import { BackupStatus } from '@/components/BackupStatus'

export default function Dashboard() {
  return (
    <div className="space-y-6">
      {/* Componentes existentes */}
      <DashboardStats />
      <SalesChart />
      
      {/* ADICIONAR AQUI */}
      <BackupStatus />
      
      {/* Resto do código */}
    </div>
  )
}
```

### **9. Verificar Agendamento do Cron**

No **SQL Editor**:

```sql
-- Ver tarefas agendadas
SELECT * FROM cron.job WHERE jobname = 'backup-automatico-diario';

-- Ver últimas execuções
SELECT 
  start_time,
  end_time,
  status,
  return_message
FROM cron.job_run_details 
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'backup-automatico-diario')
ORDER BY start_time DESC
LIMIT 10;
```

### **10. Testar no Frontend**

1. Execute o projeto: `npm run dev`
2. Faça login no sistema
3. Acesse o Dashboard
4. Verifique o card **"🔐 Backup Automático"**
5. Clique em **"▶️ Executar Agora"** para testar

---

## 📊 Verificações Pós-Implementação

### ✅ Checklist de Validação

- [ ] Edge Function deployed com sucesso
- [ ] Secrets configurados (SERVICE_ROLE_KEY, SUPABASE_URL)
- [ ] SQL executado sem erros
- [ ] Bucket `backups` criado no Storage
- [ ] Políticas RLS configuradas
- [ ] pg_cron agendado (verificar com `SELECT * FROM cron.job`)
- [ ] Backup manual executado com sucesso
- [ ] Arquivos aparecendo no Storage
- [ ] Componente `BackupStatus` renderizando no Dashboard
- [ ] Botão "Executar Agora" funcionando

---

## 🔧 Troubleshooting

### Erro: "pg_cron extension not found"

**Causa:** Projeto não está no plano Pro do Supabase.

**Solução:**
1. Upgrade para Pro: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/settings/billing
2. Ou use fallback: executar backup via Edge Function + GitHub Actions

**Alternativa (sem pg_cron):**

Crie GitHub Action (`.github/workflows/backup.yml`):

```yaml
name: Backup Automático
on:
  schedule:
    - cron: '0 6 * * *' # 03:00 BRT
  workflow_dispatch: # Permite execução manual

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Executar Backup
        run: |
          curl -X POST https://kmcaaqetxtwkdcczdomw.supabase.co/functions/v1/backup-automatico \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_ANON_KEY }}" \
            -H "Content-Type: application/json" \
            -d '{}'
```

### Erro: "Function invocation failed"

**Verificar:**
1. Secrets configurados: `supabase secrets list`
2. Logs da função: Dashboard → Edge Functions → Logs
3. RLS functions existem: `SELECT * FROM pg_proc WHERE proname LIKE 'backup_%'`

### Erro: "Storage bucket not found"

**Executar SQL novamente:**
```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('backups', 'backups', false)
ON CONFLICT (id) DO NOTHING;
```

### Backup não aparece no frontend

**Verificar permissões:**
```sql
-- Verificar políticas do bucket
SELECT * FROM storage.objects WHERE bucket_id = 'backups' LIMIT 5;

-- Testar acesso manual
SELECT * FROM storage.buckets WHERE id = 'backups';
```

---

## 🎯 Resumo do Sistema

### **Como Funciona:**

1. **Agendamento:** `pg_cron` chama Edge Function às 03:00 diariamente
2. **Execução:** Edge Function usa `backup_listar_empresas()` e `backup_tabela_por_user()`
3. **Storage:** Salva JSON no bucket `backups` (pasta por empresa)
4. **Limpeza:** Remove backups com +7 dias automaticamente
5. **Frontend:** Componente `BackupStatus` mostra status e histórico

### **Vantagens:**

✅ **Zero configuração** no computador do cliente  
✅ **Funciona offline** (backup roda no servidor)  
✅ **Multiplataforma** (PWA, mobile, desktop)  
✅ **Centralizado** (todos os backups em um lugar)  
✅ **Seguro** (RLS isola dados por empresa)  
✅ **Automático** (cliente não precisa fazer nada)  

---

## 📞 Suporte

**Problemas?** Execute diagnóstico completo:

```sql
-- Diagnóstico completo
SELECT 'Funções RPC' as tipo, COUNT(*) as total
FROM pg_proc WHERE proname LIKE 'backup_%'
UNION ALL
SELECT 'Bucket Storage', COUNT(*) FROM storage.buckets WHERE id = 'backups'
UNION ALL
SELECT 'Cron Jobs', COUNT(*) FROM cron.job WHERE jobname LIKE '%backup%'
UNION ALL
SELECT 'Backups Salvos', COUNT(*) FROM storage.objects WHERE bucket_id = 'backups';
```

**Tudo pronto!** 🎉 Sistema de backup automático implementado com sucesso!
