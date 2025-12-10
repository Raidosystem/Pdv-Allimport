-- ============================================
-- DEBUG: Verificar colunas da tabela ordens_servico
-- ============================================

-- 1. Ver todas as colunas da tabela
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'ordens_servico'
  AND column_name IN ('cor', 'numero_serie', 'senha_aparelho', 'checklist')
ORDER BY ordinal_position;

-- 2. Verificar se as colunas existem
SELECT 
  EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'cor') as cor_existe,
  EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'numero_serie') as numero_serie_existe,
  EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'senha_aparelho') as senha_aparelho_existe,
  EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'ordens_servico' AND column_name = 'checklist') as checklist_existe;

-- 3. Ver os dados da última ordem criada (OS-20251026-002)
SELECT 
  id,
  numero_os,
  tipo,
  marca,
  modelo,
  cor,
  numero_serie,
  senha_aparelho,
  checklist,
  created_at
FROM ordens_servico
WHERE numero_os = 'OS-20251026-002';

-- 4. Tentar atualizar manualmente para testar
-- DESCOMENTE PARA TESTAR:
-- UPDATE ordens_servico
-- SET 
--   cor = 'Azul',
--   numero_serie = '123456789012345',
--   senha_aparelho = '{"tipo":"pin","valor":"1234"}'::jsonb
-- WHERE numero_os = 'OS-20251026-002';

-- 5. Verificar políticas RLS que podem estar bloqueando INSERT
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
WHERE tablename = 'ordens_servico'
  AND cmd IN ('INSERT', 'ALL');
