-- ============================================
-- LIMPAR E ORGANIZAR FUNCIONÁRIOS
-- ============================================
-- Remove duplicatas e organiza dados
-- ============================================

-- 1. ANÁLISE ATUAL
-- ============================================

-- Ver funcionários sem login
SELECT 
    f.id,
    f.nome,
    f.status,
    f.tipo_admin,
    'SEM LOGIN CADASTRADO' as problema
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE lf.id IS NULL
  AND f.tipo_admin = 'funcionario'
ORDER BY f.nome;

-- 2. CORRIGIR STATUS 'PENDENTE' PARA 'ATIVO'
-- ============================================

-- Mudar todos status 'pendente' para 'ativo'
UPDATE funcionarios
SET status = 'ativo'
WHERE status = 'pendente';

-- 3. OPCIONAL: EXCLUIR FUNCIONÁRIOS SEM LOGIN
-- ============================================
-- ⚠️ CUIDADO: Isso vai excluir funcionários que não têm login cadastrado
-- Descomente as linhas abaixo se quiser executar

/*
DELETE FROM funcionarios
WHERE id IN (
    SELECT f.id
    FROM funcionarios f
    LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
    WHERE lf.id IS NULL
      AND f.tipo_admin = 'funcionario'
);
*/

-- 4. VERIFICAR RESULTADO FINAL
-- ============================================

SELECT 
    f.id,
    f.nome,
    f.status,
    f.tipo_admin,
    f.ultimo_acesso,
    lf.usuario,
    lf.ativo as login_ativo
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
ORDER BY 
    CASE 
        WHEN f.tipo_admin = 'admin_empresa' THEN 1
        WHEN f.tipo_admin = 'funcionario' THEN 2
        ELSE 3
    END,
    f.nome;

-- 5. RESUMO
-- ============================================

SELECT 
    'ADMINS' as tipo,
    COUNT(*) as quantidade
FROM funcionarios
WHERE tipo_admin = 'admin_empresa'

UNION ALL

SELECT 
    'FUNCIONÁRIOS COM LOGIN' as tipo,
    COUNT(*) as quantidade
FROM funcionarios f
INNER JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.tipo_admin = 'funcionario'

UNION ALL

SELECT 
    'FUNCIONÁRIOS SEM LOGIN' as tipo,
    COUNT(*) as quantidade
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.tipo_admin = 'funcionario'
  AND lf.id IS NULL;

-- ============================================
-- INSTRUÇÕES
-- ============================================
-- 1. Execute este script para ver os problemas
-- 2. Status 'pendente' serão mudados para 'ativo'
-- 3. Se quiser excluir funcionários sem login, descomente a seção 3
-- ============================================
