-- =====================================
-- TESTE: VERIFICAR ESTRUTURA DE PERMISSÕES
-- =====================================

-- 1. Ver todas as funções da empresa
SELECT 
  f.id as funcao_id,
  f.nome as funcao_nome,
  f.empresa_id
FROM funcoes f
ORDER BY f.nome;

-- 2. Ver funcao_permissoes com JOIN em permissoes
SELECT 
  fp.funcao_id,
  f.nome as funcao_nome,
  fp.permissao_id,
  p.recurso,
  p.acao,
  p.descricao,
  fp.empresa_id
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
ORDER BY f.nome, p.recurso, p.acao;

-- 3. Ver total de permissões por função
SELECT 
  f.id,
  f.nome,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
GROUP BY f.id, f.nome
ORDER BY f.nome;

-- 4. Testar estrutura da query do Supabase (formato esperado)
-- Esta seria a query correta no PostgreSQL que simula o que o Supabase deveria retornar
SELECT 
  f.id,
  f.nome,
  f.escopo_lojas,
  json_agg(
    json_build_object(
      'funcao_id', fp.funcao_id,
      'permissao_id', fp.permissao_id,
      'permissoes', json_build_object(
        'id', p.id,
        'recurso', p.recurso,
        'acao', p.acao,
        'descricao', p.descricao
      )
    )
  ) FILTER (WHERE fp.id IS NOT NULL) as funcao_permissoes
FROM funcoes f
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = f.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
GROUP BY f.id, f.nome, f.escopo_lojas
ORDER BY f.nome;
