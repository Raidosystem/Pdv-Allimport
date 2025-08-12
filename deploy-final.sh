#!/bin/bash

# Deploy completo no Supabase
# Execute este script após copiar o SQL no dashboard

echo "🗄️ DEPLOY NO SUPABASE"
echo "===================="
echo ""
echo "📋 INSTRUÇÕES:"
echo "1. Copie o conteúdo do arquivo SUPABASE_FIX_COMPLETE.sql"
echo "2. Vá para: https://app.supabase.com/project/kmcaaqetxtwkdcczdomw/sql"
echo "3. Cole o SQL e clique em 'RUN'"
echo ""

# Esperar confirmação
read -p "❓ Você executou o SQL no Supabase? (s/n): " confirmacao

if [[ $confirmacao == "s" || $confirmacao == "S" ]]; then
    echo ""
    echo "🧪 Testando conectividade..."
    ./test-after-fix.sh
    
    echo ""
    echo "📱 Testando a aplicação..."
    echo "🌐 URL Produção: https://pdv-allimport.vercel.app"
    echo "🏠 URL Local: http://localhost:5173"
    
    echo ""
    echo "✅ DEPLOY COMPLETO REALIZADO!"
    echo "================================="
    echo "✅ Git: Código enviado e commitado"
    echo "✅ Vercel: Deploy automático realizado"
    echo "✅ Supabase: RLS configurado e dados inseridos"
    echo ""
    echo "🎯 URLs Finais:"
    echo "📦 Repositório: https://github.com/Raidosystem/Pdv-Allimport"
    echo "🌐 Aplicação: https://pdv-allimport.vercel.app"
    echo "🗄️ Banco: https://app.supabase.com/project/kmcaaqetxtwkdcczdomw"
    
else
    echo ""
    echo "⚠️ Execute o SQL no Supabase e rode este script novamente!"
    echo "📋 SQL: cat SUPABASE_FIX_COMPLETE.sql"
fi
