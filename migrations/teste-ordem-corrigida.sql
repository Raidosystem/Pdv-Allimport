-- ✅ Teste Final - Ordem de Serviço Corrigida
-- Execute no SQL Editor do Supabase para testar a correção

-- 1. Verificar se temos clientes para usar
SELECT id, nome, telefone FROM clientes LIMIT 3;

-- 2. Testar inserção com status corrigido
INSERT INTO ordens_servico (
  numero_os,
  cliente_id,
  tipo,
  marca,
  modelo,
  defeito_relatado,
  descricao_problema,
  equipamento,
  status, -- ✅ Agora usando 'Em análise' ao invés de 'Aberta'
  usuario_id
) VALUES (
  'TEST-FIXED-' || extract(epoch from now())::text,
  (SELECT id FROM clientes ORDER BY created_at DESC LIMIT 1),
  'Celular',
  'Samsung',
  'Galaxy A10',
  'Não liga após queda',
  'Não liga após queda',
  'Celular Samsung Galaxy A10',
  'Em análise', -- ✅ Status válido da enum
  auth.uid()
) RETURNING id, numero_os, status, created_at;

-- 3. Verificar se funcionou e quantas ordens temos
SELECT COUNT(*) as total_ordens_servico FROM ordens_servico;

-- 4. Ver as últimas 3 ordens criadas
SELECT 
  numero_os,
  status,
  tipo,
  marca,
  modelo,
  defeito_relatado,
  created_at
FROM ordens_servico 
ORDER BY created_at DESC 
LIMIT 3;