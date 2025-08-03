#!/bin/bash

# Script para deploy direto no Supabase sem Docker local
# Use este script quando quiser fazer deploy sem rodar localmente

echo "🚀 Deploy direto para Supabase (sem Docker local)"
echo "----------------------------------------"

# 1. Build da aplicação
echo "📦 Fazendo build da aplicação..."
npm run build

# 2. Deploy para Vercel
echo "🌐 Fazendo deploy para Vercel..."
npm run deploy

echo "✅ Deploy concluído!"
echo "📋 Para aplicar migrações SQL:"
echo "   1. Acesse: https://supabase.com/dashboard"
echo "   2. Vá em SQL Editor"
echo "   3. Cole o conteúdo dos arquivos .sql das migrations"
echo "   4. Execute cada migration"
