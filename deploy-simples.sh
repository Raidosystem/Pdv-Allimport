#!/bin/bash

# Deploy Simplificado - Sistema PDV Completo
# Execute apenas o arquivo create-missing-tables.sql no Supabase

echo "🚀 DEPLOY SISTEMA PDV COMPLETO"
echo "=============================="

echo "✅ AGORA VOCÊ SÓ PRECISA EXECUTAR 1 ARQUIVO!"
echo ""
echo "📋 INSTRUÇÕES SIMPLES:"
echo "1. Acesse: https://supabase.com/dashboard/project/[SEU_PROJECT_ID]"
echo "2. Vá para 'SQL Editor'"
echo "3. Copie TODO o conteúdo do arquivo: create-missing-tables.sql"
echo "4. Cole no SQL Editor e clique 'Run'"
echo "5. Aguarde a execução (pode demorar 1-2 minutos)"
echo ""

echo "🎯 O QUE SERÁ CRIADO AUTOMATICAMENTE:"
echo "===================================="
echo "📊 9 TABELAS:"
echo "  • caixa - Controle de sessões"
echo "  • movimentacoes_caixa - Movimentações financeiras"
echo "  • configuracoes - Configurações do sistema"
echo "  • clientes - Cadastro de clientes"
echo "  • categorias - Categorias de produtos"
echo "  • produtos - Produtos do estoque"
echo "  • vendas - Vendas realizadas"
echo "  • itens_venda - Itens das vendas"
echo "  • user_backups - Backups dos usuários"
echo ""

echo "🔐 SEGURANÇA:"
echo "  • RLS habilitado em todas as tabelas"
echo "  • Cada usuário vê apenas seus dados"
echo "  • Triggers automáticos para user_id"
echo "  • Permissões configuradas"
echo ""

echo "📦 BACKUP SYSTEM:"
echo "  • 8 funções SQL para backup/restore"
echo "  • Export/import JSON"
echo "  • Backup manual e automático"
echo "  • Limpeza automática (30 dias)"
echo ""

echo "⚡ APÓS EXECUTAR O SQL:"
echo "====================="
echo "1. Para ativar backup automático, execute também:"
echo "   SELECT cron.schedule('daily-user-backup', '0 2 * * *', 'SELECT public.daily_backup_all_users();');"
echo ""
echo "2. Teste o sistema:"
echo "   • Faça login na aplicação"
echo "   • Verifique se os dados aparecem isolados"
echo "   • Teste o componente BackupManager"
echo ""

echo "✨ PRONTO! Sistema PDV com privacidade total e backup automático funcionando!"
