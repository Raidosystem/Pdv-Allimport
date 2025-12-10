-- =====================================================
-- SIMULAR VERIFICAÇÃO DE PERMISSÕES (sem login real)
-- =====================================================
-- Este script simula o que o usePermissions.tsx faz

-- 1️⃣ DADOS DO FUNCIONÁRIO
WITH funcionario_info AS (
  SELECT 
    f.id as funcionario_id,
    f.nome,
    f.email,
    f.tipo_admin,
    f.status,
    func.id as funcao_id,
    func.nome as funcao_nome,
    f.empresa_id,
    f.user_id
  FROM funcionarios f
  LEFT JOIN funcoes func ON f.funcao_id = func.id
  WHERE f.email = 'jennifer_sousa@temp.local' -- ✏️ MUDE O EMAIL AQUI
),

-- 2️⃣ PERMISSÕES DA FUNÇÃO
permissoes_funcao AS (
  SELECT 
    fi.funcionario_id,
    p.categoria,
    p.recurso,
    p.acao,
    p.categoria || ':' || p.acao as permissao_completa
  FROM funcionario_info fi
  JOIN funcao_permissoes fp ON fi.funcao_id = fp.funcao_id
  JOIN permissoes p ON fp.permissao_id = p.id
),

-- 3️⃣ DETERMINAR TIPO DE ACESSO
tipo_acesso AS (
  SELECT 
    fi.*,
    CASE 
      WHEN fi.tipo_admin = 'super_admin' THEN '🔴 SUPER ADMIN'
      WHEN fi.tipo_admin = 'admin_empresa' THEN '🟡 ADMIN EMPRESA'
      WHEN fi.funcao_nome = 'Administrador' THEN '🟡 ADMIN EMPRESA (auto)'
      ELSE '🟢 FUNCIONÁRIO'
    END as tipo_acesso,
    CASE 
      WHEN fi.tipo_admin IN ('super_admin', 'admin_empresa') THEN true
      WHEN fi.funcao_nome = 'Administrador' THEN true
      ELSE false
    END as is_admin
  FROM funcionario_info fi
)

-- ✅ RESULTADO FINAL
SELECT 
  '👤 INFORMAÇÕES DO FUNCIONÁRIO' as secao,
  ta.nome,
  ta.email,
  ta.funcao_nome,
  ta.tipo_acesso,
  ta.is_admin,
  ta.status,
  CASE 
    WHEN ta.user_id IS NULL THEN '❌ NÃO PODE LOGAR'
    ELSE '✅ PODE LOGAR'
  END as pode_logar
FROM tipo_acesso ta

UNION ALL

SELECT 
  '🔑 TOTAL DE PERMISSÕES' as secao,
  CAST(COUNT(DISTINCT pf.permissao_completa) AS TEXT) as valor,
  '' as col3,
  '' as col4,
  '' as col5,
  '' as col6,
  '' as col7
FROM permissoes_funcao pf

UNION ALL

SELECT 
  '📋 PERMISSÕES DETALHADAS' as secao,
  pf.categoria,
  pf.recurso,
  pf.acao,
  pf.permissao_completa,
  '' as col6,
  '' as col7
FROM permissoes_funcao pf
ORDER BY secao DESC, categoria, recurso, acao;

-- =====================================================
-- 🎯 TESTE DE PERMISSÕES ESPECÍFICAS
-- =====================================================

-- Verificar se TEM permissão específica
SELECT 
  '🔍 VERIFICAR PERMISSÃO' as teste,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM funcionarios f
      JOIN funcoes func ON f.funcao_id = func.id
      WHERE f.email = 'jennifer_sousa@temp.local' -- ✏️ MUDE O EMAIL AQUI
      AND (
        f.tipo_admin IN ('super_admin', 'admin_empresa')
        OR func.nome = 'Administrador'
      )
    ) THEN '✅ ADMIN - TEM TODAS AS PERMISSÕES'
    WHEN EXISTS (
      SELECT 1 FROM funcionarios f
      JOIN funcao_permissoes fp ON f.funcao_id = fp.funcao_id
      JOIN permissoes p ON fp.permissao_id = p.id
      WHERE f.email = 'jennifer_sousa@temp.local' -- ✏️ MUDE O EMAIL AQUI
      AND p.categoria = 'vendas' -- ✏️ MUDE A CATEGORIA AQUI
      AND p.acao = 'create' -- ✏️ MUDE A AÇÃO AQUI
    ) THEN '✅ TEM PERMISSÃO'
    ELSE '❌ SEM PERMISSÃO'
  END as resultado,
  'vendas:create' as permissao_testada;

-- =====================================================
-- 📊 COMPARAÇÃO COM OUTROS FUNCIONÁRIOS
-- =====================================================
SELECT 
  '👥 COMPARAÇÃO' as info,
  f.nome,
  f.email,
  func.nome as funcao,
  f.tipo_admin,
  COUNT(fp.permissao_id) as total_permissoes,
  CASE 
    WHEN f.tipo_admin IN ('super_admin', 'admin_empresa') THEN '👑 ADMIN'
    WHEN func.nome = 'Administrador' THEN '👑 ADMIN (auto)'
    ELSE '👤 FUNCIONÁRIO'
  END as nivel_acesso
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
WHERE f.empresa_id = (
  SELECT empresa_id FROM funcionarios WHERE email = 'jennifer_sousa@temp.local' LIMIT 1
)
GROUP BY f.id, f.nome, f.email, func.nome, f.tipo_admin
ORDER BY total_permissoes DESC;
