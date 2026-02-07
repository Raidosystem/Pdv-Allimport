# Guia de Deploy Manual - Backup Automático Backend

## ⚠️ IMPORTANTE: Deploy Manual Necessário

Como o Supabase CLI requer login interativo, você precisa fazer o deploy manualmente.

## 📋 Passo a Passo Completo

### **OPÇÃO 1: Deploy via Dashboard Supabase (MAIS FÁCIL)**

1. **Acesse o Dashboard:**
   - https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/functions

2. **Criar Nova Função:**
   - Clique em **"Create a new function"**
   - Nome: `backup-automatico`

3. **Copiar Código:**
   - Abra: `C:\Users\GrupoRaval\Desktop\Pdv-Allimport\supabase\functions\backup-automatico\index.ts`
   - Copie TODO o conteúdo
   - Cole no editor do Dashboard

4. **Configurar Variáveis de Ambiente:**
   - Na mesma página, seção **"Secrets"**
   - Adicionar:
     ```
     SUPABASE_URL=https://kmcaaqetxtwkdcczdomw.supabase.co
     SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQyNjUxMywiZXhwIjoyMDcyMDAyNTEzfQ.Lgiq5fY-XMQyqhZYof4cvYMNkw4DTGikvAk56im-Hks
     ```

5. **Fazer Deploy:**
   - Clique em **"Deploy function"**

6. **Testar:**
   - No SQL Editor, execute:
     ```sql
     SELECT executar_backup_manual();
     ```

---

### **OPÇÃO 2: Deploy via CLI (Terminal)**

1. **Instalar CLI:**
   - Baixe: https://github.com/supabase/cli/releases
   - Extraia para `C:\supabase\`
   - Adicione ao PATH

2. **Login:**
   ```bash
   supabase login
   ```

3. **Link ao Projeto:**
   ```bash
   cd C:\Users\GrupoRaval\Desktop\Pdv-Allimport
   supabase link --project-ref kmcaaqetxtwkdcczdomw
   ```

4. **Deploy:**
   ```bash
   supabase functions deploy backup-automatico
   ```

5. **Configurar Secrets:**
   ```bash
   supabase secrets set SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NjQyNjUxMywiZXhwIjoyMDcyMDAyNTEzfQ.Lgiq5fY-XMQyqhZYof4cvYMNkw4DTGikvAk56im-Hks
   
   supabase secrets set SUPABASE_URL=https://kmcaaqetxtwkdcczdomw.supabase.co
   ```

---

### **OPÇÃO 3: Deploy via API REST (Avançado)**

Você pode criar a função diretamente pela API Management do Supabase, mas a Opção 1 é mais simples.

---

## ✅ Verificar Deploy

Após o deploy, verificar:

1. **Função criada:**
   - Dashboard → Edge Functions → Deve aparecer `backup-automatico`

2. **Secrets configurados:**
   - Dashboard → Edge Functions → backup-automatico → Settings → Secrets

3. **Testar execução:**
   ```sql
   SELECT executar_backup_manual();
   ```

4. **Verificar Storage:**
   - Dashboard → Storage → bucket `backups`
   - Devem aparecer pastas `empresa_[id]` com arquivos JSON

---

## 🎯 Resumo

**Status Atual:**
- ✅ SQL executado com sucesso
- ✅ Backup agendado (03:00 BRT)
- ✅ Bucket criado
- ✅ Políticas RLS configuradas
- ⚠️ **FALTA: Deploy da Edge Function**

**Recomendação:** Use a **OPÇÃO 1** (Dashboard) - é a mais simples e visual!

**Após deploy, o sistema estará 100% funcional!** 🎉
