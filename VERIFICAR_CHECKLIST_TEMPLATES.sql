-- ✅ VERIFICAÇÃO DA TABELA checklist_templates

-- 1. Verificar se a tabela existe e suas colunas
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'checklist_templates'
ORDER BY ordinal_position;

-- 2. Verificar políticas RLS
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'checklist_templates';

-- 3. Verificar se RLS está habilitado
SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables 
WHERE tablename = 'checklist_templates';

-- 4. Verificar índices criados
SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'checklist_templates';

-- 5. Verificar triggers
SELECT
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'checklist_templates';

-- 6. Teste de inserção (descomentar para testar)
/*
INSERT INTO checklist_templates (usuario_id, empresa_id, items)
VALUES (
  auth.uid(), 
  auth.uid(), 
  '[
    {"id": "aparelho_liga", "label": "Aparelho liga", "ordem": 1},
    {"id": "carregamento_ok", "label": "Carregamento OK", "ordem": 2},
    {"id": "tela_ok", "label": "Tela OK", "ordem": 3}
  ]'::jsonb
);
*/

-- 7. Buscar templates do usuário (descomentar para testar)
/*
SELECT 
  id,
  usuario_id,
  jsonb_array_length(items) as total_itens,
  items,
  created_at,
  updated_at
FROM checklist_templates 
WHERE usuario_id = auth.uid();
*/
