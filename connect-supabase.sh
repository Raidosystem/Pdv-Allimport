#!/bin/bash

# Script para conectar ao Supabase e corrigir RLS
# PDV Allimport - Correção de Permissões

echo "🔧 Conectando ao Supabase para corrigir permissões..."

# Aplicar correções de RLS via SQL
echo "📝 Aplicando correções de RLS no Supabase..."

# Usando npx supabase para executar SQL
if command -v npx &> /dev/null && npx supabase --version &> /dev/null; then
    echo "✅ Supabase CLI encontrada"
    npx supabase db push
else
    echo "⚠️ Supabase CLI não encontrada. Aplique manualmente o arquivo fix-supabase-rls.sql"
fi

echo "🎯 Próximos passos:"
echo "1. Entre no dashboard do Supabase: https://app.supabase.com/project/kmcaaqetxtwkdcczdomw"
echo "2. Vá em SQL Editor"
echo "3. Execute o conteúdo do arquivo fix-supabase-rls.sql"
echo "4. Ou execute este comando:"
echo ""
echo "-- Permitir acesso público à tabela produtos"
echo "ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;"
echo ""
echo "-- Permitir acesso público à tabela categorias"  
echo "ALTER TABLE categorias DISABLE ROW LEVEL SECURITY;"
echo ""
echo "-- Permitir acesso público à tabela clientes"
echo "ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;"
