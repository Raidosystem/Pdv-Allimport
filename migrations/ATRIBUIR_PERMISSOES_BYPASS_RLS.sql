-- ============================================
-- ATRIBUIR PERMISSÕES - BYPASS RLS TEMPORÁRIO
-- ============================================
-- Como não temos auth.uid() no SQL Editor, vamos desabilitar RLS temporariamente

-- 1. DESABILITAR RLS TEMPORARIAMENTE
ALTER TABLE funcao_permissoes DISABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
  RAISE NOTICE '⚠️  RLS desabilitado temporariamente para funcao_permissoes';
END $$;

-- 2. ATRIBUIR TODAS AS PERMISSÕES
DO $$
DECLARE
  v_funcao RECORD;
  v_permissao RECORD;
  v_total_funcoes INT := 0;
  v_total_permissoes INT := 0;
  v_total_inserted INT := 0;
BEGIN
  RAISE NOTICE '🚀 Atribuindo permissões às funções Administrador...';
  RAISE NOTICE '';
  
  -- Para cada função Administrador
  FOR v_funcao IN 
    SELECT 
      f.id as funcao_id,
      f.empresa_id,
      e.nome as empresa_nome
    FROM funcoes f
    JOIN empresas e ON e.id = f.empresa_id
    WHERE f.nome = 'Administrador'
  LOOP
    v_total_funcoes := v_total_funcoes + 1;
    v_total_permissoes := 0;
    
    RAISE NOTICE '📦 Processando empresa: %', v_funcao.empresa_nome;
    
    -- Para cada permissão do catálogo
    FOR v_permissao IN 
      SELECT id, recurso, acao FROM permissoes
    LOOP
      BEGIN
        INSERT INTO funcao_permissoes (
          funcao_id,
          permissao_id
        ) VALUES (
          v_funcao.funcao_id,
          v_permissao.id
        )
        ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
        
        v_total_permissoes := v_total_permissoes + 1;
        v_total_inserted := v_total_inserted + 1;
        
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '   ⚠️ Erro: % - %', v_permissao.recurso, SQLERRM;
      END;
    END LOOP;
    
    RAISE NOTICE '   ✅ % permissões atribuídas', v_total_permissoes;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ Total de funções processadas: %', v_total_funcoes;
  RAISE NOTICE '✅ Total de permissões inseridas: %', v_total_inserted;
END $$;

-- 3. REABILITAR RLS
ALTER TABLE funcao_permissoes ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
  RAISE NOTICE '✅ RLS reabilitado para funcao_permissoes';
END $$;

-- 4. VERIFICAR TOTAL DE REGISTROS
SELECT 
  COUNT(*) as total_registros_funcao_permissoes,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ SUCESSO!'
    ELSE '❌ FALHOU'
  END as status
FROM funcao_permissoes;

-- 5. VERIFICAR RESULTADO POR EMPRESA
SELECT 
  e.nome as empresa,
  func.nome as funcao,
  COUNT(DISTINCT fp.permissao_id) as total_permissoes,
  CASE 
    WHEN COUNT(DISTINCT fp.permissao_id) >= 35 THEN '✅ COMPLETO'
    WHEN COUNT(DISTINCT fp.permissao_id) > 0 THEN '⚠️ PARCIAL'
    ELSE '❌ SEM PERMISSÕES'
  END as status
FROM funcoes func
JOIN empresas e ON e.id = func.empresa_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE func.nome = 'Administrador'
GROUP BY e.id, e.nome, func.id, func.nome
ORDER BY e.nome;

-- 6. VERIFICAR RESULTADO POR USUÁRIO
SELECT 
  u.email as usuario_email,
  e.nome as empresa,
  f.nome as funcionario_nome,
  func.nome as funcao,
  COUNT(DISTINCT fp.permissao_id) as total_permissoes,
  CASE 
    WHEN COUNT(DISTINCT fp.permissao_id) >= 35 THEN '✅ COMPLETO'
    WHEN COUNT(DISTINCT fp.permissao_id) > 0 THEN '⚠️ PARCIAL'
    ELSE '❌ SEM PERMISSÕES'
  END as status
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
GROUP BY u.id, u.email, e.nome, f.nome, func.nome
ORDER BY u.email;

-- 7. RESUMO FINAL
SELECT 
  COUNT(DISTINCT u.id) as total_usuarios,
  COUNT(DISTINCT e.id) as total_empresas,
  COUNT(DISTINCT f.id) as total_funcionarios,
  COUNT(DISTINCT func.id) as total_funcoes,
  COUNT(DISTINCT fp.permissao_id) as total_permissoes_atribuidas,
  '✅ CONCLUÍDO!' as status
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id;

-- 8. LISTAR ALGUMAS PERMISSÕES PARA CONFERIR
SELECT 
  u.email,
  p.recurso,
  p.acao,
  p.categoria
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
JOIN funcoes func ON func.id = ff.funcao_id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE p.categoria = 'administracao'
ORDER BY u.email, p.recurso, p.acao
LIMIT 20;
