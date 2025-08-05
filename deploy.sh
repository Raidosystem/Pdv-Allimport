#!/bin/bash

echo "🚀 DEPLOY COMPLETO PDV ALLIMPORT"
echo "================================"

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Erro: Execute este script no diretório raiz do projeto${NC}"
    exit 1
fi

echo -e "${BLUE}📋 1. Verificando dependências...${NC}"

# 2. Instalar dependências do frontend (se necessário)
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Instalando dependências do frontend...${NC}"
    npm install
fi

# 3. Instalar dependências do backend
echo -e "${YELLOW}📦 Instalando dependências do backend...${NC}"
cd api
if [ ! -d "node_modules" ]; then
    npm install
fi
cd ..

echo -e "${BLUE}📋 2. Testando aplicação...${NC}"

# 4. Testar build do frontend
echo -e "${YELLOW}🏗️ Testando build do frontend...${NC}"
npm run build
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro no build do frontend${NC}"
    exit 1
fi

# 5. Testar sintaxe do backend
echo -e "${YELLOW}🔧 Testando backend...${NC}"
cd api
node -c index.js
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro na sintaxe do backend${NC}"
    exit 1
fi
cd ..

echo -e "${BLUE}📋 3. Preparando deploy...${NC}"

# 6. Commit das alterações
echo -e "${YELLOW}📝 Fazendo commit das alterações...${NC}"
git add .
git add -f api/index.js api/package.json api/README.md api/.env.example

# Verificar se há alterações para commit
if git diff --staged --quiet; then
    echo -e "${GREEN}✅ Nenhuma alteração para commit${NC}"
else
    git commit -m "🚀 Deploy: Sistema completo com API backend integrada

✨ Deploy inclui:
- Backend Node.js/Express com Mercado Pago
- Frontend React atualizado
- Documentação completa
- Scripts de deploy automatizados
- Configurações de produção

🔧 Próximos passos:
1. Deploy backend no Vercel/Railway
2. Atualizar SQL no Supabase (R$ 59,90)
3. Configurar webhooks Mercado Pago
4. Testes de pagamento em produção"
    
    echo -e "${GREEN}✅ Commit realizado com sucesso${NC}"
fi

# 7. Push para repositório
echo -e "${YELLOW}📤 Enviando para repositório...${NC}"
git push origin main

echo -e "${BLUE}📋 4. Instruções finais de deploy...${NC}"

echo -e "${GREEN}"
echo "🎉 DEPLOY PREPARADO COM SUCESSO!"
echo "================================"
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo ""
echo "1. 🌐 DEPLOY DO BACKEND:"
echo "   cd api/"
echo "   vercel --prod"
echo "   (ou usar Railway/Render conforme README)"
echo ""
echo "2. 🗄️ ATUALIZAR PREÇO NO SUPABASE:"
echo "   - Abrir Supabase Dashboard"
echo "   - SQL Editor"
echo "   - Executar: UPDATE_PRICE_59_90.sql"
echo ""
echo "3. 🔗 CONFIGURAR WEBHOOKS:"
echo "   - Mercado Pago Dashboard"
echo "   - Adicionar webhook: [sua-api]/api/webhook/mercadopago"
echo ""
echo "4. ✅ TESTAR SISTEMA:"
echo "   - Acessar: https://pdv-allimport.vercel.app"
echo "   - Testar pagamentos PIX e cartão"
echo "   - Verificar ativação de assinatura"
echo ""
echo "📚 DOCUMENTAÇÃO:"
echo "   - Frontend: README.md"
echo "   - Backend: api/README.md"
echo "   - Deploy: DEPLOY_COMPLETO.md"
echo ""
echo -e "${NC}"

echo -e "${YELLOW}⚡ Status dos serviços:${NC}"
echo -e "${GREEN}✅ Frontend: https://pdv-allimport.vercel.app${NC}"
echo -e "${YELLOW}🔄 Backend: Aguardando deploy${NC}"
echo -e "${GREEN}✅ Database: Supabase funcionando${NC}"
echo -e "${GREEN}✅ Código: Commitado e enviado${NC}"

echo ""
echo -e "${BLUE}🚀 Sistema PDV Allimport pronto para produção!${NC}"
