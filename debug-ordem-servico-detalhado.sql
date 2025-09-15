-- 🔍 Debug: Verificação da estrutura da tabela ordens_servico
-- Executar linha por linha no SQL Editor do Supabase

-- 1. Verificar se a tabela existe e sua estrutura
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'ordens_servico' 
ORDER BY ordinal_position;

-- 2. Verificar triggers e constraints
SELECT trigger_name, event_manipulation, action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'ordens_servico';

-- 3. Verificar RLS (Row Level Security)
SELECT schemaname, tablename, rowsecurity, enablerls
FROM pg_tables 
WHERE tablename = 'ordens_servico';

-- 4. Verificar políticas RLS
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'ordens_servico';

-- 5. Testar inserção manual (usar dados reais de teste)
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
  'TEST-' || to_char(now(), 'YYYYMMDD-HH24MISS'),
  (SELECT id FROM clientes LIMIT 1), -- Pegar um cliente existente
  'Celular',
  'Samsung',
  'Galaxy S21',
  'Tela quebrada',
  'Tela quebrada',
  'Celular Samsung Galaxy S21',
  'Aberta',
  auth.uid()
);

-- 6. Verificar se foi inserido
SELECT * FROM ordens_servico 
WHERE numero_os LIKE 'TEST-%' 
ORDER BY created_at DESC 
LIMIT 1;