-- ============================================================================
-- PREENCHER TIPOS DAS ORDENS ANTIGAS BASEADO NO EQUIPAMENTO
-- ============================================================================
-- Objetivo: Identificar automaticamente o tipo baseado em marca/modelo/equipamento
-- Categorias: Celular, Notebook, Console/Game, Tablet, TV, Desktop
-- ============================================================================

-- 1️⃣ VERIFICAR ORDENS SEM TIPO PREENCHIDO
SELECT 
  id,
  equipamento,
  marca,
  modelo,
  tipo,
  CASE
    -- CELULARES (marcas conhecidas)
    WHEN LOWER(equipamento) LIKE '%iphone%' 
      OR LOWER(marca) LIKE '%iphone%' 
      OR LOWER(modelo) LIKE '%iphone%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%samsung%' 
      OR LOWER(marca) LIKE '%samsung%'
      OR LOWER(marca) LIKE '%sam%'
      OR LOWER(equipamento) LIKE '%galaxy%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%motorola%' 
      OR LOWER(marca) LIKE '%motorola%'
      OR LOWER(marca) LIKE '%moto%'
      OR LOWER(marca) LIKE '%mot%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%xiaomi%' 
      OR LOWER(marca) LIKE '%xiaomi%'
      OR LOWER(marca) LIKE '%redmi%'
      OR LOWER(marca) LIKE '%poco%'
      OR LOWER(marca) LIKE '%mi%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%lg%' 
      OR LOWER(marca) LIKE '%lg%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%nokia%' 
      OR LOWER(marca) LIKE '%nokia%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%asus%' AND (LOWER(equipamento) LIKE '%zenfone%' OR LOWER(modelo) LIKE '%zenfone%') THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%celular%' THEN 'Celular'
    
    -- NOTEBOOKS (marcas e palavras-chave)
    WHEN LOWER(equipamento) LIKE '%notebook%' 
      OR LOWER(modelo) LIKE '%notebook%'
      OR LOWER(equipamento) LIKE 'not %'
      OR LOWER(equipamento) LIKE '% not %' THEN 'Notebook'
    WHEN LOWER(equipamento) LIKE '%lenovo%' 
      OR LOWER(marca) LIKE '%lenovo%'
      OR LOWER(equipamento) LIKE '%ideapad%'
      OR LOWER(equipamento) LIKE '%thinkpad%' THEN 'Notebook'
    WHEN LOWER(equipamento) LIKE '%dell%' 
      OR LOWER(marca) LIKE '%dell%' THEN 'Notebook'
    WHEN LOWER(equipamento) LIKE '%acer%' 
      OR LOWER(marca) LIKE '%acer%' THEN 'Notebook'
    WHEN LOWER(equipamento) LIKE '%asus%' AND LOWER(equipamento) LIKE '%vivobook%' THEN 'Notebook'
    WHEN LOWER(equipamento) LIKE '%positivo%' 
      OR LOWER(marca) LIKE '%positivo%' THEN 'Notebook'
    WHEN LOWER(equipamento) LIKE '%laptop%' THEN 'Notebook'
    
    -- CONSOLES E GAMES
    WHEN LOWER(equipamento) LIKE '%xbox%' 
      OR LOWER(marca) LIKE '%xbox%' THEN 'Console'
    WHEN LOWER(equipamento) LIKE '%playstation%' 
      OR LOWER(equipamento) LIKE '%ps%'
      OR LOWER(marca) LIKE '%ps%'
      OR LOWER(equipamento) LIKE '%play%' THEN 'Console'
    WHEN LOWER(equipamento) LIKE '%nintendo%' 
      OR LOWER(marca) LIKE '%nintendo%'
      OR LOWER(equipamento) LIKE '%switch%' THEN 'Console'
    WHEN LOWER(equipamento) LIKE '%controle%' THEN 'Console'
    WHEN LOWER(equipamento) LIKE '%game%' THEN 'Console'
    
    -- TABLETS
    WHEN LOWER(equipamento) LIKE '%tablet%' 
      OR LOWER(equipamento) LIKE '%ipad%' THEN 'Tablet'
    
    -- OUTROS
    ELSE 'Outros'
  END as tipo_sugerido
