-- Verificar estrutura das tabelas do sistema de permissões
SELECT 
  table_name,
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name IN ('permissoes', 'funcoes', 'funcao_permissoes', 'funcionarios')
  AND table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- Ver exemplos da tabela permissoes
SELECT * FROM permissoes LIMIT 5;

-- Ver exemplos da tabela funcoes
SELECT * FROM funcoes LIMIT 5;

-- Ver exemplos da tabela funcao_permissoes
SELECT * FROM funcao_permissoes LIMIT 5;
