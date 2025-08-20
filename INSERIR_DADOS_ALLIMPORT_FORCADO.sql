-- 🚀 FORÇAR INSERÇÃO DOS PRODUTOS DA ALLIMPORT

-- Este script força a inserção dos produtos mesmo se já existirem similares

-- INSERIR PRODUTOS ÚNICOS DA ALLIMPORT COM PREFIXOS ÚNICOS
INSERT INTO products (id, name, description, price, cost, stock_quantity, active) VALUES 
(gen_random_uuid(), 'ALLIMPORT - WIRELESS MICROPHONE', 'Microfone sem fio para assistência técnica', 89.90, 45.00, 15, true),
(gen_random_uuid(), 'ALLIMPORT - CABO USB TIPO C ORIGINAL', 'Cabo USB-C original para smartphones', 29.90, 18.00, 25, true),
(gen_random_uuid(), 'ALLIMPORT - BATERIA SMARTPHONE SAMSUNG', 'Bateria original para smartphones Samsung', 79.90, 45.00, 12, true),
(gen_random_uuid(), 'ALLIMPORT - TELA TOUCH SCREEN COMPLETA', 'Tela touch screen completa com display LCD', 159.90, 95.00, 8, true),
(gen_random_uuid(), 'ALLIMPORT - CARREGADOR ORIGINAL TURBO', 'Carregador original turbo 65W', 65.90, 38.00, 18, true),
(gen_random_uuid(), 'ALLIMPORT - FONE DE OUVIDO BLUETOOTH', 'Fone de ouvido Bluetooth profissional', 119.90, 75.00, 20, true),
(gen_random_uuid(), 'ALLIMPORT - PELICULA VIDRO 9H', 'Película de vidro temperado 9H premium', 24.90, 12.00, 50, true),
(gen_random_uuid(), 'ALLIMPORT - CAPA PROTETORA ANTI-IMPACTO', 'Capa protetora resistente a impactos', 39.90, 22.00, 35, true),
(gen_random_uuid(), 'ALLIMPORT - PLACA MAE CELULAR ORIGINAL', 'Placa mãe original para reparo de celulares', 289.90, 180.00, 5, true),
(gen_random_uuid(), 'ALLIMPORT - CONECTOR DE CARGA MICRO USB', 'Conector de carga Micro USB para reparo', 19.90, 8.00, 40, true),
(gen_random_uuid(), 'ALLIMPORT - ALTO FALANTE INTERNO', 'Alto falante interno para smartphones', 29.90, 15.00, 30, true),
(gen_random_uuid(), 'ALLIMPORT - CAMERA TRASEIRA 48MP', 'Câmera traseira 48MP para smartphones', 89.90, 55.00, 12, true),
(gen_random_uuid(), 'ALLIMPORT - CAMERA FRONTAL 16MP', 'Câmera frontal 16MP para selfies', 49.90, 28.00, 15, true),
(gen_random_uuid(), 'ALLIMPORT - FLEX DO VOLUME ORIGINAL', 'Flex do volume original para reparo', 24.90, 12.00, 25, true),
(gen_random_uuid(), 'ALLIMPORT - FLEX DO POWER BUTTON', 'Flex do botão power original', 24.90, 12.00, 25, true),
(gen_random_uuid(), 'ALLIMPORT - MICROFONE INTERNO ORIGINAL', 'Microfone interno original para reparo', 19.90, 9.00, 30, true),
(gen_random_uuid(), 'ALLIMPORT - VIBRACALL MOTOR', 'Motor vibracall original', 15.90, 7.00, 35, true),
(gen_random_uuid(), 'ALLIMPORT - SENSOR DE PROXIMIDADE', 'Sensor de proximidade original', 29.90, 15.00, 20, true),
(gen_random_uuid(), 'ALLIMPORT - BOTAO HOME TOUCH ID', 'Botão home com Touch ID original', 79.90, 45.00, 10, true),
(gen_random_uuid(), 'ALLIMPORT - DISPLAY LCD RETINA', 'Display LCD Retina de alta qualidade', 189.90, 120.00, 6, true);

