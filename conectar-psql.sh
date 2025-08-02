#!/bin/bash

# Configuração do Supabase
SUPABASE_URL="https://kmcaaqetxtwkdcczdomw.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg"

# Extrair informações da URL
PROJECT_REF="kmcaaqetxtwkdcczdomw"
SUPABASE_HOST="db.${PROJECT_REF}.supabase.co"
SUPABASE_PORT="5432"
SUPABASE_DB="postgres"

echo "🚀 DEPLOY DIRETO NO SUPABASE"
echo "============================"
echo ""
echo "📊 Configuração:"
echo "Host: $SUPABASE_HOST"
echo "Port: $SUPABASE_PORT"
echo "Database: $SUPABASE_DB"
echo "Project: $PROJECT_REF"
echo ""

# Tentar conectar via psql (vai pedir senha)
echo "🔐 Conectando ao Supabase..."
echo "⚠️  ATENÇÃO: Você precisará da senha do usuário postgres do Supabase"
echo "💡 Alternativa: Use o SQL Editor do Dashboard"
echo ""

# Comando psql que o usuário pode executar manualmente
echo "📋 Comando para conectar:"
echo "export PATH=\"/opt/homebrew/opt/postgresql@14/bin:\$PATH\""
echo "psql -h $SUPABASE_HOST -p $SUPABASE_PORT -U postgres -d $SUPABASE_DB"
echo ""
echo "📄 Depois execute:"
echo "\\i DEPLOY_FINAL.sql"
echo ""
echo "🌐 OU use o Dashboard:"
echo "https://supabase.com/dashboard/project/$PROJECT_REF/sql"
