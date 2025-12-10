-- 🚨 DIAGNÓSTICO ERRO 500 NA TABELA FUNCIONARIOS

-- 1. Verificar se a tabela existe
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'funcionarios'
) as tabela_existe;

-- 2. Verificar estrutura da tabela
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'funcionarios'
ORDER BY ordinal_position;

-- 3. Verificar constraints e foreign keys
SELECT
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'funcionarios'
ORDER BY tc.constraint_type, tc.constraint_name;

-- 4. Verificar políticas RLS
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'funcionarios'
ORDER BY policyname;

-- 5. Verificar se RLS está habilitado
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename = 'funcionarios';

-- 6. Tentar query simples
SELECT COUNT(*) as total_funcionarios FROM funcionarios;

-- 7. Verificar se existe funcao_id nula ou inválida
SELECT 
  id,
  nome,
  funcao_id,
  user_id,
  empresa_id,
  tipo_admin
FROM funcionarios
WHERE funcao_id IS NULL OR funcao_id NOT IN (SELECT id FROM funcoes);

-- 8. Verificar relacionamento com funcoes
SELECT 
  f.id,
  f.nome,
  f.funcao_id,
  fc.nome as funcao_nome
FROM funcionarios f
LEFT JOIN funcoes fc ON fc.id = f.funcao_id
LIMIT 5;
