-- =====================================================
-- ATIVAR USUÁRIO ESPECÍFICO NO LOGIN LOCAL
-- =====================================================
-- Script rápido para ativar assistenciaallimport10@gmail.com
-- =====================================================

-- 1. VERIFICAR STATUS ATUAL DO USUÁRIO
SELECT 
  '📋 STATUS ATUAL' as info,
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  tipo_admin,
  empresa_id
FROM funcionarios
WHERE email = 'assistenciaallimport10@gmail.com';

-- 2. ATIVAR O USUÁRIO
UPDATE funcionarios
SET 
  usuario_ativo = TRUE,
  senha_definida = CASE 
    WHEN senha_hash IS NOT NULL AND senha_hash != '' THEN TRUE 
    ELSE FALSE 
  END
WHERE email = 'assistenciaallimport10@gmail.com';

-- 3. VERIFICAR RESULTADO
SELECT 
  '✅ STATUS APÓS ATUALIZAÇÃO' as info,
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  primeiro_acesso,
  tipo_admin,
  CASE 
    WHEN senha_hash IS NOT NULL AND senha_hash != '' THEN '🔒 Senha configurada'
    ELSE '⚠️ Senha não configurada'
  END as status_senha
FROM funcionarios
WHERE email = 'assistenciaallimport10@gmail.com';

-- 4. TESTAR A FUNÇÃO listar_usuarios_ativos
SELECT 
  '🧪 TESTE DA FUNÇÃO' as info,
  u.*
FROM listar_usuarios_ativos(
  (SELECT empresa_id FROM funcionarios WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1)
) u;

-- 5. RESULTADO FINAL
DO $$
DECLARE
  v_usuario_ativo BOOLEAN;
  v_nome TEXT;
BEGIN
  SELECT usuario_ativo, nome 
  INTO v_usuario_ativo, v_nome
  FROM funcionarios 
  WHERE email = 'assistenciaallimport10@gmail.com';
  
  IF v_usuario_ativo THEN
    RAISE NOTICE '✅ Sucesso! Usuário "%" está ATIVO e aparecerá no login local', v_nome;
  ELSE
    RAISE NOTICE '❌ Erro! Usuário ainda está INATIVO';
  END IF;
END $$;

-- =====================================================
-- INSTRUÇÕES:
-- Execute este script no SQL Editor do Supabase
-- O usuário aparecerá nos cards do login local
-- =====================================================