FROM ordens_servico
WHERE (tipo IS NULL OR tipo = '' OR LOWER(tipo) = 'tipo não informado')
ORDER BY data_entrada DESC
LIMIT 50;

-- 2️⃣ CONTAR QUANTAS ORDENS SERÃO ATUALIZADAS POR CATEGORIA
SELECT 
  CASE
    WHEN LOWER(equipamento) LIKE '%iphone%' OR LOWER(marca) LIKE '%iphone%' OR LOWER(modelo) LIKE '%iphone%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%samsung%' OR LOWER(marca) LIKE '%samsung%' OR LOWER(marca) LIKE '%sam%' OR LOWER(equipamento) LIKE '%galaxy%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%motorola%' OR LOWER(marca) LIKE '%motorola%' OR LOWER(marca) LIKE '%moto%' OR LOWER(marca) LIKE '%mot%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%xiaomi%' OR LOWER(marca) LIKE '%xiaomi%' OR LOWER(marca) LIKE '%redmi%' OR LOWER(marca) LIKE '%poco%' OR LOWER(marca) LIKE '%mi%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%lg%' OR LOWER(marca) LIKE '%lg%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%nokia%' OR LOWER(marca) LIKE '%nokia%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%celular%' OR LOWER(equipamento) LIKE '%celualr%' THEN 'Celular'
    WHEN LOWER(equipamento) LIKE '%notebook%' OR LOWER(modelo) LIKE '%notebook%' OR LOWER(equipamento) LIKE 'not %' OR LOWER(equipamento) LIKE '% not %' OR LOWER(equipamento) LIKE 'note %' OR LOWER(equipamento) LIKE '% note %' THEN 'Notebook'
    WHEN LOWER(equipamento) LIKE '%lenovo%' OR LOWER(marca) LIKE '%lenovo%' OR LOWER(equipamento) LIKE '%ideapad%' OR LOWER(equipamento) LIKE '%thinkpad%' THEN 'Notebook'
    WHEN LOWER(equipamento) LIKE '%dell%' OR LOWER(marca) LIKE '%dell%' THEN 'Notebook'
    WHEN LOWER(equipamento) LIKE '%acer%' OR LOWER(marca) LIKE '%acer%' THEN 'Notebook'
    WHEN LOWER(equipamento) LIKE '%asus%' AND LOWER(equipamento) LIKE '%vivobook%' THEN 'Notebook'
    WHEN LOWER(equipamento) LIKE '%positivo%' OR LOWER(marca) LIKE '%positivo%' THEN 'Notebook'
    WHEN LOWER(equipamento) LIKE '%xbox%' OR LOWER(marca) LIKE '%xbox%' THEN 'Console'
    WHEN LOWER(equipamento) LIKE '%playstation%' OR LOWER(equipamento) LIKE '%ps%' OR LOWER(marca) LIKE '%ps%' OR LOWER(equipamento) LIKE '%play%' THEN 'Console'
    WHEN LOWER(equipamento) LIKE '%nintendo%' OR LOWER(marca) LIKE '%nintendo%' OR LOWER(equipamento) LIKE '%switch%' THEN 'Console'
    WHEN LOWER(equipamento) LIKE '%controle%' THEN 'Console'
    WHEN LOWER(equipamento) LIKE '%tablet%' OR LOWER(equipamento) LIKE '%ipad%' THEN 'Tablet'
    ELSE 'Outros'
  END as tipo_sugerido,
  COUNT(*) as quantidade
FROM ordens_servico
WHERE (tipo IS NULL OR tipo = '' OR LOWER(tipo) = 'tipo não informado')
GROUP BY tipo_sugerido
ORDER BY quantidade DESC;

-- ============================================================================
-- ⚠️ ATENÇÃO: DESCOMENTE A QUERY ABAIXO APENAS DEPOIS DE VERIFICAR OS RESULTADOS
-- ============================================================================

