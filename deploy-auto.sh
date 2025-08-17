#!/bin/bash

# Script de Deploy Automático - PDV Allimport
# Garante que o deploy seja feito corretamente e sem cache

echo "🚀 Iniciando deploy do PDV Allimport..."

# 1. Limpar cache local
echo "🧹 Limpando cache local..."
rm -rf dist/
rm -rf node_modules/.vite/
rm -rf .vercel/

# 2. Fazer build fresh
echo "🔨 Fazendo build fresh..."
npm run build

if [ $? -ne 0 ]; then
    echo "❌ Erro no build! Parando deploy."
    exit 1
fi

# 3. Fazer commit das mudanças
echo "📝 Fazendo commit..."
git add .
git commit -m "🚀 Deploy: $(date +'%Y-%m-%d %H:%M:%S')"
git push

# 4. Deploy no Vercel
echo "☁️ Fazendo deploy no Vercel..."
npx vercel --prod

if [ $? -ne 0 ]; then
    echo "❌ Erro no deploy! Verificar configurações."
    exit 1
fi

# 5. Obter URL do último deploy
LATEST_URL=$(npx vercel ls --json | jq -r '.[0].url' | sed 's/^/https:\/\//')

echo "🔄 Configurando alias para URL principal..."
npx vercel alias "$LATEST_URL" pdv-allimport.vercel.app

echo "✅ Deploy concluído com sucesso!"
echo "🌐 URL Principal: https://pdv-allimport.vercel.app"
echo "🔗 URL Específica: $LATEST_URL"
echo ""
echo "📱 Teste o PWA em: https://pdv-allimport.vercel.app"
echo "🔍 Pressione Ctrl+F5 para forçar reload do cache"
