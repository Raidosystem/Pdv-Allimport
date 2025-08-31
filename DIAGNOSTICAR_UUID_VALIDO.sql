-- =========================================================================
-- CORREÇÃO DO ERRO DE FOREIGN KEY - MULTI-TENANT
-- PROBLEMA: UUID não existe em auth.users
-- SOLUÇÃO: Usar UUID de usuário existente ou criar um usuário válido
-- =========================================================================

-- 1. VERIFICAR USUÁRIOS EXISTENTES NA TABELA AUTH.USERS
SELECT 'USUÁRIOS EXISTENTES' as info, id, email, created_at 
FROM auth.users 
ORDER BY created_at 
LIMIT 10;

-- 2. ENCONTRAR USER_ID MAIS USADO NOS DADOS EXISTENTES
SELECT 
  'CLIENTES POR USER_ID' as info,
  user_id,
  COUNT(*) as total_registros
FROM clientes 
WHERE user_id IS NOT NULL
GROUP BY user_id
ORDER BY total_registros DESC;

SELECT 
  'PRODUTOS POR USER_ID' as info,
  user_id,
  COUNT(*) as total_registros
FROM produtos 
WHERE user_id IS NOT NULL
GROUP BY user_id
ORDER BY total_registros DESC;

-- 3. VERIFICAR SE O UUID ASSISTENCIA EXISTE
SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM auth.users WHERE id = '550e8400-e29b-41d4-a716-446655440000'::uuid)
    THEN 'UUID ASSISTENCIA EXISTE'
    ELSE 'UUID ASSISTENCIA NÃO EXISTE - USAR OUTRO'
  END as resultado;

-- 4. ENCONTRAR UUID VÁLIDO MAIS ADEQUADO
WITH user_stats AS (
  SELECT 
    u.id,
    u.email,
    u.created_at,
    COALESCE(c.total_clientes, 0) as total_clientes,
    COALESCE(p.total_produtos, 0) as total_produtos
  FROM auth.users u
  LEFT JOIN (
    SELECT user_id, COUNT(*) as total_clientes 
    FROM clientes 
    WHERE user_id IS NOT NULL 
    GROUP BY user_id
  ) c ON c.user_id = u.id
  LEFT JOIN (
    SELECT user_id, COUNT(*) as total_produtos 
    FROM produtos 
    WHERE user_id IS NOT NULL 
    GROUP BY user_id
  ) p ON p.user_id = u.id
)
SELECT 
  'USUÁRIO RECOMENDADO' as info,
  id as user_id_para_usar,
  email,
  total_clientes,
  total_produtos,
  (total_clientes + total_produtos) as total_registros
FROM user_stats
WHERE (total_clientes > 0 OR total_produtos > 0 OR email LIKE '%assistencia%')
ORDER BY total_registros DESC, created_at
LIMIT 1;

-- =========================================================================
-- INSTRUÇÕES APÓS EXECUTAR ESTE DIAGNÓSTICO:
--
-- 1. Veja o resultado "USUÁRIO RECOMENDADO" 
-- 2. Copie o "user_id_para_usar" 
-- 3. Use esse UUID no próximo script de correção
-- 
-- Se nenhum usuário for encontrado, criaremos um usuário específico
-- =========================================================================
