-- ============================================
-- TESTE: Inserir ordem com campos problemáticos
-- ============================================

-- Deletar ordem de teste se existir
DELETE FROM ordens_servico WHERE numero_os = 'OS-TESTE-DEBUG';

-- Inserir ordem de teste com TODOS os campos
INSERT INTO ordens_servico (
  numero_os,
  cliente_id,
  usuario_id,
  tipo,
  marca,
  modelo,
  cor,
  numero_serie,
  senha_aparelho,
  checklist,
  defeito_relatado,
  descricao_problema,
  equipamento,
  status,
  valor_orcamento
) VALUES (
  'OS-TESTE-DEBUG',
  (SELECT id FROM clientes WHERE nome ILIKE '%cristiano%' LIMIT 1),
  (SELECT id FROM auth.users WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1),
  'Celular',
  'Samsung',
  'Galaxy S23',
  'Azul',
  '123456789012345',
  '{"tipo":"pin","valor":"1234"}'::jsonb,
  '{"item_teste":true}'::jsonb,
  'Tela quebrada',
  'Tela quebrada',
  'Celular Samsung Galaxy S23',
  'Em análise',
  100.00
) RETURNING *;

-- Verificar se foi inserido corretamente
SELECT 
  numero_os,
  marca,
  modelo,
  cor,
  numero_serie,
  senha_aparelho,
  checklist,
  created_at
FROM ordens_servico
WHERE numero_os = 'OS-TESTE-DEBUG';
