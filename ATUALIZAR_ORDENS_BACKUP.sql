-- ============================================
-- ATUALIZAR ORDENS COM DADOS DO BACKUP
-- Total: 160 ordens
-- Campos: data_entrega, garantia_dias, observacoes
-- ============================================

-- Ordem 1/160: EDVANIA DA SILVA
UPDATE ordens_servico SET
  data_entrega = '2025-06-17',
  garantia_dias = 150,
  observacoes = NULL,
  valor_final = 290
WHERE id = 'dcdc1e19-d128-468c-b8f2-85b815a96d8e';

-- Ordem 2/160: EDVANIA DA SILVA
UPDATE ordens_servico SET
  data_entrega = '2025-06-17',
  garantia_dias = 30,
  observacoes = 'FOI RETIRADO O GMAIL DO APARELHO',
  valor_final = 380
WHERE id = '8b1bef3b-e62d-458d-aef6-c7c4eb7e3c80';

-- Ordem 3/160: SAULO DE TARSO
UPDATE ordens_servico SET
  data_entrega = '2025-06-18',
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 150
WHERE id = 'f50b8b48-e7c7-4166-ab41-5f9615450efb';

-- Ordem 4/160: ALINE CRISTINA CAMARGO
UPDATE ordens_servico SET
  data_entrega = '2025-06-18',
  garantia_dias = 150,
  observacoes = 'TROCA DE TELA',
  valor_final = 250
WHERE id = '0f526fa3-3d21-468b-b02e-f94f0f9c58fe';

-- Ordem 5/160: WINDERSON RODRIGUES LELIS
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 1
WHERE id = 'b3acbfef-c898-4df0-bfba-4922ba5b6520';

-- Ordem 6/160: ALINE CRISTINA CAMARGO
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0.01
WHERE id = 'b28607a0-3395-441f-a709-22eecc6406a1';

-- Ordem 7/160: EVALDO ANDRE MAZIETO
UPDATE ordens_servico SET
  data_entrega = '2025-06-18',
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 213
WHERE id = 'a01954f8-235d-4a3e-aa14-a1b7ce0e697f';

-- Ordem 8/160: JOSLIANA ERIDES DE PAULA FREITAS
UPDATE ordens_servico SET
  data_entrega = '2025-06-20',
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO:',
  valor_final = 0
WHERE id = 'da025224-7bd0-4220-99c8-7e98f5cee7a8';

-- Ordem 9/160: Giane Bitencourt
UPDATE ordens_servico SET
  data_entrega = '2025-06-18',
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 100
WHERE id = 'cc088a5a-cd4f-46b3-86bc-3e60b04d430d';

-- Ordem 10/160: ALINE CRISTINA CAMARGO
UPDATE ordens_servico SET
  data_entrega = '2025-06-20',
  garantia_dias = 150,
  observacoes = 'FEITO TROCA DE TELA, RETIRADO TELA ANTERIOR PAGO DIFERENÇA REFERENTE A ANTERIOR',
  valor_final = 40
WHERE id = '16dab66b-2bc4-4292-9648-123b8b688d15';

-- Ordem 11/160: ADRIANA DA SILVA CIPRIANO
UPDATE ordens_servico SET
  data_entrega = '2025-06-23',
  garantia_dias = 90,
  observacoes = 'TROCA DA BANDEJA',
  valor_final = 180
WHERE id = '96e5a161-e615-4cd5-98a9-1dd530591b84';

-- Ordem 12/160: ODAIR FERREIRA DE SOUSA
UPDATE ordens_servico SET
  data_entrega = '2025-06-20',
  garantia_dias = 150,
  observacoes = 'TROCA DE TELA WEFIX',
  valor_final = 320
WHERE id = '813bcf9e-7ef0-4787-b7b6-d1152d1417ff';

-- Ordem 13/160: CELIO SANTOS DE SOUSA
UPDATE ordens_servico SET
  data_entrega = '2025-06-20',
  garantia_dias = 90,
  observacoes = 'REPARO NA PLACA DIVIDIDO VALOR DE R$480,00 4X TOTAL 515,30 PAG COMBUSIVEL NO DEBITO R$100,00',
  valor_final = 615.3
WHERE id = 'fa8d7dd2-4d54-4ed4-9466-462472bc3b97';

-- Ordem 14/160: Tiago Luiz Da Silva
UPDATE ordens_servico SET
  data_entrega = '2025-06-20',
  garantia_dias = 90,
  observacoes = 'TROCA DE BATERIA',
  valor_final = 180
WHERE id = 'c79cae4d-07b4-41c4-bd8a-f8c8d28aaff1';

-- Ordem 15/160: Ertili Alves Brandão
UPDATE ordens_servico SET
  data_entrega = '2025-06-21',
  garantia_dias = 90,
  observacoes = 'FEITO TROCA DE PLACA',
  valor_final = 350
WHERE id = '5cb6318c-bf05-4452-abeb-70157e1678d5';

-- Ordem 16/160: Lucinei Batista
UPDATE ordens_servico SET
  data_entrega = '2025-06-21',
  garantia_dias = 90,
  observacoes = 'TROCA DE BATERIA',
  valor_final = 170
WHERE id = '0903bd43-616c-43ba-a1f0-5dd36a9756da';

-- Ordem 17/160: EDSON RODRIGO
UPDATE ordens_servico SET
  data_entrega = '2025-06-21',
  garantia_dias = 90,
  observacoes = 'com bandejinha - sem chip',
  valor_final = 350
WHERE id = '2e6f93d9-2939-466e-ae52-1e2b700cf0ef';

-- Ordem 18/160: Sirlene Janaina Amancio
UPDATE ordens_servico SET
  data_entrega = '2025-06-23',
  garantia_dias = 90,
  observacoes = 'FEITO TROCA DA BATRIA ',
  valor_final = 180
