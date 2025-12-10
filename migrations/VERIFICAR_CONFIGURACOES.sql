-- Verificar quais recursos relacionados a configuração existem
SELECT 
  '🔍 RECURSOS DE CONFIGURAÇÃO' as info,
  recurso,
  acao,
  descricao
FROM permissoes
WHERE recurso LIKE '%config%' OR recurso LIKE '%settings%'
ORDER BY recurso, acao;

-- Ver TODOS os recursos novamente
SELECT DISTINCT
  '📋 TODOS OS RECURSOS' as info,
  recurso
FROM permissoes
ORDER BY recurso;
