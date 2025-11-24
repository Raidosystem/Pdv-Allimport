-- =============================================
-- SISTEMA DE BACKUP AUTOMÁTICO SEM pg_cron
-- =============================================
-- Esta solução funciona em TODOS os planos do Supabase (inclusive Free Tier)
-- O backup será executado automaticamente em momentos estratégicos

-- =============================================
-- OPÇÃO 1: BACKUP AUTOMÁTICO POR TRIGGER
-- =============================================
-- Cria backups automaticamente quando houver mudanças significativas nos dados

-- Função para executar backup quando houver atividade
CREATE OR REPLACE FUNCTION trigger_daily_backup()
RETURNS TRIGGER AS $$
DECLARE
    last_backup_date DATE;
    current_user_id UUID;
BEGIN
    -- Pegar o user_id do registro (NEW ou OLD)
    current_user_id := COALESCE(NEW.user_id, OLD.user_id);
    
    -- Verificar se já existe backup hoje para este usuário
    SELECT backup_date INTO last_backup_date
    FROM user_backups
    WHERE user_id = current_user_id
      AND backup_date = CURRENT_DATE
    LIMIT 1;
    
    -- Se não existe backup hoje, criar um
    IF last_backup_date IS NULL THEN
        PERFORM public.save_backup_to_database(current_user_id);
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- Aplicar triggers nas tabelas principais
-- =============================================
-- O backup será criado automaticamente quando houver INSERT, UPDATE ou DELETE

-- Trigger para tabela produtos
DROP TRIGGER IF EXISTS backup_trigger_produtos ON public.produtos;
CREATE TRIGGER backup_trigger_produtos
    AFTER INSERT OR UPDATE OR DELETE ON public.produtos
    FOR EACH ROW
    EXECUTE FUNCTION trigger_daily_backup();

-- Trigger para tabela vendas
DROP TRIGGER IF EXISTS backup_trigger_vendas ON public.vendas;
CREATE TRIGGER backup_trigger_vendas
    AFTER INSERT OR UPDATE OR DELETE ON public.vendas
    FOR EACH ROW
    EXECUTE FUNCTION trigger_daily_backup();

-- Trigger para tabela clientes
DROP TRIGGER IF EXISTS backup_trigger_clientes ON public.clientes;
CREATE TRIGGER backup_trigger_clientes
    AFTER INSERT OR UPDATE OR DELETE ON public.clientes
    FOR EACH ROW
    EXECUTE FUNCTION trigger_daily_backup();

-- =============================================
-- OPÇÃO 2: BACKUP MANUAL VIA FRONTEND
-- =============================================
-- O sistema já possui funções RPC que podem ser chamadas pelo frontend:
-- 1. export_user_data_json() - Exporta dados para JSON
-- 2. save_backup_to_database() - Salva backup no banco
-- 3. list_user_backups() - Lista backups disponíveis

-- Você pode criar um botão no frontend para executar backup manual
-- Ou adicionar um timer JavaScript para executar backup periodicamente

-- =============================================
-- OPÇÃO 3: BACKUP VIA GITHUB ACTIONS (Recomendado)
-- =============================================
-- Crie um arquivo .github/workflows/backup.yml no seu repositório

-- Exemplo de conteúdo para GitHub Actions:
/*
name: Backup Diário Supabase

on:
  schedule:
    - cron: '0 2 * * *'  # Todos os dias às 2:00 AM UTC
  workflow_dispatch:  # Permite execução manual

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - name: Execute Backup
        run: |
          curl -X POST 'https://kmcaaqetxtwkdcczdomw.supabase.co/rest/v1/rpc/save_backup_to_database' \
            -H "apikey: ${{ secrets.SUPABASE_KEY }}" \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_KEY }}" \
            -H "Content-Type: application/json"
*/

-- =============================================
-- OPÇÃO 4: BACKUP VIA EDGE FUNCTION
-- =============================================
-- Crie uma Edge Function no Supabase que executa o backup
-- Depois use um serviço externo (como cron-job.org) para chamar a função periodicamente

-- Comando para criar Edge Function:
-- supabase functions new daily-backup

-- Conteúdo da função (TypeScript):
/*
import { createClient } from '@supabase/supabase-js'

Deno.serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  const { data, error } = await supabaseClient.rpc('daily_backup_all_users')

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    })
  }

  return new Response(JSON.stringify({ success: true, message: 'Backup concluído' }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
*/

-- =============================================
-- VERIFICAR SE OS TRIGGERS FORAM CRIADOS
-- =============================================
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name LIKE 'backup_trigger_%';

-- =============================================
-- TESTAR BACKUP MANUAL
-- =============================================
-- Execute este comando para criar um backup manualmente
SELECT public.save_backup_to_database();

-- Verificar se o backup foi criado
SELECT 
    user_id,
    backup_date,
    created_at,
    pg_size_pretty(pg_column_size(backup_data)::bigint) as tamanho
FROM user_backups
WHERE backup_date = CURRENT_DATE
ORDER BY created_at DESC;

-- =============================================
-- LIMPAR BACKUPS ANTIGOS MANUALMENTE
-- =============================================
-- Execute este comando periodicamente para manter apenas backups recentes
DELETE FROM user_backups
WHERE created_at < NOW() - INTERVAL '30 days';

-- =============================================
-- RESUMO DAS SOLUÇÕES
-- =============================================

-- SOLUÇÃO 1 (IMPLEMENTADA): Triggers automáticos
-- Pros: Automático, funciona em qualquer plano, sem custo extra
-- Contras: Backup só acontece quando houver alteração nos dados

-- SOLUÇÃO 2: Backup manual via frontend
-- Pros: Controle total, funciona offline
-- Contras: Depende do usuário lembrar de fazer backup

-- SOLUÇÃO 3 (RECOMENDADA): GitHub Actions
-- Pros: Totalmente automático, independente do Supabase, gratuito
-- Contras: Requer configuração no GitHub

-- SOLUÇÃO 4: Edge Function + Cron externo
-- Pros: Flexível, profissional
-- Contras: Requer configuração adicional

-- =============================================
-- RESULTADO
-- =============================================
SELECT 'BACKUP AUTOMÁTICO CONFIGURADO COM SUCESSO!' as resultado;

-- Verificar triggers criados
SELECT 
    trigger_name,
    event_object_table,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name LIKE 'backup_trigger_%';

-- Informações importantes:
-- 1. Triggers criados nas tabelas: produtos, vendas, clientes
-- 2. Backup executado automaticamente quando houver alterações
-- 3. Limite de 1 backup por dia por usuário
-- 4. Backups armazenados na tabela user_backups
-- 5. Funções RPC disponíveis para backup manual

-- Próximos passos:
-- 1. Teste modificando um produto, venda ou cliente
-- 2. Verifique: SELECT * FROM user_backups WHERE backup_date = CURRENT_DATE;
-- 3. Configure GitHub Actions para backup diário (opcional)

-- Recursos disponíveis:
-- Função de backup: public.save_backup_to_database()
-- Função de exportação: public.export_user_data_json()
-- Função de restauração: public.restore_from_database_backup(backup_id)