WHERE id = 'da3dad0d-e528-4e5f-809e-1300c054fc72';

-- Ordem 19/160: ROBERTO BEL  PRESENTES
UPDATE ordens_servico SET
  data_entrega = '2025-07-01',
  garantia_dias = 90,
  observacoes = 'ENTREGUE OK VALOR R$100,00',
  valor_final = 0
WHERE id = 'e4e52338-9604-4d24-8a09-f36f15d53314';

-- Ordem 20/160: LUIZ CARLOS ESTEVES
UPDATE ordens_servico SET
  data_entrega = '2025-06-25',
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO:',
  valor_final = 0
WHERE id = 'af585103-d8c6-4153-80bc-35f1e6b5f5fc';

-- Ordem 21/160: FLAVIA MARQUES FIGUEIREDO DE PAULA
UPDATE ordens_servico SET
  data_entrega = '2025-06-23',
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '9ba24f72-6c11-48e6-8c26-b27d041fc514';

-- Ordem 22/160: Vitor Aleixo
UPDATE ordens_servico SET
  data_entrega = '2025-06-23',
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO: GARANTIA ANTERIOR DA OS: 16741 FLEX SOLTO DA PLACA DE CARGA',
  valor_final = 0
WHERE id = 'a71375aa-15e1-4e6f-aabe-17a25bc2e52c';

-- Ordem 23/160: FLAVIA MARQUES FIGUEIREDO DE PAULA
UPDATE ordens_servico SET
  data_entrega = '2025-06-23',
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO:',
  valor_final = 80
WHERE id = 'c83a4ee1-0a1b-43cb-a590-16b4cc3e343d';

-- Ordem 24/160: IGOR DAHER RAMOS
UPDATE ordens_servico SET
  data_entrega = '2025-06-24',
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 270
WHERE id = '36210e2c-9f3c-40fc-890f-a902220b3081';

-- Ordem 25/160: Ertili Alves Brandão
UPDATE ordens_servico SET
  data_entrega = '2025-06-26',
  garantia_dias = 90,
  observacoes = 'Ordem de garantia referente à OS #7E1678D5. Defeito original: NÃO CARREGA  TESTAR PARA VERIFICAÇÃO SE VAI DESLIGAR',
  valor_final = 0
WHERE id = '5cc28c48-aa32-4079-9692-173265cc8a82';

-- Ordem 26/160: DARIO RODRIGO
UPDATE ordens_servico SET
  data_entrega = '2025-06-25',
  garantia_dias = 180,
  observacoes = NULL,
  valor_final = 280
WHERE id = '27064aeb-1278-4bbb-8b37-af3d85056a7c';

-- Ordem 27/160: cristiane matos
UPDATE ordens_servico SET
  data_entrega = '2025-07-01',
  garantia_dias = 150,
  observacoes = 'FOI FEITA A TROCA DE TELA',
  valor_final = 280
WHERE id = '11741f23-4461-40d8-9707-64961a72b314';

-- Ordem 28/160: RAFAELA BRUNA BARROS
UPDATE ordens_servico SET
  data_entrega = '2025-06-30',
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO: NÃO QUIS CONCERTAR',
  valor_final = 0
WHERE id = 'aa8fa75c-0a20-4f0b-a8ae-2e926e93721e';

-- Ordem 29/160: JORGE FRANCISCO RIBEIRO
UPDATE ordens_servico SET
  data_entrega = '2025-07-11',
  garantia_dias = 90,
  observacoes = 'NÃO DEU CONCERTO',
  valor_final = 30
WHERE id = '3891764e-4925-4983-bea8-3251ec55519e';

-- Ordem 30/160: DOUGLAS RODRIGUES FERREIRA
UPDATE ordens_servico SET
  data_entrega = '2025-06-24',
  garantia_dias = 90,
  observacoes = 'TROCA DE TELA ',
  valor_final = 97
WHERE id = '1f87f15a-3682-4f4f-b296-d11c4f5c7959';

-- Ordem 31/160: FRANCISCO GENILDO
UPDATE ordens_servico SET
  data_entrega = '2025-06-26',
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO: Quando o aparelho for analisado e o defeito identificado, mas o cliente optar por não realizar o conserto, será cobrado uma taxa de avaliação sobre o processo de diagnóstico do técnico, no valor de R$ 30,00.',
  valor_final = 0
WHERE id = '920e1321-f918-476a-bdd8-b8435ca2fdef';

-- Ordem 32/160: joana darc teixeira
UPDATE ordens_servico SET
  data_entrega = '2025-06-27',
  garantia_dias = 90,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 130
WHERE id = 'c643ae63-07e3-4b7f-a99a-80bb5f5163be';

-- Ordem 33/160: MARISSELMA DE OLIVEIRA BORGES
UPDATE ordens_servico SET
  data_entrega = '2025-06-24',
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO: ESTA SÓ COM UMA BANDEJA DE SIM CARD',
  valor_final = 240
WHERE id = '4cd05493-b617-4864-994e-de0b4a599094';

-- Ordem 34/160: DANIELA BARBOSA
UPDATE ordens_servico SET
  data_entrega = '2025-06-27',
  garantia_dias = 90,
  observacoes = 'NÃO TEM BANDEJA DE SIM CARD',
  valor_final = 160
WHERE id = '0bd6af65-d2af-48bd-8d1b-e47206adeb9b';

-- Ordem 35/160: Aguetoni Transportes LTDA
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '67061904-603b-4ca4-b9e4-6a290f508821';

-- Ordem 36/160: LUCIANO TAVARES
UPDATE ordens_servico SET
  data_entrega = '2025-06-27',
  garantia_dias = 90,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 180
