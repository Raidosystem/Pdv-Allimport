-- =============================================
-- ATUALIZAÇÃO/IMPORTAÇÃO DE DADOS (UPSERT)
-- Gerado automaticamente em 19/10/2025, 23:35:11
-- Usa ON CONFLICT para atualizar dados existentes
-- =============================================

-- Desabilitar triggers temporariamente (opcional)
SET session_replication_role = replica;

-- =============================================
-- CLIENTES (141 registros) - UPSERT
-- =============================================

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '795481e5-5f71-46f5-aebf-80cc91031227',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ANTONIO CLAUDIO FIGUEIRA',
  '17999740896',
  '',
  '33393732803',
  '33393732803',
  'AV 23, 631',
  'Guaíra',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-17T20:36:15.817985+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fb78f0fa-1c56-4bf1-b783-8c5a60c00c62',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'EDVANIA DA SILVA',
  '17999790061',
  'BRANCAFABIANA@GMAIL.COM',
  '37511773885',
  '37511773885',
  'AV JACARANDA, 2226',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-17T21:14:28.92461+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '67526f20-485e-40a0-b448-303ce34932fc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SAULO DE TARSO',
  '17991784929',
  '',
  '32870183968',
  '32870183968',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-18T13:27:30.544639+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '98e0b7d7-7362-4855-89f0-fa7c1644964f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ALINE CRISTINA CAMARGO',
  '17999746003',
  '',
  '37784514808',
  '37784514808',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-18T13:47:31.189798+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7af82c1b-9588-471f-b700-d2427b18c6ec',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'WINDERSON RODRIGUES LELIS',
  '16991879011',
  '',
  '23510133870',
  '23510133870',
  'AV 29, COAB 1',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-18T16:28:42.232978+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fd5eb3bf-4054-430f-9f28-647b785dd2b8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ALINE MARIA PEREIRA DA CRUZ',
  '17999765852',
  '',
  '37736820856',
  '37736820856',
  'RUA 48,833 ANTONIO MANOEL',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-18T16:57:07.630239+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3c26ce91-1a8b-4a18-8e63-37244ee21d9e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JORGE FRANCISCO RIBEIRO',
  '999790204',
  '',
  '03243736862',
  '03243736862',
  'RUA 14 829 CENTRO',
  'GUAÍRA',
  'SÃO PAULO',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-18T19:55:37.778877+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '66727ef3-2636-49fd-969f-233e1cc07f13',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Giane Bitencourt',
  '17999795647',
  '',
  '138.737.088-09',
  '13873708809',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-18T20:40:34.724816+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7b05bd0a-1fc7-4334-8576-c4e77d27b196',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'EVALDO ANDRE MAZIETO',
  '17991230981',
  '',
  '12652723871',
  '12652723871',
  '',
  'Guaíra',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-18T20:42:48.976204+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1de38261-6f87-45fb-966f-74f80d9a2b82',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Ertili Alves Brandão',
  '17991412197',
  '',
  '156.749.464-18',
  '15674946418',
  'AV 55 269 MURAISH',
  'GUAÍRA',
  'SP',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-20T13:27:38.554856+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd8995586-abf4-457a-9756-735f5606e41c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JOSLIANA ERIDES DE PAULA FREITAS',
  '17981544129',
  '',
  '19504768806',
  '19504768806',
  'AV 37 A, 56, RES MARINA',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-20T13:31:27.248986+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '159ef458-4b88-422f-b6b5-98d99d53bd95',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FLAVIA MARQUES FIGUEIREDO DE PAULA',
  '17999758595',
  '',
  '13873648806',
  '13873648806',
  'RUA 08,1462, JARDIM ELDORADO ',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-20T18:39:48.799224+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '81402fa3-218d-470d-b679-b477902b08ec',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CELIO SANTOS DE SOUSA',
  '17999787190',
  '',
  '28911352888',
  '28911352888',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-20T19:51:50.126577+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1a735ff3-17fb-41d7-9e44-e6ae6515b713',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ODAIR FERREIRA DE SOUSA',
  '17999790003',
  '',
  '13454225809',
  '13454225809',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-20T19:52:35.036402+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd1c2b00e-4923-42a8-bd93-de8d2d18cfdd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Vitor Aleixo',
  '17999763679',
  '',
  '104.225.468-01',
  '10422546801',
  'RUA 10, 23, CENTRO',
  'GUAIRA',
  'S.P',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-20T20:06:11.979807+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5c8b794a-ff86-4106-99af-43936b883814',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Tiago Luiz Da Silva',
  '17999797127',
  '',
  '354.574.208-33',
  '35457420833',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-20T20:30:38.666175+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0de00017-d115-484d-9800-a2e818be06e0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'EDSON RODRIGO',
  '17999750395',
  '',
  '30119076845',
  '30119076845',
  'RUA 28A , 383 - MURAISH ',
  'GUAÍRA',
  'SP',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-21T12:49:41.642789+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cec352ec-fd75-46f8-885e-f97c204ec860',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Lucinei Batista',
  '(17)99979-7787',
  '',
  '050.527.058-75',
  '05052705875',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-21T14:54:52.836878+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '57abc05f-f89f-4214-89f4-7c2419c1d8ec',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'cristiane matos',
  '1733311381',
  '',
  '44408932876',
  '44408932876',
  'av 53 , 625 antonio manoel',
  'guaír',
  'sp',
  '147900000',
  'Física',
  true,
  NULL,
  '2025-06-23T12:32:25.942236+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8e5f7dad-f0b8-4108-8df8-a5d72b71b091',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ROBERTO BEL  PRESENTES',
  '17991061836',
  '',
  '01806598639',
  '01806598639',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-23T12:52:37.160898+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fa2c9924-ad76-4174-bfa8-c738facbc740',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LUIZ CARLOS ESTEVES',
  '17999784472',
  '',
  '05344087888',
  '05344087888',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-23T13:02:23.200329+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e6ad0da5-e52c-44db-9303-c51b6224f5d7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Sirlene Janaina Amancio',
  '98128-2418',
  '',
  '336.403.368-44',
  '33640336844',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-23T15:41:18.203002+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b8a4a1cc-80ab-420b-b720-eb4798e77c77',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADRIANA DA SILVA CIPRIANO',
  '(17)99978-9106',
  '',
  '330.240.828-59',
  '33024082859',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-23T15:42:43.178918+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '698ca802-0757-4442-9189-904b031b73ae',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MARISSELMA DE OLIVEIRA BORGES',
  '017999765810',
  '',
  '06834934693',
  '06834934693',
  'RUA 11B, 660, TAIS 1',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-23T16:23:22.04139+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '66e6e8d8-44d6-48de-8e45-3ea38d16cbc8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'maria vitoria medeiros',
  '17',
  '',
  '44478437881',
  '44478437881',
  'av 13a, 256 ',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-27T14:52:44.488653+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3e706edc-3e4c-412a-b806-ba9ab6adbedc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'DARIO RODRIGO',
  '999771325',
  '',
  '12443429636',
  '12443429636',
  'AV 1 , N 27 CENTRO',
  'GUAÍRA',
  'SP',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-23T20:44:11.133276+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1a684b17-330b-46e9-9b78-bb36fc213b74',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'IGOR DAHER RAMOS',
  '16989958303',
  '',
  '22920585886',
  '22920585886',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-24T13:00:40.552359+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b84d45af-8e02-4296-9ef7-30dfffe05754',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'RAFAELA BRUNA BARROS',
  '017999758149',
  '',
  '38025416852',
  '38025416852',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-24T16:06:00.944733+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ddbe4aae-4f51-4d41-bb29-53492d0b1343',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'adriana moraes',
  '17991343770',
  '',
  '17869855863',
  '17869855863',
  '',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-24T18:11:26.83835+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8139ca41-e231-49e9-b8a3-d7266552bb93',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'DOUGLAS RODRIGUES FERREIRA',
  '17999754390',
  'douuglinha@gmail.com',
  '45085989864',
  '45085989864',
  'Rua 14b numero 64 Tonico Garcia',
  'Guaira',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-24T20:24:19.357898+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1a1ffa9c-b2f8-4ea3-8fc9-e875cd05d180',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JULIANA ALVES DE SOUZA',
  '11993242073',
  '',
  '32744523860',
  '32744523860',
  'AV 29A. 143 RES TOBIAS LANDIM',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-24T21:12:02.001278+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fa24c59c-38bd-4e12-a9ca-87d267f61ad6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CRISTIANO LUIZ ',
  '17996821951',
  '',
  '11840713810',
  '11840713810',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-25T12:28:44.595176+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b003b09f-423b-4587-a007-aa0daa5d9dfa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JAQUELINE CARDOSO',
  '17992061589',
  '',
  '35444342880',
  '35444342880',
  'AV OVIDIO GARCIA NOGUEIRA , 347',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-25T15:58:05.935337+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c7cddd7c-ce2b-4040-bf6d-48fa899289e1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'GABRIEL VICTOR DOS SANTOS',
  '17999791152',
  '',
  '44366925826',
  '44366925826',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-25T16:34:57.954511+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bb9ffa5d-e7c4-42ac-b03d-142f0e44f387',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Daiane Hukumoto',
  '17999742737',
  '',
  '109.761.394-13',
  '10976139413',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-25T18:35:56.614586+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cf3869e6-ec88-428a-af48-e7fc8ae74867',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'raimundo da silva barcelar',
  '17999748155',
  '',
  '01389283399',
  '01389283399',
  'fazenda santa clara',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-25T19:22:41.44893+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '809316fe-c175-4d05-b735-5d3fd215d955',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'gabriela domiciano soares',
  '17991193787',
  '',
  '42710463881',
  '42710463881',
  '',
  'guaíra',
  '',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-26T12:58:14.672517+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a78f10de-a548-4890-b8bd-4b66f512c1b4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'marco aurélio becari ',
  '17997070468',
  '',
  '18184335830',
  '18184335830',
  'av 13a, 211 são francisco ',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-26T14:51:56.404127+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ade9a716-2479-44c4-a405-fe97970149b5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JEAN JUNIOR RIBEIRO',
  '17999710015',
  '',
  '37816971850',
  '37816971850',
  'RUA 8B, 423, ANICETO CARLOS NOGUEIRA',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-26T16:09:06.667725+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5c3f2244-1899-4c3b-bd49-afd6c5e24be3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FRANCISCO GENILDO',
  '',
  '',
  '49725683803',
  '49725683803',
  'AV JOSE FLORES , N 84',
  'GUAÍRA',
  'SP',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-26T18:35:49.343509+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '34d03de0-1545-4d24-ac72-7d75577a3697',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LUCIANO TAVARES',
  '17999766445',
  '',
  '45758194840',
  '45758194840',
  'RUA 020, N 310 REINALDO STEIN',
  'guaíra',
  'sp',
  '',
  'Física',
  true,
  NULL,
  '2025-06-26T20:21:56.581635+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6bd751c7-a33f-49eb-a21c-1e76dc9c59d5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Aguetoni Transportes LTDA',
  '33302400',
  'aguetoni@aguetoni.com.br',
  '65744138/0001-40',
  '65744138000140',
  'av joão jorge garcia leal, 0601 - parque industrial',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-27T15:37:59.629117+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '604c4701-d666-4422-b870-39ecdccacd77',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Laurence wilians',
  '17991669948',
  '',
  '49107558880',
  '49107558880',
  'rua 3b , n37 aniceto',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-27T19:51:04.772555+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9f4c0884-bf60-40a3-bca5-cb5b04bcf10f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'joana darc teixeira',
  '',
  '',
  '27444011885',
  '27444011885',
  'av 21 , n 1075',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-06-27T15:22:40.774691+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '35ddca11-a4b7-4989-b5a8-56cc672a8d1e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'WILSON JOSE SERIBELI JUNIOR',
  '17991636614',
  '',
  '41330085884',
  '41330085884',
  'FAZ ESTANCIA SANTA MARIA',
  'GUAIA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-28T13:18:28.48103+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f18c4f04-7829-4d62-8c65-5484173e0659',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Lucas Caio dos Santos',
  '179965639578',
  '',
  '42802293842',
  '42802293842',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-28T14:20:25.759413+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '82d9c39d-f5e4-49ca-b07c-74204ea768c7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'GABRIEL FLORA',
  '17991301037',
  '',
  '53783269822',
  '53783269822',
  'rua 6b aniceto n 290 ',
  'guaíra',
  'sp',
  '147900000',
  'Física',
  true,
  NULL,
  '2025-06-30T13:41:03.789163+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8841b79a-af00-4b18-b12c-2ee28eaa9648',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ALEXANDRE BUENO',
  '17991318714',
  '',
  '35625393800',
  '35625393800',
  'AURA',
  'GUAIRA',
  'SP',
  '1490000',
  'Física',
  true,
  NULL,
  '2025-06-30T14:16:50.681485+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'feab2273-8e47-4147-b813-e1fbe555e562',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JOVAN NASCIMENTO',
  '17999761669',
  '',
  '00579409830',
  '00579409830',
  'AV 15, 315',
  'GUAÍRA',
  'SP',
  '147900000',
  'Física',
  true,
  NULL,
  '2025-06-30T14:48:01.373104+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9149ae67-077d-4b9d-b0ff-26314e221838',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MARCELO ARAUJO FARIAS',
  '75998842139',
  '',
  '09453025500',
  '09453025500',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-30T16:01:41.839837+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b7832b5f-04af-4692-8ce5-7b191af49506',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LUIZ CARLOS XAVIER',
  '17999797470',
  '',
  '07743304817',
  '07743304817',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-30T16:57:21.608435+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ebf9273f-7a34-4a17-9d78-eb0431a20d22',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ROBERTO CARLOS  OLIVEIRA SILVA ',
  '17999753155',
  '',
  '16721681803',
  '16721681803',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-30T17:31:50.817455+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b9beffce-eb06-4a17-ae27-acaefa71bc8d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SANDRO ROCHA',
  '17991215666',
  'sousajeni25@gmail.com',
  '09178360811',
  '09178360811',
  'RUA 16, 234,NOBRE VILLE',
  'Guaíra',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-30T18:28:21.65765+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '37909573-d8eb-4110-bd05-f53bc065c218',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'VANESIO MARTINS GUEDES',
  '17992862930',
  '',
  '18640769842',
  '18640769842',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-06-30T18:50:22.307087+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '955f6165-be0b-4aad-856a-badb9016a00c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'liliane maria dos santos',
  '',
  '',
  '14776462486',
  '14776462486',
  'reinaldo stein 022 ',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-01T12:32:12.99733+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '55c84001-83c9-43a5-aaf1-6b37974164c9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'milena aparecida rico',
  '17992151977',
  '',
  '26034330831',
  '26034330831',
  'rua 36, 320 - centro',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-01T18:22:55.659617+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fb405b8e-c47b-4cca-ab26-d9601769f7c2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'gustavo henrique',
  '17991885720',
  '',
  '44733118805',
  '44733118805',
  'av 33a , multirao 3 2255',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-01T19:46:28.936462+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '35b6fb5c-45f6-4257-a7fe-e1744d475c0d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Luka Guia Guaira',
  '(17)99975-7575',
  '',
  '118.688.778-84',
  '11868877884',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-01T20:39:47.28029+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3dc3e949-f54e-45f3-bff8-3a887f068d56',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'leticia costa ',
  '17991108057',
  '',
  '36049382875',
  '36049382875',
  'av 25, n 1047 jardim paulista',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-02T12:27:43.449261+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '817ca735-c027-47ef-8339-01f51c7a1a3e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'OTAVIO DE OLIVEIRA',
  '17999793159 17999792414',
  '',
  '12944092120',
  '12944092120',
  'FAZ SANTO ANTONIO',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-02T13:59:32.436819+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0785fc34-bbc5-42a6-adf5-87e5e8334a4f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'DENIS VIEIRA',
  '34999989601',
  '',
  '06971944690',
  '06971944690',
  'RUA 2 , N1942 PORTAL DO LAGO',
  'GUAÍRA',
  'SP',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-02T18:57:19.272094+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2916edbe-88cd-4b52-8096-6a23c8051127',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SILVIO BRITO',
  '17999794951',
  '',
  '30370900812',
  '30370900812',
  'RUA 21B - 1296',
  'GUAÍRA',
  'SP',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-02T19:06:37.897434+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e996b904-ab4f-48cd-bc27-9a3a111230e9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JOEMERSON SILVEIRA DOS SANTOS',
  '17999784526',
  '',
  '42961494826',
  '42961494826',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-02T19:27:34.302279+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cdeaa159-0c2a-498e-b229-3e4ca0740694',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'joão batista serafim gonçalves',
  '999742270',
  '',
  '05256498835',
  '05256498835',
  'av 1 n 8',
  'guaíra',
  'sp ',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-03T15:14:59.177319+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2ecb5b24-f0b6-4c84-a80a-30a55b7cdd2a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'larissa de oliveira espacini',
  '17992359416',
  '',
  '45615712879',
  '45615712879',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-03T16:18:35.119254+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b5c5c7b8-ccb6-4f32-9f34-949ca12ebd45',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'DEIVID RUBIO ',
  '17999786757 017999783068',
  '',
  '21657438856',
  '21657438856',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-03T16:41:16.427505+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0bbf9bb0-4a3a-47dd-955f-2f7e87875417',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Valter  Baudoino',
  '17991304712',
  '',
  '10949782807',
  '10949782807',
  'rua 46, 16',
  'guiara',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-03T17:56:38.757315+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '35c5f024-c9b0-4dfa-b37d-54ae13349318',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'rogerio basilio de araujo',
  '17991217180',
  '',
  '28938245870',
  '28938245870',
  'rua 21b , n 1160 jose pugliede',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-04T12:39:34.379623+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fecf496e-9991-4cb4-a66e-b9bfd761d5c1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BEATRIZ DE SOUZA DA SILVA',
  '17997879280',
  '',
  '08154604574',
  '08154604574',
  'FAZENHA BREJINHO DAS ANTAS',
  'GUAIRA',
  'SP',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-04T14:47:31.735586+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '059ee7ac-66c9-4212-915b-077814b74010',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ANA CAROLNA SANTOS DE OLIVEIRA',
  '17992310882',
  '',
  '44787946854',
  '44787946854',
  'AV 9A,84',
  'GUAIRA',
  'SP',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-04T15:01:48.46822+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f9ad1aaf-75bd-4c2a-a152-100ad806b9ea',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MATHEUS CIRINO',
  '17991530919',
  '',
  '48358542844',
  '48358542844',
  'AV 23 , N 1235 JARDIM PAULISTA',
  'GUAÍRA',
  'SP',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-04T15:42:36.693893+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f8eaa952-ba4a-48af-8af0-b8252477f9ac',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JOILSON DARLAN',
  '17997413689',
  '',
  '42198637880',
  '42198637880',
  'rua 18b n 1057 jose pugliese ',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-04T16:16:39.108294+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9c5ddf65-713e-4ffe-aa54-b86746b3da99',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ELIAS MATIAS',
  '17999775678',
  '',
  '386623748088',
  '386623748088',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-04T16:58:02.328894+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1f044170-d8cd-462f-a2e7-b36c5688aa6c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ANTONIO MORAES',
  '17999790117',
  '',
  '08416705879',
  '08416705879',
  'RUA 9B, 099',
  'GUAÍRA',
  'SP',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-04T19:19:54.853287+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bbc37e46-1971-4c24-b602-e6f725424982',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADRIAN RENAN GONÇALVES PEREIRA',
  '16994008655',
  '',
  '50039370836',
  '50039370836',
  'AV 35A , N 463 - JARDIM ELIZA ',
  'GUAÍRA',
  'SP',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-04T20:38:25.929374+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3aefe9d8-e78c-494b-9bc9-b841bd34a645',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JOÃO VITOR RIBEIRO DOS REIS',
  '17997544156',
  '',
  '15143463629',
  '15143463629',
  'RUA 16B, 0891 JOAQUIM PEREIRA LELIS',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-05T13:59:15.155099+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '48ad1879-63a7-421c-a4fc-fdb33cb45127',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'DARCI ORTIGOSO',
  '17999793639',
  '',
  '04419717840',
  '04419717840',
  'AV 13, 1035, CENTRO',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-07T15:39:38.173921+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1e03897b-633e-46ec-90bb-5a12dc99698e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MARIA JULIA',
  '17991914170',
  '',
  '47530774891',
  '47530774891',
  'RUA 9B, 204 ANICETO',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-07T17:05:34.769042+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1bb74617-424f-4c0b-bcfc-2de5e87faf80',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ALEX VACARO',
  '17999791111',
  '',
  '17214975874',
  '17214975874',
  'RUA 6, 285, CENTRO',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-07T17:12:40.782568+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd92548f8-b488-4246-8f8d-f3e42f243fb1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'RENATA CRISTINA CAETANO',
  '17981463015',
  '',
  '22209680816',
  '22209680816',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-08T17:17:07.513419+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2181c9cb-fcb9-4148-b55a-19f0144c1975',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FRANCIsNEI DA SILVA',
  '17999783166',
  '',
  '29426291857',
  '29426291857',
  'RUA 9B, 315 ANICETO',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-07T16:51:09.210042+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '497352d6-c054-4c9e-ad12-ad8a568f183f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'mMARIA BENEDITA DE ALMEIDA FOGAÇA',
  '43991784929',
  '',
  '4968350991',
  '4968350991',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-08T21:13:11.350998+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3d6fda07-bf9a-4746-b050-73e7ead568aa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Roseli Lacerda Cartola',
  '999745417',
  'sousajeni25@gmail.com',
  '37725481800',
  '37725481800',
  'rua 020, 89, Reinaldo Stein',
  'Guaíra',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-10T12:05:52.616172+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '067e4459-c80b-434b-bfef-bd3018d0424d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MATEUS PAVANELLO',
  '01799975-2725',
  '',
  '297.396.898-41',
  '29739689841',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-10T12:51:06.445273+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0f7e4449-6876-4362-8afa-d410f9c32a6b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'DANIELE CUSTODIO DE MELO',
  '17999760238',
  '',
  '32157483802',
  '32157483802',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-10T13:11:40.361293+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9ddd4f52-f2d7-400d-bad9-3e6ff55d64a2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JOSIANE VENTURA',
  '017991952462',
  '',
  '29995627809',
  '29995627809',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-10T15:41:12.388621+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7dc2d6f3-4033-4506-a195-1931a601d1bd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'WELLINGTON LUIZ',
  '16997123251',
  '',
  '26050956812',
  '26050956812',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-10T17:12:12.191125+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6c644847-f4f6-452c-bca5-fbe646a6ed1c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'RAQUEL APARECIDA GOMES',
  '17999717214',
  '',
  '17214937867',
  '17214937867',
  'RUA 23B, 1330, TAIS DOIS',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-10T17:24:25.93316+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8638766e-3406-4274-8463-db5b82ea21ad',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LUANA VAZ',
  '17999756366',
  '',
  '408.588.348-80',
  '40858834880',
  'RUA 012, 202, REINALDOSTEN',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-11T12:28:47.489187+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '03baff14-c408-472e-bce7-ec48646a370e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LUCAS LINO TEIXEIRA',
  '17992256085',
  '',
  '47541396826',
  '47541396826',
  'RUA 20B, 908, JOSE PUGLIESE',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-11T13:09:29.870636+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4c3b4b09-32cd-4d15-98ea-1b8878121f80',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'EDISON CAETANO',
  '17999712389',
  '',
  '06545918818',
  '06545918818',
  'AV 37,143, JARDIM ELIZA',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-11T13:22:26.546518+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '65084213-045c-428c-afb4-afba359cc486',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'EDSON GUILHERME FONSECA',
  '17981872044',
  '',
  '14450904818',
  '14450904818',
  'RUA 12B 0784 LUIZ AFONSO',
  'GUAÍRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-11T13:25:38.85345+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '75b108c1-e5d8-4c19-9fd9-e97516ec4b01',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Elson Teixeira',
  '17999750851',
  '',
  '288.331.508-60',
  '28833150860',
  'Avenida 27,1370, Vila Aparecida',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-11T18:24:27.922062+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4e905e3d-8b94-48e2-a4aa-de5879e592ae',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Altamiro Antonio de Matos',
  '17999797840',
  '',
  '268.936.398-48',
  '26893639848',
  'RUA 21B, 940, JOSE PUGLIESE',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-12T12:50:44.774874+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6ae15fcc-9409-47de-ba9a-d6920a70f73a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'Pedro Henrique Eugenio',
  '(17)98135-9545',
  '',
  '247.477.278-25',
  '24747727825',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-14T12:10:52.309145+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '985bd782-ea67-4237-99bf-889eeaaa7108',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JAIR DELEFRATE ',
  '17999794405',
  '',
  '98110012868',
  '98110012868',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-14T13:58:33.503607+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cab561cb-890f-4afc-b249-3e9ddaf2626e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'jennifer maria de sousa',
  '17999754042',
  '',
  '46524955870',
  '46524955870',
  'rua 22 n 913b centro',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-14T19:25:06.055988+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '85460a9d-3277-4d82-9574-39cd914028c6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'DANIELA BARBOSA',
  '17991207314 - 17999795159-17988472165',
  '',
  '48121494877',
  '48121494877',
  'RUA 40, 026A, CODESPAULO',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-06-26T13:24:14.285862+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'df7e11e2-3856-4b11-8df7-40ad0465a54d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'NEIDE FRAGUA',
  '01721430706',
  '',
  '02020878836',
  '02020878836',
  'RUA 12, RODOVIARIA',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-15T12:27:48.479799+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4a60083b-113f-42db-a163-b35cb738fc9f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'TARINAN GOMES DOS SANTOS',
  '17981612202',
  '',
  '37706722830',
  '37706722830',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-15T13:04:35.240407+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '87a08f99-196d-44af-930d-fa8ff3d3e0e5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'mirela vitoria ferreira de sousa',
  '17999758064',
  '',
  '49442948830',
  '49442948830',
  'av 29 n 034 eldorado',
  'guaíra',
  'sp',
  '14790000',
  'Física',
  true,
  NULL,
  '2025-07-15T13:29:10.480524+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '73b62e47-eca9-45a4-bed8-705ca9f5ddc8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'edna cristina spigali',
  '17999794274',
  '',
  '09991724842',
  '09991724842',
  'av 11a n 33 vivendas',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-15T19:09:23.992254+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '50e05cb2-6587-4ebf-8cec-33b52037f93f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LARICE DE CASTRO',
  '17999741581',
  '',
  '37183938832',
  '37183938832',
  'AV PAULO DE LIMA,98, COAB II',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-15T19:34:06.428593+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e8c33d27-ebd6-49e2-82a7-2d4aab7883c2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'rafael borges',
  '17992672844',
  '',
  '32438935855',
  '32438935855',
  'rua 24 n 206 centro',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-16T12:45:38.920066+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '231c72a1-2a56-4f0b-a6ae-dce0da1e44f4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MAIRA GARCIA LELLIS',
  '17999760079',
  '',
  '17528119000134',
  '17528119000134',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-16T13:42:09.878932+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '823f02e0-dc7c-407c-94eb-29b415d2120d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ana paula garcia barbosa',
  '17999790166',
  '',
  '',
  '',
  'av 1 n 66 centro',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-17T18:27:12.521709+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b80944ee-91c7-4109-9698-18596d006321',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'rogerio de paiva',
  '17981617312',
  '',
  '33004014882',
  '33004014882',
  'rua 18 , n 363 nobre vile ',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-18T13:44:34.756596+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0f5f5458-b45b-408f-82f9-8f1053969c17',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CRISTIAN PAULINO ',
  '17999766666',
  '',
  '25455434896',
  '25455434896',
  'FAZENDA SÃO PEDRO',
  'GUAÍRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-18T16:06:27.476498+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd9d8853a-b8bc-41a7-ade6-fcaccc7146f0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ELAINE CRISTINA RIBEIRO',
  '17999742346 - 17999761871',
  '',
  '16216272845',
  '16216272845',
  'AV 41,182, JARDIM ELIZA',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-18T16:07:46.560158+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5d289b72-c214-4f59-a73c-68d2642518ef',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PAULO SERGIO OLIMPIO',
  '17992329831',
  '',
  '16401918870',
  '16401918870',
  'AV1,2268, NOVA GUAIRA',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-18T16:39:37.543529+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8b3fadbc-273d-402f-8de8-5a46fca50ca1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LUIZ FABIO TALARICO DE OLIVEIRA',
  '17991933809',
  '',
  '48555523800',
  '48555523800',
  'RUA 17B , 0815, LUIZ AFONSO PGNANELLI',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-18T17:12:45.672882+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fc7cb829-0208-4f73-bdb6-cbaf96f5117b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'daltoni da cunha teixeira',
  '34991333654',
  '',
  '06536272625',
  '06536272625',
  'av edson bernardes doo nascimento n 1387 jardim eliza',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-19T12:24:44.118865+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b8485121-7418-463d-ac9e-d955f60b9a10',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'valeria cristina da costa ',
  '17991116588',
  '',
  '17536826818',
  '17536826818',
  'rua 10b n 27 antonio garcia',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-19T13:42:32.694193+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2b2e6d7f-6c38-4648-96a4-c47005ae0a5e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SULAMITA FERREIRA DE SOUZA',
  '17991092353',
  '',
  '33998581839',
  '33998581839',
  'RUA 18,82 CENTRO',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-19T14:16:30.382195+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '77e3cf28-ea42-4cae-b5b5-7d3a7db2a073',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ANA LIVIA  FONSECA',
  '98791810214',
  'ANA@GMAIL.COM',
  '39244943808',
  '39244943808',
  'rua 10',
  'Guaíra',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-18T16:59:44.026357+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5ea16650-778e-4ae4-8598-fca206c7dff1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ANDREA LUGUE',
  '17981796738',
  '',
  '17833757870',
  '17833757870',
  'RUA 16, 990, CENTRO',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-22T13:18:23.06397+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9fba2dcd-5b6b-4778-8702-ce6cdd8cbf48',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'joao batista serafim gonçalves',
  '17999792270',
  '',
  '05256498835',
  '05256498835',
  'av 1 n 8 centro',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-22T16:16:56.212261+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e4aa6d76-2168-4c06-ac88-3c619aff787b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'IRENE ROSA DE SOUZA VALENTI',
  '17999796224 -17991201805',
  '',
  '19640932876',
  '19640932876',
  'AV 53,146, ANTONIO MANOEL',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-22T17:52:06.106252+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e956c295-b989-406a-ae1a-44ea6503b2e6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JOAO VITOR CAVENAG',
  '17981304376',
  '',
  '40984285806',
  '40984285806',
  'AV 47, 3989, ANTONIO M,ANOEL',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-23T12:11:45.483115+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3f805d2c-c858-48b3-98c2-ff570a7331e5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MAX MARQUES',
  '17999793265',
  '',
  '29857273831',
  '29857273831',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-23T12:26:29.303922+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1736c2f0-7acd-49ee-bb2e-dd44d858ee7b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'marcos junior',
  '17999751297',
  '',
  '38218957804',
  '38218957804',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-23T17:05:48.715809+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '45a74957-2a39-4890-afdf-3869f387a3d1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'josé reinaldo junior',
  '17999792729',
  '',
  '15786172864',
  '15786172864',
  'av 55c n 110 - moraish',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-23T18:13:01.561044+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4d9d3d2e-b209-436b-a950-9e9589df5165',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'DENIS VIEIRA',
  '3499989601',
  '',
  '06971944690',
  '06971944690',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-24T12:39:39.12398+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd942be79-f8ab-4300-b5e1-408b4de2fdad',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LILIAN CRISTINA FLOR',
  '33313150',
  '',
  '29875741850',
  '29875741850',
  'RUA 02 N 1421 - NADIA ',
  'GUAÍRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-24T12:45:03.563089+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '94606b30-8603-4773-87ea-0207d3043045',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FERNANDA MARQUES DA SILVA CANDIDO',
  '17991016837',
  '',
  '36980762842',
  '36980762842',
  'AV 25,14 RES NADIA 4',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-24T13:30:06.234281+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2a49ab83-e053-418b-9d16-88f14ff2d028',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'gabriel alves scarpelini dos santos',
  '17992327268',
  '',
  '49556225854',
  '49556225854',
  'av 45 n 245 -  antonio manoel ',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-24T19:38:19.223312+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd2b69b59-b14d-4563-ab72-40a41f728cf7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'COOPERCITRUS VALTRA',
  '016991925271',
  '',
  '452367910008176',
  '452367910008176',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-24T20:05:18.45802+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6ff3b90e-ecb0-48b8-814e-52567807c752',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'gilson zanotelo',
  '17999797964 josi',
  '',
  '15612765886',
  '15612765886',
  'rua 12b - n 409',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-24T20:39:51.950619+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5487ccc9-e53a-4a83-b29f-46e8297c842a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'anizio gabriel',
  '17991794274',
  '',
  '47929390896',
  '47929390896',
  'av vicente lopes n 2 ',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-25T13:15:49.787728+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f1afda76-5bbf-410f-a007-36775ef2cf1d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'suelen carla davanço ',
  '17991963907',
  '',
  '31514012871',
  '31514012871',
  'guaira',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-25T14:59:20.926541+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bce4a60f-ce64-4114-9f6c-cc377171b978',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'JOSE DE OLIVEIRA',
  '17997294388',
  '',
  '01369425635',
  '01369425635',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-25T18:10:25.506783+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7bd6c0d8-e754-4de4-9918-a890d59f07a9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ANISIO GABRIEL',
  '17991794274',
  '',
  '47929390896',
  '47929390896',
  'AV VICENTE LOPES DO NASCIMENTO, 152, BOM JESUS',
  'GUAIRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-26T14:04:40.568298+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c10ae076-2713-4ce1-9d46-91736af859b3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CRISTIANE APARECIDA SOUZA FERRAZ',
  '17991314775',
  '',
  '33603005805',
  '33603005805',
  'AV 35A N 1976 MULTIRÃO 3',
  'GUAÍRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-28T13:12:37.490006+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3dd98e80-a9bc-409b-bbc3-d3069202f766',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARLOS DA SILVA BARBOSA',
  '',
  '',
  '03345882408',
  '03345882408',
  'RUA 34 N 350',
  'GUAÍRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-28T13:38:27.555333+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd87374ff-86cd-4872-9684-bec98c167ca9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'VALESCA RUBIA PAIVA TOLENTINO',
  '179992637183',
  '',
  '40603851827',
  '40603851827',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-28T16:27:40.200708+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd4ed0f0b-82ec-46cd-9906-871f97065b5a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ANGELO GABRIEL ',
  '17',
  '',
  '48984593826',
  '48984593826',
  'AV 17 N 1947 GUAIRA E ',
  'GUAÍRA',
  'SP',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-28T12:21:53.546679+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0a812f7f-5c68-4044-a6c3-f2e8ae8a2d32',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MARCIO MB INFORMATICA',
  '17981260094',
  '',
  '12419217850',
  '12419217850',
  '',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-28T19:04:27.923603+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ffbceb28-0219-4eef-81f6-4238586e03a9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'andrea da silva brosco',
  '33313646',
  '',
  '11815499818',
  '11815499818',
  'av 49 n 135 palmeiras ',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-29T14:27:03.288702+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '719a0456-02b7-4934-b9d8-fa68cefa4822',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'dara neves',
  '17',
  '',
  '47629721854',
  '47629721854',
  '19b n 1106 jose pugliese',
  '',
  '',
  '',
  'Física',
  true,
  NULL,
  '2025-07-29T14:37:53.650301+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a07aeea2-bd3b-4b5c-9a1a-b3c87f50cfcd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'maiza gonçalves',
  '17981174856',
  '',
  '49538399862',
  '49538399862',
  'av 25 nadia 4 n 4',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-29T15:41:05.427848+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();