-- 3️⃣ ATUALIZAR TIPOS DAS ORDENS
UPDATE ordens_servico
SET tipo = CASE
  -- CELULARES
  WHEN LOWER(equipamento) LIKE '%iphone%' OR LOWER(marca) LIKE '%iphone%' OR LOWER(modelo) LIKE '%iphone%' THEN 'Celular'
  WHEN LOWER(equipamento) LIKE '%samsung%' OR LOWER(marca) LIKE '%samsung%' OR LOWER(marca) LIKE '%sam%' OR LOWER(equipamento) LIKE '%galaxy%' THEN 'Celular'
  WHEN LOWER(equipamento) LIKE '%motorola%' OR LOWER(marca) LIKE '%motorola%' OR LOWER(marca) LIKE '%moto%' OR LOWER(marca) LIKE '%mot%' THEN 'Celular'
  WHEN LOWER(equipamento) LIKE '%xiaomi%' OR LOWER(marca) LIKE '%xiaomi%' OR LOWER(marca) LIKE '%redmi%' OR LOWER(marca) LIKE '%poco%' OR LOWER(marca) LIKE '%mi%' THEN 'Celular'
  WHEN LOWER(equipamento) LIKE '%lg%' OR LOWER(marca) LIKE '%lg%' THEN 'Celular'
  WHEN LOWER(equipamento) LIKE '%nokia%' OR LOWER(marca) LIKE '%nokia%' THEN 'Celular'
  WHEN LOWER(equipamento) LIKE '%asus%' AND (LOWER(equipamento) LIKE '%zenfone%' OR LOWER(modelo) LIKE '%zenfone%') THEN 'Celular'
  WHEN LOWER(equipamento) LIKE '%celular%' OR LOWER(equipamento) LIKE '%celualr%' THEN 'Celular'
  
  -- NOTEBOOKS
  WHEN LOWER(equipamento) LIKE '%notebook%' OR LOWER(modelo) LIKE '%notebook%' OR LOWER(equipamento) LIKE 'not %' OR LOWER(equipamento) LIKE '% not %' OR LOWER(equipamento) LIKE 'note %' OR LOWER(equipamento) LIKE '% note %' THEN 'Notebook'
  WHEN LOWER(equipamento) LIKE '%lenovo%' OR LOWER(marca) LIKE '%lenovo%' OR LOWER(equipamento) LIKE '%ideapad%' OR LOWER(equipamento) LIKE '%thinkpad%' THEN 'Notebook'
  WHEN LOWER(equipamento) LIKE '%dell%' OR LOWER(marca) LIKE '%dell%' THEN 'Notebook'
  WHEN LOWER(equipamento) LIKE '%acer%' OR LOWER(marca) LIKE '%acer%' THEN 'Notebook'
  WHEN LOWER(equipamento) LIKE '%asus%' AND LOWER(equipamento) LIKE '%vivobook%' THEN 'Notebook'
  WHEN LOWER(equipamento) LIKE '%positivo%' OR LOWER(marca) LIKE '%positivo%' THEN 'Notebook'
  WHEN LOWER(equipamento) LIKE '%laptop%' THEN 'Notebook'
  
  -- CONSOLES
  WHEN LOWER(equipamento) LIKE '%xbox%' OR LOWER(marca) LIKE '%xbox%' THEN 'Console'
  WHEN LOWER(equipamento) LIKE '%playstation%' OR LOWER(equipamento) LIKE '%ps%' OR LOWER(marca) LIKE '%ps%' OR LOWER(equipamento) LIKE '%play%' THEN 'Console'
  WHEN LOWER(equipamento) LIKE '%nintendo%' OR LOWER(marca) LIKE '%nintendo%' OR LOWER(equipamento) LIKE '%switch%' THEN 'Console'
  WHEN LOWER(equipamento) LIKE '%controle%' THEN 'Console'
  WHEN LOWER(equipamento) LIKE '%game%' THEN 'Console'
  
  -- TABLETS
  WHEN LOWER(equipamento) LIKE '%tablet%' OR LOWER(equipamento) LIKE '%ipad%' THEN 'Tablet'
  
  -- OUTROS
  ELSE 'Outros'
END,
updated_at = NOW()
WHERE (tipo IS NULL OR tipo = '' OR LOWER(tipo) = 'tipo não informado');

-- ============================================================================
-- ✅ INSTRUÇÕES
-- ============================================================================
-- 1. Execute as queries 1️⃣ e 2️⃣ para VERIFICAR quais tipos serão atribuídos
-- 2. Se estiver correto, DESCOMENTE a query 3️⃣ (remova /* e */)
-- 3. Execute a query 3️⃣ para atualizar os tipos
-- 4. Atualize a página de Rankings para ver os dados organizados por tipo