WHERE id = 'b2895ee6-1913-4108-a705-44e87cabf91b';

-- Ordem 37/160: CRISTIANO LUIZ 
UPDATE ordens_servico SET
  data_entrega = '2025-06-25',
  garantia_dias = 150,
  observacoes = NULL,
  valor_final = 290
WHERE id = '3c888d30-4571-4706-8710-488dda28856e';

-- Ordem 38/160: JAQUELINE CARDOSO
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO:',
  valor_final = 0
WHERE id = 'd3252c8b-b148-4350-9d17-82ff4c2e07bb';

-- Ordem 39/160: GABRIEL VICTOR DOS SANTOS
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO: FAZER UMA AVALIAÇÃO GERAL, PREÇO DA BATERIA, E ORÇAMENTO DO REPARO DA TELA.',
  valor_final = 0
WHERE id = '23a73d1f-7440-46e7-b70d-29213dc6435e';

-- Ordem 40/160: Daiane Hukumoto
UPDATE ordens_servico SET
  data_entrega = '2025-06-25',
  garantia_dias = 90,
  observacoes = 'PAGO TOTAL ',
  valor_final = 750
WHERE id = '12b17573-9df9-47bb-96eb-db1bca7620e7';

-- Ordem 41/160: raimundo da silva barcelar
UPDATE ordens_servico SET
  data_entrega = '2025-06-25',
  garantia_dias = 150,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 270
WHERE id = '7df002ed-fde7-4fd8-acb2-9e42600fd968';

-- Ordem 42/160: ALINE MARIA PEREIRA DA CRUZ
UPDATE ordens_servico SET
  data_entrega = '2025-06-26',
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '899169dc-1c5f-4ab0-9fd3-6f3eed2b12e3';

-- Ordem 43/160: LUCIANO TAVARES
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 90
WHERE id = '972df3f7-5fb3-4537-a7ce-52d8018a3c95';

-- Ordem 44/160: Laurence wilians
UPDATE ordens_servico SET
  data_entrega = '2025-06-27',
  garantia_dias = 90,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 110
WHERE id = '946956e1-20ad-47bd-bd11-7283a2b5f060';

-- Ordem 45/160: gabriela domiciano soares
UPDATE ordens_servico SET
  data_entrega = '2025-06-27',
  garantia_dias = 90,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.  Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 80
WHERE id = 'ac5e9822-a114-4c13-b804-e475ee90e94b';

-- Ordem 46/160: JEAN JUNIOR RIBEIRO
UPDATE ordens_servico SET
  data_entrega = '2025-06-28',
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO: Quando o aparelho for analisado e o defeito identificado, mas o cliente optar por não realizar o conserto, será cobrado uma taxa de avaliação sobre o processo de diagnóstico do técnico, no valor de R$ 30,00.',
  valor_final = 100
WHERE id = 'cd5f1671-7533-4de3-b749-76a84accd80c';

-- Ordem 47/160: Lucas Caio dos Santos
UPDATE ordens_servico SET
  data_entrega = '2025-06-28',
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO: Quando o aparelho for analisado e o defeito identificado, mas o cliente optar por não realizar o conserto, será cobrado uma taxa de avaliação sobre o processo de diagnóstico do técnico, no valor de R$ 30,00.',
  valor_final = 30
WHERE id = '5957cb23-c1e2-4730-9cfa-48b706c91bdf';

-- Ordem 48/160: maria vitoria medeiros
UPDATE ordens_servico SET
  data_entrega = '2025-06-28',
  garantia_dias = 90,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais. TROCA DO FLEX ',
  valor_final = 90
WHERE id = '0771a194-683e-4674-b70e-869efcb69227';

-- Ordem 49/160: joana darc teixeira
UPDATE ordens_servico SET
  data_entrega = '2025-06-28',
  garantia_dias = 90,
  observacoes = 'Ordem de garantia referente à OS #5F5163BE. Defeito original: conector',
  valor_final = 0
WHERE id = '66f9be9f-8548-4263-a6fb-8e92d5ae5604';

-- Ordem 50/160: LUIZ CARLOS ESTEVES
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO: BANDEJA',
  valor_final = 390
WHERE id = '946f2654-5fa5-4523-8b58-d6dd5c6bd92b';

-- Ordem 51/160: WILSON JOSE SERIBELI JUNIOR
UPDATE ordens_servico SET
  data_entrega = '2025-06-30',
  garantia_dias = 179,
  observacoes = NULL,
  valor_final = 290
WHERE id = '13a944b0-246a-4343-88df-839692455d7c';

-- Ordem 52/160: marco aurélio becari 
UPDATE ordens_servico SET
  data_entrega = '2025-07-03',
  garantia_dias = 150,
  observacoes = 'troca de tela',
  valor_final = 260
WHERE id = 'ebd3e236-83be-463d-a1ee-95f4068466b8';

-- Ordem 53/160: adriana moraes
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'deixou só video game   Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 280
WHERE id = '34a726fe-c8f4-42e7-ac76-d3cca20cc98a';

-- Ordem 54/160: GABRIEL FLORA
UPDATE ordens_servico SET
  data_entrega = '2025-07-05',
  garantia_dias = 90,
  observacoes = 'display wefix',
  valor_final = 290
WHERE id = 'ca2d1dbc-a4cd-4a41-8f4f-550548544ca8';

-- Ordem 55/160: gabriela domiciano soares
UPDATE ordens_servico SET
  data_entrega = '2025-07-05',
  garantia_dias = 180,
  observacoes = 'TROCOU DISPLAY',
  valor_final = 350
WHERE id = '19802d6a-69dc-4eef-920b-c03162938063';

-- Ordem 56/160: ALEXANDRE BUENO
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = 'e6c7962a-f5bd-40b1-80ba-8d9acdcbf5ad';

