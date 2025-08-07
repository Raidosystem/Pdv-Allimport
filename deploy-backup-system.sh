#!/bin/bash

# Deploy do Sistema de Backup e Privacidade - PDV Allimport
# Este script executa todas as configurações necessárias no Supabase

echo "🔐 DEPLOY: Sistema de Privacidade Total + Backup Automático"
echo "============================================================"

# Verificar se temos as variáveis de ambiente necessárias
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Erro: Variáveis de ambiente SUPABASE_URL e SUPABASE_ANON_KEY são necessárias"
    echo "Configure-as no arquivo .env ou .env.local"
    exit 1
fi

echo "✅ Variáveis de ambiente configuradas"
echo "📦 Supabase URL: $SUPABASE_URL"

# Verificar se o arquivo SQL existe
if [ ! -f "create-missing-tables.sql" ]; then
    echo "❌ Erro: Arquivo create-missing-tables.sql não encontrado"
    exit 1
fi

echo "✅ Arquivo SQL encontrado"

# Instruções para execução manual
echo ""
echo "📋 INSTRUÇÕES PARA DEPLOY MANUAL:"
echo "=================================="
echo ""
echo "1. Acesse o Supabase Dashboard:"
echo "   https://supabase.com/dashboard/project/[SEU_PROJECT_ID]"
echo ""
echo "2. Vá para 'SQL Editor' no menu lateral"
echo ""
echo "3. Copie e cole o conteúdo do arquivo: create-missing-tables.sql"
echo ""
echo "4. Execute o script clicando em 'Run'"
echo ""
echo "5. Aguarde a execução completa (pode demorar alguns minutos)"
echo ""
echo "6. Para habilitar backup automático, execute também:"
echo "   SELECT cron.schedule('daily-user-backup', '0 2 * * *', 'SELECT public.daily_backup_all_users();');"
echo ""

# Mostrar resumo do que será criado
echo "🔧 O QUE SERÁ CRIADO/CONFIGURADO:"
echo "================================="
echo "✅ Tabelas com isolamento por usuário (RLS)"
echo "✅ Políticas de segurança (cada usuário vê apenas seus dados)"
echo "✅ Triggers automáticos para user_id"
echo "✅ Sistema de backup no banco de dados"
echo "✅ Funções para exportar/importar JSON"
echo "✅ Backup automático diário (via pg_cron)"
echo "✅ Limpeza automática de backups antigos (30 dias)"
echo "✅ Permissões para usuários autenticados"
echo ""

# Mostrar tabelas que serão afetadas
echo "📊 TABELAS COM PRIVACIDADE TOTAL:"
echo "================================"
echo "• categorias"
echo "• produtos" 
echo "• clientes"
echo "• vendas"
echo "• itens_venda"
echo "• caixa"
echo "• movimentacoes_caixa"
echo "• configuracoes"
echo "• user_backups (nova)"
echo ""

# Mostrar funções que serão criadas
echo "⚙️ FUNÇÕES DE BACKUP CRIADAS:"
echo "============================"
echo "• create_user_backup_data() - Criar dados de backup"
echo "• save_backup_to_database() - Salvar backup no banco"
echo "• restore_from_backup_data() - Restaurar de backup"
echo "• export_user_data_json() - Exportar para JSON"
echo "• import_user_data_json() - Importar de JSON"
echo "• list_user_backups() - Listar backups"
echo "• restore_from_database_backup() - Restaurar backup específico"
echo "• daily_backup_all_users() - Backup diário automático"
echo ""

echo "🚨 IMPORTANTE:"
echo "============="
echo "• Este deploy irá habilitar RLS em todas as tabelas"
echo "• Cada usuário verá apenas seus próprios dados"
echo "• Dados existentes serão mantidos mas isolados por usuário"
echo "• Backup automático será configurado para rodar às 2:00 AM"
echo "• Backups são mantidos por 30 dias automaticamente"
echo ""

echo "✨ APÓS O DEPLOY:"
echo "================"
echo "• Teste o login no sistema"
echo "• Verifique se os dados aparecem corretamente"
echo "• Teste a funcionalidade de backup no frontend"
echo "• Monitore os logs de backup automático"
echo ""

echo "📱 COMPONENTE FRONTEND:"
echo "======================"
echo "• Componente BackupManager.tsx criado"
echo "• Hook useBackup.ts implementado"
echo "• Adicione <BackupManager /> na sua aplicação"
echo ""

echo "🔄 Para verificar se está funcionando:"
echo "====================================="
echo "SELECT 'Backup funcionando!' as status, NOW() as timestamp;"
echo ""

echo "🎯 Deploy ready! Execute o SQL no Supabase Dashboard para ativar."
