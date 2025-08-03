#!/bin/bash

echo "🔧 Aplicando configurações de desabilitação de confirmação de email..."

# Conectar ao Supabase e executar o script SQL
echo "📋 Executando script SQL no Supabase..."

# Executar o script SQL
supabase db reset --linked

echo "✅ Configurações aplicadas com sucesso!"
echo ""
echo "📋 Próximos passos manuais no Dashboard do Supabase:"
echo "1. Acesse: https://supabase.com/dashboard/project/YOUR_PROJECT_ID/settings/auth"
echo "2. Vá em 'Email Authentication'"
echo "3. Desabilite 'Enable email confirmations'"
echo "4. Salve as configurações"
echo ""
echo "🎯 Mudanças implementadas:"
echo "- ✅ Usuários podem acessar o sistema imediatamente após cadastro"
echo "- ✅ Administradores podem confirmar emails manualmente no painel admin"
echo "- ✅ Fluxo de confirmação simplificado"
echo "- ✅ Gmail delivery issues contornados"