-- Ordem 57/160: MARCELO ARAUJO FARIAS
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '240be68f-de20-4252-9e90-911ec2a48a91';

-- Ordem 58/160: ROBERTO CARLOS  OLIVEIRA SILVA 
UPDATE ordens_servico SET
  data_entrega = '2025-06-30',
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 250
WHERE id = '8830179d-5d3e-451f-92c3-67bc27522e36';

-- Ordem 59/160: Laurence wilians
UPDATE ordens_servico SET
  data_entrega = '2025-06-30',
  garantia_dias = 90,
  observacoes = 'Ordem de garantia referente à OS #A2B5F060. Defeito original: arrumou gatilho LT',
  valor_final = 0
WHERE id = '7582e557-e571-41be-b460-db264f08ad5e';

-- Ordem 60/160: leticia costa 
UPDATE ordens_servico SET
  data_entrega = '2025-07-10',
  garantia_dias = 90,
  observacoes = 'atualização',
  valor_final = 30
WHERE id = 'c77931e2-63b1-4e79-b528-63ea0d432764';

-- Ordem 61/160: DENIS VIEIRA
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '296aa3d6-ea77-4608-884c-6681c4ee21b1';

-- Ordem 62/160: JOVAN NASCIMENTO
UPDATE ordens_servico SET
  data_entrega = '2025-06-30',
  garantia_dias = 90,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 130
WHERE id = '7cac97d5-2e69-4a80-95e3-c7b59721f170';

-- Ordem 63/160: SILVIO BRITO
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = 'd3ba2a4a-ebd4-4785-9780-af5b865bf5e7';

-- Ordem 64/160: VANESIO MARTINS GUEDES
UPDATE ordens_servico SET
  data_entrega = '2025-06-30',
  garantia_dias = 90,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 200
WHERE id = 'd80b63e9-6209-4ad8-af11-939948eb491d';

-- Ordem 65/160: LUIZ CARLOS XAVIER
UPDATE ordens_servico SET
  data_entrega = '2025-06-30',
  garantia_dias = 180,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 400
WHERE id = '5c841b7f-83e0-4ed2-a265-f8f352dfe420';

-- Ordem 66/160: gustavo henrique
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '2600a6e6-9ff6-4b9c-bbf4-2f174bdcf8af';

-- Ordem 67/160: DEIVID RUBIO 
UPDATE ordens_servico SET
  data_entrega = '2025-07-03',
  garantia_dias = 90,
  observacoes = 'TROCA DA BORRACHA , BANDEJA E HD INTERNO',
  valor_final = 200
WHERE id = 'f0787984-3a78-4976-9a10-b15d92e36019';

-- Ordem 68/160: ELIAS MATIAS
UPDATE ordens_servico SET
  data_entrega = '2025-07-10',
  garantia_dias = 90,
  observacoes = 'NÃO TEVE CONCERTO',
  valor_final = 0
WHERE id = '67f4322c-fac9-4470-b412-403426a6968a';

-- Ordem 69/160: larissa de oliveira espacini
UPDATE ordens_servico SET
  data_entrega = '2025-07-03',
  garantia_dias = 90,
  observacoes = 'bateria',
  valor_final = 290
WHERE id = '04f9a0c7-2994-45b8-a4b1-7c8a041416ab';

-- Ordem 70/160: larissa de oliveira espacini
UPDATE ordens_servico SET
  data_entrega = '2025-07-03',
  garantia_dias = 150,
  observacoes = 'display oled',
  valor_final = 1100
WHERE id = '8abfde5f-853e-4741-bcd8-8ccdf9f50a28';

-- Ordem 71/160: liliane maria dos santos
UPDATE ordens_servico SET
  data_entrega = '2025-07-04',
  garantia_dias = 90,
  observacoes = 'FEITO A COMPRA DO APARELHO R$40,00',
  valor_final = 0
WHERE id = 'a58bddaa-0ffb-41d3-bd6b-c8bbd817db94';

-- Ordem 72/160: ANA CAROLNA SANTOS DE OLIVEIRA
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = 'f1257dc2-c1fb-47ac-ad9d-db52161d8bdd';

-- Ordem 73/160: JOILSON DARLAN
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '9aa40615-375d-47a4-9b93-63ca809a65a9';

-- Ordem 74/160: OTAVIO DE OLIVEIRA
UPDATE ordens_servico SET
  data_entrega = '2025-07-04',
  garantia_dias = 90,
  observacoes = 'troca de tela e limpeza',
  valor_final = 200
WHERE id = 'f8c4d7dd-b71d-4f31-b7b8-fd3193614c96';

-- Ordem 75/160: ROBERTO CARLOS  OLIVEIRA SILVA 
UPDATE ordens_servico SET
  data_entrega = '2025-07-04',
  garantia_dias = 90,
  observacoes = 'MICROFONE',
  valor_final = 0
WHERE id = '4ab908a4-025b-4fbf-99d1-a75941617286';

-- Ordem 76/160: joão batista serafim gonçalves
UPDATE ordens_servico SET
  data_entrega = '2025-07-04',
  garantia_dias = 150,
  observacoes = 'TROCA DE TELA PAGAMENTO VIA PIX',
  valor_final = 1000
WHERE id = 'b4a40143-2ec6-4a26-8e4c-c5fa4a5ac72b';

-- Ordem 77/160: MATHEUS CIRINO
UPDATE ordens_servico SET
  data_entrega = '2025-07-04',
  garantia_dias = 150,
  observacoes = 'TROCA DE BATERIA',
  valor_final = 170
WHERE id = '9050307b-017b-4b37-91f5-4e33a3fa5b5f';

-- Ordem 78/160: liliane maria dos santos
UPDATE ordens_servico SET
  data_entrega = '2025-07-04',
  garantia_dias = 90,
  observacoes = 'FEITO A COMPRA DO APARELHO R$70,00',
  valor_final = 0
