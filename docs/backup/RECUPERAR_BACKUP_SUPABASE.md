# 🚨 RECUPERAÇÃO DE DADOS - BACKUP DO SUPABASE

## PASSO 1: Acessar Backups Automáticos

1. Entre no Dashboard do Supabase: https://app.supabase.com
2. Selecione seu projeto
3. Vá em **Settings** → **Database**
4. Role até a seção **Backups** ou **Point-in-Time Recovery**

## PASSO 2: Restaurar para Antes do DROP

O Supabase mantém backups automáticos:
- **Plano Free**: backup diário dos últimos 7 dias
- **Plano Pro**: Point-in-Time Recovery (PITR) - qualquer momento das últimas 7 dias
- **Plano Team/Enterprise**: até 30 dias

### Se tiver PITR (Plano Pago):
```
1. Na seção Backups, clique em "Point-in-Time Recovery"
2. Selecione a data/hora ANTES de rodar o DROP (ex: hoje 10:00 AM se rodou às 11:00)
3. O Supabase vai criar um NOVO projeto com os dados restaurados
4. Exporte os dados da tabela `subscriptions` restaurada
```

### Se tiver apenas Backup Diário (Free):
```
1. Na seção Backups, veja a lista de backups disponíveis
2. Restaure o backup de ONTEM (ou do último dia antes do problema)
3. Exporte a tabela `subscriptions` do backup
```

## PASSO 3: Exportar Dados Recuperados

Depois de restaurar, execute no SQL Editor do projeto restaurado:

```sql
-- Exportar todas as assinaturas ativas/pagas
COPY (
  SELECT 
    u.email,
    u.id as user_id,
    s.status,
    s.plan_type,
    s.trial_start_date,
    s.trial_end_date,
    s.subscription_start_date,
    s.subscription_end_date,
    s.amount,
    s.payment_method,
    s.created_at
  FROM subscriptions s
  JOIN auth.users u ON u.id = s.user_id
  WHERE s.status IN ('active', 'trial')
  ORDER BY s.created_at
) TO '/tmp/subscriptions_backup.csv' WITH CSV HEADER;
```

Ou use o botão **"Export to CSV"** na interface do Supabase Table Editor.

## PASSO 4: Importar de Volta no Projeto Principal

Com o CSV em mãos, reimporte:

```sql
-- Para cada linha do CSV, rode:
INSERT INTO subscriptions (user_id, status, plan_type, subscription_start_date, subscription_end_date, trial_start_date, trial_end_date, amount, payment_method)
VALUES (
  'UUID_DO_USUARIO',
  'active',  -- ou 'trial'
  'premium', -- ou 'free'
  '2025-05-01 00:00:00-03',
  '2026-05-01 00:00:00-03',
  NULL,
  NULL,
  99.90,
  'pix'
)
ON CONFLICT (user_id) DO UPDATE SET
  status = EXCLUDED.status,
  plan_type = EXCLUDED.plan_type,
  subscription_start_date = EXCLUDED.subscription_start_date,
  subscription_end_date = EXCLUDED.subscription_end_date,
  updated_at = NOW();
```

---

## ALTERNATIVA: Logs de Aplicação

Se você tiver logs da aplicação (console do navegador, servidor, etc.), procure por:
- Requisições à tabela `subscriptions`
- Checagens de status de assinatura
- Eventos de pagamento

Isso pode ajudar a identificar quem tinha plano ativo.

---

## PREVENÇÃO FUTURA

1. **NUNCA mais use DROP TABLE em produção**
2. Configure backups regulares fora do Supabase
3. Use migrations versionadas (Supabase CLI)
4. Teste scripts destrutivos em projeto de desenvolvimento primeiro

---

## CONTATO SUPABASE SUPPORT

Se não conseguir acessar backups:
- Email: support@supabase.com
- Discord: https://discord.supabase.com
- Explique que executou DROP acidentalmente e precisa de PITR urgente
