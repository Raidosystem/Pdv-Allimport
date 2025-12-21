-- ========================================
-- SOLUÇÃO: MARCAR USUÁRIO ÓRFÃO COMO REMOVIDO
-- ========================================
-- O usuário órfão TEM dados históricos (produtos, vendas, caixa, clientes)
-- NÃO podemos deletar sem perder histórico
-- Solução: Renomear email para liberar o original

-- ========================================
-- 1️⃣ VERIFICAR DADOS DO USUÁRIO ÓRFÃO
-- ========================================
SELECT 
  '🔍 DADOS DO USUÁRIO ÓRFÃO' as info,
  au.id as user_id,
  au.email as email_atual,
  au.email || '.REMOVIDO' as email_novo,
  au.created_at,
  -- Contar dependências
  (SELECT COUNT(*) FROM produtos WHERE user_id = au.id) as total_produtos,
  (SELECT COUNT(*) FROM vendas_itens WHERE user_id = au.id) as total_vendas_itens,
  (SELECT COUNT(*) FROM vendas WHERE user_id = au.id) as total_vendas,
  (SELECT COUNT(*) FROM clientes WHERE user_id = au.id) as total_clientes,
  (SELECT COUNT(*) FROM caixa WHERE user_id = au.id) as total_caixa
FROM auth.users au
LEFT JOIN funcionarios f ON f.user_id = au.id
WHERE f.id IS NULL
  AND au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%@allimport%'
  AND au.role = 'authenticated'
LIMIT 1;

-- ========================================
-- 2️⃣ MARCAR COMO REMOVIDO (LIBERA EMAIL)
-- ========================================
-- Renomeia o email adicionando .REMOVIDO
-- Marca deleted_at para indicar inativo
-- Adiciona flag no metadata

UPDATE auth.users
SET 
  email = email || '.REMOVIDO',
  deleted_at = NOW(),
  raw_user_meta_data = jsonb_set(
    jsonb_set(
      COALESCE(raw_user_meta_data, '{}'::jsonb),
      '{status}',
      '"removido_historico"'
    ),
    '{removido_em}',
    to_jsonb(NOW()::text)
  )
WHERE id IN (
  SELECT au.id
  FROM auth.users au
  LEFT JOIN funcionarios f ON f.user_id = au.id
  WHERE f.id IS NULL
    AND au.email NOT LIKE '%@supabase%'
    AND au.email NOT LIKE '%@allimport%'
    AND au.email NOT LIKE '%.REMOVIDO'
    AND au.role = 'authenticated'
  LIMIT 1
);

-- ========================================
-- 3️⃣ VERIFICAR RESULTADO
-- ========================================
SELECT 
  '✅ USUÁRIO MARCADO COMO REMOVIDO' as status,
  id as user_id,
  email as email_marcado,
  deleted_at,
  raw_user_meta_data->>'status' as status_meta
FROM auth.users
WHERE email LIKE '%.REMOVIDO'
  AND deleted_at IS NOT NULL
ORDER BY deleted_at DESC
LIMIT 5;

-- ========================================
-- 4️⃣ CONFIRMAR EMAIL LIBERADO
-- ========================================
-- Verificar se não há mais usuários órfãos com email original
SELECT 
  '🎯 VERIFICAÇÃO FINAL' as info,
  COUNT(*) as usuarios_orfaos_ativos,
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ Email liberado! Pode criar novo funcionário'
    ELSE '⚠️ Ainda há usuários órfãos'
  END as resultado
FROM auth.users au
LEFT JOIN funcionarios f ON f.user_id = au.id
WHERE f.id IS NULL
  AND au.email NOT LIKE '%@supabase%'
  AND au.email NOT LIKE '%@allimport%'
  AND au.email NOT LIKE '%.REMOVIDO'
  AND au.role = 'authenticated';

-- ========================================
-- 📋 PRÓXIMOS PASSOS
-- ========================================
/*
✅ AGORA VOCÊ PODE:

1. Criar novo funcionário com o email original
2. O sistema vai criar novo registro em auth.users
3. Dados históricos preservados (produtos, vendas mantidos)
4. Usuário antigo marcado como .REMOVIDO (inativo)

⚠️ OBSERVAÇÕES:

- Dados históricos (vendas, produtos) continuam vinculados ao user_id antigo
- Isso é CORRETO - preserva auditoria
- Novo funcionário terá user_id diferente
- Relatórios históricos continuam funcionando

🔄 SE PRECISAR REVERTER:

UPDATE auth.users
SET 
  email = REPLACE(email, '.REMOVIDO', ''),
  deleted_at = NULL
WHERE email LIKE '%.REMOVIDO'
  AND id = 'COLE_USER_ID_AQUI';
*/

-- ========================================
-- 🎯 RESUMO DA SOLUÇÃO
-- ========================================
/*
❌ PROBLEMA ORIGINAL:
   - Funcionário excluído mas auth.users mantido
   - Email bloqueado por dados históricos
   - Não pode recriar funcionário com mesmo email

✅ SOLUÇÃO APLICADA:
   - Email renomeado para [email].REMOVIDO
   - Usuário marcado com deleted_at
   - Dados históricos preservados
   - Email original liberado

📊 RESULTADO:
   - ✅ Email disponível para novo cadastro
   - ✅ Histórico de vendas/produtos mantido
   - ✅ Integridade referencial preservada
   - ✅ Sistema funcionando normalmente
*/