INSERT INTO clientes (
  id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4af50a1b-acf2-4229-b806-f0ce578119ac',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'daniel rosa de oliveira',
  '',
  '',
  '323.455.568-03',
  '32345556803',
  'rua 7c n 117 - residencial amélia ',
  'guaíra',
  'sp',
  '14790-000',
  'Física',
  true,
  NULL,
  '2025-07-29T16:21:45.866399+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  telefone = EXCLUDED.telefone,
  email = EXCLUDED.email,
  cpf_cnpj = EXCLUDED.cpf_cnpj,
  cpf_digits = EXCLUDED.cpf_digits,
  endereco = EXCLUDED.endereco,
  cidade = EXCLUDED.cidade,
  estado = EXCLUDED.estado,
  cep = EXCLUDED.cep,
  updated_at = NOW();


-- =============================================
-- PRODUTOS (813 registros) - UPSERT
-- =============================================

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a2d4691b-ab4d-4aba-a1e6-a1e69f57a3b0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'WIRELESS MICROPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T12:37:11.163625+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '17fd37b4-b9f0-484c-aeb1-6702b8b80b5f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MINI MICROFONE DE LAPELA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T12:38:30.078078+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1b843d2d-263a-4333-8bba-c2466a1bad27',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARTÃO DE MEMORIA A GOLD 64GB',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T12:41:19.19484+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a2239653-68de-4ca3-aeea-7327ff7a2606',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARTÃO DE MEMORIA KAPBOM 16GB',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T12:44:45.239733+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '74b3c9b8-bd69-4356-8c92-ec21b1a3fd76',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARTÃO DE MEMORIA MULTILASER 8GB',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T12:49:33.838667+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1270d1ba-b6d3-49b6-bbc7-a0827f8fb0c8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PENDRIVE KAPBOM 64GB KA-G-64',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T12:50:50.001684+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3d95bdde-ab64-4f85-9eca-98456113a7e4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PENDRIVE KAPBOM 64GB KA-P-64',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T12:43:40.133166+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'dd12a1c0-dfed-4a67-b012-2885535a5ae1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MINI SELFIE STICK HEREBOS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T13:48:35.376238+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8a2e68ca-98e3-447f-b985-e1a518520ec4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR KAPBOM KA-1092',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T13:51:01.674467+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0dbd1aab-f209-4cc2-9aa0-e538b29cb75a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LUZ ESTRELA DE ASTRONAUT ALTOMEX AL-L13',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T13:54:28.204555+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8280216c-cb9f-470a-a0fb-77489ae50bee',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'DIFUSOR DE AROMAS LAREIRA VINTAGE KAPBOM KA-2777',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T13:58:16.478438+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd9665c04-b309-4f44-96ba-cf8687f65627',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'UMIDIFICADOR DE AR E AROMATIZADOR LELONG LE-2340',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T13:59:21.911802+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4fd577a5-d4f1-4c05-bab4-5429924d26ae',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'RING LIGHT B-MAX BM-L20',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T14:01:23.027849+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5d6cf82d-e2fd-4cf0-a8a6-6361a9b3382d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR TURBO OK''GOLD IPHONE CA31-6',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T14:04:13.896811+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '82f891b4-510c-47ae-bd05-b6bf539a7e56',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO WALLO B12 TIPO C PARA IPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T14:09:55.899927+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '34811c96-3955-409b-9dcf-86fc17f3ea18',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO BASIKE BA-CBO100 TIPO C PARA IPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T15:49:57.920508+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '96a77d27-3e19-494b-88cc-19a6a7cee6fb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO HREBIS HS-70 USB PARA IPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:08:57.794703+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c1708060-fcab-4dde-acfe-96d80e957adb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO KAIDI KD-26 TIPO C PARA IPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:16:34.224924+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3819cbd9-7c25-42f5-88a7-e18e27ab90cc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO AVULSO USB PARA IPHONE 2M',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:18:09.889493+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '93569458-750d-4f5b-b48e-4d43eb98b5a9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO PMCELL CB-11 USB PARA IPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:20:52.618494+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fda7c272-1a59-472a-8324-21aac6548460',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO PMCELL CROMO-729 USB PARA IPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:21:55.771658+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'db30478a-e88e-4c78-879a-717d9f5895ea',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR O''GOLD CBA-02 USB /IPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:22:53.386394+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a48a81a6-ff51-48e1-a5ad-7d537be8c649',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO A''GOLD CB96 TIPO C PARA IPHONE ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:05:04.310672+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '600c0074-e492-4bc1-9eae-934742336bfa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO AUXILIAR O''GOLDE CB-59 IPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:25:43.49883+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '20ed49fd-5b04-48d1-8e86-cf089bbf6d03',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE COM FIO LELONG LE-0221',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:50:56.605476+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7fe731fa-756c-49d3-a941-599841490a52',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE COM FIO PMCELL FO-15',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:51:59.155176+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '112f029d-a4db-4c85-9f25-f3ddf396d6a0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE SEM FIO DOTCELL DC-BL1200',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:53:53.779096+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2d816c9e-7b24-4981-a5fd-e1f5a10607fe',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE SEM FIO KAPBOM KA-990',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:55:14.685887+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c9e76dec-e98f-45d7-a364-67be62886685',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO KAIDI KD-02A TIPO C PARA IPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T14:07:35.712952+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2a3654bf-8819-481c-a0e3-1ed5b6dfed45',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO KAIDI KD-335A USB PARA IPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:17:17.213585+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a2a220b5-4cf3-41ca-a9bf-40c043540611',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO AVULSO USB PARA IPHONE 1M',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:20:09.427643+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a99bd0b3-09c9-4dfe-8681-fcf4bb2366e9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONTE IPHONE TIPO C IPHONE PRO MAX ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T14:06:28.576256+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd1005824-18e0-486c-ad9a-88a806457170',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PENDRIVE KAPBOM 32GB',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T12:47:01.512214+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '324a3936-67c6-4f8b-8696-6a73cf2d7534',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARTÃO DE MEMORIA SANDISK 32GB',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T12:46:08.726378+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1af3437d-d722-4dba-a429-ae3bc1897caf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE SEM FIO ULTRAPODS PRO ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T12:55:07.077351+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e65a0d9d-d293-4257-9bc9-b85a60ec21ee',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE O''GOLD COM FIO FN-A21',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:50:26.88938+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '25ab1cd1-ab54-4ec7-9a74-946a7642ca09',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARTÃO DE MEMORIA MULTILASER 4GB',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T12:48:25.634828+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '395c198e-8777-4061-9d51-afab1e9b66c9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'chip algar Esim',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T15:47:46.672113+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '06d4af43-5a47-4099-a53e-0585f1bc0131',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONTE OK''GOLD CA31-4 TIPO C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T14:08:21.400536+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bae894f4-e412-4a74-bc3f-aeeebc14eb8c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARTÃO DE MEMORIA LEON GTS 128GB',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T12:42:21.698872+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2426d443-939d-489d-8057-60cbc325f630',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE SEM FIO O''GOLD FN-BT28 ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:52:56.557791+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '24f734de-126f-4fb6-b7db-7b13f7b03dd7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB AVULSO V8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:56:18.735812+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f4f147f2-2a0b-438d-be28-05a0b08a6c74',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'EMBALAGEM TAMANHO MEDIO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T13:00:03.023108+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ca50cdc9-1e8d-46cc-9446-9cd7a63008ed',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE COM FIO O''GOLD FN-A62 IPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T16:48:07.893331+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c83c60b9-2a7f-447b-b4b6-d8b3a2225410',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CHIP ALGAR TELECOM',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T14:41:22.623923+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6cf815c5-14a0-451b-9541-d8a06f37a719',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'REPETIDOR DE SINAL WIRELESS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T17:05:20.96294+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6e4d54ed-1e42-4ab8-adb3-a57f778feaff',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR SEM FIO INOVA BTME-6314',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T17:08:45.121387+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8a4ae12d-89c5-46e0-8d03-9d26b407560b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PEDRIVE BLUETOOTH PLUG  E PLAY 4.0',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T17:10:13.931336+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '99fa470e-5401-48f4-a02c-a891add7e8f3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR WIRELESS MP3 PARA CARRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T17:11:06.248071+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '880840ac-475e-4746-9dde-6c06c619b5bc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR TOMATE MTG-251A',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T17:23:02.594698+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e6a39b4c-7ba2-4fcb-8bd1-8c087cbeb404',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR LELONG LE-011',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T17:23:54.015571+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '65fa5e61-997e-43ef-8fde-cdf180435edb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA TELEFONE IT-BLUE LE-024',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T17:47:21.225609+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'caca0f44-1bd5-4afa-a971-7a5830d20b2f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA RECARREGAVEL MOX AA 2600 MAH',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T17:49:06.864716+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4ee5acdb-af6f-4d76-a853-f431f694dccd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CHIP CLARO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T21:25:08.612686+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9c515f22-9ef1-4e28-a55b-0b0f7d3cc084',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA TOSHIBA  AA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:04:26.075438+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '29bbf577-739c-4efa-8d5c-98a62aa32b8f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA KNUP 12V KP-23A',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:07:56.043519+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7c0e94f8-da7c-4581-8b7e-48df53c2a184',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA PG 27A -12V',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:10:00.2523+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ae3a1c79-ebb2-4cc5-9c31-a3a88fdb7357',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BATERIA PG 9V ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:10:42.642445+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5b9105bd-3bf9-48af-9c0d-3eaef3c21d9d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA TOSHIBA AAA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:11:26.062412+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a5cdb849-7941-45f3-8c81-d37c02df321d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA ELGIN AAA ALCALINA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:14:34.521792+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6c14e648-36fb-4292-833b-71812291e710',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA RECARREGÁVEL FLEX AAA 1.2V 1100MAH ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:17:12.894283+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5c004672-66c1-4a03-b6c4-96f59bed965f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA  ELGIN CR2430 3V',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:22:31.740369+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '76303878-b865-4e2b-9172-8e9e1ea95a85',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA SONY 3V CR1620',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:48:29.880814+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'dd9309c5-3210-47f5-b24f-0c1c3f9d7c7c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA CR2016 3V',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:49:52.272762+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4c18bfc5-5899-4745-83cb-8fe24b164361',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA SONY CR2016',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T19:16:29.382864+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fd497d17-ff8c-4238-b906-d1bc9e887bf6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BATERIA SONY 3V CR2025',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T19:23:29.243423+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '97d54eb0-b3a2-4a15-9020-45a403f9e104',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BATERIA CR2025 3V',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T19:24:26.800748+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '99f57b8d-f1ab-4622-a680-15d38f0990e1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BATERIA DURACEL PARA APARELHO AUDITIVO 13',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T19:32:35.958736+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '653c5664-eba2-4266-a001-bb2e8179671c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BATERIA DURACEL PARA APARELHO AUDITIVO 675',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T19:32:57.697335+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fd613e3d-3f4e-4d80-8592-5d9b2695f94e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BATERIA DURACEL PARA APARELHO AUDITIVO P312',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T19:33:31.9376+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '573853ef-2da3-45a5-90aa-8d408fcee8b6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BATERIA DURACEL PARA APARELHO AUDITIVO 10',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T19:32:10.20364+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8bfa58ce-21b1-45cd-8c65-41abe504906e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BATERIA TOSHIBA LR 44 1.5V',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T19:54:18.995274+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '204a7a0c-2fbc-4d94-bcce-cc9129022d33',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BATERIA PARA SEM FIO GP 3A',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T19:56:40.658751+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '57cd2886-ae01-4f59-88fc-fc0390022f92',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BATERAI PARA SEM FIO FLEX AA 2.4V',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T19:57:50.606191+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '79d24d0f-d08c-484b-9cdc-ac46b662d9d0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BATERIA PARA SEM FIO FLEX AA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T19:58:22.921929+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7d4a931b-54d3-48cb-b805-79565dc32731',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA MOTOROLA MACRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T21:05:40.229351+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0a6fc88a-6302-4014-92fb-18181708686a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PAG OS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T21:09:52.049276+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '749f2dd5-a01e-4d06-94f1-fe8b32f4125a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR DE PILHA RECARREGAVEL MOX MO-CP50',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T13:37:50.367875+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e301b859-47d6-45f7-8406-6b232e8bea6c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADO DE PILHA RECARREGAVEL MAXDAY',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T13:38:45.443385+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '12961929-49e6-4663-9d8a-1823ead0d412',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR DE PILHA RECARREGAVEL SMART',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T13:50:15.885551+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2b672f24-58b5-44c8-97b5-91cf69b938f9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LIMPA TELA IMPLASTEC',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T13:50:55.31633+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a84d7467-d38d-47b1-a92e-3a36fa95f73d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR KNUP',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T13:52:03.930399+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9c605de1-5278-434b-8ccb-69b2ceeec32e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR BICYCLE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T13:52:49.726619+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cd61ed52-5598-482c-84c4-f520226e0faa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR MEX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T13:54:21.26271+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '92182646-5fbd-4ff9-8f47-e621d2b8d931',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR OBERON',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T13:54:57.797574+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c480698b-4bd1-4ed0-acf4-7da2374d02f1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA SEGNA 1.5V AAA 4V',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:21:23.15476+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ade79679-e8d3-4e7b-ac19-9554679c4dd8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA LEHMOX LE-23A 12V',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:08:43.874616+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '478ad7a3-ff66-4aa5-9244-e993de4adbc2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA CR2032 3V',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T18:23:29.301943+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e8db85e4-1bbe-4d60-96d3-b4fd7e310359',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONTE ALIMENTAÇÃO REGULADA 3.5A 7 PLUGUES',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T20:52:46.655328+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '00880c3e-f383-452e-85d8-b80fe1d2517b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'TELEFONE SEM FIO TS 3110',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T20:34:09.52855+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ce4447fd-a4d4-4710-bcb2-6c83e27ac834',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR SEM FIO BG KA-1100',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T17:07:31.205815+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bf8107a2-0b3c-490e-b83e-06bb9da69e50',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR LELONG LE-024',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T17:43:29.389346+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a62ff112-ff8a-4613-8621-506a01fada4f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PILHA GLACIER AA  RECARREGAVEL',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T17:48:28.334167+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1cf88987-771c-4af2-8db5-2f6da64bf7c3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELLULAR IT-BLUE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T15:33:25.780521+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fc4845c7-ce23-40b0-b9cb-b8a51141c379',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR LEMOX LE-21',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T15:34:04.587374+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '88faaac0-81a9-4487-9db7-3ae8e1e4a2a5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR E GPS HREBOS ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T15:35:12.64435+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '93855e9e-8c59-4286-aa4a-9f9fbf815e18',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO AUXILIAR LEMOX LEY-16',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T15:57:52.496258+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b3cddbf8-4928-43ca-8bd6-cdd338057013',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB CHENRONG ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T15:58:56.021746+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '77f04a5e-2e6e-4316-a8ec-6f004dd969ef',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO DE VIDEO P2',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:01:02.33889+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b92e3916-844e-46d1-aaf9-0db36c459dfb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PULSEIRA BASIK WU-269',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:03:53.256788+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8506fd00-74a8-4afa-90cd-0cf9af4afb44',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PULSEIRA BASIK WU-150',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:07:31.819616+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bf4de585-1ea3-48ab-9538-e4f7c0a2e756',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE SEM FIO BASIKE BA-FON6697',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:11:17.576974+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '693334f9-0851-4623-8b66-f5065e833d7f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE COM FIO O''GOLD FN-A55',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:16:36.193795+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '370f6fff-2dec-4763-aa1b-9bc9b9b199b3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE COM FIO O''GOLD TIPO C FN-A51',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:17:23.17672+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5f0de0e1-9e9f-4add-9744-bf85373b7386',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE COM FIO KAPBOM KA-717',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:18:36.188916+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5f00ca08-4aaf-4c7a-80bc-0a66c0a397e0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE COM FIO KAPBOM KA-718',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:19:08.097709+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f5fbd43f-18eb-4a80-8fb9-02d225ad7cc4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR  E GPS PMCELL SP-51 ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T15:35:59.550529+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1c581628-7b80-4b16-a7bf-849b0b2915d7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR E GPS TOMATE 5.5',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:15:44.260409+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '22accfb2-5192-40e8-998a-611176313d80',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR E GPS HREBOS ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:17:12.802125+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a8026095-4fff-47c7-ad31-7208c2e57bdb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE VEICUAR PARA TABLET TOMATE MTG-002',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:18:19.595621+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '018acbb9-7425-4fb3-a00a-49b36b50cfc5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR TOMATE MTG-008',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:21:11.503009+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9b6fdc9b-3995-48ad-80f4-3954f5284725',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR IN PINDI PD-26',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:23:47.510182+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9a0426bb-30d3-462c-aadf-f5ffa8664ec2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CELULAR KAPBOM KAP-C020',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:25:25.904961+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9eb88834-a03e-4123-b3f9-4ab845a4066b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA TABLET LELONG LE-025',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:27:21.192544+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5c0fe928-4644-4c36-a002-32c55fff8ce6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR E DIVISOR PARA IPHONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:28:36.193706+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '16acb036-4847-43c4-a164-65a2a68aa159',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR OTG AL-0303 USB 3.0',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:29:47.807109+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2acfd696-06f6-4fc8-b0ab-1db8ee4de10b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR KY-174 TIPO C 2 EM 1',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:34:59.774899+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cb7b2e66-cbd0-4020-af3e-530dc91fb048',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR TIPO C OTG USB',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:39:59.754734+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f914fb1b-d103-41fd-8e5d-05206b1079d1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR PARA FONE HEADSET',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:43:43.43838+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '21774516-cf1f-402a-98ec-defbde20661d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR USB  MICRO OTG ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:45:14.984975+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'dbb219c2-f860-48fe-a42b-2fd22699132f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE COM FIO LELONG LE-0213',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:15:50.538624+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bbff662d-7da7-4996-b5a8-91887bd387a8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PULSEIRA BASIK WU-255',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:06:00.505375+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd00f5ba0-b5f3-4007-bf4f-eb37c2999e6e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR USB PARA TIPO C LEON KY-002',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:57:35.720919+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '31d3cb65-5dda-4f96-8f33-f3cef3836438',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO LEHMOX LE-478 TIPO C PARA TIPO C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T18:00:42.995447+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8ae9259a-592a-4e5c-9bb8-3ce686fc3389',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO O''GOLD CB91',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T18:08:30.74567+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9583aada-6892-44e5-b965-5505eb05847d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR COMPLETO MI 120W',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:53:09.63743+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '068512a9-7e45-4758-9f68-0595344f443b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB AVULSO TIPO C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:01:45.386543+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '72f2c45b-08fd-4a3f-97d0-cb32357a8214',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO O''GOLD CB79 TIPO C PARA TIPO C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T18:30:25.647717+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '44feaa2a-3822-4efa-b942-0ad667e4fc41',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONTE POWER LEHMOX LE-487',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T18:31:41.00838+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '77c50b19-3dd6-467f-8b6a-a46c2ebda5dc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONTE SAMSUNG EP-TA300',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T18:35:27.312811+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e567c414-5388-41f1-83dd-41218d785c09',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR OTG USB P/ TIPO C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:47:03.134456+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9c716258-8b6e-4c8d-a52d-a4ced7a26bd6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO O''GOLD CB17-3 TIPO C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T18:01:24.068446+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bcf726b4-c9e3-4467-848e-08e7bf029929',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO AVULSO TIPO C PARA TIPOC C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T18:02:54.868093+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2402af87-eeff-4103-a671-04ef04327359',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE SEM FIO BASIKE BA-FON6694',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:14:16.318559+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fcaf38e9-ad20-4972-902c-0181dd3b6ecf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'pelicula motorola e22',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:22:09.52504+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '66811069-9bb5-4694-a23d-1e2f93deb0d6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PULSEIRA POP SHOP 42/44L',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:08:29.346261+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3f50f2b6-8894-4c7a-9cd6-414daa339cba',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPITADOR PMCELL CB-41',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T17:36:36.351975+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b836996d-be8e-42b0-a3c2-64c0864a8819',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO AVULSO USB COLORIDO IPHONE ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T18:26:01.21197+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7b5d8e56-5f8b-4a31-a82d-4b19ffe4110c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO BASIKE BA-CBO0101 TIPO C PARA TIPO C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T18:00:08.400169+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd525822d-c990-4de8-84ce-81a6828e0b6b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'REMOÇÃO DE VIRUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T21:22:35.336772+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'df9e4329-5253-42d8-9bf1-a9b2bef05c7e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR KAIDI KD-6705',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:31:39.29906+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '67f6a392-c12e-47ca-a116-6baadfa34483',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR O''GOLD CA40-1',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:32:57.778735+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '93445499-909a-4d1b-9653-d4fa161af9e6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR MI 33W V8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:34:10.891465+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '587e6b5d-fbf4-46d5-ae70-c3172fb3ff02',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB O''GOLD CB52-1 V8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:38:26.773376+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '14054b9a-c4a1-457a-ab2a-b32b32cab9c9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB O''GOLD CB0-1 V8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:46:35.111789+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a64b3a1b-7a23-4e72-abd0-5e39c1653d27',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB KAIDI 3M KD-330M',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:47:53.284043+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9b8c20b8-fcf3-41b2-8806-2cc2bac52810',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO PMCELL CB-11 V8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:49:10.650281+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fd9dfb58-d6d1-484e-a369-67b15ecddd9d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'GGARRAFA TERMICA COLL KATYFIELD KDFE-6214',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:14:31.216935+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd290db5c-49be-468a-8c5c-eb6afb8f7e68',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR PORTATIL PINENG PN-951',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T20:17:47.44212+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '14add4d8-faf9-4358-833f-833176810f03',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR VEICULAR TURBO MOTOROLA  8983N',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T20:21:05.149268+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '087e0182-d4f1-4425-9dd8-a61634cde50c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB CHARGING CABLE LEY-1842',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T17:24:29.145327+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '126029b6-b62e-43a5-93e6-1a0ed3dfcba3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB H''MASTON V8 H109-1',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T17:25:24.542512+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'df748c07-003a-40b8-8bed-0efbfb513bf0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB PMCELL CB-26  V8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T17:26:17.221807+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '071711ea-e813-463c-ad98-d640f3c4d899',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB HREBOS HS-255 V8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T17:27:23.520492+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b59202f5-511f-41d2-a250-9f3982c0f7cd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB O''GOLD CB09-1 V8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T17:28:10.421353+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2014e5d3-2b78-4888-a774-4a394d1a44a2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR SAMSUNG V8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T17:38:46.192409+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'edd47e40-3e70-407f-a574-e83dca3014e9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR SAMSUNG V8 ORIGINAL ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T17:40:03.722533+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bdb63f9a-70ee-4825-98fc-97eed3d6c366',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR V8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T17:41:41.9319+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '04e0e9a7-d59e-43aa-b59d-750a40cca770',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 7 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T18:35:03.163129+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0111b85e-3a44-460d-ba55-718b9a4cce9f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE GAMER BOAS BQ-9700 COM FIO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T14:51:23.448672+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '51e44c70-1216-4900-9525-f9027c5a2571',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOTO G52',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T21:00:01.718566+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3246e3a1-ac8a-49b4-8139-3e89cc00586e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G23',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T19:23:49.981281+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '58c1143a-40c3-430f-aab4-1846efed6267',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR O''GOLD CA40-3',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:30:18.538838+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '152952ed-3fdf-468d-9e19-87ac8330c7ed',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR INDUTIVO O''GOLD BTE-06A',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T20:07:31.258019+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e76a64cf-f24c-41b5-9d0b-a46b64103e52',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR INDUTIVO O''GOLD BTE-85',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T20:03:28.234184+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '31489610-3aa0-42cc-b2a6-ad4111ed58cf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR 3 EM 1 O''GOLD SEM FIO BA-WXC011',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T20:15:15.760633+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a16f640c-3216-4bc6-b9dc-f93cbadb0801',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR PORTATIL O''GOLD BTE-05',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T20:16:03.316114+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b253ca10-fe06-40a5-b34a-f9c35ecc1cf2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '2 VIA ALGAR',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T15:54:30.556612+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '712c1c5d-6bf3-4024-8cbf-774cdb790c09',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR RAPIDO O''GOLD CA28-3',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:29:45.847426+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1ab5b635-4a47-440e-956b-2ffe3cc8063b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE SEM FIO LEHMOX LEF-1039',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:01:46.091992+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '01757c6d-3268-4cd3-b731-520782a0f1de',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOT G22',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T19:25:38.496708+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b8e855d7-bd9f-481a-89f4-acb1520a7932',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE GSMING A65',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:05:07.901942+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '69e5734c-01e5-41b2-922c-7f463966adf1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE SEM FIO BASIKE BA-FON170',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:03:53.958433+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6d8270ce-e2b8-410f-b154-edfde64c9507',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE SEM FIO LEHMOX LEF-1029',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:06:48.729727+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '84215aa8-ed74-4d93-8c11-81742e17228a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'GARRAFA TERMICA TOMATE AK-1008',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:15:15.569616+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3972206a-aa98-4e84-94a8-cc7bc655e43f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE GAMIG KAPBOM KA-9007',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:06:08.529377+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'da4da1ff-a432-46f4-abaf-e1ecfe7cd691',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE SEM FIO FON-886',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:03:09.495446+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '02bce1fa-c771-4e5b-93ef-b082cef7372c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR O''GOLD CA19-5 V8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:36:35.798626+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a3bde72e-3bd0-4fbe-961b-803176fcffb1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA X6 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:22:49.804891+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bef88eed-4fdc-49e7-ab61-e687b6500823',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO AVULSO USB COLORIDO AVULSO V8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T20:19:00.959099+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1b97b8b8-c193-4011-8891-a20cc88cf408',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CONFIGURAÇÃO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T13:18:07.613011+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6d8e6634-2c0b-4591-9336-374f9ed5ee50',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR VEICULAR INOVA CAR-G5140',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T20:20:08.580149+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '96cfd0ce-f878-4ba4-93c4-85ecf1351416',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR PORTATIL ALTOMEX P3',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T20:17:01.546253+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '271afdc1-ab53-4ad8-9760-fc398770a8c4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ARREGADOR VEICULAR O''GOLD CJ12-3',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:27:48.62777+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b0b26a23-c22d-4421-9c38-cdca4ec26e20',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO AVULSO USB COLORIDO TIPO C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-20T20:34:26.382352+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bac8c341-d160-403f-a19c-5462b405c584',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'GARRAFA TERMICA STANLEY  DOURADA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:15:54.336985+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3048ea2f-84e8-4fe3-bb12-869b98c40302',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'COPO STANLEY 1200ML ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:24:11.269762+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ca505d68-4c05-426f-95f2-f49d2f148a9a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'TELEFONE FIXO COM FIO PLENO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:27:51.336059+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3498551b-71e1-4066-84ea-ae0fbc8b8abf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'REDMI 14C 16G DE RAM 256G DE ROM  - EMEI-864120074767287',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:49:00.64074+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '99fc5c54-6ae2-4352-ad5d-881ff1aa20d7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LAMPADA LED COLOR ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:24:02.195324+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '147b8d75-c4e0-4f19-a770-86c71117e9ff',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LAMPADA ALTOMEX LED WJ-L2',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:25:41.196906+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a8a348d7-a953-4a19-964f-fefe484a5ca2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LOUSA MAGICA KK-1055',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:27:19.998468+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'be4ead02-0cfb-49df-943f-d46f907cafb3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'EXTENSÃO TOMADA BM-8696B',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:29:24.142365+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'be194404-efb5-469b-81bd-018bc1eaa5b7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'RELOGIO INTELIGENTE BASIK PRIME W48PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:33:21.13099+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3b22ca4b-6ce8-4e81-b8b6-961d1810a1e8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'RELOGIO INTELIGENTE BASIK PRIME W73 PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:33:52.106096+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '154dad9b-59a2-4c70-a337-f328c5001833',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LANTERNA DP LED LIGHT DP-770',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:35:36.627986+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd0e87359-340a-4c90-8b51-20b72c4fe307',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LANTERNA MULTIFUNCTION SWAOT ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:36:30.038149+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '270c9652-0734-4cb6-9e11-7ced5725b5b9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'LANTERNA RECARREGAVEL USB KAPBOM KA-L1300',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:37:32.285506+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bcaf2952-bd2e-4bb4-8638-18b5d68695b2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'RADIO BOAFENG BF-777S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:45:08.605335+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b1b21b20-8722-4995-b481-93a971dbf352',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CALCULADORA LEHMOX LEY-1894',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:50:40.780941+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9f7d6066-4e21-44f6-9e95-410e25c5b5a5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ISTOLA DE COLA QUENTE ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:52:33.447182+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8c6f2ce0-d462-495d-ad4f-fa252a936c73',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CALCULADORA LEHMOX LEY-1900',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:53:50.174391+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '20bcb3c8-3dea-4664-b935-4746affdad97',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CALCULADORA LEHMOX LEY-1897',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:55:19.837884+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '18b50c57-d9ec-4cb5-bc97-379783037127',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CALCULADORA LEHMOX LEY-1891',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:54:32.207172+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '626d2070-565b-4a3c-9666-c96f7aa832e9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONTE INOVA CAR-5203',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T19:37:30.656649+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b1f3e204-86d3-42c2-9a06-85c1c22b58b3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARRINHO DE SOM INOVA RAD-20339',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T16:13:45.842282+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ed8d6eec-e420-47af-9383-297fef6fd904',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM H''MASTON AM24 ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T16:51:00.428014+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2aa1a4f4-6a0a-4976-bd23-593cc1c65e84',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM KAPBOM WS-528 ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T16:51:46.104915+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b703b395-b73e-425c-b2ca-b860926c3b87',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM INOVA RAD-20436',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T16:52:20.069579+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '53f73a71-643a-4bea-8723-bfc37aefb556',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM KAPBOM WS-538',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T16:52:59.500789+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b5c37a88-a340-41bd-ab79-f61569e69512',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM KAPBOM WS-592',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T16:53:36.561313+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b67cc26b-d3e1-48e2-9fca-f44fb8abd2ff',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DESOM INOVA MD-570',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T16:58:13.463635+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '63b72d6a-1490-4d6c-9c79-4ea69633b006',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM ONOVA RAD-12333',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T16:59:33.016447+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1984d002-6c50-42c6-afe9-bafc67790103',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BOMBA ELETRICA PARA GALÃO DE ÁGUA LEHMOX LEY-57',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T13:51:45.090915+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f6c7b1af-fef2-404e-ad3f-0999614b9789',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CHAVE TIGRE IT-BLUE 360',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:04:47.720287+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5865303b-efdf-433c-8b1d-92493f0ed558',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CONTROLE COPIADOR KAPBOM',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:05:59.705104+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7b9df4a9-3aef-4446-b934-aaf0d5382554',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CHAVEIRO ALTOMAX AL-B5773',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:07:41.00048+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'de121f95-e9dc-4ef1-9c61-b3b1a8a61626',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM PORTATIL SOM BOX D-X338',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:14:35.590427+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7da7b5ae-3035-4231-aece-a484255fe807',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM ALTOMEX AL-652',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:27:21.362485+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd6c90066-9e24-4cf8-836b-2b77e080d6f7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM BIG SOUD KTS-1204',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:30:27.890238+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4afd7da1-e17c-48bc-8fb5-65ba96c76678',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CHIPTM',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:36:17.996984+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '58894601-aeff-4528-955f-cbaf358d8918',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM O''GOLD SM-20',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:40:44.783439+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cb196fcc-828b-46fb-9b4d-5797d05a52e9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM MULTFUNCIOAL WIRELESS Q3',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:42:51.118814+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'dfdcff1e-1709-42d7-aad2-16f87dd6f4ab',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CANECA DE CERVEJA WU-005',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:58:24.456972+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bf5f49b9-65ec-4363-9a8f-ceb0eceedfa0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'COPO TERMICO COM CAIXA DE SOM STANLEY ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:00:19.435567+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '76599287-f2ed-43d9-bdca-d4210ac3fd68',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'COPO MAGNETICO 380 ML',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:05:26.64381+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cd74bd7d-cdec-4a6a-869d-2c7db0439ba0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MARMITA ELETRICA LEHMOX LEY-2200',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:06:17.06085+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'daf0f88a-37c9-4ee3-84f4-1bdc69ff3bcd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'COPO TERMICO STANLEY BEER PINT',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:10:26.797997+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e0a25678-4079-47c9-8a61-dc0e98ca955d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CHIP CLARO ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:35:26.30647+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2bc7c380-2bf5-4d3a-abed-ddaad79687c5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM KAPBOM KA-8709',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:37:38.718681+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0307066d-d220-467a-8fd4-a98e924685cb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'REDMI 14C 8G DE RAM 128G DE ROM  - EMEI-863998071199104',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-21T15:50:08.934329+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '90e7b52c-6390-4480-be6f-7e6f95ec1b95',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CHIP VIVO ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:36:59.77014+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'dac3c975-b64b-4159-93d4-c8168688fbd4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'COPO TERMICO STANLEY E SUPORTE PARA GARRAFA BEER PINTS 420ML',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:12:19.741231+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cff3a84e-20ca-4527-aaa6-f47c1a762622',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FAQUEIRO CERAMIC PEELER ER-009',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:14:25.886706+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1a321851-46e0-42c1-bfb5-a9aaf5ca71d4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA FACA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:18:30.843528+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e3b8578d-2ad0-4bcb-87b1-adf19d3893a5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MACHADINHA PEQUENA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:20:11.990091+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f58a45b2-817f-45df-8e6c-2c78a63a783c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MACHADINHA GRANDE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:20:31.584507+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '46678517-84d9-44e0-b6c2-c4068dea04cf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FACA LUATEK SLK-A147',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:21:40.014666+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd712d246-d775-4abd-a50d-b7c187d899a6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FACA LUATEK SLK-AF61',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:22:58.5239+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1d694498-ffc0-456b-969e-8b87ff47f10d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FACA LUATEK SLK-A40',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:24:28.716965+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2907b275-65c6-4e3b-a89e-76af3acbd789',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FACA LUATEK SLK-A157',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:27:07.167309+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '89b7189a-49cb-4c54-84f3-cf2f2fa122a0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOUSE PAD GAMER KNUP KP-S08',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:32:35.406229+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9719b8b7-85aa-4a3b-97fe-dc0a172479dc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'KIT TECLADO E MOUSE OPTICO COM FIO TOMATE MKT-01713',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:38:16.229874+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e73f859e-cdae-4f4d-ba3d-737a4733cbda',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'TECLADOESSENCIAL SLIM COM FIO  USB TOOMATE MTE-0107',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:40:22.875064+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a91a1710-1e0d-4863-8db4-27f7d0d69702',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'TECLADO O''GOLD SEM FIO TCD-02',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:41:49.343857+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '029985f1-c697-49b1-ab01-d2e07882bd9f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'TECLADO LEHMOX LEY-171',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:42:44.630103+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0f8b88c8-e502-4220-83d7-4476c95bb12f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'TECLADO LEHMOX LEY-174',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:43:23.428682+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a142a142-0780-4467-8dc2-109bc21a3e20',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'TECLADO LEHMOX LEY-2080',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:44:00.778787+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b37bcd11-4e81-4961-b773-e19768e7ef3d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOUSE PAD TOMATE MTC-8030',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:47:20.511083+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fd8e9610-209b-4bab-91a0-59e04992f7a7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'GAMER MOUSE PED B-MAX BM781',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:48:00.392018+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '56995104-bcc3-41c3-8092-83ac379776d5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'COTROLE PS2 - PS2010',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:48:39.975302+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4c296680-4198-46c0-99f4-b2faa739b6f3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A04S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:00:11.926929+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '122a175a-e7ec-4ed2-9399-756097ad6248',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE SEM FIO ALTOMEX U60 ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:54:18.201596+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '17c2d817-b24f-4b3f-a7b3-f2528744e9c1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE BUETOOTH XBOX 360',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:55:32.106003+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '90dcc74b-cc0d-437d-912d-59e54ab67a77',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOUSE KNUP ANUBIS V4',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T19:02:43.933634+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4a8adae3-0e29-465e-b15f-dbe2ebe1e325',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOUSE GAMER WEIBO  WB-5150',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T19:03:22.897318+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '77bbca4e-3e37-4c7f-82e4-9211d1ba56f1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOUSE H''MASTON SHA-07',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T19:04:43.54597+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd3b3a250-b555-4c47-ba72-98add6991c64',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOUSE LEHMOX LET-26',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T19:05:42.077021+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bffb8c49-ce79-4370-af00-95115320a16e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CONTROLE GAMER DOUBLER - MOTOR VIBRATION 4',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:49:47.237582+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9dceec20-0f34-4f3e-863b-9c1653ab086d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A13',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:20:35.880111+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bcc02ebe-3f7c-4494-9a2e-05567f1aa50d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA IPHONE 13 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T16:01:25.701724+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '66616d6e-1251-4d39-819b-bbc51ab84d2a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOUSE PED CLONE 04200',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T17:09:58.123863+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2e9746a1-b65e-4b30-a7f2-6c6878b7beea',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOUSE PAD PURUS 1106',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T17:09:08.029926+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0f58882a-c71d-4474-88a2-f330325932e1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PE DE MOUSE KNUP S04',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T17:21:03.510872+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0633b17f-6ea8-4d79-979f-b0d825dd3a31',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A02',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T17:38:24.27183+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0b4fd782-6906-4071-a357-116096732867',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA A02',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T17:38:47.651816+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0f63de98-52ef-496a-bc55-beffb5126ef0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A02 S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T17:39:20.268681+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6d98967b-f3cf-42d8-a6ff-a5fe8ed7507a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA A02S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T17:39:39.424928+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd4fd5753-5e21-4b69-bd6e-d6fa19db7a80',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A03 CORE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T17:55:21.950362+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7a743e43-dfc0-4617-8c23-31070adf4290',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A03S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T17:57:37.119314+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e2eb3724-f475-4d68-922a-1bb71b392c5e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A03S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T17:58:05.630469+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0af282b4-1436-4cf3-8325-ce57f461ef63',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A04',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:00:57.749955+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '10b5d52c-1585-4dca-858e-879924d44a49',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASER SAM A04',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:01:59.805996+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '21d3cd7f-760e-4071-b49a-8810c07fa8cc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A12',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:09:49.523406+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7fd442e3-01fa-4bd6-941b-15e49687287b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A05',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:05:26.494616+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2750a1e6-519a-4f59-8b9e-8340082ab327',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A06',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:05:42.895685+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6548a024-5e99-4a76-b2e9-4aa376afd889',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A10',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:08:50.438723+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '94e1264f-18e6-4157-8614-c9ac978c5d36',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A11 ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:09:30.144607+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '223ad39b-e95b-432b-adee-846a6cc19ed9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A10S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:07:58.802244+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9c33711d-7e17-4cb9-9393-ada074cee957',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A04',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:02:19.486787+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a65430a9-8d34-4153-a687-9f613ae0c341',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOUSE O''GOLD MS04A',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T19:05:13.192014+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'dac9846b-4482-4692-b4f7-414dd761aa29',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOUSE COM FIO MULTI MF100',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T19:03:53.387795+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f50daf0a-2ef5-45a4-8d0b-d1aa75b0772b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONTE 12V O''GOLD',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T15:58:13.988762+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f42a9c16-d2f2-4ba1-87e7-1d38e85613e2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A15',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:22:05.271056+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '71cc58d9-1200-4afc-80b8-9d2e014167cc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A14 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:22:29.606059+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3e65d9fd-64e4-4859-b59c-0c5d9b51ac16',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A20',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:25:19.519422+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6e2bb6dc-c32c-4312-8c6c-65ed2aed77bf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A21',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:25:50.577535+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a4c5d05a-4ad2-4bc4-8179-bce09d764939',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A21S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:28:40.961995+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c40096ee-ca4a-4cec-a600-8f243dcd4fef',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A21S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:29:08.389571+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0aa173ff-dd83-4b0f-8073-f40bb185feb1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A20S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:36:39.435842+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '46f7e227-0831-49f4-bb81-e2d76ee3ef74',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A20S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:37:05.530442+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '73436daa-76fc-447e-a556-7538238464cd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A22 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:42:30.047346+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'de043f14-a664-42d9-9453-2ccc4bb371f7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE  SAM A22 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:43:10.189875+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c84afcc7-9514-4ecb-9a55-14bc9a46221f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM A22 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:43:36.25953+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3dfce755-666e-4f85-959a-247f8eafd524',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A23',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:44:59.848983+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'eeb3734a-071f-49a6-89c0-c2db448ccc29',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A22 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:41:25.436642+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'dbdfd5f8-b104-4add-b4f2-93392061ef02',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM A22 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:50:13.440435+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ceac6b7a-ff33-475e-8d6e-c51008895ea5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A22 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:50:57.784214+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd777321a-7d3d-417c-9844-be4abdb550f1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A30S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:04:20.900569+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '86936022-df21-4945-9811-7458c62f092b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A30',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:05:07.113614+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8e5fa29c-fe92-4e03-a67b-1911af6b8742',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A31',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:12:04.543665+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '197c7a45-5291-4785-8928-030d5e1844ca',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM A32 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:17:12.342289+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9c984979-964b-4230-88f7-9b8fe208a265',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A32 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:19:09.592799+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '08686142-3a85-42b2-a6f3-4b94f8549c4f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A25 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:52:14.995739+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '20334947-4e55-46fc-8446-0147f8e9bc5d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM A32 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:16:46.822033+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '50bfa15a-9846-45bd-b7a8-6a921723cbcb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A56 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:48:36.595398+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '504f759d-129a-4b08-80a4-d414bd6be7fa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A71',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:47:38.757361+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '87bd0fd6-01f5-40ad-826b-05824b388a05',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM S20 FE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T20:11:45.587372+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7532c6e4-eae4-48be-af07-a0deb50d4dfe',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A33 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:27:05.409932+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '24c346d9-12f2-46e6-bc27-b9e0662bbcf1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A34',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:28:29.204741+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e76111a7-6d36-4062-b44a-7d1a00ee3af1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM A34',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:28:53.048568+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4f38be46-aa47-4168-b74a-9671c9e0bf11',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A35',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:30:56.500413+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'eb1c56b7-f712-4fa7-ac28-19d1683e6c07',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A50',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:31:32.954864+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b1137e7c-d6f5-4e90-8af0-9dbe096a79ae',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A50',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:31:58.378255+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd6d0d235-25b1-4711-a27a-458dcac1571f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A51 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:39:40.439658+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '876b8ad2-d1e4-40b5-92a9-abaf878695a3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A51',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:40:02.361382+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '30bdaaa4-7f4c-4e0b-bce4-9c7024292f65',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A52',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:41:07.35994+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e830c272-64fc-4a35-aacd-da9c819ec319',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A52',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:41:27.373726+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '91cafdbf-c938-4571-99d1-fdc6e756feda',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM A53',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:43:00.996495+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd75b95a7-352b-4c3e-ada1-c2215021c71a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A53 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:43:36.25625+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '63dc051d-fb9a-495c-aba4-f1a9e6f0f074',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A54',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:44:01.891949+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '69669c94-0107-4ca5-ae75-9e24114647bd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A70',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:47:20.222352+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '528e042b-9278-4859-9fe6-fc9e0ac9f888',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM A73',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:51:11.513201+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd2bbbd2e-06f0-485b-a279-052b2595fc29',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM J8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:54:14.259862+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a0759b36-7556-4a9b-9bff-34d731c6725a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S9 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:57:07.652361+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a2ce54a7-e6ec-405a-a7da-de4b2baa2c26',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:57:59.743585+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '059ca2a5-2eaf-4b6f-a315-151e5102ce72',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S20 ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T20:05:24.559625+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8fd72da9-65fa-4267-a5af-4e635fa73dee',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM NOT 20 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T20:06:19.780105+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'de2ec469-18e6-4c78-ac20-8d5d5375d671',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S20 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T20:06:54.483765+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a266a659-f69f-4b34-b833-f04fa64f0e63',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM S20 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T20:07:34.707846+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ffab66af-44d9-4c65-9f3d-4d0d958c0b56',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A32 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:19:29.372626+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '188c0bed-1254-4aa0-af35-5eaec7ae0ca9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A73',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:51:30.023763+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '689a639b-d138-468b-bd74-bbc9ef96a960',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A72',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:48:04.520966+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '44ea9d62-be69-4f03-b1ac-f72413f2baec',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A23',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:52:45.699001+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1b914213-b90b-4b2f-888b-4ffc79b804e3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A31',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:11:50.464511+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd77b81f7-5e51-4ae0-a6c7-7ab429b0c44b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A32 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:18:33.976735+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '265c3b6d-fe28-4fe0-badd-74f5ce63ac98',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A23 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:45:27.622268+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0c4b1cae-1e38-4b78-b5fe-f3b02645d4c5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A23 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T18:53:14.969708+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3493c8e6-d718-49e0-8524-8e78d3666a6f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S21 FE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T20:13:27.507181+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd6a3f5c8-6865-4c28-b109-4798157d650b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S22 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T20:17:04.413316+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '076b1911-ba5f-4080-af32-9da2104a3b2b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S22 ULTRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T20:33:29.170858+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5a0b6188-4688-4483-ae9c-4388057b92fa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM 22',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T20:33:59.457015+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e2b1028e-de58-4b36-8958-f0f011717ecd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONTE O''GOLD',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T20:55:44.164936+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '587ae32b-6ed5-4b09-99f9-adf5a260984f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S22',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T15:34:02.382672+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5317006d-8d51-44a1-a13f-1746e63d8c49',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'RECEPTOR DE TV CLARO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T18:04:05.712559+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e8efb815-93a9-450f-8382-76c7ad6a8315',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S24 FE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T15:40:43.922674+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a00f268e-b105-407d-8ad0-c9e38364f7dc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S23 ULTRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T16:37:47.063472+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '90f6be11-c319-4508-a4f4-5d17e8cda742',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S24',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T16:38:24.81108+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8f367561-728c-4550-8b5b-6eed6525ddf6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM A51',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T16:41:10.995499+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0350fde0-edc6-4076-a919-da9af1dfe054',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM S21 ULTRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T16:42:01.076911+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c3b57b24-4753-4a9e-9c87-dc316f920071',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM A23 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T16:52:03.849655+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd267b090-d9e0-472f-89ce-ff4b19a9523c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM 24 plus',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:13:40.932359+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a16f2bd1-c202-4657-b560-929f6b70f2c1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MODEM TP-LINK TD-CG5611',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T18:05:17.056145+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '898ade38-ba70-468e-ae95-de64498eb109',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM A70',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:16:55.287997+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5484d4a9-3e92-4034-b7b9-351bb51eee25',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA SAM M23',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:18:32.407239+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '68164e44-943f-4f05-a30e-4dd557641588',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONE SEM FIO O''GOLD FN-12',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-18T16:12:41.193239+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1b5d69ef-a726-4358-86b4-456b79bbfb44',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM M32 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:19:07.630419+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '68a4f8ef-49b5-42fc-881f-a9d556669bea',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ALTO-FALANTE INOVA RAD-12423',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T18:40:45.359065+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f71ef927-9b50-40c7-85f3-e2c4de8916e7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MP5 PLAYER PARA CARRO 2 DIN LEHMOX LEY-2069',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T18:41:44.906661+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '600e7378-0744-430a-aa64-277117596ffb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MULTIFUNCIONAL LASER LEVELER BOM -6203',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T18:42:54.413068+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '98e43aa3-dc79-4223-bcfc-9eafbeb9cabf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S23 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T16:35:07.225009+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '73402ffa-c3de-42ad-ad5a-0842a5da1f36',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SINCRONIZADOR AUTOMATICO DE ARQUIVOS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T18:44:14.073555+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3ef37ef9-0949-44b1-806e-4afadc16843c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM S23 ULTRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T15:36:46.390733+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '50a9bc4e-1477-4bd8-b672-2fc58f319e7a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM A03',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T17:57:00.870947+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '00724312-d044-4871-8c86-040a9f3918df',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S9',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T19:56:40.12733+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '285cd3ea-eb49-48a8-abaf-4109135afa34',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM M23',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:18:06.337965+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f06d59f6-becc-4e47-9330-c7fcae4acbe5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM M13 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:37:17.57411+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8c5c9a08-28dc-4f2d-a2fc-70ba5936b24d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S20 ULTRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:11:31.791975+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ec4928da-d9d6-4041-95e6-ab0829b410df',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM M31',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:38:30.324384+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f172283a-fbbf-43e0-b1e8-612d269043c9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MULTI-FUNCTION 7 EM 1 ALTOMEX TYPE-C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T18:46:19.366137+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'eebfcb81-18e5-49d7-9bae-dbd73f16ad0a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S21',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-24T20:13:10.909262+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'dfca40b8-108f-4cd3-b5f4-682e383839c8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM M33',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:51:13.513017+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '714e6adc-b863-4e28-9875-0b951e5c5dc6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM M51',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:52:52.649024+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2dd2742f-25db-4085-9593-ee3d1de878ce',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE SAM M52',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:53:23.710785+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c455b403-e679-48e4-aa3f-f0a92a20cd5c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM M52',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:58:13.833671+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f390f5c2-5f1c-4efd-944c-aa8113495027',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM M53',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:59:23.595332+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ad6544e3-32c7-44ed-981f-c4144a4a4938',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM M54',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T17:59:48.03448+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '74697987-780b-44e2-b78f-449530d00ddc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM M62',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T18:00:41.39595+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '15cb2c62-459f-4d38-97d5-ffb8ff99a1a2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA PRA CELULAR DE CINTO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T18:02:10.715062+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f3f4c8b8-1ead-4ede-acda-14390bbee9ef',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR USB LOTUS LT-H008',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T18:48:05.106215+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '28c8e57e-1dc2-430e-a123-a04a0c4ef233',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CONVERSOR  OUTPUT VGA/HDMI',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T18:49:34.181956+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9636fc65-eafa-43a1-b1c3-6830333f02fb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONTE PARA TV BOX KAPBOM KAP-1181',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:00:22.070042+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '47e95e31-80d2-41dd-be53-a1a9085be25e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE HD EXTERNA ALTOMEX AU-90',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:01:56.491043+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '480d6a94-431c-42cf-b418-0c0f91d9c9ec',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CASE PARA HA SATA 5.5',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:02:43.241428+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7dd39ed8-cf41-4a43-8f09-2a9b80ba95da',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA TV LCD-800',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:09:59.37235+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3ce26bac-5bb7-4691-bb54-11e89c3af782',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA TV LEHMOX LEY-22',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:10:34.164372+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ef5550de-ce8c-45ba-8ac4-34febfba4a02',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CONTROLE TV BOX KAPBOM',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:11:42.675872+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '33b27a0a-2a76-4ad2-a2a5-a7569c5e1e31',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MINI TECLADO KEYBOARD ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:12:49.250385+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b68c0161-6442-4e1f-83be-e01da75e9ad3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CONTROLE PARA ARCONDICIONADO AM-0035',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:16:28.54935+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3ada577f-642c-4877-b893-8df28fbcb181',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CONTROLE SMART PHILCO AM-0012',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:26:25.49462+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7af2e2ac-c197-42f6-8bb3-9e266f1a686f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FONTE DE ALIMENTAÇÃO IT-BLUE LE-0186',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:28:46.936006+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f9d7fe31-e02f-492f-b004-bc4657b7af77',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR AC KAPBOM KAP-360 ONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:31:31.029954+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9837204a-168a-41be-9b20-1fdd90170cb9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR AC MICROSOFT  A10-120N1A',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:33:37.076169+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '33a0ed6f-7d3e-4703-b819-993f6d41c4db',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO CONVERSOR HD KAPBOM KP-V079',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:18:23.551452+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '872b1060-3448-49d1-af82-4f269fe0d0ea',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO ADPTADOR DISPLAYPPORT NOVA VOO X-005',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:19:06.126812+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '862e1d2f-cc4d-4d9b-abe1-5f5e033894b9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADPTADOR 3 EM 1 KNUP KP-AD118',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:20:55.556423+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cc5a423c-8336-4ae3-8998-5c83586926b1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR V8 PARA HDMI',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:24:36.857557+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '345b8dbb-e17c-4f76-b856-0364c6acde54',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO ADAPTADOR HDMI PARA VGA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:25:29.548603+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '57f35d47-6e58-4274-8f37-e9f97315dbdf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO DE VIDEO VGA PARA VGA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:29:05.428121+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b1840b2d-28c5-4105-84f6-bf0f5bfdb135',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO DE REDE O''GOLD 1M',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:31:20.57247+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a22ffae0-5fd9-4777-bee6-34c9839b4294',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO DE REDE O''GOLD 3M',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:32:39.117688+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b5ce5613-4973-48f5-b75a-7239d6e1dc77',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO DE REDE KNUP 3M',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:33:20.944149+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f04626e5-f919-464c-a426-ccd502f432d2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO DE VIDEO KAPBOM AV-33',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:46:36.826081+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f4e5937e-99ff-4a30-879b-0a957b4a4bf5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO DE VIDEO IT-BLUE ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:47:05.949865+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '23ad2647-87c7-487d-a623-bdcf6c324a08',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO CONVERSOR HD VGA ALTOMEX AL-VGA100',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:49:48.221809+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a5a016a9-4ddc-49ca-b024-817024424ddc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO HDMI KNUP SM-KP HS-HS100',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:51:09.107634+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '459c07d2-5985-4c3c-8706-72929f0a0e69',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CONVERSOR DE VIDEO HD INOVA ZJF50003',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:52:07.183407+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2d5d9956-02c4-4951-b901-e4e53aee101a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 6 CARTEIRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:53:32.943849+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fb44bb35-ae33-4032-bc54-d8edb77217e7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 6',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:53:54.169935+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a31812e4-73c8-48db-8f75-76917af4f847',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 6 PLUS CARTEIRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:54:24.428988+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8d610835-b8d4-49b4-b672-3bdfe4296a13',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOT E 6 PLAY ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:54:53.265555+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '878aa701-2f22-4031-85a2-0201bcca2dd3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 7 POWER ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:55:40.722962+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd233d3c1-268e-47a1-9884-8cd8e1d8a42c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 7 CARTEIRA ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:56:26.558787+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c6a6e891-a58d-4272-926e-80b763a55afc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 7 PLUS ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:57:01.566504+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'eede86c7-609a-4cf3-9652-a044f60007d4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 7 PLUS CASE ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:57:40.255743+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e2564b59-b457-4ba2-8a43-f73515ead1e8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 7 POWER CARTEIRA ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:58:02.463839+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5f733bd2-9905-4fca-957f-287acd1a2317',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 7 POWER CASE ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:58:30.182212+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '265bb357-6dbc-4a94-8ca5-dfd7c0ff42f0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 20 CARTEIRA ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:58:50.819707+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a04018e4-a391-4fca-8ead-445f93a29f73',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 20 CASE ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:59:44.097099+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '685148ec-b7a1-4ddb-aa59-a200c85853c2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 22',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:00:04.980083+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4ff46c0f-497b-4a13-9ee2-a77f8cf5403a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 30 CASE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:00:34.116554+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7d0062bf-21b5-4fda-bc44-1d86370d6cb3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 13',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:01:14.060115+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cd9bda3e-477d-459b-9873-0ebcbf630646',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 32',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:01:40.543018+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '414e0239-fc76-4104-8ba9-242fbf7176ed',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 32 CASE ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:01:57.25866+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'feda2f92-5de2-4090-a267-002ba4859cb0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOTOROLA ONE VISION CARTEIRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:02:36.035205+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '07fef9d8-0aad-4274-8496-c3d340ad356c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOTOROLA ONE VISION ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:03:06.967207+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c6341aa7-d30b-41d3-bfb8-d19e1bbe5601',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOTO EDGE 30 FUSION ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:03:36.187126+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8256c50c-5142-4089-b4b5-274191645c68',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO  ONE ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:07:27.946398+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '019aeda3-5f8f-44d3-a703-e65d0d3de0c7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO  ONE ACTION',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:08:13.209928+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e9df01f5-97c1-417a-8190-4e184bc3bffd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G04S ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:09:19.505139+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '271d8670-1b1d-4626-80d2-bbe96382e75c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G6 PLAY',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:11:32.856609+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6f55b41c-514d-4173-bf7a-f55bf3ff54a2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G6',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:12:10.9039+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '189bc4f9-b5db-4003-896e-c7a771075ad6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G6 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:12:37.158584+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2a49534f-ac6a-42a4-b020-17e0769f7df5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G7 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:13:03.525557+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e466dcc0-29ea-440c-8980-d498f1d21940',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G7 POWER',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:13:26.015389+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9029b88d-0c77-47b6-9e87-7ca3b2210ad4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G8 PLAY',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:14:15.190971+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '754fc118-4a65-43b5-94e0-3b00014ec9cc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 30',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:00:52.013249+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f800fff6-b281-41dc-beb8-badab53dbc4d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR PORTATIL B-MAX AB019',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:29:36.883704+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0571dfe6-51c0-46dd-a6bf-6ba46e94a9e5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'MOTO ONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:04:00.589319+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6fc81740-4180-41fd-9e42-893b500fe0c4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO E 20',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:59:16.228913+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7f9f6211-2548-4d9c-8b45-d458205cc3da',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO HDMI 2M KAPBOM',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T17:50:23.313613+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '46077f59-e980-4e27-8132-ed0e5b3959b8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G8 PLAY CARTEIRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:14:51.632509+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c3634265-0fef-4c94-b373-afc6fd6358d1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO  G8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:15:08.759762+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '14732c63-9405-44c9-9a90-fcecd87b9c04',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO  G8 POWER ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:15:38.436446+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f41f0ea0-bd6b-4d7e-964c-c84e5b85165d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G8 CASE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:16:02.196557+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a0e6dc35-e2cd-40a0-ab2e-08a472cc9d15',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G9 POWER',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:26:35.719459+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '57d9c9a7-212e-462c-a9ca-aa8d5c5c5ddb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G9 CARTEIRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:27:00.280323+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '25819b64-789f-4414-964a-9006c40cf6c4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D M33',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:48:51.101165+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0a4745d0-67c9-4df9-90f3-9015bd4f87e1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'DIVERSOS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:56:44.404297+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2d8e872c-67b7-492d-b4f2-f79d34adc8f9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G10 CASER',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T19:14:35.456908+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1d124f7e-a9cd-40b7-9068-6ed776e7519e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G10',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T19:15:23.393564+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '451697cc-4fde-469f-af95-f12e9beac66c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G53',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:26:27.214533+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fcb898e1-5110-4d9d-a033-5edba3ce7970',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR RAPIDO OK''GOLD CA32-2 IPHONE ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-17T14:03:11.750916+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0fb2b529-217f-432b-b1ce-0d76576419a4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G24',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:24:04.113919+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c47d4956-e607-4854-9795-15803a31e87b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G23',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:24:34.094362+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e3c143d1-d4c6-4fc4-ba55-1d8ccb201582',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G32 CASE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:24:54.077138+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1a702758-8f96-4057-bc4e-8df55523fc6c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G32',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:25:14.11628+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0d9d3a8a-5e44-4c2e-a2e3-1c5a6a5a2d95',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G35',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:25:32.852631+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bd521095-e0e3-4a21-9250-4c0e39d60240',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G55',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:26:09.08915+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '64c29919-bdfb-4e1c-b67d-81ae6f536af3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G51',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:26:49.543008+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e0838982-e48e-4698-a4ab-75d99f050733',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G50',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:27:16.306778+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd9dc7689-1f85-41d5-9c3c-3907d87b622a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G60 CARTEIRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:28:38.149981+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8e19a421-3db6-4f05-8dfa-abf83c0de786',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G60S CASE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:29:30.116791+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '84ccbf3e-64f8-4bd7-8c12-ca90280efbc8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G60S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:29:59.870992+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cf94102b-c5e1-46ec-86db-d8c358497c42',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G62',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:30:47.717996+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ddd11642-a39f-4c78-953e-0a6616e59140',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G64',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:31:02.251271+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0a997e93-41f0-4b54-9ac1-dae9b3b9e60a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G71',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:31:19.643065+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '79306af1-da65-4848-bb8a-af41b42386c7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G71 CASE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:31:42.672743+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9952eedf-1f10-472a-9004-a06c1ff2753b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G73',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:32:02.047748+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2a04b6d6-5591-4dfa-b1dc-2a512a6c6f58',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G82',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:32:17.864376+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c499b1db-4ba1-42ed-833e-3d38bbecfa8f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G85',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:32:35.740578+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4a6728e6-896b-4592-b48b-58393030ff5f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G84',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:32:52.799858+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '95fa16de-89ef-4ea6-b9fa-7f7ad82a7e6d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO ED40',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:33:22.830783+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c2b1533d-79a0-407f-9ea7-2a4cc6c622a6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO ED30',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:33:39.864641+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a4da98ca-b945-4d7a-89fb-3721113912c4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO ED50',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:33:54.360053+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ec48eb68-716c-458d-8014-ec6994c842b8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA POCO M5',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:37:43.303495+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f1e09dd8-0029-4881-97f0-7e053fe942e9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA POCO M5S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:38:09.637777+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f9abea12-c0f8-4b27-b9d6-913509cac9b0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA POCO F5',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:37:08.157353+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b0e2bd1f-fd9b-4b31-81a0-477d3b1b9caa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA POCO F5 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:37:27.922071+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '38bbdabd-d0da-4cca-bc23-93c7211fe68c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA POCO F4',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:36:52.500204+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '71c4e85f-b335-4dd3-8416-bde3508f46fd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA POCO X7',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:36:30.829715+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '09c0297b-864a-4aa1-a5b1-a73f4d23916c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MI POCO M4 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:36:07.305131+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '50b1d882-38d8-43e6-9a56-972b6aa6bf39',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA POCO X5',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:34:36.530647+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '621cf7fc-5bd0-4a99-88e7-ea57548e4843',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA POCO X5 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:34:55.674383+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0b3847c3-44fe-4e97-8db5-08839c88b907',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA POCO X5 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:35:42.859248+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd3654b6f-83af-481f-b210-0c46aea3e17e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA POCO X4 GT',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:35:25.445436+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fce6586c-09ce-4418-92dc-b6e8ec537f3d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA POCO X3GT',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:34:17.211631+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6587802f-875d-4d77-8387-21f556188a69',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED NOTE 7',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:49:33.937221+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '724c5359-f401-47bc-87d6-6e0e11e34235',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED NOTE 9',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:49:53.02325+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c546697d-0fb3-4b84-88b8-f7573751b279',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED 9C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:51:01.368475+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '42e2949c-81ae-4e71-91a6-c9722b52fb54',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED NOT 10 CASE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:53:34.016665+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd839d737-fbfd-41b5-8996-00cca72d0fac',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED 10 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:54:03.852972+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8698677c-fba1-4516-a81c-ad26d728f399',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A23 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T20:48:11.479069+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '13acbef8-078a-4777-b45f-e3be3aa4259a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G54',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:25:48.960727+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8d611538-3eb6-43ff-8fae-639f7feb30f8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G41',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:27:42.401317+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7b54958d-28ee-411c-a903-5b29641f76db',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED NOT 8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:48:57.9284+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '41d80a59-284d-4f6d-b31a-727b5aad2626',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED NOT 13 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:54:23.44189+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e6978c52-2ca4-4a9a-a994-b1a2b8f817ed',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED NOTE 13 PRO ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:54:59.267287+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6bbd0204-ab1a-4bc4-acaa-eb6626d141f8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED NOTE 14 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:55:42.381221+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd573ceca-5bce-4d50-851e-6348ef55e0e5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED 10C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:56:03.221585+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '27dbeb53-eff9-4dc2-a5f5-8651222a1be9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'FASHION PHONE ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:56:57.333461+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '02d8ac0c-008d-493d-b978-bfe3499bca0e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED NOTE 12',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:57:36.983675+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fb6674a1-ffe5-41c7-87fd-1d0911a2384a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MI 12 LITE ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:58:10.91549+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a1b99cdd-a48e-4733-a9f0-0c51a3b209de',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MI 9 LITE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:58:28.443133+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7ad3dc6a-a3d3-4181-b3a8-af374cdb4e49',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA XIAOMI NOTE 10 LITE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T13:00:44.333459+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ec84430f-7961-4479-a33d-b2da700cc6e6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA XIAOMI 10C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:58:45.251337+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'edf94519-d858-429e-a414-87e3a282296d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA XIAOMI NOTE 10',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T13:01:39.887659+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e0f10b41-bc38-44c3-aef5-dafd8716dcda',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SMART STAND RELOG''S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T13:03:19.545642+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '54b66bba-2055-4e66-91db-7bb5a91332b9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MI 11 LITE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T13:03:47.3486+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd4832fb0-32d4-4153-954d-2433899cc0d3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA HM12',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T13:04:21.515521+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4db4b282-09c9-47bb-87bf-40a84fa3fffa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED 12',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T13:04:39.895262+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3ec706f6-d99b-4996-b2cb-78bd0e080ab9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MI 8 LITE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T13:04:59.684788+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '765be566-4ce5-476f-8f5b-fbdedbc239df',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA LG K10',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T13:05:18.169426+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd0dddca7-c135-47a4-bf6f-e19838eff529',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA LG K10 POWER',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T13:05:40.461416+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '75598308-fcad-4fdd-8857-ca70611cd878',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA LG K12',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T13:06:04.051092+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '58b897e2-c7bd-4a4f-9d0b-3abcd540a1f9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA LG K50S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T13:06:26.26991+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd1472501-ff3c-4716-b4fd-ed4f61ad2555',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA LG K61',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T13:06:54.09687+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a78c14e4-4351-4b6a-9314-4af64fc18991',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAIXA DE SOM ALTOMEX A-6037',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T17:41:39.348339+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'efd8efc4-ad93-4eb6-b08d-4ef0340af4dd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'IPHONE 12 ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T17:52:04.788516+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e7c441f6-4bc9-42bf-9749-8b0e2b1698e2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A15',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T17:55:17.757548+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ec9759fa-18c8-4674-a124-35e47a9a2ada',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOTO Z4 PLAY',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:03:40.797233+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5c65bdc7-460c-46ea-b2be-d2d635fffa4e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D LG K50S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:04:14.764965+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '74815d56-53e9-4e16-92a6-f29dfd6f5b69',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A01 CORE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:05:24.35822+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1806f6c0-785f-4a95-bd30-b4e5d4051c23',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A01 VIDRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:05:54.446977+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4367c848-d09c-47f9-ad4c-1f489ff29844',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A05/A05 S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:06:42.277663+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0b834ae2-6688-4f4b-aaca-6253d3f62630',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A10S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:07:06.334387+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8b57e41d-2426-4eca-be24-e6784578d986',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A11',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:08:06.096404+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fdbc4dc7-1c8e-4bd0-9251-2334d0bd29ac',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A13 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:17:43.846043+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd4b4e21a-1412-4b89-b7d4-cd052adb6ed5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A21S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:21:18.516213+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7ad8365b-92bc-44e1-a1c2-e61eb4180e4a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A20',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:21:38.233597+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b5e64c36-14c3-4b3a-be07-9bc2a3f1dbc6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A22 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:22:26.086514+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '78169f20-817a-4e48-9ef2-2710d897b27f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A24',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:23:58.042779+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6f72f185-fd86-4248-84da-6af235ae5878',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM  A24 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:24:18.29117+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c355df4b-be03-444b-be9e-6abe884f0722',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A25',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:24:38.066069+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '47a76d43-155e-49a6-9e7c-4612c975f04e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A31',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:24:57.005918+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'be5355c2-ceb5-47f7-83bd-3d7b91e91fc9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A30S ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:25:15.875627+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3aaeb907-10d3-40ba-a98e-2705935fea39',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A30',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:25:30.295843+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b4f4ba7c-4bc2-4daa-8a12-8c328cb4b16b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A30 VIDRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:25:56.351176+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ab81139c-649c-4595-b6ed-16eb5dc749db',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A32 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:26:22.440052+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'de425441-9d3c-498e-88c2-00073ad56be9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A32 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:26:42.495606+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8c28de48-a042-4cbb-a024-a719f32889ed',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A33 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:27:04.178931+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '174976b9-fc85-4cb6-83c3-ee4fbdf1dd99',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A02',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:06:10.716822+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'dfbb777a-1448-4744-9ab3-aedf56b33f0a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D X6 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:02:51.959936+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '634bef84-f147-4866-a597-5455b17494b1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA RED 13C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:55:15.805802+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4ab5e0aa-a76e-427e-98b4-32a1941fe270',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A20S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:21:58.537709+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'afc03b2a-f11c-4cb9-8ec2-6dd2c1703cdf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D K12 PRIME',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:04:35.796923+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '21ef4e0e-b82c-4809-9c46-f43099b5da91',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A14 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:18:16.020441+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '00c81870-2dd9-4145-b418-1765438a4c1b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A23 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:22:47.375532+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'de1e91ea-15b8-4bdd-a9b5-0bd13c55c18f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G60',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T12:29:04.525647+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '44724988-91d8-47d5-b553-c3ff93648bfc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A13 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:10:00.169455+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bcfa464c-bb82-457f-ac4d-34745ea6bf20',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A33',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:27:17.278556+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a3197a91-292a-4a46-b0a1-2b9bd5d54165',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A34',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:27:47.15077+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b5142ead-613c-4ba5-9d98-2791caf9620e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM 35 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:28:09.305854+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0348ff8d-5a7f-443b-9f7a-68adb98604fe',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A35',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:28:30.699557+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd4e26816-285d-42a6-894b-b8d17d6c03f2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A40',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:28:51.97972+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '233ae995-70f7-48cd-a07c-e7d0a9f96759',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A50',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:29:29.227438+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5b49a5e6-8c8e-4210-a296-3786508c2cdc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A52S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:40:46.425598+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4e753955-c0b2-4a6a-8a93-961514fd9f98',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A53',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:42:03.455881+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '593688ff-a3f6-48ae-8c99-6e6ce6d9b9d5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A52',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:43:13.48634+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3bff94be-0b18-46c9-a9db-e992767c6e9e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A55 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:44:54.359554+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '49b2b1dd-c09b-407d-a3ad-e96828f472f3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A60',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:45:18.961202+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b24ebd67-440b-404e-8857-b60266ae8690',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A71',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:46:23.241279+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1708cb7d-6446-41e4-ae41-67a51b5909c9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A72',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:47:09.350934+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd6b153dc-4111-4757-993a-b29907f91fc3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A73',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:47:26.89131+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c99b96da-d0d3-4473-a226-936d51d6494f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A80',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:47:43.344229+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '05659d62-c59a-4e86-ab4c-52258f074a79',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M20',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:48:21.090163+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f2e9034d-aaeb-418f-98ff-56baa1c681bd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M22',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:49:54.160345+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'aec0e6e9-ef57-47c6-88d0-a246e3f8eecf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M23',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:50:15.847934+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9564755d-945f-4ba6-bd0b-6d724f4353f8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M31',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:50:32.617857+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7d4fd4ff-764f-430b-8301-96d6af3955fc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M32',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:50:51.84953+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c43a6422-3f9a-4246-aa46-d4c3537f9bc0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M33',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:51:09.863953+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9669889f-5b36-42f1-bb9c-ba14b1afd88e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M34',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:51:26.106148+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e0aa2893-4560-49bf-82bb-a99e25610149',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M52',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:51:42.624279+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c135a1df-e6b9-4440-aacb-36a48b868f76',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M51',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:52:26.259768+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '39469b50-2ddb-44a7-93fb-5d1837cb5f08',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S21',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:53:16.04069+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4191db97-2d0a-4ce8-96bf-4c3623b598d2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S20 FE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:54:23.660956+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8d768d51-041f-43ba-8946-c61e0736e17f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S21 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:55:23.184879+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4c05f067-f26d-4a86-bf55-f7a98d431697',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S21 FE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:55:55.352111+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd7d27a14-2a36-4c80-b39c-722ae8980283',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S22',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:56:21.833718+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '718d4c17-05fa-472b-8dca-0d82201767f1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S22 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:56:41.880435+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6e239cbb-5d22-4f88-a72e-6e38b920f8d5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S23',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:57:08.735484+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4d18f473-5064-47fc-a912-e980d7425aaf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOTO E14',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:57:27.378677+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '09f7b1be-7151-43a2-8c77-26580704c844',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S23 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:58:11.811843+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd5973414-886f-467a-a544-34d935f93828',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S24 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:59:23.520681+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a67ff490-801e-44ba-aa59-61a88dcb09c8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM J2 PRIME',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:00:24.570242+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '38d549b2-25d8-4446-9949-7d7066957e00',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM J2 CORE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:00:40.264804+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1b7816ac-0b11-4200-b068-d1bc2e63e998',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:01:05.804859+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4060dd3e-f103-4f8c-b4e5-c4bd9e09eadc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM J5 PRIME',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:03:12.504987+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0d965c14-1175-4257-852b-ad2eb622b801',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM J5 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:03:36.882108+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a21e6c78-5cc2-4611-9f12-69fd58d3cde1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM J7 PRIME',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:20:45.200329+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c10cf3a8-06ad-480a-a632-b5feadf5eb65',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M53',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:23:02.511215+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '240e6591-47ef-47ce-a33d-60cc1f3061f5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S8+',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:24:30.516215+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '781e831a-7f56-4ee0-aee4-a9b440c46124',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S8 PLSTICO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:31:07.351107+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4d98edba-dfb5-4135-8c53-7c2491545b04',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A54',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:44:09.431108+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bc29bc49-0618-4a24-9195-26bf4256c48b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S23 FE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:58:33.579168+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8b695938-e1c5-41b1-a6b5-710c42e38e88',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S9+',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:31:31.022317+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7a7c4428-432e-4656-832c-ded0b9a7b1eb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D FOR',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:52:04.456964+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fa51423a-4362-4126-94cd-a6275ff91082',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M62',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:52:46.221251+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5cbd0c18-b10d-4101-a511-f491329df590',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A51',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:29:10.031453+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a81b8503-7af4-4c74-a093-f602461e2dbd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M14',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:47:59.429762+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '10e3ba0e-22cf-4afe-8742-3069b13c0944',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S24',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:00:02.431413+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '71c08a91-3879-4082-9701-a1a5979d1578',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM M55',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:23:51.936822+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9a316664-9e73-4f73-a817-2d302e9744e7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM J4',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:01:56.163746+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '62b17f46-d084-4e44-8297-86e91b378ab3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A70',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:45:59.774169+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f8fc14dd-c1ad-4dfe-8997-6c9018a6b343',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S10',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:31:45.806041+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b87d65dc-a91f-4b5d-b721-21c2a037ebaa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A7',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:32:06.374596+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd04fcab1-0f95-477b-92a4-c87d9d086660',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:32:21.444836+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e629a3d7-7fbb-47ce-acf2-d0f26c9d8df4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT E65',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:32:58.557383+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '50f179cb-0768-44ed-b4fb-55d715126487',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT E6I',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:33:31.504924+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '40ebf384-5114-410e-a74f-e76888c18c20',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT E6',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:33:45.242528+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7da0952d-9c62-43c0-acce-b983c7182a2c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT E5 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:34:06.10718+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '431719bf-6fb5-4921-8916-5a32cf7d9b59',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT E7 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:34:42.372704+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '220c9a1f-8878-4521-83e7-d8c6a6e56121',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G53',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:57:50.81413+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd47bd442-a80f-43f7-9393-f45de9bae27d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT E13',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:35:42.474095+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'eb78f64c-3071-443d-afb4-e9950766e858',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT S22',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:36:35.984346+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '49119c62-7b5e-4165-a038-3d890e7ead71',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT E32',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:37:14.060647+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd8bf9e4b-3bd5-4812-86aa-e09eba39fe02',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G31',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:38:43.444503+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'db48d4ab-1727-46c3-abee-35c559ec2af2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G5 PLUS ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:42:23.892848+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7372f19d-8608-46a3-82e4-af4c7b69963f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G5',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:42:42.394097+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'eb5f1d8b-c21f-4ed9-be25-9402380dc44a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G5',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:42:55.717485+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7a70f8ad-f795-46f7-be2a-118acf7ce087',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G5 VIDRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:43:41.160804+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '54c5f81a-2919-47a0-8926-1ec04fca8073',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G6',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:44:11.460425+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '69710908-61e6-4347-8586-7bf6656eaec3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G6 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:44:36.279864+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '608ebb82-d5a4-405e-b4df-88325637c107',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G6 PLAY',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:44:53.858401+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5bc4e172-7b28-4f13-b8a3-d21c8b219f38',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G6 VIDRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:45:13.076661+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '86079672-2e95-41e0-b082-97a0895e7a9c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G7',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:45:27.642351+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '18b3eb7f-e7ac-47df-a89a-c37a1c02ee5b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G7 PLAY',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:45:51.272437+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f2452c53-a845-4023-94ab-2c5cb78142fa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G7 POWER',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:46:19.876115+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '230213e5-a291-49c1-ade5-fe8c6709ea59',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G7 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:46:37.273417+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '366be900-1cf8-4938-b89b-4d7a5f536a9b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G8 VIDRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:46:52.725959+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '04e088aa-8ac3-4eb8-937a-607b39635ab5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G8 POWR LITE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:47:14.113087+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b6d9e915-be0f-4629-8c23-70a34d055202',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:47:30.530126+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6784dd45-01e8-4469-a58a-fb7922a0a360',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G8 PLAY',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:47:46.443581+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'da964672-bd83-4ea2-890b-173e5658baa8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G8 PLAY VIDRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:48:06.316485+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '68b5d6a3-b051-449c-a686-da4f599eeca0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G8 POWER LITE VIDRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:49:14.719296+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'eda26d44-c0fe-4019-b3b7-f5d10091f553',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G8 POWER',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:49:45.409143+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b39f6af6-db07-42f3-bab3-783b1ff1aa8b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G8 POWER VIDRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:50:10.095131+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3a2b66ec-19ae-4d68-85cc-6dd0092f5490',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G9',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:50:26.77296+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '26f4dec7-9352-4095-ba99-9587f415de32',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G9 POWER',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:50:45.48368+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4fb01583-3726-4d4b-ab9b-aad0aac2ced6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G34',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:51:02.289763+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9acf7ca4-8e55-47dd-9f56-f5d7a8a830bf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G35',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:55:19.772647+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fb466ed9-7541-4623-8267-08dbd250554b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ED30',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:56:00.012816+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '31f143bc-1d60-47cd-bd7a-d16b28c98593',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G42',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:56:26.200701+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '015a5d08-1994-4047-a538-5145692b0820',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G50',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:56:41.342285+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '554a71a3-1000-45d1-b97e-e06c68e6feb5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G51',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:56:57.617326+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'aeebbbb9-322f-4df4-97e7-97c3bb596911',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G51 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:57:16.093474+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '73e25cfc-d0b1-4afa-b73f-b158db01243b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G52',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:57:36.8016+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e309c566-8c18-425e-8449-20aa1d15a7fb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G60',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:58:34.988763+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0d1cb7b1-5b56-4189-a0d9-38ee91a35dd8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT E40',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:38:25.589212+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '587a7ea5-3ff7-4df1-b6f4-f56945440395',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G13',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:36:55.874949+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5a08ab33-79ed-4d56-9503-1ccf9c51053e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT E7',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:34:25.054265+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'da4ee7e9-77e3-48e7-84b5-4f1b175ea39a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G9 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:36:20.051681+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '65b46a4f-0628-4cc5-a64d-ef2acfa6a843',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G54',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:58:21.137541+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0a87eb1f-8336-4ff1-95f6-2ec87b8ef7f0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ED30 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:55:44.488605+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1edaf776-a991-4f1d-8db9-95979e7a41c7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G9 PLAY',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:36:02.806645+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '97231340-fd52-422a-b8cc-fc3aa9884df6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G14/54',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:37:56.695252+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e94c7b12-7c15-4401-a0c3-cc815495a3cd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT E30',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:38:59.341454+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6e1061b7-684d-4dad-9e39-13f3f4bc242a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G8 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:48:32.283453+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '37f545df-0f42-42de-949c-4eb87f0d5051',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G62',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:59:11.024829+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b5476253-788f-453b-97bf-9ab01a40936b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G64',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:01:15.389342+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cb07f138-7d05-41ca-aa7d-b4855055743c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G71',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:01:35.498304+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8f0572ce-6301-49fa-a09b-1173bd96a8b6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G73',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:01:49.094185+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '04de0def-dcf6-482a-a8e5-7a12193c6280',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G82',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:02:09.108768+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '99e03841-891d-4c2d-97b2-03fd69f70e90',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ED20',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:02:27.994621+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4c27d2a0-231c-4ac1-b1ae-088821b210e9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G200',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:03:21.010705+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f7371c07-7bc0-41ef-b170-384fb6f1afd7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G04',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:03:45.436013+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9256933a-92e9-4cb7-b7e6-ee965e1b023f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ONE MACRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:04:23.247874+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd8b84017-2447-4107-9e7d-6a529b124f9e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ONE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:04:45.701054+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4da5cbe4-bba8-497e-a544-ae5ea6860f70',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ONE FUSION PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:05:08.768357+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '58547ec4-13dd-4e3e-8c7b-967d6db2f9ea',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ONE VISION',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:05:34.012908+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e75de332-1e5c-4b59-8f85-e26ef6c814e2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ONE MACRO VIDRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:05:55.102914+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bb0d85ce-9447-47a0-82a7-03952168946c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ONE HIPER',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:06:14.079282+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2abc640a-fd9c-46a7-b68a-3545afb00acb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ONE ZOON ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:06:51.114324+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ebe85152-ea1e-494f-9e30-fb826d10bf86',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ED20 LITE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:07:59.16661+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bcb3d0d5-da94-480c-980b-c5309cb60c26',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ED20 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:08:33.758843+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '582bf3c3-2deb-4a99-99cf-3c9dd48bc8dc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT ED30',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:08:53.545756+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c1017e85-cf2b-4939-b593-31a231ff20f4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'BATERIA DO XBOX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:17:18.279554+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '26d167ff-33e9-48d6-bd7d-f83449b8ca8a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A32 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:15:24.551894+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '520aabc3-717d-436b-b169-9827915a047e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE IPONE 15 PRO MAX ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T15:47:46.985238+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '87c110bf-fd93-4ad7-8659-eb15ad3b66f1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT E7 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:35:00.240992+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8f4b0753-fab2-4285-b407-eb593190b5dd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE IPHONE 15',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T15:48:44.622786+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e45b30e7-6ed8-4e97-9d10-1ca6c7e72021',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 13',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-28T13:58:47.742929+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f54f501c-5a32-43d6-afc5-e554177a058a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE IPHONE 13',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-28T14:02:08.592951+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e0d46e19-6220-4244-860d-488c209583a2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G100',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:03:05.389282+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd8c5be65-44a2-455b-92ee-b30aa0edb4d8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM S24 ULTRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:59:46.199362+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '312e07d0-861d-49d5-8c3d-a8aa4d478e50',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA IPHONE 11 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:38:43.965918+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8f6dbb0e-39c5-4ddf-9013-1ec6a3d85e3b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE IPHONE 11',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:49:13.093191+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7cce829f-69a1-498a-88bd-af52a919dff5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA IPHONE 11',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:49:35.733849+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1607715a-4345-49e9-8718-aa1290e7827a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA IPHONE 11 PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:50:18.849072+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '11b21cdf-5b60-4683-9009-2d0f3b0b53e7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA IPHONE 12',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:51:13.438857+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '92124d2a-5eda-49a4-beed-9ab49b818eb3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA IPHONE 12 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:52:10.285+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0f4d1361-686f-413f-8249-77bd0d8fddb0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE IPHONE 12 PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:53:05.841446+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '55429f7b-3349-4069-a4ef-0d6b00b53624',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE IPHONE 12',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:54:06.955951+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4e54aac2-701e-4485-82b1-8b832a2e952d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA IPHONE 13 PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:55:10.930896+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e2fe8e8f-d3fc-416c-8882-2070d8fd3505',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA IPHONE 13',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:55:31.035523+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9f62a847-a50a-4b52-aaae-dd2bdbd58e36',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE IPHONE 14',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:58:14.181617+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9e2936f3-1017-4709-bc09-d55290a5a04f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA XASE IPHONE 14 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:59:12.329116+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'da3db5ee-87f0-483d-bcb3-89f54930fc0f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA IPHONE 14 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T15:46:12.828091+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '539d941a-3d4a-45a3-bf63-a6b4e4434283',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA IPHONE X',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T15:49:46.214326+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b5b828c0-f777-40c0-a564-275c2146a2b5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CASE IPHONE X/XS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T15:50:28.478063+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '03762f18-fa42-4d44-a519-deafe7c7ce80',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA IPHONE XS MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T15:52:03.70361+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c881e4ff-a71e-409a-bf78-13d4724e3cff',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAMERA  TRASEIRA IPHONE 15 PRO/ PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T18:09:38.87726+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd6480976-2fe4-4a1e-8163-0381ea4e0c95',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAMERA  TRASEIRA IPHONE 14/14 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T19:33:55.187584+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c9705f41-892c-4e21-95d4-4873fd13518b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAMERA  TRASEIRA IPHONE 14 PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T19:34:24.288544+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2bac1526-6c03-46a9-afcc-6622edfd8bf5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAMERA  TRASEIRA IPHONE 15 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T19:35:04.389297+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6fd65ce5-d995-427c-af93-22fa27eee37a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA IPHONE 14',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T13:57:41.60396+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '90b25c9c-67b6-45e0-af16-900ebf346f49',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G05',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T18:10:06.986364+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '92a95960-0b22-40a7-8a8c-875589c53f75',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G84',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:02:46.953663+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '04ab9220-9651-4a35-b2ce-d9d7ccc3191b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA SAM S24 ULTRA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T15:36:22.834407+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0eab3dc1-7b2b-455c-b497-9bdd8d146a42',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G04S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:04:00.275425+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd5fde5cd-ea49-4370-a0a9-c6c541cdd7eb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G62',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T20:00:57.37653+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f0f7af94-15b4-4251-950c-c7b94d642a31',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MOT G60S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T19:58:52.203213+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ccbb79f9-eeaf-4ec9-a1a1-09fa62dae946',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAMERA  TRASEIRA IPHONE 13 PRO/13 PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T19:46:07.688773+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8cd0e3bd-860b-4836-8a16-d6eb29a02737',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAMERA  TRASEIRA IPHONE 11 PRO/11PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T19:46:41.744611+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'dbcc7dcf-d456-4e10-8076-8b9900fddb6f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAMERA  TRASEIRA IPHONE 12 PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T19:49:56.16455+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fe0c3168-e138-4271-8e37-1dd6b6127372',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAMERA  TRASEIRA IPHONE 12',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T19:50:28.824689+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6fd55f82-9dae-4fb0-9fbd-fd287c3ed2cd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE XS MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T19:55:16.776369+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '89352e22-6e5e-4cf5-86bf-aa255532ece2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA NOT 11 LITE 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T21:34:56.463404+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'af02118b-7fd0-42b9-928e-e1e9f021921f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA NOTE 10 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T15:55:35.554463+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '69addfc8-ead8-4e4f-b31c-85af2fb1be6a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA REDMI 13 C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T16:42:59.108414+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'c926f498-c959-4bbd-abce-72537b207649',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D X/XS/11 PRO PRIVACIDADE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T16:52:14.775828+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7fe2287b-47b7-4629-9563-c1cfdfc31026',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D X/XS/11 PRO ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T16:53:03.645595+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3776be4f-7fc2-4be6-842b-c4fdf791dd7c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D XS MAX/11 PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T16:55:50.066468+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '57d03512-6afb-4601-93ff-3f8d4bf33409',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAMERA  TRASEIRA IPHONE 13/12 MINI',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T19:48:01.407574+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '97dbce85-bb8d-4ddd-8285-ba3d795e4d40',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 7 ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T17:01:10.260345+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '02feeb21-cae8-49cf-ac69-458c2f9420fe',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 7 G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T17:41:11.420921+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '80f8adbb-e841-4d4f-b065-9ee31e673cc0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 6 PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T17:51:29.102716+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '98be6a98-6f97-41df-a4a0-7447c88dcfb5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAMERA  TRASEIRA IPHONE 13 MINI',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T19:45:31.050486+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd1e9d291-5fc1-4d87-9c5a-33733706b080',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 5',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T18:40:33.905983+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2a742525-8ec2-4aea-9dd3-f35c9e37eee2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA TRASEIRA IPHONE 8',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T18:41:42.486174+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e82bd0e3-a522-4213-8834-2eab1312c4f1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA TRASEIRA IPHONE X',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T18:43:55.987851+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ded97ccf-8e70-4eba-ac59-4862caf2122b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA DE VIDRO IPHONE X',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T18:45:25.628219+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '64a20fc4-f88e-4c4b-b204-d2e445fc25c1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 12 5.4',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T18:52:45.270287+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '58b64b4b-551d-4221-b704-7fe5c8c71b8f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D NOTE 10T',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T15:59:39.353489+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0658098a-227f-4c82-9435-aba2d31f84e6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 12 PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T18:55:38.955363+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '01f04e44-0fd1-449c-8367-c54d31c66d67',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 12 PRO MAX PRIVATIVA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T18:56:42.682498+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '77714fbe-de38-4310-93e9-f704aa95c1d0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 13/13 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T18:57:56.076764+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4077ce62-8f61-46f7-b122-3471eb7b0a43',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 13/14 PRIVATIVA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:00:50.610998+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cc43089d-9ed2-4742-801f-e194290309f9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 14 PRO PRIVATIVA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:01:29.286151+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3e134b20-043a-400b-afe8-902913bd2f60',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 14 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:02:23.774113+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '6bbae314-8c90-4adc-9ef3-307d5bc47796',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 14 PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:02:54.840536+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9f5c8d66-907f-4a84-89be-853808c23773',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 15',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:04:32.423155+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '770c58f4-330f-4ccb-ab8f-d402afc33f37',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 15 PRIVATIVA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:06:25.952194+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '27fbb89c-fd89-4e48-988e-de86892d4ab3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA XIOMI NOTE 8 ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:11:42.381052+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'dd46efb8-8aaf-4e53-84b4-6ff476c1150d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA XIOMI NOTE 8 LITE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:12:07.226466+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '040ae906-4bef-41ac-a7d6-1df8600225ec',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D REDMI NOTE 9S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:14:56.429314+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '0bfa9778-b320-4802-bd5e-8013ca747a92',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D REDMI NOTE 9T',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:15:47.944382+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4faea064-5e38-419d-af4a-6abb196d656b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D REDMI 9C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:18:18.015593+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9e8ea88a-7da4-44f2-827f-2fde86e45eb1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'RECARGA CELULAR',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T18:53:29.382162+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f4faf5e1-5d07-42ac-b202-9fec9e04f677',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D REDMI NOTE 10 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T15:50:02.74274+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f95f3a67-fe97-4dff-babc-0727e445a525',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA NOTE 10/10S',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T15:53:47.030739+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a5f7681d-3787-473f-a50d-cb6b1ae007e9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA REDMI 10A',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T15:56:18.258617+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '06b25463-db57-4f03-9011-f2dab9ad0bc3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA REDMI 10C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T15:57:04.167932+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '80d6defa-d6d1-48a8-a799-6a79cf0f453b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D NOTTE 10 LITE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:01:12.820504+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '17f0deb7-1f80-4b65-b183-395436545bfa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D RM NOTE 12',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:05:45.043035+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1a0dc5e7-1dc7-45dd-9afb-f166cac1ef6d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D REDMI 12',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:03:16.053003+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7760f9b2-b5f6-4f31-b2cd-3159f639c2a6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D REDMI 13',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T16:46:07.909983+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4ebb173e-f0d9-4aef-b8fd-386d507ff89c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA REDMI 14C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T13:04:29.511003+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '96cfbf32-675e-4947-a1d6-7e792baf4c73',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 13 PRO MAX',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T16:49:14.888998+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'da541c30-668f-499e-a6b2-78a1941102cc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D REDMI NOTE 12 PRO/POCO X5 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:08:55.625932+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'bdd6d432-fc53-43f0-98c5-69392144484e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 14',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:00:17.893867+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fd4114b8-f5ce-45b4-b064-b1c4dc881f69',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 15 PRO MAX PRIVATIVA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:05:11.389366+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '5a74fd40-db77-4682-bb77-2bddacd252eb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D DO IPHONE 11/XR',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-30T20:14:10.686708+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '24f7917b-9f99-4c6b-8f9e-6bd27f8977fc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D IPHONE 6G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T17:55:52.502307+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'db513c3e-201d-4448-acf8-b5c663558aa3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D REDMI NOTE 11 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:10:07.673739+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9034f05a-2419-4ff4-b708-6497049ab9b8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D REDMI NOTE 14',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:14:59.20709+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '21668071-e172-4315-b46f-31368c6fce50',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D POCO X4 GT',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:17:38.595031+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '1416372e-f39d-4673-bd96-b200a5939852',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D POCO X4',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:17:58.827621+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f674d80e-012f-492b-8641-949150f9aa4b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D POCO M3',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:21:00.332439+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ef1df032-cb65-42c2-9b10-0680722234eb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D POCO M4 PRO 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:21:39.655147+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '212d23c2-0e8e-49fc-a568-f4e50e521743',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D POCO F3',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:25:06.344078+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '31bd5181-d7d5-4607-bca5-2ab9525d153d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D XIAOMI MI 10 LITE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:26:01.644286+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '06de4f3f-35fc-44a9-8335-60b74f134cfb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D XIAOMI POCO C3',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:26:32.140176+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '51fac82d-f5ea-4fa7-81eb-2b6b28e2e656',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D NOTE 8 PRO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-01T19:10:28.235387+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '19fb7f59-b3e7-4f79-af13-5d30317818fd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CADEADO ANTIFURTO',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T17:05:19.586474+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f2a0c244-3ca7-47ba-b969-a3c824a45938',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CADEADO KAPBOM KA-5721',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T17:06:35.123285+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'cbcdc24b-1d3d-4042-87dd-37947022ec58',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA A12',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T18:31:11.688121+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'dcb81eb3-197a-4e87-bc4a-f64ba74c6854',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G42',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T18:39:11.106958+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e0449774-965b-4cb2-aa62-d011e5e7e086',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA CARTEIRA A22 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T18:47:46.999505+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '03967bde-dde9-499b-bf8e-f80ca1ed3de8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO ONE FUSION PLUS',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T18:49:59.575702+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '7ee1bf2b-5283-40d5-9688-e440194529ae',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CANETA BIC PRETA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-08T18:01:38.689966+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '3cb082d9-a5c4-4f09-8901-b2d1a082f36a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CANETA BIC VERMELHA',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-08T18:03:47.871232+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b1a07f02-52e0-4323-872e-ab1a3a3c4f60',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SUPORTE PARA CARRO O''GOLD SPC-03',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-04T16:11:39.183019+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a7c6eabf-d8ca-48b1-baba-e5610df2deac',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D POCO X5',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:19:41.370938+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '26739b7d-afe2-468d-949d-387f457598e9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D POCO X3',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:16:53.523032+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '44249c20-036c-4f45-a2b5-71a4d1697aa6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D SAM A01',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-27T18:04:58.946469+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '41cc8a6c-66aa-4481-b906-a3275445e27d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB O''GOLD CB04-2',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-04T18:16:27.241345+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f95122ce-d25b-4198-9aba-1432ae7f3c49',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO DE ENERGIA O''GOLD WX-53',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-04T18:58:16.292036+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '68eb8f40-901b-483e-90d6-e38d1b2cc0da',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO DE ENERGIA O''GOLDE WX-51',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-04T19:08:19.560207+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fe31db9d-b0e7-4baf-8daf-e0c408e7fc55',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO DE ENERGIA O''GOLD WX-52',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-04T19:07:31.602487+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2308b82a-09dd-441c-ac92-f27267cb386f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CELULAR SAMSUNG S20 FE 353042530695621',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-04T20:41:03.294675+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '4f56cdb8-11b2-4514-b189-56948f257b00',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CONSERTO NOTEBOOK',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-05T13:46:37.301347+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9a1e2d43-9ea9-4595-82a0-9f5842986090',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'SAMUSNG GALAXY A22 - 571798810689517',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-05T14:00:55.444976+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd25498fd-3e21-4e76-b38e-d500e590c005',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CELULAR POSITIVO P26 4G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-07T19:38:08.096192+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd1ccf80d-f1ad-4aa6-94fd-f4616ad41c2d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D POCO F5',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:22:36.348905+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'b4f7a145-baeb-4803-81a5-bcb997505e5f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CANETA BIC AZUL',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-08T17:59:33.506204+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ef32ec29-3bf9-4dfd-ba21-96ec6b30f23f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CANETA MARCADOR PARA PROJETOR ',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-08T18:16:42.148029+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '719cc510-7058-4abb-8131-ece864c7ff5e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CELULAR SAMSUNG  GALAX A30',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-08T21:15:19.673698+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '9008bc11-8e77-4346-8c52-169bffc5be69',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D REDMI 13',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:14:17.502424+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ce0efe56-aa15-44bd-b3a7-2764d9bb9ee1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CANIVETE LUATEK SLK-D51 UNIDADE',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-23T18:26:32.114617+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ec884cff-d76a-4d8f-bcd7-db2c1c4283c8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CAPA MOTO G14',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-26T19:15:45.835908+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'e0dadeef-e816-4aae-b597-1cde9401b385',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB AVULSO V8 MINI',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-12T13:08:21.181438+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'fdc14b35-37d2-4bd6-9e6e-7186ed701292',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB PARA V3 INOVA CBO-7596',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-12T12:44:38.690695+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'ba9c87c0-380c-40d1-91d5-eb991fc0acfe',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB PARA V3 PLUGX 292',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-12T13:01:43.797462+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '35fa71b5-f91f-4934-bedb-c988aba5af7b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ADAPTADOR HDMI',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-12T14:06:47.696786+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '2faf629a-598c-483b-bb98-aa93be55a217',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D REDMI 14C',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-03T19:33:47.420929+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '8939aba3-3065-40df-b23f-67c8eec17649',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D MI 11 LITE 5G',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:09:26.545896+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'a17919c9-715d-45d0-88f3-6553c3a43501',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CELULAR REDMI NOTE 13 -86039073883988',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-15T12:58:47.772619+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '88247a29-3772-44eb-9351-8878af91a4f4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CABO USB TIPO C O''GOLD CB04-3',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-10T12:24:44.404019+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'f08e9dce-894a-4285-a78a-24a91472253c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'PELICULA 3D REDMI NOTE 13',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T16:11:37.905096+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  'd478172d-aced-499b-8f23-a851a656f5fa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CONTROLE SMART TV ALTOMEX AM-0016',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-06-25T19:15:37.529307+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '92539e45-a4f3-4095-8d0f-e652e63bf9ed',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR TIPO C O''GOLD CA19-3',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-02T17:59:11.763989+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();

INSERT INTO produtos (
  id, empresa_id, nome, codigo, preco, custo, estoque,
  estoque_minimo, categoria, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '982df267-41a0-4a2f-bf78-50543ed72f0d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'CARREGADOR O''GOLD TIPO C CA42-3',
  NULL,
  0,
  0,
  0,
  0,
  NULL,
  true,
  NULL,
  '2025-07-16T19:06:17.080931+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  nome = EXCLUDED.nome,
  codigo = EXCLUDED.codigo,
  preco = EXCLUDED.preco,
  custo = EXCLUDED.custo,
  estoque = EXCLUDED.estoque,
  estoque_minimo = EXCLUDED.estoque_minimo,
  categoria = EXCLUDED.categoria,
  updated_at = NOW();


-- =============================================
-- ORDENS DE SERVIÇO (160 registros) - UPSERT
-- =============================================

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'dcdc1e19-d128-468c-b8f2-85b815a96d8e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'fb78f0fa-1c56-4bf1-b783-8c5a60c00c62',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-17T21:17:03.501815+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '8b1bef3b-e62d-458d-aef6-c7c4eb7e3c80',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'fb78f0fa-1c56-4bf1-b783-8c5a60c00c62',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-17T21:19:41.909371+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'f50b8b48-e7c7-4166-ab41-5f9615450efb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '67526f20-485e-40a0-b448-303ce34932fc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-18T13:29:07.43627+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '0f526fa3-3d21-468b-b02e-f94f0f9c58fe',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '98e0b7d7-7362-4855-89f0-fa7c1644964f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-18T13:48:41.334054+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'b3acbfef-c898-4df0-bfba-4922ba5b6520',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '7af82c1b-9588-471f-b700-d2427b18c6ec',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-18T16:30:10.591938+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'b28607a0-3395-441f-a709-22eecc6406a1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '98e0b7d7-7362-4855-89f0-fa7c1644964f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-18T16:59:13.680217+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'a01954f8-235d-4a3e-aa14-a1b7ce0e697f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '7b05bd0a-1fc7-4334-8576-c4e77d27b196',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-18T20:49:34.213213+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'da025224-7bd0-4220-99c8-7e98f5cee7a8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'd8995586-abf4-457a-9756-735f5606e41c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-20T13:33:12.579104+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'cc088a5a-cd4f-46b3-86bc-3e60b04d430d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '66727ef3-2636-49fd-969f-233e1cc07f13',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-18T20:51:45.540101+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '16dab66b-2bc4-4292-9648-123b8b688d15',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '98e0b7d7-7362-4855-89f0-fa7c1644964f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-20T12:56:31.891513+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '96e5a161-e615-4cd5-98a9-1dd530591b84',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'b8a4a1cc-80ab-420b-b720-eb4798e77c77',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-23T15:53:05.093047+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '813bcf9e-7ef0-4787-b7b6-d1152d1417ff',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '1a735ff3-17fb-41d7-9e44-e6ae6515b713',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-20T19:54:12.190594+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'fa8d7dd2-4d54-4ed4-9466-462472bc3b97',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '81402fa3-218d-470d-b679-b477902b08ec',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-20T20:00:45.946856+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'c79cae4d-07b4-41c4-bd8a-f8c8d28aaff1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '5c8b794a-ff86-4106-99af-43936b883814',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-20T20:32:02.898689+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '5cb6318c-bf05-4452-abeb-70157e1678d5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '1de38261-6f87-45fb-966f-74f80d9a2b82',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-20T13:28:31.34024+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '0903bd43-616c-43ba-a1f0-5dd36a9756da',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'cec352ec-fd75-46f8-885e-f97c204ec860',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-21T14:57:03.717929+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '2e6f93d9-2939-466e-ae52-1e2b700cf0ef',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '0de00017-d115-484d-9800-a2e818be06e0',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-21T12:51:10.210627+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'da3dad0d-e528-4e5f-809e-1300c054fc72',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'e6ad0da5-e52c-44db-9303-c51b6224f5d7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-23T15:54:40.2839+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'e4e52338-9604-4d24-8a09-f36f15d53314',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '8e5f7dad-f0b8-4108-8df8-a5d72b71b091',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-23T12:54:11.949709+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'af585103-d8c6-4153-80bc-35f1e6b5f5fc',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'fa2c9924-ad76-4174-bfa8-c738facbc740',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-23T13:04:02.434086+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '9ba24f72-6c11-48e6-8c26-b27d041fc514',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '159ef458-4b88-422f-b6b5-98d99d53bd95',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-20T18:42:37.467441+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'a71375aa-15e1-4e6f-aabe-17a25bc2e52c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'd1c2b00e-4923-42a8-bd93-de8d2d18cfdd',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-20T20:11:09.361877+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'c83a4ee1-0a1b-43cb-a590-16b4cc3e343d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '159ef458-4b88-422f-b6b5-98d99d53bd95',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-20T18:44:56.651484+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '36210e2c-9f3c-40fc-890f-a902220b3081',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '1a684b17-330b-46e9-9b78-bb36fc213b74',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-24T13:01:57.568518+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '5cc28c48-aa32-4079-9692-173265cc8a82',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '1de38261-6f87-45fb-966f-74f80d9a2b82',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-23T19:43:42.80626+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '27064aeb-1278-4bbb-8b37-af3d85056a7c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '3e706edc-3e4c-412a-b806-ba9ab6adbedc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-23T20:45:42.181711+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '11741f23-4461-40d8-9707-64961a72b314',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '57abc05f-f89f-4214-89f4-7c2419c1d8ec',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-23T12:34:05.23734+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'aa8fa75c-0a20-4f0b-a8ae-2e926e93721e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'b84d45af-8e02-4296-9ef7-30dfffe05754',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-24T16:07:09.847248+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '3891764e-4925-4983-bea8-3251ec55519e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '3c26ce91-1a8b-4a18-8e63-37244ee21d9e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-18T19:57:15.130694+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '1f87f15a-3682-4f4f-b296-d11c4f5c7959',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '8139ca41-e231-49e9-b8a3-d7266552bb93',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-24T20:28:02.295418+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '920e1321-f918-476a-bdd8-b8435ca2fdef',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '5c3f2244-1899-4c3b-bd49-afd6c5e24be3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-26T18:36:32.365508+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'c643ae63-07e3-4b7f-a99a-80bb5f5163be',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '9f4c0884-bf60-40a3-bca5-cb5b04bcf10f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-27T15:23:40.924257+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '4cd05493-b617-4864-994e-de0b4a599094',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '698ca802-0757-4442-9189-904b031b73ae',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-23T16:24:28.651418+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '0bd6af65-d2af-48bd-8d1b-e47206adeb9b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '85460a9d-3277-4d82-9574-39cd914028c6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-26T13:25:32.290591+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '67061904-603b-4ca4-b9e4-6a290f508821',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '6bd751c7-a33f-49eb-a21c-1e76dc9c59d5',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-27T15:38:44.737129+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'b2895ee6-1913-4108-a705-44e87cabf91b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '34d03de0-1545-4d24-ac72-7d75577a3697',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-27T17:46:15.781026+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '3c888d30-4571-4706-8710-488dda28856e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'fa24c59c-38bd-4e12-a9ca-87d267f61ad6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-25T12:29:55.502728+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'd3252c8b-b148-4350-9d17-82ff4c2e07bb',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'b003b09f-423b-4587-a007-aa0daa5d9dfa',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-25T15:58:52.453835+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '23a73d1f-7440-46e7-b70d-29213dc6435e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'c7cddd7c-ce2b-4040-bf6d-48fa899289e1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-25T16:36:15.047681+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '12b17573-9df9-47bb-96eb-db1bca7620e7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'bb9ffa5d-e7c4-42ac-b03d-142f0e44f387',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-25T18:37:01.632733+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '7df002ed-fde7-4fd8-acb2-9e42600fd968',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'cf3869e6-ec88-428a-af48-e7fc8ae74867',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-25T19:24:05.385604+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '899169dc-1c5f-4ab0-9fd3-6f3eed2b12e3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'fd5eb3bf-4054-430f-9f28-647b785dd2b8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-26T15:30:54.064995+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '972df3f7-5fb3-4537-a7ce-52d8018a3c95',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '34d03de0-1545-4d24-ac72-7d75577a3697',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-26T20:22:57.576938+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '946956e1-20ad-47bd-bd11-7283a2b5f060',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '604c4701-d666-4422-b870-39ecdccacd77',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-27T19:52:20.822349+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'ac5e9822-a114-4c13-b804-e475ee90e94b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '809316fe-c175-4d05-b735-5d3fd215d955',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-26T13:00:05.67018+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'cd5f1671-7533-4de3-b749-76a84accd80c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ade9a716-2479-44c4-a405-fe97970149b5',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-26T16:10:59.85346+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '5957cb23-c1e2-4730-9cfa-48b706c91bdf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'f18c4f04-7829-4d62-8c65-5484173e0659',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-28T14:21:30.406899+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '0771a194-683e-4674-b70e-869efcb69227',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '66e6e8d8-44d6-48de-8e45-3ea38d16cbc8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-27T14:53:42.578258+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '66f9be9f-8548-4263-a6fb-8e92d5ae5604',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '9f4c0884-bf60-40a3-bca5-cb5b04bcf10f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-28T12:12:07.776654+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '946f2654-5fa5-4523-8b58-d6dd5c6bd92b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'fa2c9924-ad76-4174-bfa8-c738facbc740',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-25T19:51:24.227947+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '13a944b0-246a-4343-88df-839692455d7c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '35ddca11-a4b7-4989-b5a8-56cc672a8d1e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-28T13:19:55.852927+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'ebd3e236-83be-463d-a1ee-95f4068466b8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'a78f10de-a548-4890-b8bd-4b66f512c1b4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-26T14:53:04.796674+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '34a726fe-c8f4-42e7-ac76-d3cca20cc98a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ddbe4aae-4f51-4d41-bb29-53492d0b1343',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-24T18:12:34.112706+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'ca2d1dbc-a4cd-4a41-8f4f-550548544ca8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '82d9c39d-f5e4-49ca-b07c-74204ea768c7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-30T13:41:50.724909+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '19802d6a-69dc-4eef-920b-c03162938063',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '809316fe-c175-4d05-b735-5d3fd215d955',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-28T13:12:44.667883+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'e6c7962a-f5bd-40b1-80ba-8d9acdcbf5ad',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '8841b79a-af00-4b18-b12c-2ee28eaa9648',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-30T14:50:32.797586+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '240be68f-de20-4252-9e90-911ec2a48a91',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '9149ae67-077d-4b9d-b0ff-26314e221838',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-30T16:02:55.961365+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '8830179d-5d3e-451f-92c3-67bc27522e36',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ebf9273f-7a34-4a17-9d78-eb0431a20d22',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-30T17:33:50.766477+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '7582e557-e571-41be-b460-db264f08ad5e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '604c4701-d666-4422-b870-39ecdccacd77',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-28T12:26:44.952981+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'c77931e2-63b1-4e79-b528-63ea0d432764',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '3dc3e949-f54e-45f3-bff8-3a887f068d56',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-02T12:29:00.217158+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '296aa3d6-ea77-4608-884c-6681c4ee21b1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '0785fc34-bbc5-42a6-adf5-87e5e8334a4f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-02T18:57:52.87888+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '7cac97d5-2e69-4a80-95e3-c7b59721f170',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'feab2273-8e47-4147-b813-e1fbe555e562',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-30T14:48:47.534866+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'd3ba2a4a-ebd4-4785-9780-af5b865bf5e7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '2916edbe-88cd-4b52-8096-6a23c8051127',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-02T19:07:19.520678+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'd80b63e9-6209-4ad8-af11-939948eb491d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '37909573-d8eb-4110-bd05-f53bc065c218',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-30T18:51:19.622532+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '5c841b7f-83e0-4ed2-a265-f8f352dfe420',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'b7832b5f-04af-4692-8ce5-7b191af49506',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-06-30T16:59:49.807085+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '2600a6e6-9ff6-4b9c-bbf4-2f174bdcf8af',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'fb405b8e-c47b-4cca-ab26-d9601769f7c2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-01T19:47:09.518288+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'f0787984-3a78-4976-9a10-b15d92e36019',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'b5c5c7b8-ccb6-4f32-9f34-949ca12ebd45',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-03T16:46:35.982222+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '67f4322c-fac9-4470-b412-403426a6968a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '9c5ddf65-713e-4ffe-aa54-b86746b3da99',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-04T16:59:19.811431+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '04f9a0c7-2994-45b8-a4b1-7c8a041416ab',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '2ecb5b24-f0b6-4c84-a80a-30a55b7cdd2a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-03T20:17:20.023499+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '8abfde5f-853e-4741-bcd8-8ccdf9f50a28',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '2ecb5b24-f0b6-4c84-a80a-30a55b7cdd2a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-03T16:19:30.841772+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'a58bddaa-0ffb-41d3-bd6b-c8bbd817db94',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '955f6165-be0b-4aad-856a-badb9016a00c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-01T12:34:14.079769+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'f1257dc2-c1fb-47ac-ad9d-db52161d8bdd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '059ee7ac-66c9-4212-915b-077814b74010',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-04T15:03:54.670344+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '9aa40615-375d-47a4-9b93-63ca809a65a9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'f8eaa952-ba4a-48af-8af0-b8252477f9ac',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-04T16:17:08.065453+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'f8c4d7dd-b71d-4f31-b7b8-fd3193614c96',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '817ca735-c027-47ef-8339-01f51c7a1a3e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-02T14:00:55.856949+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '4ab908a4-025b-4fbf-99d1-a75941617286',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ebf9273f-7a34-4a17-9d78-eb0431a20d22',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-02T20:25:32.891888+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'b4a40143-2ec6-4a26-8e4c-c5fa4a5ac72b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'cdeaa159-0c2a-498e-b229-3e4ca0740694',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-03T15:16:33.024022+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '9050307b-017b-4b37-91f5-4e33a3fa5b5f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'f9ad1aaf-75bd-4c2a-a152-100ad806b9ea',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-04T15:44:09.442593+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '0ce457a1-c215-4257-9d7f-c6a47941363a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '955f6165-be0b-4aad-856a-badb9016a00c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-01T12:33:12.244878+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '3c885a25-828d-4611-ad46-95f751d67f4d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'cdeaa159-0c2a-498e-b229-3e4ca0740694',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-05T15:00:36.657032+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '0725e057-9820-4ab6-8335-7073f8e78a94',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '2ecb5b24-f0b6-4c84-a80a-30a55b7cdd2a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-03T20:18:45.003035+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '60c5c130-bce5-4195-95d2-ab2aad5ef9b3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'fecf496e-9991-4cb4-a66e-b9bfd761d5c1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-04T14:49:02.551981+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '96765271-63eb-4106-b7d1-4d154077ea4d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '604c4701-d666-4422-b870-39ecdccacd77',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-01T19:28:00.513311+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'd2c90a31-e1a5-4188-9846-65cb9c9ea1f5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '0bbf9bb0-4a3a-47dd-955f-2f7e87875417',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-03T17:57:58.18898+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '65a9a591-0528-4459-84eb-9b76640eb7c6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '35b6fb5c-45f6-4257-a7fe-e1744d475c0d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-01T20:40:38.580438+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'f972bd08-95fe-4055-9c43-a403ec9b70d2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '1f044170-d8cd-462f-a2e7-b36c5688aa6c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-04T19:21:09.244012+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '39a0a972-0876-4e2b-bd2c-10f5a8275530',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '55c84001-83c9-43a5-aaf1-6b37974164c9',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-01T18:23:32.730168+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '1d9a3122-4262-4864-adcf-dfe6a3348684',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'bce4a60f-ce64-4114-9f6c-cc377171b978',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-28T13:19:34.516196+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'b576b52c-2089-42a7-85b6-a163c6699cd1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '35c5f024-c9b0-4dfa-b37d-54ae13349318',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-04T12:40:08.974946+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'b9e35df5-b49b-4928-83e0-8e182c6b86f1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '1e03897b-633e-46ec-90bb-5a12dc99698e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-07T17:07:06.077343+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '389ee475-63d7-489a-aa7f-769b150c3f83',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '48ad1879-63a7-421c-a4fc-fdb33cb45127',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-07T15:41:19.363668+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '67db952d-4c2c-4343-9367-cbec89af21f5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'e996b904-ab4f-48cd-bc27-9a3a111230e9',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-10T12:44:13.661388+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '4c15c58e-b383-47db-b3a2-987624bbb256',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'bbc37e46-1971-4c24-b602-e6f725424982',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-05T15:43:12.833537+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '148452fd-a7c4-49d6-ad91-4c88c0d8ff7b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'cdeaa159-0c2a-498e-b229-3e4ca0740694',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-14T14:09:27.77439+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'fe5b5593-cb83-48b3-8477-073827767a5b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '65084213-045c-428c-afb4-afba359cc486',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-11T13:26:28.572558+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '696b2e88-c774-4e8c-97a1-61059287dba6',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '6c644847-f4f6-452c-bca5-fbe646a6ed1c',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-10T17:25:21.521662+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'd5964b11-e1dd-4da6-87aa-4fa036f91927',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '1bb74617-424f-4c0b-bcfc-2de5e87faf80',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-07T17:13:28.144959+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '6186002b-6e87-4822-8612-9e35aeb17ca0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'd92548f8-b488-4246-8f8d-f3e42f243fb1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-08T17:18:27.359189+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '65254cde-f5c7-4e56-859b-c8d52c3f1705',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '75b108c1-e5d8-4c19-9fd9-e97516ec4b01',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-11T18:26:27.616468+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'f5e52807-010a-4422-8f06-840685d082f0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '2181c9cb-fcb9-4148-b55a-19f0144c1975',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-07T16:52:57.811999+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '2a382108-899d-437f-a32f-679dc5cd087b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '3d6fda07-bf9a-4746-b050-73e7ead568aa',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-10T12:06:52.471074+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '1c925caa-fe00-451b-854d-8e43e324cb86',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'a78f10de-a548-4890-b8bd-4b66f512c1b4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-16T13:35:06.21804+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'b92addb5-3a15-4e2c-849e-962c175c49ba',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '067e4459-c80b-434b-bfef-bd3018d0424d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-10T12:51:58.563253+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '859153ae-fb25-4f3f-978f-3ba5eeccb9a3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '85460a9d-3277-4d82-9574-39cd914028c6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-08T16:43:15.370717+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '0e31a761-33d1-4e8a-b903-29bbf0b8c2dd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '7dc2d6f3-4033-4506-a195-1931a601d1bd',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-10T17:13:48.966271+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '760e0ff4-bac5-4902-aba7-0180ba5b85e5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'df7e11e2-3856-4b11-8df7-40ad0465a54d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-15T12:28:57.866728+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '3941b403-34b4-40fc-b0a7-8cd35ab84ff2',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '03baff14-c408-472e-bce7-ec48646a370e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-11T13:10:53.20126+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'fb952c9e-ff82-427b-92e4-1458c666b225',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '9ddd4f52-f2d7-400d-bad9-3e6ff55d64a2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-10T15:44:43.586394+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '86cbdc96-0600-4487-a087-83f05fbc605e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '0f7e4449-6876-4362-8afa-d410f9c32a6b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-10T13:14:11.286334+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'a32fe765-83b6-4e27-bee5-c3bba81eb792',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '4e905e3d-8b94-48e2-a4aa-de5879e592ae',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-12T12:51:29.813114+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'dcd7be3e-99a1-47bd-b165-203952b029c3',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '35b6fb5c-45f6-4257-a7fe-e1744d475c0d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-07T17:11:07.10554+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'b598466b-abb9-4214-9c65-ddbb8c911d18',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '8638766e-3406-4274-8463-db5b82ea21ad',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-11T12:30:08.07315+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'c439748d-570e-439e-900d-8810687d13c4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '73b62e47-eca9-45a4-bed8-705ca9f5ddc8',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-15T19:10:20.801231+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '456c1c6f-114f-4aae-aa94-6f2ce0162fa8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '3dc3e949-f54e-45f3-bff8-3a887f068d56',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-16T20:24:09.366533+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'bd1908e0-b5bc-4772-b1e1-f340de054822',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '50e05cb2-6587-4ebf-8cec-33b52037f93f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-15T19:35:32.327211+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '3168f47a-d442-4756-9cf2-098627160718',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '231c72a1-2a56-4f0b-a6ae-dce0da1e44f4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-16T13:44:12.64965+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '925b42b4-3858-4870-91d6-31faa1104c9b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '985bd782-ea67-4237-99bf-889eeaaa7108',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-14T13:59:23.020143+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'fa56d3f5-b5c4-404f-91e6-1fc4450332f4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '6ae15fcc-9409-47de-ba9a-d6920a70f73a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-14T12:12:07.109478+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '35e79443-66c6-47c8-b8a4-0de4b3f62e7f',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'e8c33d27-ebd6-49e2-82a7-2d4aab7883c2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-16T12:46:55.042591+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '7887d360-70fd-41f0-bb3f-b804281b1ee8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '3f805d2c-c858-48b3-98c2-ff570a7331e5',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-23T12:26:59.237031+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '4860a5b6-4ac7-4e1f-9a29-bf6d9202ef2d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '4a60083b-113f-42db-a163-b35cb738fc9f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-15T13:05:23.016697+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '8b219c38-d1ee-4e0e-9b2b-1d80613a48d7',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'e8c33d27-ebd6-49e2-82a7-2d4aab7883c2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-17T18:18:01.352814+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'b126c2c5-968e-4564-abe2-9f3eeeb8a80c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '94606b30-8603-4773-87ea-0207d3043045',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-24T13:33:50.877916+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '749fb822-f7fc-458a-99a4-c88b24de13ca',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '823f02e0-dc7c-407c-94eb-29b415d2120d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-17T18:27:48.739623+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '10e3261b-d0b9-4984-918b-4dff74934ebf',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'd9d8853a-b8bc-41a7-ade6-fcaccc7146f0',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-18T16:09:11.878504+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '9d37fc30-5fea-4f27-9fc7-bc7b958d48c0',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '6ae15fcc-9409-47de-ba9a-d6920a70f73a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-18T16:26:24.410333+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '65b43bae-37ea-488b-abff-c05910535b3a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '6ae15fcc-9409-47de-ba9a-d6920a70f73a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-18T16:27:46.61445+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'e30bd71b-6e8a-4b73-8cd5-30bb8c169f79',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '65084213-045c-428c-afb4-afba359cc486',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-18T12:25:14.784132+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '89013be4-d8a0-4c74-ae69-af89eaa40f2b',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'fc7cb829-0208-4f73-bdb6-cbaf96f5117b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-19T12:25:40.033087+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '9cc36704-6d79-4af4-9397-734c1cd6a8e5',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '2b2e6d7f-6c38-4648-96a4-c47005ae0a5e',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-19T14:18:27.56507+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'bdb2b08b-0e0b-4673-b343-a2984ad0369c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'd4ed0f0b-82ec-46cd-9906-871f97065b5a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-28T12:22:44.83042+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '494c4d35-bdc6-4f81-be43-fd676d3080cd',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '8b3fadbc-273d-402f-8de8-5a46fca50ca1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-18T17:14:04.860311+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '4b0b700c-6f2f-44b7-bde8-a5e9a2815df8',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'e4aa6d76-2168-4c06-ac88-3c619aff787b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-22T17:52:53.935861+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '4b3eddac-6ec2-4839-ba45-3687d8d79969',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '5d289b72-c214-4f59-a73c-68d2642518ef',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-18T16:40:21.65525+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'a5884473-3da5-4c57-bb0b-07200146c4af',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '77e3cf28-ea42-4cae-b5b5-7d3a7db2a073',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-18T17:00:40.085997+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '6c0d0d59-251c-4543-9335-f0bf04474c0d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'b8485121-7418-463d-ac9e-d955f60b9a10',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-19T13:43:33.483432+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '97fce405-22e3-453c-b58b-ef5c9606f7a1',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '5ea16650-778e-4ae4-8598-fca206c7dff1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-22T13:26:27.236958+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '597bc28a-3426-4a70-a5ac-84a88ac83d59',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '1736c2f0-7acd-49ee-bb2e-dd44d858ee7b',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-23T17:06:18.907426+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '018038b8-22e9-4a9e-8356-a8249ba83535',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'd942be79-f8ab-4300-b5e1-408b4de2fdad',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-24T12:46:08.648402+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'cbbc2646-ca83-49f7-9158-9564c19541f4',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'e956c295-b989-406a-ae1a-44ea6503b2e6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-23T12:12:39.605281+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '3cf3b52a-671b-4974-af2e-a82dfa400f3a',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '0785fc34-bbc5-42a6-adf5-87e5e8334a4f',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-24T12:41:11.92638+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '062f29eb-26f4-4383-b84e-052344999839',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '6ff3b90e-ecb0-48b8-814e-52567807c752',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-24T20:41:07.572939+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '30309151-c423-4358-8f4d-8bc0612e024c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'f1afda76-5bbf-410f-a007-36775ef2cf1d',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-25T15:00:17.265742+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'ed55f3c4-194d-4820-8dc3-43620d34d263',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'b80944ee-91c7-4109-9698-18596d006321',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-18T13:45:26.561559+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '5bb60895-1c84-4249-9834-8b3d2c7d0150',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'bce4a60f-ce64-4114-9f6c-cc377171b978',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-25T18:11:38.719284+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '768401ea-500b-437b-9a61-3f12c19e4231',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '7bd6c0d8-e754-4de4-9918-a890d59f07a9',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-26T14:06:56.385001+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '0390cd38-b6d0-4373-bb23-1aa333f96070',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'a78f10de-a548-4890-b8bd-4b66f512c1b4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-19T13:13:24.688163+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '23020e40-5b94-4972-8cbf-23fd90c12e31',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '67526f20-485e-40a0-b448-303ce34932fc',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-26T15:23:14.155664+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'a219233b-0c3c-4336-ad7f-2dde79ae4544',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '5ea16650-778e-4ae4-8598-fca206c7dff1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-25T19:16:01.66323+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '09a79ecb-1108-4ad0-9b08-05caf349ac18',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'd2b69b59-b14d-4563-ab72-40a41f728cf7',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-24T20:07:51.723348+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '66466177-a934-46b4-94ef-10f8b4768004',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '3dd98e80-a9bc-409b-bbc3-d3069202f766',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-28T13:39:17.250026+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'eeebc373-a742-425a-930a-7e351dac3a57',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '231c72a1-2a56-4f0b-a6ae-dce0da1e44f4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-28T13:44:26.285215+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '312f1c4a-2642-4a7a-ab32-0bfcd77322c9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'd87374ff-86cd-4872-9684-bec98c167ca9',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-28T16:28:41.365409+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'ee31ad2c-6eae-41bd-9ea1-80ce156453d9',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '0a812f7f-5c68-4044-a6c3-f2e8ae8a2d32',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-28T19:05:27.979823+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '4629ee92-6153-432f-85b9-3e9197da12fe',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'ffbceb28-0219-4eef-81f6-4238586e03a9',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-29T14:31:09.996648+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '0ac02371-83ef-4ab1-8e7d-3eae97c70efa',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '719a0456-02b7-4934-b9d8-fa68cefa4822',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-29T14:38:47.176805+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  'f17e96e5-61d8-4c02-814c-6326226110ce',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  'a07aeea2-bd3b-4b5c-9a1a-b3c87f50cfcd',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-29T15:42:10.162715+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '57c2ed01-a5d1-4493-bd60-6a7673186863',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '2a49ab83-e053-418b-9d16-88f14ff2d028',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-29T16:12:57.415619+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '58d0e69f-60fb-40f1-8c53-7c3dd9b6fe1e',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '4af50a1b-acf2-4229-b806-f0ce578119ac',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-29T16:25:03.320145+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '13a3afe6-0f24-4d03-a570-389953f5592d',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '5487ccc9-e53a-4a83-b29f-46e8297c842a',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'aberta',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-25T13:16:56.054745+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();

INSERT INTO ordens_servico (
  id, empresa_id, cliente_id, equipamento, marca, modelo,
  numero_serie, defeito_relatado, observacoes_tecnico,
  status, valor_servico, valor_pecas, data_entrada,
  data_prevista, laudo_tecnico, created_at, updated_at
) VALUES (
  '89ca6338-a9df-4fea-b757-5140779b889c',
  'f1726fcf-d23b-4cca-8079-39314ae56e00',
  '0f5f5458-b45b-408f-82f9-8f1053969c17',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  'fechada',
  0,
  0,
  NULL,
  NULL,
  NULL,
  '2025-07-18T16:07:04.590351+00:00',
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  status = EXCLUDED.status,
  valor_servico = EXCLUDED.valor_servico,
  valor_pecas = EXCLUDED.valor_pecas,
  observacoes_tecnico = EXCLUDED.observacoes_tecnico,
  laudo_tecnico = EXCLUDED.laudo_tecnico,
  updated_at = NOW();


-- Reabilitar triggers
SET session_replication_role = DEFAULT;

-- Verificar dados atualizados
SELECT 'clientes' as tabela, COUNT(*) as total, 
       COUNT(CASE WHEN telefone IS NOT NULL AND telefone != '' THEN 1 END) as com_telefone,
       COUNT(CASE WHEN cpf_cnpj IS NOT NULL AND cpf_cnpj != '' THEN 1 END) as com_cpf
FROM clientes WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
UNION ALL
SELECT 'produtos', COUNT(*), 0, 0 FROM produtos WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
UNION ALL
SELECT 'ordens_servico', COUNT(*), 0, 0 FROM ordens_servico WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00';

-- =============================================
-- FIM DA ATUALIZAÇÃO
-- =============================================
