-- ============================================================================
-- CRIAR EMPRESA MANUALMENTE PARA USUÁRIO ESPECÍFICO
-- ============================================================================
-- Use este script quando precisar criar uma empresa para um usuário específico
-- Substitua o UUID do user_id pelo UUID real do usuário
-- ============================================================================

-- PASSO 1: Buscar usuários que NÃO têm empresa
SELECT 
    u.id as user_id,
    u.email,
    u.created_at as user_created_at,
    CASE 
        WHEN e.id IS NULL THEN '❌ SEM EMPRESA'
        ELSE '✅ TEM EMPRESA: ' || e.nome
    END as status
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id
ORDER BY u.created_at DESC;

-- ============================================================================
-- PASSO 2: Criar empresa para um usuário específico
-- ============================================================================

-- ⚠️ SUBSTITUA o UUID abaixo pelo user_id real do usuário
-- Você pode copiar o UUID da query acima

-- Exemplo: Para o usuário 922d4f20-6c99-4438-a922-e275eb527c0b (cris-ramos30@hotmail.com)

INSERT INTO empresas (
    nome,
    user_id,
    created_at,
    updated_at
)
VALUES (
    'Empresa de Cristiane Ramos',  -- ✏️ Edite o nome aqui
    '922d4f20-6c99-4438-a922-e275eb527c0b',  -- ✏️ Substitua pelo user_id correto
    NOW(),
    NOW()
)
ON CONFLICT (user_id) DO NOTHING  -- Evita erro se empresa já existir
RETURNING id, nome, user_id, created_at;

-- ============================================================================
-- PASSO 3: Verificar empresas criadas
-- ============================================================================

SELECT 
    e.id as empresa_id,
    e.nome as empresa_nome,
    e.user_id,
    u.email as user_email,
    e.created_at
FROM empresas e
LEFT JOIN auth.users u ON u.id = e.user_id
ORDER BY e.created_at DESC
LIMIT 10;

-- ============================================================================
-- ALTERNATIVA: Criar empresas para TODOS os usuários sem empresa
-- ============================================================================

-- ⚠️ CUIDADO: Isso criará empresas para TODOS os usuários que não têm uma

INSERT INTO empresas (nome, user_id, created_at, updated_at)
SELECT 
    'Empresa de ' || COALESCE(u.email, 'Usuário') as nome,
    u.id as user_id,
    NOW() as created_at,
    NOW() as updated_at
FROM auth.users u
WHERE NOT EXISTS (
    SELECT 1 FROM empresas e WHERE e.user_id = u.id
)
RETURNING id, nome, user_id;

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

SELECT '✅ Empresas criadas com sucesso!' as status;

SELECT 
    COUNT(*) as total_usuarios,
    COUNT(DISTINCT e.user_id) as usuarios_com_empresa,
    COUNT(*) - COUNT(DISTINCT e.user_id) as usuarios_sem_empresa
FROM auth.users u
LEFT JOIN empresas e ON e.user_id = u.id;
