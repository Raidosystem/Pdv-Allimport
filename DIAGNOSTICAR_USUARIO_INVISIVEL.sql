-- =====================================================
-- DIAGNÓSTICO: USUÁRIO NÃO APARECE NO LOGIN LOCAL
-- =====================================================
-- Investiga por que assistenciaallimport10@gmail.com
-- não aparece nos cards de seleção
-- =====================================================

-- 1. VERIFICAR SE O FUNCIONÁRIO EXISTE
SELECT 
  'VERIFICANDO FUNCIONÁRIO' as etapa,
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

-- 2. VERIFICAR TODOS OS FUNCIONÁRIOS DA EMPRESA
SELECT 
  'TODOS OS FUNCIONÁRIOS DA EMPRESA' as etapa,
  f.id,
  f.nome,
  f.email,
  f.usuario_ativo,
  f.senha_definida,
  f.tipo_admin,
  e.nome as empresa_nome
FROM funcionarios f
LEFT JOIN empresas e ON e.id = f.empresa_id
WHERE f.empresa_id IN (
  SELECT empresa_id 
  FROM funcionarios 
  WHERE email = 'assistenciaallimport10@gmail.com'
);

-- 3. TESTAR A FUNÇÃO listar_usuarios_ativos
-- (usando a empresa_id do funcionário)
SELECT 
  'TESTANDO FUNÇÃO listar_usuarios_ativos' as etapa,
  u.*
FROM listar_usuarios_ativos(
  (SELECT empresa_id FROM funcionarios WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1)
) u;

-- 4. VERIFICAR SE EXISTE EMPRESA ASSOCIADA
SELECT 
  'VERIFICANDO EMPRESA' as etapa,
  e.*
FROM empresas e
WHERE e.id = (
  SELECT empresa_id 
  FROM funcionarios 
  WHERE email = 'assistenciaallimport10@gmail.com' 
  LIMIT 1
);

-- 5. VERIFICAR COLUNA usuario_ativo
SELECT 
  'VERIFICANDO CAMPO usuario_ativo' as etapa,
  column_name,
  data_type,
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'funcionarios'
  AND column_name = 'usuario_ativo';

-- 6. CONTAR FUNCIONÁRIOS ATIVOS VS INATIVOS
SELECT 
  'ESTATÍSTICAS' as etapa,
  COUNT(*) FILTER (WHERE usuario_ativo = TRUE) as ativos,
  COUNT(*) FILTER (WHERE usuario_ativo = FALSE OR usuario_ativo IS NULL) as inativos,
  COUNT(*) as total
FROM funcionarios;

-- 7. SE NÃO ESTÁ ATIVO, ATIVAR O USUÁRIO
DO $$
DECLARE
  v_funcionario_id UUID;
  v_usuario_ativo BOOLEAN;
BEGIN
  -- Buscar o funcionário
  SELECT id, usuario_ativo 
  INTO v_funcionario_id, v_usuario_ativo
  FROM funcionarios 
  WHERE email = 'assistenciaallimport10@gmail.com'
  LIMIT 1;
  
  IF v_funcionario_id IS NULL THEN
    RAISE NOTICE '❌ Funcionário não encontrado!';
  ELSIF v_usuario_ativo = FALSE OR v_usuario_ativo IS NULL THEN
    RAISE NOTICE '⚠️ Funcionário está INATIVO. Ativando...';
    
    UPDATE funcionarios
    SET usuario_ativo = TRUE
    WHERE id = v_funcionario_id;
    
    RAISE NOTICE '✅ Funcionário ativado com sucesso!';
  ELSE
    RAISE NOTICE '✅ Funcionário já está ATIVO';
  END IF;
END $$;

-- 8. VERIFICAR RESULTADO FINAL
SELECT 
  '✅ RESULTADO FINAL' as etapa,
  id,
  nome,
  email,
  usuario_ativo,
  senha_definida,
  tipo_admin
FROM funcionarios
WHERE email = 'assistenciaallimport10@gmail.com';

-- 9. TESTAR NOVAMENTE A FUNÇÃO
SELECT 
  '✅ TESTE FINAL DA FUNÇÃO' as etapa,
  u.*
FROM listar_usuarios_ativos(
  (SELECT empresa_id FROM funcionarios WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1)
) u;

-- =====================================================
-- INSTRUÇÕES:
-- 1. Execute este script no SQL Editor do Supabase
-- 2. Verifique cada etapa do diagnóstico
-- 3. O script ativará automaticamente o usuário se necessário
-- 4. Teste o login local novamente
-- =====================================================
