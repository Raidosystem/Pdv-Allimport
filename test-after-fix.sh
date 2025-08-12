#!/bin/bash

# Teste rápido de conectividade após fix do Supabase
# Execute: ./test-after-fix.sh

echo "🔍 Testando conectividade após correção do Supabase..."
echo ""

# Testar produtos via API REST
echo "📦 Testando produtos..."
RESPONSE=$(curl -s "https://kmcaaqetxtwkdcczdomw.supabase.co/rest/v1/produtos?select=count" \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5MjU3MDksImV4cCI6MjA2OTUwMTcwOX0.gFcUOoNPESqp2PALV5CYhMceTQ4HVuf-noGn94Fzbwg" \
  -H "Prefer: count=exact")

if [[ $RESPONSE == *"permission denied"* ]]; then
  echo "❌ Ainda com erro de permissão nos produtos"
  echo "   Execute o SQL no Supabase primeiro!"
elif [[ $RESPONSE == *"count"* ]]; then
  echo "✅ Produtos acessíveis! Resposta: $RESPONSE"
else
  echo "⚠️ Resposta inesperada: $RESPONSE"
fi

echo ""
echo "🎯 Próximos passos:"
echo "1. Se viu ✅, o Supabase está conectado!"
echo "2. Teste o PDV - os produtos reais devem aparecer"
echo "3. Se ainda viu ❌, execute o SQL no Supabase"

echo ""
echo "🔗 Links úteis:"
echo "- Dashboard: https://app.supabase.com/project/kmcaaqetxtwkdcczdomw"
echo "- SQL Editor: https://app.supabase.com/project/kmcaaqetxtwkdcczdomw/sql"
echo "- PDV Local: http://localhost:5173"
