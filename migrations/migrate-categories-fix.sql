-- 🔧 MIGRAR CATEGORIAS ÓRFÃS PARA USUÁRIO CORRETO

-- User ID do usuário logado (Cristiano)
-- f7fdf4cf-7101-45ab-86db-5248a7ac58c1

-- 1. Ver quantas categorias têm empresa_id NULL ou inconsistente
SELECT 
  COUNT(*) as total,
  COUNT(CASE WHEN empresa_id IS NULL THEN 1 END) as sem_empresa_id,
  COUNT(CASE WHEN empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as com_usuario_correto
FROM categories;

-- 2. Atualizar categorias SEM empresa_id para o usuário correto
UPDATE categories
SET empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'::uuid
WHERE empresa_id IS NULL;

-- 3. Verificar se a categoria específica existe agora
SELECT 
  id, 
  name, 
  empresa_id,
  (empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1') as pertence_ao_usuario
FROM categories
WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514';

-- 4. Conferir total final
SELECT 
  COUNT(*) as total_categorias,
  COUNT(CASE WHEN empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1' THEN 1 END) as categorias_do_usuario
FROM categories;
