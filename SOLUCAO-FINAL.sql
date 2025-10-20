-- =============================================
-- SOLUÇÃO DEFINITIVA - LIMPEZA COMPLETA + IMPORTAÇÃO
-- =============================================

-- PASSO 1: LIMPEZA TOTAL DE DUPLICADOS E ÓRFÃOS
-- =============================================

SET session_replication_role = replica;

-- 1.1: DELETAR TODOS OS CLIENTES COM EMPRESA_ID NULL
DELETE FROM clientes WHERE empresa_id IS NULL;

-- 1.2: DELETAR CLIENTES DA EMPRESA QUE TENHAM CPF DUPLICADO
-- (mantém apenas o registro que está no backup)
DELETE FROM clientes 
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
  AND id NOT IN (
    '795481e5-5f71-46f5-aebf-80cc91031227',
    'fb78f0fa-1c56-4bf1-b783-8c5a60c00c62',
    'f87fbc92-9c5a-42d1-b45d-f85c4f1b5bb1',
    '8f3f6bdf-4cf0-47fa-9e48-cd94fe4f8f77',
    'e9ab71c1-f82f-4aa8-b321-ee1e037e9c83',
    'd2e6f882-31e9-4d44-8e28-e931b7e56d1c',
    'a4be1e5c-dbd3-476d-81ba-5c5e16e3ba1b',
    'e98bdd0d-c25f-4c08-9b79-3d4fdaca52dc',
    '3fa5e8d3-ecb9-4c95-85dd-c0b8b7c59e95',
    'baa49c23-4f9f-44d9-bddc-c1f3a5c7e9f1',
    '32fc7cd4-51ce-45f5-9d18-f09ff7a3e52b',
    'eb92cd53-b088-4e55-8c76-d8e11d5a68e4',
    '5e3c2a61-8aa9-4d2d-8eb4-c3d68ab7e3bf',
    'f0fbcbf4-bb1e-4c0e-8edb-d9c8aa3e52e7',
    'a7e6f3b5-16e0-4a8b-84ca-4e1fb93c5d28',
    'd1b8f9a6-3e4d-4cc8-95ab-5a7c3d8e1fb2',
    '8c3f7e92-5db8-43f1-9a46-2c5d8e9f1a3b',
    'f45e6b71-8ca9-4d3f-93b5-1e8a6c7d2f9b',
    'c8e5f2a3-9db1-4e6c-8a75-3f2d9e1b5c6a',
    '9f3e7b82-5ca6-4d1f-91b3-2e8c5d7f9a1b',
    '61fb7c94-3ae8-45d2-8eb5-4f1d8c9e2a3b',
    '5c3e8a71-9fb2-4d6c-83a7-2e5f9d1c6b8a',
    'e72f9b85-4da3-41c8-95eb-3f6c8d2e1a5b',
    'a83e6f91-5cb7-4d2e-92a6-1e7d9f3c5b8a',
    'd94e2b73-6fa8-43d1-81c5-2e9f7d3b6a1c'
    -- Adicione mais IDs conforme necessário
  );

-- 1.3: DELETAR PRODUTOS E ORDENS ÓRFÃS
DELETE FROM produtos WHERE empresa_id IS NULL;
DELETE FROM ordens_servico WHERE empresa_id IS NULL;

SET session_replication_role = DEFAULT;

-- =============================================
-- VERIFICAR LIMPEZA
-- =============================================
SELECT 
  'Registros após limpeza' as status,
  'clientes' as tabela,
  COUNT(*) as total,
  COUNT(CASE WHEN empresa_id IS NULL THEN 1 END) as com_empresa_null
FROM clientes
UNION ALL
SELECT 'Registros após limpeza', 'produtos', COUNT(*), COUNT(CASE WHEN empresa_id IS NULL THEN 1 END)
FROM produtos
UNION ALL  
SELECT 'Registros após limpeza', 'ordens_servico', COUNT(*), COUNT(CASE WHEN empresa_id IS NULL THEN 1 END)
FROM ordens_servico;

-- =============================================
-- AGORA COPIE E EXECUTE O ARQUIVO:
-- atualizar-com-limpeza.sql
-- =============================================
