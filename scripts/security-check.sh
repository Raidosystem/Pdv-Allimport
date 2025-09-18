#!/bin/bash
# Script de Verificação de Segurança - PDV AllImport
# Execute após rotacionar todas as chaves

echo "🔒 VERIFICAÇÃO DE SEGURANÇA - PDV ALLIMPORT"
echo "==========================================="
echo ""

# 1. Verificar se não há arquivos .env versionados
echo "1️⃣ Verificando arquivos .env versionados..."
if git ls-files | grep -E "\.env(\.|$)" | grep -v "\.env\.example"; then
    echo "❌ ERRO: Arquivos .env encontrados no Git!"
    echo "Execute: git rm -f .env* && git commit -m 'remove env files'"
    exit 1
else
    echo "✅ Nenhum arquivo .env versionado"
fi

# 2. Verificar .gitignore
echo ""
echo "2️⃣ Verificando .gitignore..."
if grep -q "\.env" .gitignore && grep -q "\.env\.\*" .gitignore; then
    echo "✅ .gitignore configurado corretamente"
else
    echo "❌ ERRO: .gitignore não está protegendo arquivos .env"
    echo "Adicione: .env e .env.* ao .gitignore"
    exit 1
fi

# 3. Verificar variáveis de ambiente no código
echo ""
echo "3️⃣ Verificando se SERVICE_ROLE_KEY não está no frontend..."
if grep -r "VITE_SUPABASE_SERVICE_ROLE_KEY" src/ 2>/dev/null; then
    echo "❌ ERRO: SERVICE_ROLE_KEY encontrada no frontend!"
    echo "SERVICE_ROLE_KEY deve estar apenas em api/ (backend)"
    exit 1
else
    echo "✅ SERVICE_ROLE_KEY não encontrada no frontend"
fi

# 4. Verificar se há hardcoded secrets
echo ""
echo "4️⃣ Verificando secrets hardcoded..."
if grep -r -E "(eyJ|APP_USR-|sk_|pk_)" --include="*.ts" --include="*.js" --include="*.tsx" src/ api/ 2>/dev/null; then
    echo "❌ ERRO: Possíveis secrets hardcoded encontrados!"
    exit 1
else
    echo "✅ Nenhum secret hardcoded encontrado"
fi

# 5. Verificar estrutura de segurança
echo ""
echo "5️⃣ Verificando estrutura de segurança..."

# Webhook seguro existe?
if [ -f "api/webhooks/mercadopago-secure.ts" ]; then
    echo "✅ Webhook seguro implementado"
else
    echo "⚠️ Webhook seguro não encontrado"
fi

# Documentação de emergência existe?
if [ -f "EMERGENCIA_SEGURANCA.md" ]; then
    echo "✅ Documentação de emergência presente"
else
    echo "❌ Documentação de emergência não encontrada"
fi

echo ""
echo "🎯 CHECKLIST DE ROTAÇÃO DE CHAVES:"
echo "=================================="
echo ""
echo "Supabase (https://supabase.com/dashboard):"
echo "  [ ] anon key rotacionada"
echo "  [ ] service_role key rotacionada"
echo "  [ ] JWT secret rotacionado (opcional)"
echo ""
echo "MercadoPago (https://www.mercadopago.com.br/developers/panel):"
echo "  [ ] Access Token rotacionado"
echo "  [ ] Public Key atualizada"
echo "  [ ] Webhook Secret rotacionado"
echo ""
echo "Vercel (https://vercel.com/raidosystem/pdv-allimport/settings/environment-variables):"
echo "  [ ] Variáveis antigas deletadas"
echo "  [ ] Novas variáveis configuradas"
echo "  [ ] Redeploy realizado"
echo ""
echo "GitHub (https://github.com/Raidosystem/Pdv-Allimport/settings/security_analysis):"
echo "  [ ] Secret scanning ativado"
echo "  [ ] Push Protection ativado"
echo ""
echo "🚨 IMPORTANTE: Teste o sistema após rotacionar todas as chaves!"
echo "🚨 URL do sistema: https://pdv.crmvsystem.com"
echo ""
echo "✅ Verificação de segurança concluída!"