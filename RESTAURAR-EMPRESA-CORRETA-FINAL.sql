-- =============================================
-- RESTAURAÇÃO COM EMPRESA_ID CORRETO
-- Empresa: f7fdf4cf-7101-45ab-86db-5248a7ac58c1
-- 141 clientes do backup
-- Gerado em 19/10/2025, 23:49:50
-- =============================================

SET session_replication_role = replica;

-- Limpar clientes existentes
DELETE FROM clientes WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';
DELETE FROM clientes WHERE empresa_id IS NULL;

-- 1/141: ANTONIO CLAUDIO FIGUEIRA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 2/141: EDVANIA DA SILVA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 3/141: SAULO DE TARSO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 4/141: ALINE CRISTINA CAMARGO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 5/141: WINDERSON RODRIGUES LELIS
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 6/141: ALINE MARIA PEREIRA DA CRUZ
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 7/141: JORGE FRANCISCO RIBEIRO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 8/141: Giane Bitencourt
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 9/141: EVALDO ANDRE MAZIETO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 10/141: Ertili Alves Brandão
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 11/141: JOSLIANA ERIDES DE PAULA FREITAS
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 12/141: FLAVIA MARQUES FIGUEIREDO DE PAULA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 13/141: CELIO SANTOS DE SOUSA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 14/141: ODAIR FERREIRA DE SOUSA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 15/141: Vitor Aleixo
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 16/141: Tiago Luiz Da Silva
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 17/141: EDSON RODRIGO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 18/141: Lucinei Batista
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 19/141: cristiane matos
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 20/141: ROBERTO BEL  PRESENTES
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 21/141: LUIZ CARLOS ESTEVES
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 22/141: Sirlene Janaina Amancio
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 23/141: ADRIANA DA SILVA CIPRIANO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 24/141: MARISSELMA DE OLIVEIRA BORGES
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 25/141: maria vitoria medeiros
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 26/141: DARIO RODRIGO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 27/141: IGOR DAHER RAMOS
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 28/141: RAFAELA BRUNA BARROS
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 29/141: adriana moraes
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 30/141: DOUGLAS RODRIGUES FERREIRA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 31/141: JULIANA ALVES DE SOUZA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 32/141: CRISTIANO LUIZ 
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 33/141: JAQUELINE CARDOSO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 34/141: GABRIEL VICTOR DOS SANTOS
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 35/141: Daiane Hukumoto
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 36/141: raimundo da silva barcelar
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 37/141: gabriela domiciano soares
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 38/141: marco aurélio becari 
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 39/141: JEAN JUNIOR RIBEIRO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 40/141: FRANCISCO GENILDO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 41/141: LUCIANO TAVARES
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 42/141: Aguetoni Transportes LTDA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 43/141: Laurence wilians
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 44/141: joana darc teixeira
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 45/141: WILSON JOSE SERIBELI JUNIOR
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 46/141: Lucas Caio dos Santos
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 47/141: GABRIEL FLORA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 48/141: ALEXANDRE BUENO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 49/141: JOVAN NASCIMENTO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 50/141: MARCELO ARAUJO FARIAS
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 51/141: LUIZ CARLOS XAVIER
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 52/141: ROBERTO CARLOS  OLIVEIRA SILVA 
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 53/141: SANDRO ROCHA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 54/141: VANESIO MARTINS GUEDES
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 55/141: liliane maria dos santos
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 56/141: milena aparecida rico
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 57/141: gustavo henrique
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 58/141: Luka Guia Guaira
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 59/141: leticia costa 
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 60/141: OTAVIO DE OLIVEIRA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 61/141: DENIS VIEIRA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 62/141: SILVIO BRITO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 63/141: JOEMERSON SILVEIRA DOS SANTOS
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 64/141: joão batista serafim gonçalves
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 65/141: larissa de oliveira espacini
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 66/141: DEIVID RUBIO 
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 67/141: Valter  Baudoino
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 68/141: rogerio basilio de araujo
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 69/141: BEATRIZ DE SOUZA DA SILVA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 70/141: ANA CAROLNA SANTOS DE OLIVEIRA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 71/141: MATHEUS CIRINO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 72/141: JOILSON DARLAN
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 73/141: ELIAS MATIAS
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 74/141: ANTONIO MORAES
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 75/141: ADRIAN RENAN GONÇALVES PEREIRA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 76/141: JOÃO VITOR RIBEIRO DOS REIS
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 77/141: DARCI ORTIGOSO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 78/141: MARIA JULIA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 79/141: ALEX VACARO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 80/141: RENATA CRISTINA CAETANO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 81/141: FRANCIsNEI DA SILVA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 82/141: mMARIA BENEDITA DE ALMEIDA FOGAÇA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 83/141: Roseli Lacerda Cartola
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 84/141: MATEUS PAVANELLO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 85/141: DANIELE CUSTODIO DE MELO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 86/141: JOSIANE VENTURA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 87/141: WELLINGTON LUIZ
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 88/141: RAQUEL APARECIDA GOMES
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 89/141: LUANA VAZ
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 90/141: LUCAS LINO TEIXEIRA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 91/141: EDISON CAETANO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 92/141: EDSON GUILHERME FONSECA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 93/141: Elson Teixeira
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 94/141: Altamiro Antonio de Matos
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 95/141: Pedro Henrique Eugenio
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 96/141: JAIR DELEFRATE 
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 97/141: jennifer maria de sousa
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 98/141: DANIELA BARBOSA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 99/141: NEIDE FRAGUA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 100/141: TARINAN GOMES DOS SANTOS
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 101/141: mirela vitoria ferreira de sousa
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 102/141: edna cristina spigali
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 103/141: LARICE DE CASTRO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 104/141: rafael borges
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 105/141: MAIRA GARCIA LELLIS
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 106/141: ana paula garcia barbosa
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 107/141: rogerio de paiva
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 108/141: CRISTIAN PAULINO 
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 109/141: ELAINE CRISTINA RIBEIRO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 110/141: PAULO SERGIO OLIMPIO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 111/141: LUIZ FABIO TALARICO DE OLIVEIRA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 112/141: daltoni da cunha teixeira
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 113/141: valeria cristina da costa 
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 114/141: SULAMITA FERREIRA DE SOUZA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 115/141: ANA LIVIA  FONSECA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 116/141: ANDREA LUGUE
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 117/141: joao batista serafim gonçalves
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 118/141: IRENE ROSA DE SOUZA VALENTI
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 119/141: JOAO VITOR CAVENAG
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 120/141: MAX MARQUES
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 121/141: marcos junior
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 122/141: josé reinaldo junior
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 123/141: DENIS VIEIRA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 124/141: LILIAN CRISTINA FLOR
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 125/141: FERNANDA MARQUES DA SILVA CANDIDO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 126/141: gabriel alves scarpelini dos santos
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 127/141: COOPERCITRUS VALTRA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 128/141: gilson zanotelo
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 129/141: anizio gabriel
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 130/141: suelen carla davanço 
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 131/141: JOSE DE OLIVEIRA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 132/141: ANISIO GABRIEL
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 133/141: CRISTIANE APARECIDA SOUZA FERRAZ
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 134/141: CARLOS DA SILVA BARBOSA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 135/141: VALESCA RUBIA PAIVA TOLENTINO
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 136/141: ANGELO GABRIEL 
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 137/141: MARCIO MB INFORMATICA
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 138/141: andrea da silva brosco
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 139/141: dara neves
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 140/141: maiza gonçalves
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

-- 141/141: daniel rosa de oliveira
INSERT INTO clientes (
  id, user_id, empresa_id, nome, telefone, email, cpf_cnpj, cpf_digits,
  endereco, cidade, estado, cep, tipo, ativo, observacoes,
  created_at, updated_at
) VALUES (
  '',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  '',
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
);

SET session_replication_role = DEFAULT;

-- VERIFICAÇÃO FINAL
SELECT 
  'Após restauração' as momento,
  COUNT(*) as total_clientes,
  COUNT(CASE WHEN telefone IS NOT NULL AND telefone != '' THEN 1 END) as com_telefone,
  COUNT(CASE WHEN cpf_cnpj IS NOT NULL AND cpf_cnpj != '' THEN 1 END) as com_cpf
FROM clientes
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- =============================================
-- FIM DA RESTAURAÇÃO
-- =============================================

