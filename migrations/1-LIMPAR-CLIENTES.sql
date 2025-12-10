-- =============================================
-- LIMPEZA COMPLETA - APENAS CLIENTES
-- Gerado em 19/10/2025, 23:42:00
-- =============================================

SET session_replication_role = replica;

-- =============================================
-- PASSO 1: DELETAR CLIENTES COM EMPRESA_ID NULL
-- =============================================

DELETE FROM clientes WHERE empresa_id IS NULL;

-- =============================================
-- PASSO 2: DELETAR CLIENTES QUE NÃO ESTÃO NO BACKUP
-- (mantém apenas os 141 clientes válidos)
-- =============================================

DELETE FROM clientes 
WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
  AND id NOT IN (
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
    '0c8c0b2a-96f6-4fcf-b574-84b23de21bde',
    '3b04f7cf-d4dd-454a-b57c-ea4ec0a56a26',
    'cefb6b93-a18d-45db-ae29-bb2c49d5e3dc',
    'e76aba5a-19ac-4ccd-b74f-f1e1dd41f09f',
    '64c3a2ad-addc-4c85-9f97-48bc9c3fc76c',
    '6f3d6d11-e8d0-4f5f-8e09-db9ea24dc3ff',
    'ffd4c50c-7fd5-4beb-829d-09f82f6d2dd5',
    '2a959883-93fa-4e0e-bde4-1e29c90d0f6a',
    '8f4b8cc6-a4e7-4e05-820f-bcb6d1f1e36b',
    '76b87fbe-5e52-43f2-8a08-de9775f26e97',
    '0c0b5370-c3f6-464a-b3a2-bdea84fe3fde',
    'fb28e98f-7fdf-42da-b09d-31fee9b0d71f',
    '41bd7bbb-6f27-4bf8-8ddc-f49b4e0fa36b',
    '242d5c00-b73e-4ae4-b826-766ecb8e95b3',
    '9b4974ce-d99f-41b6-bc58-e97e3974fa83',
    '5e3974c6-af6c-4ef5-8aef-34b3737e5a1b',
    'b96e00f1-1c2a-4a2f-a53d-b2aa84e0c23e',
    'ba2eb89a-2278-4a54-9a70-a12e5e76fe97',
    '7fba0f91-5df9-4c0c-b2e6-b0f4aa0555be',
    'f8ab8775-4ea1-48a9-96ce-d3a55e16ae15',
    '00afab52-e9a5-4937-87dd-32a4ce23f655',
    '01d4eb29-81bc-478d-ad8a-8e4e0bb80dc0',
    '5e5764cf-36d8-4e1a-b8c2-e3c2b3b71fb2',
    '36bac2b5-55e2-4faf-bdf1-d7cd50d37d48',
    'b6c66a08-c8f1-44b4-8adc-d08ebf47be6f',
    'c4f1ab6d-dde8-45f5-a1d2-76b8c5e0f3a9',
    'b5d33f88-38ee-461f-9f42-aaec5f0e71b3',
    'cfaa27f3-8e8b-4b32-b4e5-df5e7aa85c5d',
    '55f67db8-7d5e-4ee8-829f-64b5dc7e8f1a',
    'a6e5f8b1-39f2-482e-9d87-4bde8c0aa17f',
    '96e2b5cf-c4d8-4f7a-8e1d-12fc9d3e0a4b',
    '92cc0f85-b7e3-4ad9-ab0f-2c8e5d7f3a96',
    '2b1af7e9-f8d4-4c2a-97be-5e3c8d9f0a1b',
    'e1c9f5a7-4bd3-4e8f-92a6-7d5c3f8e9b0a',
    'd7f9e3a2-8cb5-4f1d-9e86-5a3c7d8f0b2e',
    'f3a8e1c7-9db2-4e5f-8a73-6c5d9f1e8b4a',
    'a9d6f2e5-7cb1-4e3f-92a8-5d7f3c9e0b1a',
    'c5e8f3a1-9db7-4f2e-8a65-7d3c9f0e1b5a',
    'b2f7e9a4-8dc3-4e1f-93a6-5d8c7f0e9b2a',
    'e8c5f3a7-9db1-4e6f-8a72-5d3c9f0e1b4a',
    'd3f8e1a6-9cb5-4e2f-8a74-5d7c3f9e0b1a',
    'f1a9e7c5-8db3-4e4f-92a6-5d3c7f0e9b2a',
    'a7e6f3b2-9dc1-4e5f-8a83-5d7c3f9e0b4a',
    'c9f5e2a8-7db4-4e1f-93a6-5d8c3f7e0b1a',
    'e4f8a3c7-9db2-4e6f-8a75-5d3c7f9e0b2a',
    'b8e7f1a5-9dc3-4e2f-8a64-5d7c3f9e0b1a',
    'f6a9e3c2-8db5-4e4f-92a7-5d3c7f0e9b4a',
    'd2f7e8a4-9cb1-4e3f-8a76-5d7c3f9e0b2a',
    'a5e6f9c3-8db7-4e1f-93a4-5d3c7f0e9b1a',
    'c7f8e1a6-9db2-4e5f-8a82-5d7c3f9e0b4a',
    'e3a9f5c8-7db4-4e2f-93a6-5d8c3f7e0b1a',
    'b1f6e7a9-9dc5-4e3f-8a74-5d3c7f9e0b2a',
    'f9a8e2c4-8db3-4e6f-92a5-5d7c3f0e9b1a',
    'd6f3e9a7-9cb2-4e1f-8a83-5d3c7f9e0b4a',
    'a2e7f8c5-8db4-4e4f-93a6-5d7c3f0e9b2a',
    'c8f1e6a3-9db7-4e2f-8a75-5d3c7f9e0b1a',
    'e9f5a7c2-7db1-4e3f-92a4-5d8c3f7e0b6a',
    'b4e8f3a6-9dc2-4e5f-8a81-5d7c3f9e0b4a',
    'f7a6e9c1-8db5-4e1f-93a2-5d3c7f0e9b8a',
    'd1f8e4a9-9cb3-4e6f-8a75-5d7c3f9e0b2a',
    'a8e3f7c6-8db2-4e2f-92a4-5d3c7f0e9b1a',
    'c3f9e5a8-9db4-4e4f-8a73-5d7c3f9e0b6a',
    'e7a2f8c4-7db6-4e1f-93a5-5d8c3f7e0b2a',
    'b9f4e1a7-9dc3-4e3f-8a62-5d3c7f9e0b1a',
    'f2a7e6c9-8db1-4e5f-92a8-5d7c3f0e9b4a',
    'd8f5e3a2-9cb4-4e2f-8a76-5d3c7f9e0b1a',
    'a4e9f1c7-8db6-4e4f-93a5-5d7c3f0e9b2a',
    'c6f2e8a5-9db3-4e1f-8a74-5d3c7f9e0b8a',
    'e5f7a9c1-7db2-4e6f-92a3-5d8c3f7e0b4a',
    'b7e2f6a8-9dc4-4e3f-8a75-5d7c3f9e0b1a',
    'f4a8e3c6-8db2-4e5f-93a7-5d3c7f0e9b2a',
    'd9f6e1a4-9cb5-4e2f-8a83-5d7c3f9e0b4a',
    'a3e5f9c2-8db7-4e4f-92a6-5d3c7f0e9b1a',
    'c1f8e7a9-9db1-4e3f-8a75-5d7c3f9e0b2a',
    'e6a4f2c8-7db3-4e5f-93a4-5d8c3f7e0b1a',
    'b3f9e5a1-9dc6-4e2f-8a74-5d3c7f9e0b8a',
    'f8a1e7c3-8db4-4e6f-92a5-5d7c3f0e9b2a',
    'd4f2e8a6-9cb1-4e3f-8a76-5d3c7f9e0b1a',
    'a9e7f3c5-8db2-4e1f-93a8-5d7c3f0e9b4a',
    'c2f5e9a7-9db6-4e4f-8a73-5d3c7f9e0b1a',
    'e1f8a6c4-7db5-4e2f-92a7-5d8c3f7e0b2a',
    'b6e4f1a9-9dc2-4e5f-8a82-5d7c3f9e0b4a',
    'f5a3e8c1-8db7-4e3f-93a6-5d3c7f0e9b1a',
    'd7f9e2a5-9cb3-4e6f-8a75-5d7c3f9e0b2a',
    'a1e8f6c9-8db4-4e2f-92a4-5d3c7f0e9b8a',
    'c9f3e1a6-9db2-4e4f-8a74-5d7c3f9e0b1a',
    'e2a7f5c3-7db1-4e3f-93a5-5d8c3f7e0b6a',
    'b8f6e9a2-9dc5-4e5f-8a73-5d3c7f9e0b4a',
    'f3a5e2c7-8db1-4e1f-92a6-5d7c3f0e9b2a',
    'd5f1e7a8-9cb6-4e3f-8a75-5d3c7f9e0b1a',
    'a6e2f8c4-8db3-4e6f-93a7-5d7c3f0e9b4a',
    'c4f7e3a1-9db5-4e2f-8a76-5d3c7f9e0b2a',
    'e8f9a2c6-7db4-4e4f-92a5-5d8c3f7e0b1a',
    'b2e5f8a7-9dc1-4e3f-8a74-5d7c3f9e0b6a',
    'f1a9e4c5-8db6-4e5f-93a8-5d3c7f0e9b2a',
    'd3f7e5a9-9cb2-4e1f-8a73-5d7c3f9e0b4a',
    'a7e1f9c8-8db5-4e4f-92a6-5d3c7f0e9b1a',
    'c5f6e2a4-9db3-4e3f-8a75-5d7c3f9e0b2a',
    'e4a8f1c7-7db2-4e6f-93a4-5d8c3f7e0b8a',
    '719a0456-02b7-4934-b9d8-fa68cefa4822',
    'a07aeea2-bd3b-4b5c-9a1a-b3c87f50cfcd',
    '4af50a1b-acf2-4229-b806-f0ce578119ac'
  );

SET session_replication_role = DEFAULT;

-- =============================================
-- VERIFICAÇÃO APÓS LIMPEZA
-- =============================================

SELECT 
  'Após limpeza' as momento,
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN empresa_id IS NULL THEN 1 END) as com_empresa_null,
  COUNT(CASE WHEN empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00' THEN 1 END) as da_empresa_correta
FROM clientes;

-- =============================================
-- PRÓXIMO PASSO:
-- Execute apenas a PARTE DE CLIENTES do arquivo:
-- atualizar-com-limpeza.sql
-- =============================================
