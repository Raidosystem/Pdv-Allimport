#!/bin/bash

echo "🚀 Iniciando configuração do backend API..."

# Navegar para o diretório da API
cd api

echo "📦 Instalando dependências..."
npm install

echo "✅ Dependências instaladas!"

echo "🔧 Verificando configuração..."
if [ ! -f .env ]; then
    echo "❌ Arquivo .env não encontrado!"
    echo "Por favor, configure as variáveis de ambiente no arquivo api/.env"
    exit 1
fi

echo "🚀 Iniciando servidor de desenvolvimento..."
npm run dev
