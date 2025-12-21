-- ========================================
-- DIAGNÓSTICO SIMPLIFICADO - USUÁRIO ÓRFÃO
-- ========================================
-- Identifica qual tabela está bloqueando a exclusão

-- 1️⃣ Identificar o usuário órfão
SELECT 
  '👤 USUÁRIO ÓRFÃO ENCONTRADO' as info,
  au.id as user_id,
  au.email
FROM auth.users au
LEFT JOIN funcionarios f ON f.user_id = au.id
WHERE f.id IS NULL
  AND au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%@allimport%'
  AND au.role = 'authenticated'
LIMIT 1;

-- ========================================
-- 2️⃣ COPIE O user_id ACIMA E COLE AQUI 👇
-- ========================================
-- Substitua 'USER_ID_AQUI' pelo user_id do resultado acima

WITH user_orfao AS (
  SELECT au.id as user_id, au.email
  FROM auth.users au
  LEFT JOIN funcionarios f ON f.user_id = au.id
  WHERE f.id IS NULL
    AND au.email NOT LIKE '%@supabase%'
    AND au.email NOT LIKE '%@allimport%'
    AND au.role = 'authenticated'
  LIMIT 1
)
SELECT 
  '📊 DEPENDÊNCIAS DO USUÁRIO ÓRFÃO' as categoria,
  'vendas' as tabela,
  COUNT(*) as total_registros
FROM vendas v, user_orfao u
WHERE v.user_id = u.user_id

UNION ALL

SELECT 
  '📊 DEPENDÊNCIAS DO USUÁRIO ÓRFÃO',
  'vendas_itens',
  COUNT(*)
FROM vendas_itens vi, user_orfao u
WHERE vi.user_id = u.user_id

UNION ALL

SELECT 
  '📊 DEPENDÊNCIAS DO USUÁRIO ÓRFÃO',
  'produtos',
  COUNT(*)
FROM produtos p, user_orfao u
WHERE p.user_id = u.user_id

UNION ALL

SELECT 
  '📊 DEPENDÊNCIAS DO USUÁRIO ÓRFÃO',
  'clientes',
  COUNT(*)
FROM clientes c, user_orfao u
WHERE c.user_id = u.user_id

UNION ALL

SELECT 
  '📊 DEPENDÊNCIAS DO USUÁRIO ÓRFÃO',
  'caixa',
  COUNT(*)
FROM caixa cx, user_orfao u
WHERE cx.user_id = u.user_id

UNION ALL

SELECT 
  '📊 DEPENDÊNCIAS DO USUÁRIO ÓRFÃO',
  'ordens_servico',
  COUNT(*)
FROM ordens_servico os, user_orfao u
WHERE os.user_id = u.user_id

UNION ALL

SELECT 
  '📊 DEPENDÊNCIAS DO USUÁRIO ÓRFÃO',
  'configuracoes',
  COUNT(*)
FROM configuracoes cfg, user_orfao u
WHERE cfg.user_id = u.user_id

UNION ALL

SELECT 
  '📊 DEPENDÊNCIAS DO USUÁRIO ÓRFÃO',
  'profiles',
  COUNT(*)
FROM profiles pf, user_orfao u
WHERE pf.user_id = u.user_id

UNION ALL

SELECT 
  '📊 DEPENDÊNCIAS DO USUÁRIO ÓRFÃO',
  'empresas',
  COUNT(*)
FROM empresas e, user_orfao u
WHERE e.id = u.user_id

ORDER BY total_registros DESC;

-- ========================================
-- 3️⃣ RESULTADO ESPERADO
-- ========================================
-- Vai mostrar algo como:
-- | tabela        | total_registros |
-- |---------------|-----------------|
-- | vendas_itens  | 15              |
-- | produtos      | 3               |
-- | vendas        | 2               |
-- | clientes      | 0               |

-- Se alguma tabela tiver registros > 0, ela está impedindo a exclusão!
