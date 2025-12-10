-- =====================================================
-- VERIFICAR E CORRIGIR PERMISSÕES
-- =====================================================

-- 1. Ver quais permissões realmente existem na tabela
SELECT 
  '🔍 PERMISSÕES EXISTENTES' as info,
  recurso,
  acao,
  descricao,
  categoria
FROM permissoes
ORDER BY recurso, acao;

-- 2. Ver quantas permissões existem por categoria
SELECT 
  '📊 TOTAL POR CATEGORIA' as info,
  categoria,
  COUNT(*) as total
FROM permissoes
GROUP BY categoria
ORDER BY total DESC;

-- 3. Ver TODAS as permissões (para copiar os nomes exatos)
SELECT DISTINCT
  '📋 LISTA COMPLETA DE RECURSOS' as info,
  recurso
FROM permissoes
ORDER BY recurso;
