#!/bin/bash

echo "🔧 Configurando URLs de redirecionamento no Supabase..."

# Adicionar as URLs corretas de redirecionamento
echo "📋 URLs que devem estar configuradas no Dashboard do Supabase:"
echo ""
echo "Authentication > Settings > Redirect URLs:"
echo "✅ https://pdv-allimport.vercel.app/confirm-email"
echo "✅ https://pdv-allimport.vercel.app/reset-password"
echo "✅ https://pdv-allimport.vercel.app/dashboard"
echo "✅ http://localhost:5174/confirm-email"
echo "✅ http://localhost:5174/reset-password" 
echo "✅ http://localhost:5174/dashboard"
echo ""

echo "Site URL:"
echo "✅ https://pdv-allimport.vercel.app"
echo ""

echo "📧 Configurações de Email que devem estar habilitadas:"
echo "✅ Enable email confirmations: ON"
echo "✅ Confirm email: ON"
echo "✅ Secure password change: ON"
echo ""

echo "🔗 Links para configuração:"
echo "Dashboard: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw"
echo "Auth Settings: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/auth/settings"
echo "Email Templates: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/auth/templates"
echo ""

echo "🧪 Para testar o fluxo:"
echo "1. Acesse: http://localhost:5174/email-flow-diagnostic"
echo "2. Execute o diagnóstico"
echo "3. Teste criando um usuário real"
echo "4. Verifique o email de confirmação"
echo "5. Clique no link e veja se redireciona corretamente"
echo ""

echo "✅ Script concluído!"
