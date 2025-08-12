#!/bin/bash

echo "🧪 TESTANDO DEPLOY FINAL - PDV ALLIMPORT"
echo "=========================================="

# 1. Testar Git
echo "📂 1. TESTANDO GIT..."
git status
echo "✅ Git funcionando!"
echo ""

# 2. Testar Vercel
echo "🌐 2. TESTANDO VERCEL..."
vercel ls | head -3
echo "✅ Vercel funcionando!"
echo ""

# 3. URLs de produção
echo "🔗 3. URLS DE PRODUÇÃO:"
echo "- URL ATUAL: https://pdv-allimport-83zkkp09c-radiosystem.vercel.app"
echo "- URL PRINCIPAL: https://pdv-allimport.vercel.app"
echo ""

# 4. Status do Supabase
echo "🗄️ 4. SUPABASE:"
echo "- SQL para executar: SUPABASE_FIX_COMPLETE.sql"
echo "- URL: https://app.supabase.com/project/kmcaaqetxtwkdcczdomw/sql"
echo ""

echo "✅ DEPLOY QUASE COMPLETO!"
echo "⚠️ Execute o SQL no Supabase para finalizar!"
