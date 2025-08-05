#!/bin/bash
# Script de build customizado para Vercel

echo "🏗️  Iniciando build do frontend PDV Allimport..."

# Verificar se estamos na raiz do projeto
if [ ! -f "package.json" ]; then
    echo "❌ package.json não encontrado na raiz"
    exit 1
fi

# Instalar dependências apenas do frontend
echo "📦 Instalando dependências do frontend..."
npm ci

# Verificar TypeScript
echo "🔍 Verificando TypeScript..."
npm run type-check

# Build do projeto
echo "🏗️  Fazendo build do projeto..."
npm run build

echo "✅ Build concluído com sucesso!"