WHERE id = '0ce457a1-c215-4257-9d7f-c6a47941363a';

-- Ordem 79/160: joão batista serafim gonçalves
UPDATE ordens_servico SET
  data_entrega = '2025-07-07',
  garantia_dias = 150,
  observacoes = 'FOITO A TROCA DA TELA',
  valor_final = 0
WHERE id = '3c885a25-828d-4611-ad46-95f751d67f4d';

-- Ordem 80/160: larissa de oliveira espacini
UPDATE ordens_servico SET
  data_entrega = '2025-07-07',
  garantia_dias = 90,
  observacoes = 'NAO FEZ',
  valor_final = 0
WHERE id = '0725e057-9820-4ab6-8335-7073f8e78a94';

-- Ordem 81/160: BEATRIZ DE SOUZA DA SILVA
UPDATE ordens_servico SET
  data_entrega = '2025-07-15',
  garantia_dias = 90,
  observacoes = 'troca da carcaça',
  valor_final = 320
WHERE id = '60c5c130-bce5-4195-95d2-ab2aad5ef9b3';

-- Ordem 82/160: Laurence wilians
UPDATE ordens_servico SET
  data_entrega = '2025-07-14',
  garantia_dias = 90,
  observacoes = 'start + rb',
  valor_final = 0
WHERE id = '96765271-63eb-4106-b7d1-4d154077ea4d';

-- Ordem 83/160: Valter  Baudoino
UPDATE ordens_servico SET
  data_entrega = '2025-07-19',
  garantia_dias = 150,
  observacoes = 'DISPLAY, TAMPA TRASEIRA PLACA',
  valor_final = 751.48
WHERE id = 'd2c90a31-e1a5-4188-9846-65cb9c9ea1f5';

-- Ordem 84/160: Luka Guia Guaira
UPDATE ordens_servico SET
  data_entrega = '2025-07-14',
  garantia_dias = 90,
  observacoes = 'conector jack e troca de componentes',
  valor_final = 420
WHERE id = '65a9a591-0528-4459-84eb-9b76640eb7c6';

-- Ordem 85/160: ANTONIO MORAES
UPDATE ordens_servico SET
  data_entrega = '2025-07-18',
  garantia_dias = 90,
  observacoes = 'FORMATAÇÃO E BACKUP',
  valor_final = 80
WHERE id = 'f972bd08-95fe-4055-9c43-a403ec9b70d2';

-- Ordem 86/160: milena aparecida rico
UPDATE ordens_servico SET
  data_entrega = '2025-07-19',
  garantia_dias = 90,
  observacoes = 'DESBLOQUEIO',
  valor_final = 308.91
WHERE id = '39a0a972-0876-4e2b-bd2c-10f5a8275530';

-- Ordem 87/160: JOSE DE OLIVEIRA
UPDATE ordens_servico SET
  data_entrega = '2025-07-28',
  garantia_dias = 90,
  observacoes = 'CLIENTE NÃO QUIS CONCERTAR',
  valor_final = 0
WHERE id = '1d9a3122-4262-4864-adcf-dfe6a3348684';

-- Ordem 88/160: rogerio basilio de araujo
UPDATE ordens_servico SET
  data_entrega = '2025-07-05',
  garantia_dias = 90,
  observacoes = 'troca bateria e conctor',
  valor_final = 230
WHERE id = 'b576b52c-2089-42a7-85b6-a163c6699cd1';

-- Ordem 89/160: MARIA JULIA
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = 'b9e35df5-b49b-4928-83e0-8e182c6b86f1';

-- Ordem 90/160: DARCI ORTIGOSO
UPDATE ordens_servico SET
  data_entrega = '2025-07-07',
  garantia_dias = 90,
  observacoes = 'FOITO A ATUALIZAÇÃO DA HORA E DEU CERTO',
  valor_final = 0
WHERE id = '389ee475-63d7-489a-aa7f-769b150c3f83';

-- Ordem 91/160: JOEMERSON SILVEIRA DOS SANTOS
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'TELA TRINCADA, TAMPA TRASEIRA DANIFICADA',
  valor_final = 120
WHERE id = '67db952d-4c2c-4343-9367-cbec89af21f5';

-- Ordem 92/160: ADRIAN RENAN GONÇALVES PEREIRA
UPDATE ordens_servico SET
  data_entrega = '2025-07-07',
  garantia_dias = 90,
  observacoes = 'TELA - GARANTIA',
  valor_final = 0
WHERE id = '4c15c58e-b383-47db-b3a2-987624bbb256';

-- Ordem 93/160: joão batista serafim gonçalves
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 150,
  observacoes = 'Ordem de garantia referente à OS #4A5AC72B. Defeito original: display',
  valor_final = 0
WHERE id = '148452fd-a7c4-49d6-ad91-4c88c0d8ff7b';

-- Ordem 94/160: EDSON GUILHERME FONSECA
UPDATE ordens_servico SET
  data_entrega = '2025-07-11',
  garantia_dias = 150,
  observacoes = 'TROCA DA TELA',
  valor_final = 302.39
WHERE id = 'fe5b5593-cb83-48b3-8477-073827767a5b';

-- Ordem 95/160: RAQUEL APARECIDA GOMES
UPDATE ordens_servico SET
  data_entrega = '2025-07-10',
  garantia_dias = 150,
  observacoes = 'troca de tela',
  valor_final = 253
WHERE id = '696b2e88-c774-4e8c-97a1-61059287dba6';

-- Ordem 96/160: ALEX VACARO
UPDATE ordens_servico SET
  data_entrega = '2025-07-07',
  garantia_dias = 90,
  observacoes = 'ABERTURA DO APARELHO PARA LOCALIZAR DEFETO TROCA TAMPA TRASEIRA',
  valor_final = 400
