-- =====================================================
-- CRIAR PERMISSÕES DE ORDEM DE SERVIÇO
-- =====================================================
-- As permissões de OS estão faltando no banco
-- E o código está procurando por 'ordens' quando deveria ser 'ordens_servico'
-- =====================================================

-- 1. Verificar se já existem permissões de ordens_servico
SELECT 
  COUNT(*) as total_permissoes_os,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ Permissões de OS já existem'
    ELSE '⚠️ Permissões de OS NÃO existem'
  END as status
FROM permissoes
WHERE recurso = 'ordens_servico';

-- 2. Criar permissões de Ordem de Serviço (se não existirem)
INSERT INTO permissoes (recurso, acao, descricao, categoria)
VALUES
  ('ordens_servico', 'read', 'Visualizar ordens de serviço', 'Ordens de Serviço'),
  ('ordens_servico', 'create', 'Criar ordens de serviço', 'Ordens de Serviço'),
  ('ordens_servico', 'update', 'Editar ordens de serviço', 'Ordens de Serviço'),
  ('ordens_servico', 'delete', 'Excluir ordens de serviço', 'Ordens de Serviço')
ON CONFLICT (recurso, acao) DO NOTHING;

-- 3. Verificar resultado
SELECT 
  id,
  recurso,
  acao,
  descricao,
  categoria,
  created_at
FROM permissoes
WHERE recurso = 'ordens_servico'
ORDER BY acao;

-- 4. Contar total de permissões criadas
SELECT 
  COUNT(*) as total_permissoes_os,
  '✅ Permissões de Ordem de Serviço criadas!' as mensagem
FROM permissoes
WHERE recurso = 'ordens_servico';

-- =====================================================
-- RESULTADO ESPERADO:
-- =====================================================
-- ✅ 4 permissões criadas:
--    - ordens_servico:read
--    - ordens_servico:create
--    - ordens_servico:update
--    - ordens_servico:delete
-- =====================================================
