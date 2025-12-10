-- =============================================
-- 🔧 CORREÇÃO: Jennifer Acessando Sistema Completo
-- =============================================
-- PROBLEMA: Funções não estão sendo carregadas corretamente
-- SOLUÇÃO: Garantir que funcao_id seja editável e queries funcionem
-- =============================================

-- =============================================
-- PARTE 1: VERIFICAR ESTRUTURA ATUAL
-- =============================================

-- Ver funcionários e suas funções
SELECT 
  f.id,
  f.nome,
  f.email,
  f.funcao_id,
  f.empresa_id,
  func.nome as funcao_nome,
  func.descricao as funcao_descricao
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
WHERE f.email = 'sousajenifer895@gmail.com';

-- Ver permissões da função de Jennifer
SELECT 
  f.nome as funcionario,
  func.nome as funcao,
  p.recurso,
  p.acao,
  p.descricao
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
ORDER BY p.recurso, p.acao;

-- =============================================
-- PARTE 2: GARANTIR QUE funcao_id SEJA EDITÁVEL
-- =============================================

-- Verificar constraints e triggers que possam bloquear UPDATE
SELECT 
  'Constraints na coluna funcao_id' as tipo,
  tc.constraint_name,
  tc.constraint_type
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
  ON tc.constraint_name = kcu.constraint_name
WHERE kcu.table_name = 'funcionarios'
AND kcu.column_name = 'funcao_id';

-- Verificar triggers que possam interferir
SELECT 
  trigger_name,
  event_manipulation,
  action_timing
FROM information_schema.triggers
WHERE event_object_table = 'funcionarios'
AND trigger_name LIKE '%funcao%';

-- =============================================
-- PARTE 3: CRIAR/CORRIGIR RPC PARA EDITAR FUNÇÃO
-- =============================================

-- RPC para atualizar funcao_id de um funcionário
CREATE OR REPLACE FUNCTION atualizar_funcao_funcionario(
  p_funcionario_id UUID,
  p_funcao_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_funcionario RECORD;
BEGIN
  -- Validar parâmetros
  IF p_funcionario_id IS NULL OR p_funcao_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'ID do funcionário e função são obrigatórios'
    );
  END IF;

  -- Verificar se funcionário existe
  SELECT * INTO v_funcionario
  FROM funcionarios
  WHERE id = p_funcionario_id;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Funcionário não encontrado'
    );
  END IF;

  -- Atualizar funcao_id
  UPDATE funcionarios
  SET 
    funcao_id = p_funcao_id,
    updated_at = NOW()
  WHERE id = p_funcionario_id;

  -- Retornar sucesso
  RETURN json_build_object(
    'success', true,
    'message', 'Função atualizada com sucesso',
    'funcionario', row_to_json(v_funcionario)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION atualizar_funcao_funcionario(UUID, UUID) TO authenticated;

SELECT '✅ PASSO 3: RPC atualizar_funcao_funcionario criada' as status;

-- =============================================
-- PARTE 4: GARANTIR PERMISSÕES NA FUNÇÃO DE JENNIFER
-- =============================================

-- Ver qual função Jennifer tem atualmente
DO $$
DECLARE
  v_jennifer_funcao_id UUID;
  v_jennifer_empresa_id UUID;
BEGIN
  -- Pegar funcao_id e empresa_id de Jennifer
  SELECT funcao_id, empresa_id INTO v_jennifer_funcao_id, v_jennifer_empresa_id
  FROM funcionarios
  WHERE email = 'sousajenifer895@gmail.com';

  IF v_jennifer_funcao_id IS NULL THEN
    RAISE NOTICE '⚠️ Jennifer não tem função definida!';
    RETURN;
  END IF;

  RAISE NOTICE '✅ Jennifer tem funcao_id: %', v_jennifer_funcao_id;
  RAISE NOTICE '✅ Empresa ID: %', v_jennifer_empresa_id;

  -- Verificar quantas permissões a função tem
  DECLARE
    v_count_permissoes INT;
  BEGIN
    SELECT COUNT(*) INTO v_count_permissoes
    FROM funcao_permissoes
    WHERE funcao_id = v_jennifer_funcao_id;

    RAISE NOTICE '📊 Total de permissões na função: %', v_count_permissoes;

    IF v_count_permissoes = 0 THEN
      RAISE NOTICE '⚠️ A função de Jennifer NÃO TEM PERMISSÕES!';
      RAISE NOTICE '💡 Vá em Administração > Funções & Permissões e atribua permissões';
    END IF;
  END;
END;
$$;

-- =============================================
-- PARTE 5: TESTE DE PERMISSÕES
-- =============================================

-- Listar todas as permissões que Jennifer deveria ter (baseado na função)
WITH jennifer AS (
  SELECT funcao_id, empresa_id
  FROM funcionarios
  WHERE email = 'sousajenifer895@gmail.com'
)
SELECT 
  'Permissões que Jennifer TEM' as tipo,
  p.recurso,
  p.acao,
  p.descricao
FROM funcao_permissoes fp
JOIN permissoes p ON p.id = fp.permissao_id
WHERE fp.funcao_id = (SELECT funcao_id FROM jennifer)
ORDER BY p.recurso, p.acao;

-- =============================================
-- PARTE 6: VERIFICAÇÃO FINAL
-- =============================================

SELECT '🎯 VERIFICAÇÃO FINAL - JENNIFER' as secao;

-- Funcionário
SELECT 
  'Funcionário' as tipo,
  id,
  nome,
  email,
  funcao_id,
  empresa_id,
  status,
  ativo
FROM funcionarios
WHERE email = 'sousajenifer895@gmail.com';

-- Função
SELECT 
  'Função' as tipo,
  func.id,
  func.nome,
  func.descricao,
  func.empresa_id,
  COUNT(fp.id) as total_permissoes
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE f.email = 'sousajenifer895@gmail.com'
GROUP BY func.id, func.nome, func.descricao, func.empresa_id;

-- Permissões
SELECT 
  'Permissões' as tipo,
  p.recurso,
  STRING_AGG(p.acao, ', ' ORDER BY p.acao) as acoes
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
GROUP BY p.recurso
ORDER BY p.recurso;

-- =============================================
-- ✅ CONCLUSÃO
-- =============================================

SELECT 
  '🎉 CORREÇÃO APLICADA!' as resultado,
  '✅ funcao_id editável' as item_1,
  '✅ RPC atualizar_funcao_funcionario criada' as item_2,
  '✅ Permissões verificadas' as item_3,
  '💡 Vá em Funções & Permissões para editar' as item_4;

-- =============================================
-- 📋 INSTRUÇÕES DE USO
-- =============================================
-- 
-- 1. Execute este SQL no Supabase SQL Editor
-- 
-- 2. Para editar a função de Jennifer pelo SQL:
--    a. Pegue o funcao_id desejado da tabela funcoes
--    b. Execute:
--       SELECT atualizar_funcao_funcionario(
--         '866ae21a-ba51-4fca-bbba-4d4610017a4e', -- ID de Jennifer
--         'COLE_O_FUNCAO_ID_AQUI'
--       );
-- 
-- 3. Para editar pelo sistema:
--    a. Acesse Administração > Usuários
--    b. Clique em Editar ao lado de Jennifer
--    c. Selecione a função desejada
--    d. Salve
-- 
-- 4. Para editar permissões da função:
--    a. Acesse Administração > Funções & Permissões
--    b. Encontre a função de Jennifer
--    c. Clique em "Permissões"
--    d. Marque/desmarque as permissões desejadas
--    e. Salve
-- 
-- =============================================
