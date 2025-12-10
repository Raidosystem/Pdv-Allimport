-- 🧹 LIMPEZA DE PRODUTOS DUPLICADOS
-- Execute este SQL para remover produtos duplicados identificados na auditoria

-- IMPORTANTE: Execute uma consulta por vez para verificar antes de deletar!

-- 1. VERIFICAR PRODUTOS DUPLICADOS ANTES DA LIMPEZA (por ID alfabético)
SELECT 
  'ANTES DA LIMPEZA' as status,
  nome,
  id,
  created_at,
  CASE 
    WHEN id::text = MIN(id::text) OVER (PARTITION BY nome) THEN 'MANTER'
    ELSE 'DELETAR'
  END as acao
FROM produtos 
WHERE nome IN (
  'PELICULA 3D MOT G62',
  'PELICULA 3D MOT G5', 
  'CAPA POCO X5 PRO',
  'CAPA SAM A23 4G',
  'PELICULA 3D SAM A32 4G',
  'PELICULA 3D MOT ED30',
  'PELICULA 3D REDMI 13',
  'SUPORTE PARA CELULAR E GPS HREBOS',
  'CAPA CARTEIRA SAM A23'
)
ORDER BY nome, id;

-- 2. DELETAR PRODUTOS DUPLICADOS (manter o primeiro ID alfabeticamente)
-- ⚠️ CUIDADO: Execute após verificar a consulta acima!

-- Manter: 37f545df-0f42-42de-949c-4eb87f0d5051 | Deletar: d5fde5cd-ea49-4370-a0a9-c6c541cdd7eb
DELETE FROM produtos WHERE id = 'd5fde5cd-ea49-4370-a0a9-c6c541cdd7eb';

-- Manter: 7372f19d-8608-46a3-82e4-af4c7b69963f | Deletar: eb5f1d8b-c21f-4ed9-be25-9402380dc44a
DELETE FROM produtos WHERE id = 'eb5f1d8b-c21f-4ed9-be25-9402380dc44a';

-- Manter: 0b3847c3-44fe-4e97-8db5-08839c88b907 | Deletar: 621cf7fc-5bd0-4a99-88e7-ea57548e4843
DELETE FROM produtos WHERE id = '621cf7fc-5bd0-4a99-88e7-ea57548e4843';

-- Manter: 0c4b1cae-1e38-4b78-b5fe-f3b02645d4c5 | Deletar: 265c3b6d-fe28-4fe0-badd-74f5ce63ac98
DELETE FROM produtos WHERE id = '265c3b6d-fe28-4fe0-badd-74f5ce63ac98';

-- Manter: 26d167ff-33e9-48d6-bd7d-f83449b8ca8a | Deletar: ab81139c-649c-4595-b6ed-16eb5dc749db
DELETE FROM produtos WHERE id = 'ab81139c-649c-4595-b6ed-16eb5dc749db';

-- Manter: 582bf3c3-2deb-4a99-99cf-3c9dd48bc8dc | Deletar: fb466ed9-7541-4623-8267-08dbd250554b
DELETE FROM produtos WHERE id = 'fb466ed9-7541-4623-8267-08dbd250554b';

-- Manter: 7760f9b2-b5f6-4f31-b2cd-3159f639c2a6 | Deletar: 9008bc11-8e77-4346-8c52-169bffc5be69
DELETE FROM produtos WHERE id = '9008bc11-8e77-4346-8c52-169bffc5be69';

-- Manter: 22accfb2-5192-40e8-998a-611176313d80 | Deletar: 88faaac0-81a9-4487-9db7-3ae8e1e4a2a5
DELETE FROM produtos WHERE id = '88faaac0-81a9-4487-9db7-3ae8e1e4a2a5';

-- Manter: 3dfce755-666e-4f85-959a-247f8eafd524 | Deletar: 44ea9d62-be69-4f03-b1ac-f72413f2baec
DELETE FROM produtos WHERE id = '44ea9d62-be69-4f03-b1ac-f72413f2baec';

-- 3. VERIFICAR DEPOIS DA LIMPEZA
-- SELECT 
--   'DEPOIS DA LIMPEZA' as status,
--   nome,
--   count(*) as quantidade
-- FROM produtos 
-- WHERE nome IN (
--   'PELICULA 3D MOT G62',
--   'PELICULA 3D MOT G5', 
--   'CAPA POCO X5 PRO',
--   'CAPA SAM A23 4G',
--   'PELICULA 3D SAM A32 4G',
--   'PELICULA 3D MOT ED30',
--   'PELICULA 3D REDMI 13',
--   'SUPORTE PARA CELULAR E GPS HREBOS',
--   'CAPA CARTEIRA SAM A23'
-- )
-- GROUP BY nome;

-- 4. SCRIPT AUTOMÁTICO PARA DELETAR TODOS OS DUPLICADOS (por menor ID)
WITH produtos_duplicados AS (
  SELECT 
    id,
    nome,
    ROW_NUMBER() OVER (PARTITION BY nome ORDER BY id::text ASC) as rn
  FROM produtos 
  WHERE nome IN (
    'PELICULA 3D MOT G62',
    'PELICULA 3D MOT G5', 
    'CAPA POCO X5 PRO',
    'CAPA SAM A23 4G',
    'PELICULA 3D SAM A32 4G',
    'PELICULA 3D MOT ED30',
    'PELICULA 3D REDMI 13',
    'SUPORTE PARA CELULAR E GPS HREBOS',
    'CAPA CARTEIRA SAM A23'
  )
)
DELETE FROM produtos 
WHERE id IN (
  SELECT id FROM produtos_duplicados WHERE rn > 1
);