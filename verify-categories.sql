-- Verify categories for user f7fdf4cf-7101-45ab-86db-5248a7ac58c1
SELECT id, name, empresa_id
FROM categories
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY name
LIMIT 20;

-- Check if the problematic UUID exists
SELECT id, name FROM categories WHERE id = 'ba8e7253-6b02-4a1c-b3c8-77ff78618514';
