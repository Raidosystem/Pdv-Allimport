-- ============================================
-- TESTE SIMPLES - INSERIR UMA PERMISSÃO
-- ============================================

-- 1. Desabilitar RLS
ALTER TABLE funcao_permissoes DISABLE ROW LEVEL SECURITY;

-- 2. Contar registros ANTES
SELECT COUNT(*) as registros_antes FROM funcao_permissoes;

-- 3. Pegar IDs para teste
SELECT 
  'IDs para teste:' as info,
  (SELECT id FROM funcoes WHERE nome = 'Administrador' LIMIT 1) as funcao_id,
  (SELECT id FROM permissoes LIMIT 1) as permissao_id;

-- 4. Tentar inserir MANUALMENTE
INSERT INTO funcao_permissoes (funcao_id, permissao_id)
SELECT 
  (SELECT id FROM funcoes WHERE nome = 'Administrador' LIMIT 1),
  (SELECT id FROM permissoes LIMIT 1);

-- 5. Contar registros DEPOIS
SELECT COUNT(*) as registros_depois FROM funcao_permissoes;

-- 6. Ver o que foi inserido
SELECT 
  fp.*,
  func.nome as funcao_nome,
  p.recurso,
  p.acao
FROM funcao_permissoes fp
JOIN funcoes func ON func.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
LIMIT 5;

-- 7. Reabilitar RLS
ALTER TABLE funcao_permissoes ENABLE ROW LEVEL SECURITY;
