-- SCRIPT PARA CORRIGIR NOMES DE TABELAS NO SERVIÇO DE RELATÓRIOS

-- Este arquivo documenta as correções necessárias no realReportsService.ts:

/*
CORREÇÕES NECESSÁRIAS NO ARQUIVO src/services/realReportsService.ts:

1. Substituir TODAS as ocorrências:
   - 'ordens_servico' → 'service_orders'
   - 'produtos' → 'products' 
   - 'nome' → 'name'
   - 'equipamento' → 'equipment'
   - 'valor_total' → 'total_amount'
   - 'cliente_id' → 'customer_id'
   - 'criado_em' → 'created_at'

2. Campos específicos das tabelas:
   
   TABELA customers:
   - name (não 'nome')
   - created_at (não 'criado_em')
   
   TABELA products:
   - name (não 'nome')
   - category (não 'categoria')
   
   TABELA sales:
   - total_amount (não 'valor_total')
   - customer_id (não 'cliente_id')
   - payment_method (não 'metodo_pagamento')
   
   TABELA sale_items:
   - product_id (não 'produto_id')
   - quantity (não 'quantidade')
   - unit_price (não 'preco_unitario')
   - total_price (não 'subtotal')
   
   TABELA service_orders:
   - customer_id (não 'cliente_id')
   - equipment (não 'equipamento')
   - total_amount (não 'valor_total')

3. Verificar queries complexas:
   - JOINs entre tabelas
   - Agregações (SUM, COUNT, AVG)
   - Filtros por data
   - Ordenação

AÇÃO NECESSÁRIA:
Fazer busca e substituição global no arquivo realReportsService.ts
*/

-- Para verificar se as tabelas existem com nomes corretos:
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('customers', 'products', 'sales', 'sale_items', 'service_orders')
ORDER BY table_name;

-- Para verificar colunas de cada tabela:
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name IN ('customers', 'products', 'sales', 'sale_items', 'service_orders')
ORDER BY table_name, ordinal_position;