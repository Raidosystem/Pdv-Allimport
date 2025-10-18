-- ============================================
-- DEBUG: VER ÚLTIMO FUNCIONÁRIO CRIADO
-- ============================================

-- Ver funcionários recém criados
SELECT 
    f.id,
    f.nome,
    f.empresa_id,
    f.status,
    f.tipo_admin,
    f.created_at,
    lf.usuario,
    lf.ativo
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.tipo_admin = 'funcionario'
ORDER BY f.created_at DESC
LIMIT 5;

-- Ver qual empresa_id está sendo usada
SELECT 
    DISTINCT f.empresa_id,
    COUNT(*) as total_funcionarios
FROM funcionarios f
WHERE f.tipo_admin = 'funcionario'
GROUP BY f.empresa_id;

-- ============================================
-- Execute e me mostre o resultado
-- ============================================
