-- ========================================
-- VERIFICAÇÃO RÁPIDA DO SISTEMA DE PERMISSÕES
-- ========================================

-- 1. Verificar usuários do sistema
SELECT 
  'USUARIOS_SISTEMA' as tipo,
  au.id,
  au.email,
  au.created_at,
  au.email_confirmed_at IS NOT NULL as email_confirmado
FROM auth.users au
WHERE au.email IN (
  'novaradiosystem@outlook.com',
  'admin@pdvallimport.com',
  'assistenciaallimport10@gmail.com'
)
ORDER BY au.email;

-- 2. Verificar funcionários
SELECT 
  'FUNCIONARIOS' as tipo,
  f.id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.status,
  e.nome as empresa_nome,
  au.email as auth_email
FROM public.funcionarios f
JOIN public.empresas e ON e.id = f.empresa_id
LEFT JOIN auth.users au ON au.id = f.user_id
WHERE f.email IN (
  'novaradiosystem@outlook.com',
  'admin@pdvallimport.com',
  'assistenciaallimport10@gmail.com'
)
ORDER BY f.email;

-- 3. Verificar empresas
SELECT 
  'EMPRESAS' as tipo,
  e.id,
  e.nome,
  e.cnpj,
  e.email,
  e.created_at,
  COUNT(f.id) as funcionarios_count
FROM public.empresas e
LEFT JOIN public.funcionarios f ON f.empresa_id = e.id
GROUP BY e.id, e.nome, e.cnpj, e.email, e.created_at
ORDER BY e.created_at;

-- 4. Verificar funções do sistema
SELECT 
  'FUNCOES_SISTEMA' as tipo,
  func.id,
  func.nome,
  func.descricao,
  func.is_system,
  e.nome as empresa_nome,
  COUNT(fp.permissao_id) as permissoes_count
FROM public.funcoes func
JOIN public.empresas e ON e.id = func.empresa_id
LEFT JOIN public.funcao_permissoes fp ON fp.funcao_id = func.id
GROUP BY func.id, func.nome, func.descricao, func.is_system, e.nome
ORDER BY e.nome, func.nome;

-- 5. Verificar vínculos funcionário-função
SELECT 
  'FUNCIONARIO_FUNCOES' as tipo,
  f.nome as funcionario_nome,
  f.email as funcionario_email,
  func.nome as funcao_nome,
  e.nome as empresa_nome
FROM public.funcionario_funcoes ff
JOIN public.funcionarios f ON f.id = ff.funcionario_id
JOIN public.funcoes func ON func.id = ff.funcao_id
JOIN public.empresas e ON e.id = ff.empresa_id
ORDER BY e.nome, f.nome;

-- 6. Verificar permissões ativas por usuário
SELECT 
  'PERMISSOES_ATIVAS' as tipo,
  f.nome as funcionario,
  f.email,
  p.recurso,
  p.acao,
  func.nome as funcao
FROM public.funcionarios f
JOIN public.funcionario_funcoes ff ON ff.funcionario_id = f.id
JOIN public.funcoes func ON func.id = ff.funcao_id
JOIN public.funcao_permissoes fp ON fp.funcao_id = func.id
JOIN public.permissoes p ON p.id = fp.permissao_id
WHERE f.status = 'ativo'
  AND p.recurso LIKE 'administracao%'
ORDER BY f.email, p.recurso, p.acao;

-- 7. Diagnóstico de problemas comuns
SELECT 
  'DIAGNOSTICO' as tipo,
  'Usuários sem funcionário' as problema,
  COUNT(*) as quantidade
FROM auth.users au
LEFT JOIN public.funcionarios f ON f.user_id = au.id
WHERE f.id IS NULL

UNION ALL

SELECT 
  'DIAGNOSTICO' as tipo,
  'Funcionários sem função' as problema,
  COUNT(*) as quantidade
FROM public.funcionarios f
LEFT JOIN public.funcionario_funcoes ff ON ff.funcionario_id = f.id
WHERE ff.funcionario_id IS NULL
  AND f.status = 'ativo'

UNION ALL

SELECT 
  'DIAGNOSTICO' as tipo,
  'Funções sem permissões' as problema,
  COUNT(*) as quantidade
FROM public.funcoes func
LEFT JOIN public.funcao_permissoes fp ON fp.funcao_id = func.id
WHERE fp.funcao_id IS NULL

UNION ALL

SELECT 
  'DIAGNOSTICO' as tipo,
  'Empresas sem funcionários' as problema,
  COUNT(*) as quantidade
FROM public.empresas e
LEFT JOIN public.funcionarios f ON f.empresa_id = e.id
WHERE f.id IS NULL;

-- 8. Verificação específica para o usuário principal
DO $$
DECLARE
  v_user_id uuid;
  v_funcionario_count int;
  v_empresa_count int;
BEGIN
  -- Buscar user_id do email principal
  SELECT id INTO v_user_id 
  FROM auth.users 
  WHERE email = 'novaradiosystem@outlook.com';
  
  IF v_user_id IS NOT NULL THEN
    -- Contar funcionários
    SELECT COUNT(*) INTO v_funcionario_count
    FROM public.funcionarios
    WHERE user_id = v_user_id;
    
    -- Contar empresas
    SELECT COUNT(*) INTO v_empresa_count
    FROM public.empresas;
    
    RAISE NOTICE '=== DIAGNÓSTICO ESPECÍFICO ===';
    RAISE NOTICE 'User ID: %', v_user_id;
    RAISE NOTICE 'Funcionários encontrados: %', v_funcionario_count;
    RAISE NOTICE 'Empresas no sistema: %', v_empresa_count;
    
    IF v_funcionario_count = 0 THEN
      RAISE NOTICE '❌ PROBLEMA: Usuário não tem registro de funcionário';
    ELSE
      RAISE NOTICE '✅ OK: Usuário tem registro de funcionário';
    END IF;
    
    IF v_empresa_count = 0 THEN
      RAISE NOTICE '❌ PROBLEMA: Não existem empresas no sistema';
    ELSE
      RAISE NOTICE '✅ OK: Existem empresas no sistema';
    END IF;
  ELSE
    RAISE NOTICE '❌ PROBLEMA: Usuário novaradiosystem@outlook.com não encontrado';
  END IF;
END $$;