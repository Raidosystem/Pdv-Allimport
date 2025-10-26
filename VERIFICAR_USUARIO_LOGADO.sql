-- ============================================
-- VERIFICAR USUÁRIO LOGADO E PERMISSÕES RLS
-- ============================================

-- 1. Verificar qual usuário está logado no Supabase SQL Editor
SELECT 
  auth.uid() as meu_user_id,
  auth.email() as meu_email;

-- 2. Verificar dados do usuário logado
SELECT 
  id,
  email,
  raw_user_meta_data->>'empresa_id' as empresa_id,
  raw_user_meta_data
FROM auth.users
WHERE id = auth.uid();

-- 3. Verificar TODOS os usuários do sistema
SELECT 
  id,
  email,
  raw_user_meta_data->>'empresa_id' as empresa_id,
  created_at
FROM auth.users
ORDER BY created_at DESC;

-- 4. Verificar usuario_id e user_id das ordens restauradas
SELECT 
  usuario_id,
  user_id,
  COUNT(*) as total
FROM ordens_servico
GROUP BY usuario_id, user_id
ORDER BY total DESC;

-- 5. Verificar se usuario_id das ordens corresponde ao usuário logado
SELECT 
  CASE 
    WHEN usuario_id = auth.uid() THEN 'SIM - Minhas ordens'
    WHEN user_id = auth.uid() THEN 'SIM - Minhas ordens (user_id)'
    ELSE 'NÃO - Ordens de outro usuário'
  END as pertence_a_mim,
  COUNT(*) as total_ordens
FROM ordens_servico
GROUP BY 
  CASE 
    WHEN usuario_id = auth.uid() THEN 'SIM - Minhas ordens'
    WHEN user_id = auth.uid() THEN 'SIM - Minhas ordens (user_id)'
    ELSE 'NÃO - Ordens de outro usuário'
  END;

-- 6. Verificar user_id dos clientes
SELECT 
  user_id,
  COUNT(*) as total_clientes
FROM clientes
GROUP BY user_id
ORDER BY total_clientes DESC;

-- 7. Verificar se user_id dos clientes corresponde ao usuário logado
SELECT 
  CASE 
    WHEN user_id = auth.uid() THEN 'SIM - Meus clientes'
    ELSE 'NÃO - Clientes de outro usuário'
  END as pertence_a_mim,
  COUNT(*) as total_clientes
FROM clientes
GROUP BY 
  CASE 
    WHEN user_id = auth.uid() THEN 'SIM - Meus clientes'
    ELSE 'NÃO - Clientes de outro usuário'
  END;

-- ============================================
-- DIAGNÓSTICO:
-- Se mostrar "NÃO - Ordens de outro usuário",
-- significa que as ordens foram restauradas com
-- usuario_id diferente do usuário logado.
-- 
-- SOLUÇÃO: Atualizar usuario_id/user_id das ordens
-- para o ID do usuário atual.
-- ============================================
