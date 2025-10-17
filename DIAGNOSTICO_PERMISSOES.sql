-- ============================================
-- DIAGNÓSTICO COMPLETO - Por que permissões não são atribuídas?
-- ============================================

-- 1. Verificar estrutura da tabela funcao_permissoes
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcao_permissoes'
ORDER BY ordinal_position;

-- 2. Verificar constraints (especialmente primary key)
SELECT
  con.conname AS constraint_name,
  con.contype AS constraint_type,
  pg_get_constraintdef(con.oid) AS definition
FROM pg_constraint con
JOIN pg_class rel ON rel.oid = con.conrelid
WHERE rel.relname = 'funcao_permissoes';

-- 3. Contar permissões no catálogo
SELECT COUNT(*) as total_permissoes_catalogo FROM permissoes;

-- 4. Contar funções Administrador
SELECT COUNT(*) as total_funcoes_admin 
FROM funcoes 
WHERE nome = 'Administrador';

-- 5. Tentar inserir UMA permissão manualmente
DO $$
DECLARE
  v_funcao_id uuid;
  v_permissao_id uuid;
BEGIN
  -- Pegar primeira função
  SELECT id INTO v_funcao_id 
  FROM funcoes 
  WHERE nome = 'Administrador' 
  LIMIT 1;
  
  -- Pegar primeira permissão
  SELECT id INTO v_permissao_id 
  FROM permissoes 
  LIMIT 1;
  
  RAISE NOTICE 'Tentando inserir:';
  RAISE NOTICE '  funcao_id: %', v_funcao_id;
  RAISE NOTICE '  permissao_id: %', v_permissao_id;
  
  -- Tentar inserir
  BEGIN
    INSERT INTO funcao_permissoes (funcao_id, permissao_id)
    VALUES (v_funcao_id, v_permissao_id);
    
    RAISE NOTICE '✅ INSERT bem sucedido!';
    
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro no INSERT: %', SQLERRM;
    RAISE NOTICE '   SQLSTATE: %', SQLSTATE;
  END;
END $$;

-- 6. Verificar se a permissão foi inserida
SELECT 
  COUNT(*) as total_apos_insert,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ INSERT FUNCIONOU'
    ELSE '❌ INSERT FALHOU'
  END as status
FROM funcao_permissoes;

-- 7. Se inseriu, listar
SELECT 
  func.nome as funcao,
  p.recurso,
  p.acao
FROM funcao_permissoes fp
JOIN funcoes func ON func.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
LIMIT 5;

-- 8. Verificar RLS (Row Level Security)
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'funcao_permissoes';

-- 9. Listar políticas RLS
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'funcao_permissoes';
