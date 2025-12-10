-- =====================================================
-- VERIFICAR TODOS OS CLIENTES (ATIVOS E INATIVOS)
-- =====================================================

-- Ver total de clientes (incluindo inativos)
SELECT 
  COUNT(*) as total_todos_clientes,
  COUNT(CASE WHEN ativo = true THEN 1 END) as ativos,
  COUNT(CASE WHEN ativo = false THEN 1 END) as inativos,
  COUNT(CASE WHEN ativo IS NULL THEN 1 END) as ativo_null
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Ver estatísticas dos clientes ativos
SELECT 
  COUNT(*) as total_ativos,
  COUNT(CASE WHEN telefone != '' THEN 1 END) as com_telefone,
  COUNT(CASE WHEN cpf_cnpj != '' THEN 1 END) as com_cpf_cnpj,
  '✅ CLIENTES ATIVOS' as categoria
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND ativo = true;

-- Ver estatísticas dos clientes inativos (se houver)
SELECT 
  COUNT(*) as total_inativos,
  COUNT(CASE WHEN telefone != '' THEN 1 END) as com_telefone,
  COUNT(CASE WHEN cpf_cnpj != '' THEN 1 END) as com_cpf_cnpj,
  '⚠️ CLIENTES INATIVOS' as categoria
FROM clientes 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND ativo = false;

-- Verificar se existem clientes em outras empresas
SELECT 
  empresa_id,
  COUNT(*) as total_clientes,
  CASE 
    WHEN empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN '✅ EMPRESA CORRETA'
    WHEN empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00' THEN '❌ EMPRESA ERRADA'
    ELSE '⚠️ OUTRA EMPRESA'
  END as status
FROM clientes 
GROUP BY empresa_id
ORDER BY total_clientes DESC;