-- INSERIR CATEGORIAS DA ALLIMPORT
INSERT INTO categories (id, name, description) VALUES
(gen_random_uuid(), 'ALLIMPORT - ACESSORIOS', 'Acessórios para dispositivos móveis'),
(gen_random_uuid(), 'ALLIMPORT - BATERIAS', 'Baterias originais e compatíveis'),
(gen_random_uuid(), 'ALLIMPORT - TELAS E DISPLAYS', 'Telas, displays e touch screens'),
(gen_random_uuid(), 'ALLIMPORT - CARREGADORES', 'Carregadores e cabos USB'),
(gen_random_uuid(), 'ALLIMPORT - PROTECAO', 'Capas, películas e proteção'),
(gen_random_uuid(), 'ALLIMPORT - COMPONENTES', 'Componentes internos para reparo'),
(gen_random_uuid(), 'ALLIMPORT - AUDIO', 'Alto falantes, microfones e áudio'),
(gen_random_uuid(), 'ALLIMPORT - CAMERAS', 'Câmeras frontais e traseiras'),
(gen_random_uuid(), 'ALLIMPORT - CONECTORES', 'Conectores de carga e dados'),
(gen_random_uuid(), 'ALLIMPORT - SENSORES', 'Sensores e componentes eletrônicos');

-- INSERIR CLIENTES DA ALLIMPORT
INSERT INTO clients (id, name, email, phone) VALUES
(gen_random_uuid(), 'MARIA SILVA SANTOS - ALLIMPORT', 'maria.silva@email.com', '(11) 99999-0001'),
(gen_random_uuid(), 'JOAO PEREIRA COSTA - ALLIMPORT', 'joao.pereira@email.com', '(11) 99999-0002'),
(gen_random_uuid(), 'ANA OLIVEIRA LIMA - ALLIMPORT', 'ana.oliveira@email.com', '(11) 99999-0003'),
(gen_random_uuid(), 'CARLOS SANTOS SILVA - ALLIMPORT', 'carlos.santos@email.com', '(11) 99999-0004'),
(gen_random_uuid(), 'LUCIA COSTA PEREIRA - ALLIMPORT', 'lucia.costa@email.com', '(11) 99999-0005'),
(gen_random_uuid(), 'PEDRO LIMA SANTOS - ALLIMPORT', 'pedro.lima@email.com', '(11) 99999-0006'),
(gen_random_uuid(), 'JULIANA SILVA COSTA - ALLIMPORT', 'juliana.silva@email.com', '(11) 99999-0007'),
(gen_random_uuid(), 'RICARDO PEREIRA LIMA - ALLIMPORT', 'ricardo.pereira@email.com', '(11) 99999-0008'),
(gen_random_uuid(), 'FERNANDA SANTOS OLIVEIRA - ALLIMPORT', 'fernanda.santos@email.com', '(11) 99999-0009'),
(gen_random_uuid(), 'ROBERTO COSTA SILVA - ALLIMPORT', 'roberto.costa@email.com', '(11) 99999-0010');

-- VERIFICAR INSERÇÃO
SELECT 'PRODUTOS ALLIMPORT INSERIDOS:' as resultado, COUNT(*) as quantidade
FROM products 
WHERE name LIKE 'ALLIMPORT -%';

SELECT 'CATEGORIAS ALLIMPORT INSERIDAS:' as resultado, COUNT(*) as quantidade  
FROM categories
WHERE name LIKE 'ALLIMPORT -%';

SELECT 'CLIENTES ALLIMPORT INSERIDOS:' as resultado, COUNT(*) as quantidade
FROM clients 
WHERE name LIKE '%- ALLIMPORT';

-- ✅ AGORA OS DADOS DA ALLIMPORT DEVEM APARECER NO PDV!
