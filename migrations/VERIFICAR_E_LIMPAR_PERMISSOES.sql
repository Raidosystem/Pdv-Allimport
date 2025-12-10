-- =====================================================
-- VERIFICAR E LIMPAR PERMISSÕES DUPLICADAS/ANTIGAS
-- =====================================================

-- 1. Ver permissões SEM categoria (aparecem em "Outros")
SELECT 
  id,
  recurso,
  acao,
  descricao,
  categoria,
  created_at
FROM permissoes
WHERE categoria IS NULL
ORDER BY recurso, acao;

-- 2. Ver permissões COM categoria
SELECT 
  categoria,
  COUNT(*) as total
FROM permissoes
WHERE categoria IS NOT NULL
GROUP BY categoria
ORDER BY categoria;

-- 3. Verificar duplicatas (mesmo recurso + acao)
SELECT 
  recurso,
  acao,
  COUNT(*) as duplicatas,
  STRING_AGG(DISTINCT COALESCE(categoria, 'NULL'), ', ') as categorias
FROM permissoes
GROUP BY recurso, acao
HAVING COUNT(*) > 1
ORDER BY recurso, acao;

-- 4. Ver TODAS as permissões agrupadas
SELECT 
  COALESCE(categoria, '📋 Outros') as secao,
  COUNT(*) as total
FROM permissoes
GROUP BY categoria
ORDER BY 
  CASE 
    WHEN categoria IS NULL THEN 999
    ELSE 1
  END,
  categoria;