WHERE id = 'd5964b11-e1dd-4da6-87aa-4fa036f91927';

-- Ordem 97/160: RENATA CRISTINA CAETANO
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 0
WHERE id = '6186002b-6e87-4822-8612-9e35aeb17ca0';

-- Ordem 98/160: Elson Teixeira
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO:',
  valor_final = 0
WHERE id = '65254cde-f5c7-4e56-859b-c8d52c3f1705';

-- Ordem 99/160: FRANSCINEI DA SILVA
UPDATE ordens_servico SET
  data_entrega = '2025-07-08',
  garantia_dias = 90,
  observacoes = 'tirar gmail - nao deu certo',
  valor_final = 0
WHERE id = 'f5e52807-010a-4422-8f06-840685d082f0';

-- Ordem 100/160: Roseli Lacerda Cartola
UPDATE ordens_servico SET
  data_entrega = '2025-07-10',
  garantia_dias = 180,
  observacoes = 'trocou display',
  valor_final = 320
WHERE id = '2a382108-899d-437f-a32f-679dc5cd087b';

-- Ordem 101/160: marco aurélio becari 
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'PROBLEMA NA PLACA',
  valor_final = 0
WHERE id = '1c925caa-fe00-451b-854d-8e43e324cb86';

-- Ordem 102/160: MATEUS PAVANELLO
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 230
WHERE id = 'b92addb5-3a15-4e2c-849e-962c175c49ba';

-- Ordem 103/160: DANIELA BARBOSA
UPDATE ordens_servico SET
  data_entrega = '2025-07-15',
  garantia_dias = 90,
  observacoes = 'SEM CONCERTO',
  valor_final = 0
WHERE id = '859153ae-fb25-4f3f-978f-3ba5eeccb9a3';

-- Ordem 104/160: WELLINGTON LUIZ
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '0e31a761-33d1-4e8a-b903-29bbf0b8c2dd';

-- Ordem 105/160: NEIDE FRAGUA
UPDATE ordens_servico SET
  data_entrega = '2025-07-15',
  garantia_dias = 180,
  observacoes = 'TROCOU DISPLAY',
  valor_final = 280
WHERE id = '760e0ff4-bac5-4902-aba7-0180ba5b85e5';

-- Ordem 106/160: LUCAS LINO TEIXEIRA
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'TELA TAMPA TRASEIRA DANIFICADA',
  valor_final = 320
WHERE id = '3941b403-34b4-40fc-b0a7-8cd35ab84ff2';

-- Ordem 107/160: JOSIANE VENTURA
UPDATE ordens_servico SET
  data_entrega = '2025-07-14',
  garantia_dias = 90,
  observacoes = 'RETIRADO DO EMAIL',
  valor_final = 220
WHERE id = 'fb952c9e-ff82-427b-92e4-1458c666b225';

-- Ordem 108/160: DANIELE CUSTODIO DE MELO
UPDATE ordens_servico SET
  data_entrega = '2025-07-11',
  garantia_dias = 90,
  observacoes = 'FORMATAÇÃO',
  valor_final = 70
WHERE id = '86cbdc96-0600-4487-a087-83f05fbc605e';

-- Ordem 109/160: Altamiro Antonio de Matos
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = 'a32fe765-83b6-4e27-bee5-c3bba81eb792';

-- Ordem 110/160: Luka Guia Guaira
UPDATE ordens_servico SET
  data_entrega = '2025-07-14',
  garantia_dias = 90,
  observacoes = 'trocou conector + bios',
  valor_final = 0
WHERE id = 'dcd7be3e-99a1-47bd-b165-203952b029c3';

-- Ordem 111/160: LUANA VAZ
UPDATE ordens_servico SET
  data_entrega = '2025-07-14',
  garantia_dias = 120,
  observacoes = 'feito troca de tela',
  valor_final = 0
WHERE id = 'b598466b-abb9-4214-9c65-ddbb8c911d18';

-- Ordem 112/160: edna cristina spigali
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = 'c439748d-570e-439e-900d-8810687d13c4';

-- Ordem 113/160: leticia costa 
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'Ordem de garantia referente à OS #0D432764. Defeito original: camera nao esta abrindo ',
  valor_final = 0
WHERE id = '456c1c6f-114f-4aae-aa94-6f2ce0162fa8';

-- Ordem 114/160: LARICE DE CASTRO
UPDATE ordens_servico SET
  data_entrega = '2025-07-17',
  garantia_dias = 180,
  observacoes = 'display',
  valor_final = 354.09
WHERE id = 'bd1908e0-b5bc-4772-b1e1-f340de054822';

-- Ordem 115/160: MAIRA GARCIA LELLIS
UPDATE ordens_servico SET
  data_entrega = '2025-07-16',
  garantia_dias = 90,
  observacoes = 'TROCA DA TELA, TELA CLIENTE COBRANÇA SO DA MÃO DE OBRA',
  valor_final = 50
WHERE id = '3168f47a-d442-4756-9cf2-098627160718';

-- Ordem 116/160: JAIR DELEFRATE 
UPDATE ordens_servico SET
  data_entrega = '2025-07-17',
  garantia_dias = 90,
  observacoes = 'tirou gmail',
  valor_final = 150
WHERE id = '925b42b4-3858-4870-91d6-31faa1104c9b';

-- Ordem 117/160: Pedro Henrique Eugenio
UPDATE ordens_servico SET
  data_entrega = '2025-07-18',
  garantia_dias = 90,
  observacoes = 'Trocou analógico esquerdo',
  valor_final = 100
WHERE id = 'fa56d3f5-b5c4-404f-91e6-1fc4450332f4';

