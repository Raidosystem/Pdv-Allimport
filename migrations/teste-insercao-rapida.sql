-- 🧪 Teste rápido de inserção na tabela ordens_servico
-- Execute no SQL Editor do Supabase para testar se a inserção funciona

-- Primeiro, vamos ver se temos clientes para usar como teste
SELECT id, nome, telefone FROM clientes LIMIT 3;

-- Agora vamos tentar inserir uma ordem de serviço de teste simples
INSERT INTO ordens_servico (
  numero_os,
  cliente_id,
  tipo,
  marca,
  modelo,
  defeito_relatado,
  descricao_problema,
  equipamento,
  status,
  usuario_id
) VALUES (
  'TEST-QUICK-' || extract(epoch from now())::text,
  (SELECT id FROM clientes ORDER BY created_at DESC LIMIT 1),
  'Celular',
  'Samsung',
  'Galaxy A10',
  'Não liga',
  'Não liga',
  'Celular Samsung Galaxy A10',
  'Aberta',
  auth.uid()
) RETURNING *;

-- Verificar se funcionou
SELECT COUNT(*) as total_ordens FROM ordens_servico;