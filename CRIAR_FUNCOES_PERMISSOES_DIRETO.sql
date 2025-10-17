-- ============================================
-- CRIAR FUNÇÕES E PERMISSÕES DIRETAMENTE
-- ============================================

-- 1. VERIFICAR ESTADO ATUAL
SELECT 
  u.email,
  e.nome as empresa,
  f.id as funcionario_id,
  f.nome as funcionario,
  func.id as funcao_id,
  func.nome as funcao
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
ORDER BY u.email;

-- 2. CRIAR FUNÇÃO ADMINISTRADOR PARA CADA EMPRESA
DO $$
DECLARE
  v_empresa RECORD;
  v_funcao_id uuid;
  v_count INT := 0;
BEGIN
  RAISE NOTICE '🚀 Criando funções Administrador...';
  
  FOR v_empresa IN 
    SELECT 
      e.id as empresa_id,
      e.nome as empresa_nome
    FROM empresas e
    LEFT JOIN funcoes f ON f.empresa_id = e.id AND f.nome = 'Administrador'
    WHERE f.id IS NULL
  LOOP
    BEGIN
      INSERT INTO funcoes (
        empresa_id,
        nome,
        descricao
      ) VALUES (
        v_empresa.empresa_id,
        'Administrador',
        'Acesso total ao sistema'
      ) RETURNING id INTO v_funcao_id;
      
      v_count := v_count + 1;
      RAISE NOTICE '✅ Função Administrador criada para empresa: % (ID: %)', v_empresa.empresa_nome, v_funcao_id;
      
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE '❌ Erro ao criar função para %: %', v_empresa.empresa_nome, SQLERRM;
    END;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ Total de funções criadas: %', v_count;
END $$;

-- 3. VERIFICAR FUNÇÕES CRIADAS
SELECT 
  e.nome as empresa,
  f.nome as funcao,
  f.descricao
FROM funcoes f
JOIN empresas e ON e.id = f.empresa_id
ORDER BY e.nome;

-- 4. ATRIBUIR FUNÇÃO ADMINISTRADOR AOS FUNCIONÁRIOS
DO $$
DECLARE
  v_funcionario RECORD;
  v_count INT := 0;
BEGIN
  RAISE NOTICE '🚀 Atribuindo funções aos funcionários...';
  
  FOR v_funcionario IN 
    SELECT 
      f.id as funcionario_id,
      f.nome as funcionario_nome,
      f.empresa_id,
      func.id as funcao_id
    FROM funcionarios f
    JOIN funcoes func ON func.empresa_id = f.empresa_id AND func.nome = 'Administrador'
    LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id AND ff.funcao_id = func.id
    WHERE ff.funcionario_id IS NULL
  LOOP
    BEGIN
      INSERT INTO funcionario_funcoes (
        funcionario_id,
        funcao_id
      ) VALUES (
        v_funcionario.funcionario_id,
        v_funcionario.funcao_id
      );
      
      v_count := v_count + 1;
      RAISE NOTICE '✅ Função atribuída para: %', v_funcionario.funcionario_nome;
      
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE '❌ Erro ao atribuir função para %: %', v_funcionario.funcionario_nome, SQLERRM;
    END;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ Total de atribuições: %', v_count;
END $$;

-- 5. VERIFICAR ATRIBUIÇÕES
SELECT 
  u.email,
  f.nome as funcionario,
  func.nome as funcao,
  CASE 
    WHEN ff.funcionario_id IS NOT NULL THEN '✅ ATRIBUÍDO'
    ELSE '❌ SEM FUNÇÃO'
  END as status
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
ORDER BY u.email;

-- 6. ATRIBUIR TODAS AS PERMISSÕES ÀS FUNÇÕES
DO $$
DECLARE
  v_funcao RECORD;
  v_permissao RECORD;
  v_total_funcoes INT := 0;
  v_total_permissoes INT := 0;
BEGIN
  RAISE NOTICE '🚀 Atribuindo permissões às funções...';
  
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
    
    -- Para cada permissão do catálogo
    FOR v_permissao IN 
      SELECT id FROM permissoes
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
        
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '⚠️ Erro ao atribuir permissão: %', SQLERRM;
      END;
    END LOOP;
    
    RAISE NOTICE '✅ % permissões atribuídas para empresa: %', v_total_permissoes, v_funcao.empresa_nome;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ Total de funções configuradas: %', v_total_funcoes;
END $$;

-- 7. VERIFICAR PERMISSÕES ATRIBUÍDAS
SELECT 
  e.nome as empresa,
  func.nome as funcao,
  COUNT(DISTINCT fp.permissao_id) as total_permissoes
FROM funcoes func
JOIN empresas e ON e.id = func.empresa_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
GROUP BY e.id, e.nome, func.id, func.nome
ORDER BY e.nome;

-- 8. VERIFICAR RESULTADO FINAL POR USUÁRIO
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

-- 9. RESUMO FINAL
SELECT 
  COUNT(DISTINCT u.id) as total_usuarios,
  COUNT(DISTINCT e.id) as total_empresas,
  COUNT(DISTINCT f.id) as total_funcionarios,
  COUNT(DISTINCT func.id) as total_funcoes,
  COUNT(DISTINCT fp.permissao_id) as total_permissoes_atribuidas
FROM auth.users u
JOIN empresas e ON e.user_id = u.id
JOIN funcionarios f ON f.user_id = u.id AND f.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.funcionario_id = f.id
LEFT JOIN funcoes func ON func.id = ff.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id;

-- 10. LISTAR ALGUMAS PERMISSÕES PARA CONFERIR
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
LIMIT 50;