-- Ordem 118/160: rafael borges
UPDATE ordens_servico SET
  data_entrega = '2025-07-18',
  garantia_dias = 180,
  observacoes = 'Display wefix',
  valor_final = 480
WHERE id = '35e79443-66c6-47c8-b8a4-0de4b3f62e7f';

-- Ordem 119/160: MAX MARQUES
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '7887d360-70fd-41f0-bb3f-b804281b1ee8';

-- Ordem 120/160: TARINAN GOMES DOS SANTOS
UPDATE ordens_servico SET
  data_entrega = '2025-07-16',
  garantia_dias = 90,
  observacoes = 'troca de tela',
  valor_final = 234
WHERE id = '4860a5b6-4ac7-4e1f-9a29-bf6d9202ef2d';

-- Ordem 121/160: rafael borges
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'veio sem as bordas - ele desmontou ',
  valor_final = 0
WHERE id = '8b219c38-d1ee-4e0e-9b2b-1d80613a48d7';

-- Ordem 122/160: FERNANDA MARQUES DA SILVA CANDIDO
UPDATE ordens_servico SET
  data_entrega = '2025-07-24',
  garantia_dias = 90,
  observacoes = 'tirou virus',
  valor_final = 30
WHERE id = 'b126c2c5-968e-4564-abe2-9f3eeeb8a80c';

-- Ordem 123/160: ana paula garcia barbosa
UPDATE ordens_servico SET
  data_entrega = '2025-07-18',
  garantia_dias = 90,
  observacoes = 'display',
  valor_final = 230
WHERE id = '749fb822-f7fc-458a-99a4-c88b24de13ca';

-- Ordem 124/160: ELAINE CRISTINA RIBEIRO
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'SEM A TAMPA LATERAL COM A FONTE DE ENERGIA ',
  valor_final = 0
WHERE id = '10e3261b-d0b9-4984-918b-4dff74934ebf';

-- Ordem 125/160: Pedro Henrique Eugenio
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'Ordem de garantia referente à OS #450332F4. Defeito original: Seta Esquerda E Direita',
  valor_final = 0
WHERE id = '9d37fc30-5fea-4f27-9fc7-bc7b958d48c0';

-- Ordem 126/160: Pedro Henrique Eugenio
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '65b43bae-37ea-488b-abff-c05910535b3a';

-- Ordem 127/160: EDSON GUILHERME FONSECA
UPDATE ordens_servico SET
  data_entrega = '2025-07-18',
  garantia_dias = 150,
  observacoes = 'troca de tela',
  valor_final = 0
WHERE id = 'e30bd71b-6e8a-4b73-8cd5-30bb8c169f79';

-- Ordem 128/160: daltoni da cunha teixeira
UPDATE ordens_servico SET
  data_entrega = '2025-07-22',
  garantia_dias = 90,
  observacoes = 'TROCA DE TELA',
  valor_final = 230
WHERE id = '89013be4-d8a0-4c74-ae69-af89eaa40f2b';

-- Ordem 129/160: SULAMITA FERREIRA DE SOUZA
UPDATE ordens_servico SET
  data_entrega = '2025-07-25',
  garantia_dias = 90,
  observacoes = 'TROCA DE SSD 240G',
  valor_final = 310
WHERE id = '9cc36704-6d79-4af4-9397-734c1cd6a8e5';

-- Ordem 130/160: ANGELO GABRIEL 
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 280
WHERE id = 'bdb2b08b-0e0b-4673-b343-a2984ad0369c';

-- Ordem 131/160: LUIZ FABIO TALARICO DE OLIVEIRA
UPDATE ordens_servico SET
  data_entrega = '2025-07-21',
  garantia_dias = 90,
  observacoes = 'Formataçaõ',
  valor_final = 80
WHERE id = '494c4d35-bdc6-4f81-be43-fd676d3080cd';

-- Ordem 132/160: IRENE ROSA DE SOUZA VALENTI
UPDATE ordens_servico SET
  data_entrega = '2025-07-23',
  garantia_dias = 90,
  observacoes = 'não quis o concerto',
  valor_final = 0
WHERE id = '4b0b700c-6f2f-44b7-bde8-a5e9a2815df8';

-- Ordem 133/160: PAULO SERGIO OLIMPIO
UPDATE ordens_servico SET
  data_entrega = '2025-07-23',
  garantia_dias = 150,
  observacoes = 'display + botão power',
  valor_final = 465.07
WHERE id = '4b3eddac-6ec2-4839-ba45-3687d8d79969';

-- Ordem 134/160: ANA LIVIA  FONSECA
UPDATE ordens_servico SET
  data_entrega = '2025-07-22',
  garantia_dias = 90,
  observacoes = 'não teve conccerto',
  valor_final = 30
WHERE id = 'a5884473-3da5-4c57-bb0b-07200146c4af';

-- Ordem 135/160: valeria cristina da costa 
UPDATE ordens_servico SET
  data_entrega = '2025-07-23',
  garantia_dias = 150,
  observacoes = 'troca do display',
  valor_final = 375.74
WHERE id = '6c0d0d59-251c-4543-9335-f0bf04474c0d';

-- Ordem 136/160: ANDREA LUGUE
UPDATE ordens_servico SET
  data_entrega = '2025-07-22',
  garantia_dias = 150,
  observacoes = 'troca de tela',
  valor_final = 470
WHERE id = '97fce405-22e3-453c-b58b-ef5c9606f7a1';

-- Ordem 137/160: marcos junior
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '597bc28a-3426-4a70-a5ac-84a88ac83d59';

-- Ordem 138/160: LILIAN CRISTINA FLOR
UPDATE ordens_servico SET
  data_entrega = '2025-07-24',
  garantia_dias = 90,
  observacoes = 'display paralelo',
  valor_final = 300.59
