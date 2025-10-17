-- ============================================
-- ATRIBUIR PERMISSÕES - FORMATO CORRETO
-- ============================================

-- 1. Desabilitar RLS
ALTER TABLE funcao_permissoes DISABLE ROW LEVEL SECURITY;

-- 2. ATRIBUIR TODAS AS PERMISSÕES CORRETAMENTE
DO $$
DECLARE
  v_funcao RECORD;
  v_permissao RECORD;
  v_total_funcoes INT := 0;
  v_total_inserted INT := 0;
  v_permissao_texto TEXT;
BEGIN
  RAISE NOTICE '🚀 Atribuindo permissões às funções Administrador...';
  
  -- Para cada função Administrador
  FOR v_funcao IN 
    SELECT 
      f.id as funcao_id,
      e.nome as empresa_nome
    FROM funcoes f
    JOIN empresas e ON e.id = f.empresa_id
    WHERE f.nome = 'Administrador'
  LOOP
    v_total_funcoes := v_total_funcoes + 1;
    
    RAISE NOTICE '📦 Processando: %', v_funcao.empresa_nome;
    
    -- Para cada permissão do catálogo
    FOR v_permissao IN 
      SELECT id, recurso, acao FROM permissoes
    LOOP
      -- Criar texto da permissão: "recurso:acao"
      v_permissao_texto := v_permissao.recurso || ':' || v_permissao.acao;
      
      BEGIN
        INSERT INTO funcao_permissoes (
          funcao_id,
          permissao_id,
          permissao
        ) VALUES (
          v_funcao.funcao_id,
          v_permissao.id,
          v_permissao_texto
        )
        ON CONFLICT DO NOTHING;
        
        v_total_inserted := v_total_inserted + 1;
        
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '   ⚠️ Erro: %', SQLERRM;
      END;
    END LOOP;
    
    RAISE NOTICE '   ✅ Concluído';
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ Funções processadas: %', v_total_funcoes;
  RAISE NOTICE '✅ Permissões inseridas: %', v_total_inserted;
END $$;

-- 3. Reabilitar RLS
ALTER TABLE funcao_permissoes ENABLE ROW LEVEL SECURITY;

-- 4. VERIFICAR RESULTADO
SELECT 
  COUNT(*) as total_registros,
  CASE 
    WHEN COUNT(*) > 0 THEN '✅ SUCESSO!'
    ELSE '❌ FALHOU'
  END as status
FROM funcao_permissoes;

-- 5. VERIFICAR POR EMPRESA
SELECT 
  e.nome as empresa,
  func.nome as funcao,
  COUNT(fp.id) as total_permissoes,
  CASE 
    WHEN COUNT(fp.id) >= 35 THEN '✅ COMPLETO'
    WHEN COUNT(fp.id) > 0 THEN '⚠️ PARCIAL'
    ELSE '❌ SEM PERMISSÕES'
  END as status
FROM funcoes func
JOIN empresas e ON e.id = func.empresa_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE func.nome = 'Administrador'
GROUP BY e.id, e.nome, func.id, func.nome
ORDER BY e.nome;

-- 6. VERIFICAR POR USUÁRIO
SELECT 
  u.email,
  e.nome as empresa,
  func.nome as funcao,
  COUNT(fp.id) as total_permissoes,
  CASE 
    WHEN COUNT(fp.id) >= 35 THEN '✅ COMPLETO'
    WHEN COUNT(fp.id) > 0 THEN '⚠️ PARCIAL'
    ELSE '❌ SEM PERMISSÕES'
  END as status
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
LEFT JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
GROUP BY u.id, u.email, e.nome, func.nome
ORDER BY u.email;

-- 7. RESUMO FINAL
SELECT 
  COUNT(DISTINCT u.id) as total_usuarios,
  COUNT(DISTINCT e.id) as total_empresas,
  COUNT(DISTINCT func.id) as total_funcoes,
  COUNT(DISTINCT fp.id) as total_permissoes_atribuidas,
  '🎉 FINALMENTE COMPLETO!' as status
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
LEFT JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id;

-- 8. LISTAR ALGUMAS PERMISSÕES
SELECT 
  u.email,
  fp.permissao
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
JOIN funcoes func ON func.id = ff.funcao_id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE fp.permissao LIKE 'administracao%'
ORDER BY u.email, fp.permissao
LIMIT 20;
