-- =============================================
-- LIMPEZA TOTAL + RESTAURAÇÃO
-- Empresa: f7fdf4cf-7101-45ab-86db-5248a7ac58c1
-- =============================================

SET session_replication_role = replica;

-- PASSO 1: DELETAR TODOS OS CLIENTES (de todas as empresas com os IDs do backup)
-- Isso garante que não haverá conflito de ID

DELETE FROM clientes WHERE id IN (
  '795481e5-5f71-46f5-aebf-80cc91031227',
  'fb78f0fa-1c56-4bf1-b783-8c5a60c00c62',
  '67526f20-485e-40a0-b448-303ce34932fc',
  '98e0b7d7-7362-4855-89f0-fa7c1644964f',
  '7af82c1b-9588-471f-b700-d2427b18c6ec',
  'fd5eb3bf-4054-430f-9f28-647b785dd2b8',
  '3c26ce91-1a8b-4a18-8e63-37244ee21d9e',
  '66727ef3-2636-49fd-969f-233e1cc07f13',
  '7b05bd0a-1fc7-4334-8576-c4e77d27b196',
  '1de38261-6f87-45fb-966f-74f80d9a2b82',
  'd8995586-abf4-457a-9756-735f5606e41c',
  '159ef458-4b88-422f-b6b5-98d99d53bd95',
  '81402fa3-218d-470d-b679-b477902b08ec',
  '1a735ff3-17fb-41d7-9e44-e6ae6515b713',
  'd1c2b00e-4923-42a8-bd93-de8d2d18cfdd',
  '5c8b794a-ff86-4106-99af-43936b883814',
  '0de00017-d115-484d-9800-a2e818be06e0',
  'cec352ec-fd75-46f8-885e-f97c204ec860',
  '57abc05f-f89f-4214-89f4-7c2419c1d8ec',
  '8e5f7dad-f0b8-4108-8df8-a5d72b71b091',
  'fa2c9924-ad76-4174-bfa8-c738facbc740',
  'e6ad0da5-e52c-44db-9303-c51b6224f5d7',
  'b8a4a1cc-80ab-420b-b720-eb4798e77c77',
  '698ca802-0757-4442-9189-904b031b73ae',
  '66e6e8d8-44d6-48de-8e45-3ea38d16cbc8',
  '3e706edc-3e4c-412a-b806-ba9ab6adbedc',
  '1a684b17-330b-46e9-9b78-bb36fc213b74',
  'b84d45af-8e02-4296-9ef7-30dfffe05754',
  'ddbe4aae-4f51-4d41-bb29-53492d0b1343',
  '8139ca41-e231-49e9-b8a3-d7266552bb93',
  '1a1ffa9c-b2f8-4ea3-8fc9-e875cd05d180',
  'fa24c59c-38bd-4e12-a9ca-87d267f61ad6',
  'b003b09f-423b-4587-a007-aa0daa5d9dfa',
  'c7cddd7c-ce2b-4040-bf6d-48fa899289e1',
  'bb9ffa5d-e7c4-42ac-b03d-142f0e44f387',
  'cf3869e6-ec88-428a-af48-e7fc8ae74867',
  '809316fe-c175-4d05-b735-5d3fd215d955',
  '719a0456-02b7-4934-b9d8-fa68cefa4822',
  'a07aeea2-bd3b-4b5c-9a1a-b3c87f50cfcd',
  '4af50a1b-acf2-4229-b806-f0ce578119ac'
);

-- PASSO 2: Deletar clientes órfãos
DELETE FROM clientes WHERE empresa_id IS NULL;

-- PASSO 3: Deletar da empresa correta
DELETE FROM clientes WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

SET session_replication_role = DEFAULT;

-- Verificar limpeza
SELECT 
  'Após limpeza total' as momento,
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as da_empresa_correta
FROM clientes;

-- =============================================
-- AGORA EXECUTE: RESTAURAR-EMPRESA-CORRETA.sql
-- (a parte que insere os clientes)
-- =============================================