WHERE id = '018038b8-22e9-4a9e-8356-a8249ba83535';

-- Ordem 139/160: JOAO VITOR CAVENAG
UPDATE ordens_servico SET
  data_entrega = '2025-07-23',
  garantia_dias = 90,
  observacoes = 'NÃO QUIS ARRUMAR',
  valor_final = 0
WHERE id = 'cbbc2646-ca83-49f7-9158-9564c19541f4';

-- Ordem 140/160: DENIS VIEIRA
UPDATE ordens_servico SET
  data_entrega = '2025-07-24',
  garantia_dias = 90,
  observacoes = 'troca de tela paalela',
  valor_final = 250
WHERE id = '3cf3b52a-671b-4974-af2e-a82dfa400f3a';

-- Ordem 141/160: gilson zanotelo
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 80
WHERE id = '062f29eb-26f4-4383-b84e-052344999839';

-- Ordem 142/160: suelen carla davanço 
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 260
WHERE id = '30309151-c423-4358-8f4d-8bc0612e024c';

-- Ordem 143/160: rogerio de paiva
UPDATE ordens_servico SET
  data_entrega = '2025-07-25',
  garantia_dias = 90,
  observacoes = 'Trocou analogico direito',
  valor_final = 110
WHERE id = 'ed55f3c4-194d-4820-8dc3-43620d34d263';

-- Ordem 144/160: JOSE DE OLIVEIRA
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 180,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 290
WHERE id = '5bb60895-1c84-4249-9834-8b3d2c7d0150';

-- Ordem 145/160: ANISIO GABRIEL
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO: COM FONTE ',
  valor_final = 0
WHERE id = '768401ea-500b-437b-9a61-3f12c19e4231';

-- Ordem 146/160: marco aurélio becari 
UPDATE ordens_servico SET
  data_entrega = '2025-07-26',
  garantia_dias = 90,
  observacoes = 'REPARO NA PLACA',
  valor_final = 489.99
WHERE id = '0390cd38-b6d0-4373-bb23-1aa333f96070';

-- Ordem 147/160: SAULO DE TARSO
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO: COM FONTE, SEM RISCOS',
  valor_final = 0
WHERE id = '23020e40-5b94-4972-8cbf-23fd90c12e31';

-- Ordem 148/160: ANDREA LUGUE
UPDATE ordens_servico SET
  data_entrega = '2025-07-26',
  garantia_dias = 150,
  observacoes = 'TROCA DA TELA',
  valor_final = 0
WHERE id = 'a219233b-0c3c-4336-ad7f-2dde79ae4544';

-- Ordem 149/160: COOPERCITRUS VALTRA
UPDATE ordens_servico SET
  data_entrega = '2025-07-28',
  garantia_dias = 90,
  observacoes = 'NÃO TEVE CONCERTO',
  valor_final = 0
WHERE id = '09a79ecb-1108-4ad0-9b08-05caf349ac18';

-- Ordem 150/160: CARLOS DA SILVA BARBOSA
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 180,
  observacoes = NULL,
  valor_final = 280
WHERE id = '66466177-a934-46b4-94ef-10f8b4768004';

-- Ordem 151/160: MAIRA GARCIA LELLIS
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = 'eeebc373-a742-425a-930a-7e351dac3a57';

-- Ordem 152/160: VALESCA RUBIA PAIVA TOLENTINO
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '312f1c4a-2642-4a7a-ab32-0bfcd77322c9';

-- Ordem 153/160: MARCIO MB INFORMATICA
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'ORÇAMENTO: COM BANDEJA',
  valor_final = 0
WHERE id = 'ee31ad2c-6eae-41bd-9ea1-80ce156453d9';

-- Ordem 154/160: andrea da silva brosco
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 0
WHERE id = '4629ee92-6153-432f-85b9-3e9197da12fe';

-- Ordem 155/160: dara neves
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 780
WHERE id = '0ac02371-83ef-4ab1-8e7d-3eae97c70efa';

-- Ordem 156/160: maiza gonçalves
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = 'Garantia não cobre danos causados por mau uso, como quedas, arranhões, contato com líquidos ou uso de acessórios não originais.',
  valor_final = 350
WHERE id = 'f17e96e5-61d8-4c02-814c-6326226110ce';

-- Ordem 157/160: gabriel alves scarpelini dos santos
UPDATE ordens_servico SET
  data_entrega = NULL,
  garantia_dias = 90,
  observacoes = NULL,
  valor_final = 170
WHERE id = '57c2ed01-a5d1-4493-bd60-6a7673186863';

-- Ordem 158/160: daniel rosa de oliveira
UPDATE ordens_servico SET
  data_entrega = '2025-07-29',
  garantia_dias = 180,
  observacoes = 'trocou bateria',
  valor_final = 300
WHERE id = '58d0e69f-60fb-40f1-8c53-7c3dd9b6fe1e';

-- Ordem 159/160: anizio gabriel
UPDATE ordens_servico SET
  data_entrega = '2025-07-29',
  garantia_dias = 90,
  observacoes = 'nada',
  valor_final = 100
WHERE id = '13a3afe6-0f24-4d03-a570-389953f5592d';

-- Ordem 160/160: CRISTIAN PAULINO 
UPDATE ordens_servico SET
  data_entrega = '2025-08-01',
  garantia_dias = 90,
  observacoes = 'troca de tela',
  valor_final = 0
WHERE id = '89ca6338-a9df-4fea-b757-5140779b889c';


-- VERIFICAR RESULTADO
SELECT
  COUNT(*) as total,
  COUNT(data_entrega) as tem_data_entrega,
  COUNT(garantia_dias) as tem_garantia_dias,
  COUNT(observacoes) as tem_observacoes
FROM ordens_servico;