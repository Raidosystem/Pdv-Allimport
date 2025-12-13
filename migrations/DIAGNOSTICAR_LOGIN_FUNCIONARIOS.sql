-- ====================================================================
-- DIAGNÓSTICO COMPLETO: LOGIN FUNCIONÁRIOS
-- Problema: Funcionários não aparecem na tela de login
-- ====================================================================

-- 1️⃣ VERIFICAR TODOS OS FUNCIONÁRIOS DA EMPRESA
SELECT 
  '1️⃣ TODOS OS FUNCIONÁRIOS' as secao,
  f.id,
  f.nome,
  f.email,
  f.status,
  f.tipo_admin,
  f.senha_definida,
  f.primeiro_acesso,
  f.empresa_id
FROM funcionarios f
WHERE f.empresa_id = (
  SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1
)
ORDER BY f.created_at;

-- 2️⃣ VERIFICAR REGISTROS DE LOGIN_FUNCIONARIOS
SELECT 
  '2️⃣ REGISTROS LOGIN_FUNCIONARIOS' as secao,
  lf.id,
  lf.funcionario_id,
  lf.usuario,
  lf.ativo,
  lf.senha_hash IS NOT NULL as tem_senha,
  lf.precisa_trocar_senha,
  lf.created_at,
  f.nome as nome_funcionario,
  f.status as status_funcionario
FROM login_funcionarios lf
INNER JOIN funcionarios f ON f.id = lf.funcionario_id
WHERE f.empresa_id = (
  SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1
)
ORDER BY lf.created_at;

-- 3️⃣ VERIFICAR RESULTADO DA RPC (O QUE O SISTEMA VÊ)
SELECT 
  '3️⃣ RESULTADO DA RPC listar_usuarios_ativos' as secao,
  *
FROM listar_usuarios_ativos(
  (SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1)
);

-- 4️⃣ FUNCIONÁRIOS QUE NÃO APARECEM (JOIN DETALHADO)
SELECT 
  '4️⃣ ANÁLISE DETALHADA - Por que não aparecem?' as secao,
  f.id,
  f.nome,
  f.email,
  f.status as status_func,
  f.senha_definida,
  CASE 
    WHEN lf.id IS NULL THEN '❌ SEM REGISTRO em login_funcionarios'
    WHEN lf.ativo = false THEN '❌ LOGIN INATIVO'
    WHEN lf.usuario IS NULL THEN '❌ SEM CAMPO USUARIO'
    WHEN f.status != 'ativo' THEN '❌ FUNCIONÁRIO INATIVO'
    ELSE '✅ DEVERIA APARECER'
  END as motivo,
  lf.usuario,
  lf.ativo as login_ativo,
  lf.senha_hash IS NOT NULL as tem_senha_hash
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = (
  SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1
)
ORDER BY f.nome;

-- 5️⃣ RESUMO EXECUTIVO
SELECT 
  '5️⃣ RESUMO EXECUTIVO' as secao,
  COUNT(*) as total_funcionarios,
  COUNT(CASE WHEN f.status = 'ativo' THEN 1 END) as funcionarios_ativos,
  COUNT(CASE WHEN lf.id IS NOT NULL THEN 1 END) as com_login_config,
  COUNT(CASE WHEN lf.ativo = true THEN 1 END) as login_ativo,
  COUNT(CASE WHEN lf.usuario IS NOT NULL THEN 1 END) as com_campo_usuario,
  COUNT(CASE 
    WHEN f.status = 'ativo' 
    AND lf.ativo = true 
    AND lf.usuario IS NOT NULL 
    THEN 1 
  END) as deveria_aparecer_na_rpc
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = (
  SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1
);

-- 6️⃣ IDENTIFICAR QUAIS PRECISAM DE CORREÇÃO
SELECT 
  '6️⃣ FUNCIONÁRIOS QUE PRECISAM DE CORREÇÃO' as secao,
  f.id,
  f.nome,
  f.email,
  CASE 
    WHEN lf.id IS NULL THEN '🔧 CRIAR registro em login_funcionarios'
    WHEN lf.ativo = false THEN '🔧 ATIVAR login (ativo = true)'
    WHEN lf.usuario IS NULL THEN '🔧 DEFINIR campo usuario'
    ELSE '✅ OK - Configuração correta'
  END as acao_necessaria,
  lf.usuario as usuario_atual,
  lf.ativo as login_ativo_atual
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = (
  SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1
)
  AND f.status = 'ativo'
  AND NOT (lf.ativo = true AND lf.usuario IS NOT NULL)
ORDER BY f.nome;

-- ====================================================================
-- CONCLUSÃO:
-- Execute este script para identificar quais funcionários não estão
-- aparecendo na tela de login e qual é o motivo específico.
-- ====================================================================
