#!/bin/bash

# Deploy Completo PDV Allimport
# Este script faz o deploy completo: Git → Vercel → Supabase

echo "🚀 INICIANDO DEPLOY COMPLETO PDV ALLIMPORT"
echo "=========================================="

# Verificar se está na branch correta
current_branch=$(git branch --show-current)
echo "📍 Branch atual: $current_branch"

# Verificar se há alterações não commitadas
if [[ -n $(git status --porcelain) ]]; then
    echo "⚠️  Há alterações não commitadas. Fazendo commit..."
    
    # Adicionar todas as alterações
    git add .
    
    # Pedir mensagem de commit ou usar padrão
    read -p "💬 Digite a mensagem do commit (ou Enter para padrão): " commit_msg
    if [[ -z "$commit_msg" ]]; then
        commit_msg="deploy: atualizações do sistema $(date '+%d/%m/%Y %H:%M')"
    fi
    
    git commit -m "$commit_msg"
    echo "✅ Commit realizado: $commit_msg"
else
    echo "✅ Não há alterações para committar"
fi

# Push para GitHub
echo ""
echo "📤 ENVIANDO PARA GITHUB..."
git push origin $current_branch
if [[ $? -eq 0 ]]; then
    echo "✅ Push para GitHub concluído"
else
    echo "❌ Erro no push para GitHub"
    exit 1
fi

# Build local
echo ""
echo "🏗️  FAZENDO BUILD LOCAL..."
npm run build
if [[ $? -eq 0 ]]; then
    echo "✅ Build local concluído"
else
    echo "❌ Erro no build local"
    exit 1
fi

# Deploy Vercel
echo ""
echo "☁️  FAZENDO DEPLOY NO VERCEL..."
npx vercel --prod
if [[ $? -eq 0 ]]; then
    echo "✅ Deploy Vercel concluído"
else
    echo "❌ Erro no deploy Vercel"
    exit 1
fi

# Verificar status Supabase
echo ""
echo "🗄️  VERIFICANDO SUPABASE..."
if [[ -f "deploy-supabase-status.sh" ]]; then
    chmod +x deploy-supabase-status.sh
    ./deploy-supabase-status.sh
else
    echo "⚠️  Script de status Supabase não encontrado"
fi

# Teste de saúde da API
echo ""
echo "🩺 TESTANDO SAÚDE DA API..."
sleep 5  # Aguardar deploy propagar
health_response=$(curl -s https://pdv-allimport.vercel.app/api/health)
if [[ $health_response == *"OK"* ]]; then
    echo "✅ API funcionando corretamente"
    echo "📊 Status: $health_response"
else
    echo "⚠️  API pode não estar respondendo corretamente"
    echo "📊 Resposta: $health_response"
fi

# Resumo final
echo ""
echo "🎉 DEPLOY COMPLETO FINALIZADO!"
echo "=============================="
echo "🌐 URL Principal: https://pdv-allimport.vercel.app"
echo "🔄 URLs Alternativas:"
echo "   - https://pdv-allimport-radiosystem.vercel.app"
echo "   - https://pdv-allimport-raidosystem-radiosystem.vercel.app"
echo ""
echo "🗄️  Supabase: https://kmcaaqetxtwkdcczdomw.supabase.co"
echo "📊 Dashboard: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw"
echo ""
echo "✅ Sistema PDV Allimport deployado com sucesso!"
echo "🎯 Contador de dias da assinatura atualizado e funcionando"
