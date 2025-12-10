-- =====================================================
-- 🎯 SISTEMA DE PERMISSÕES FLEXÍVEL E PERSONALIZÁVEL
-- =====================================================
-- REGRAS:
-- 1. Função define permissões PADRÃO (apenas sugestão)
-- 2. Admin pode PERSONALIZAR qualquer permissão
-- 3. Sistema NUNCA sobrescreve permissões já definidas
-- 4. Cada funcionário tem controle individual
-- =====================================================

BEGIN;

-- =====================================================
-- PARTE 0: VERIFICAR/CRIAR COLUNA PERMISSOES
-- =====================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'funcionarios' 
    AND column_name = 'permissoes'
  ) THEN
    ALTER TABLE funcionarios ADD COLUMN permissoes JSONB DEFAULT '{}'::jsonb;
    RAISE NOTICE '✅ Coluna permissoes criada';
  ELSE
    RAISE NOTICE '✅ Coluna permissoes já existe';
  END IF;
END $$;

-- =====================================================
-- PARTE 1: TRIGGER - SUGERIR PERMISSÕES PADRÃO
-- =====================================================
-- Aplica permissões APENAS se funcionário NÃO tiver nenhuma definida

CREATE OR REPLACE FUNCTION trigger_sugerir_permissoes_padrao_novo_funcionario()
RETURNS TRIGGER AS $$
DECLARE
  v_funcao_nome TEXT;
BEGIN
  -- ✅ SE JÁ TEM PERMISSÕES DEFINIDAS, NÃO SOBRESCREVER
  IF NEW.permissoes IS NOT NULL 
     AND jsonb_typeof(NEW.permissoes) = 'object' 
     AND jsonb_object_keys(NEW.permissoes) IS NOT NULL THEN
    RAISE NOTICE '✅ Funcionário % já tem permissões personalizadas - MANTENDO', NEW.nome;
    RETURN NEW;
  END IF;

  -- Buscar nome da função
  SELECT nome INTO v_funcao_nome
  FROM funcoes
  WHERE id = NEW.funcao_id;

  RAISE NOTICE '💡 Sugerindo permissões padrão para % (função: %)', NEW.nome, v_funcao_nome;

  -- SUGERIR permissões baseado na função
  IF v_funcao_nome ILIKE '%admin%' OR v_funcao_nome ILIKE '%gerente%' THEN
    NEW.permissoes := jsonb_build_object(
      'vendas', true, 'produtos', true, 'clientes', true, 'caixa', true,
      'ordens_servico', true, 'relatorios', true, 'configuracoes', true, 'backup', true
    );
    RAISE NOTICE '  💡 Permissões ADMIN sugeridas (pode alterar depois)';
    
  ELSIF v_funcao_nome ILIKE '%técnico%' OR v_funcao_nome ILIKE '%tecnico%' THEN
    NEW.permissoes := jsonb_build_object(
      'vendas', false, 'produtos', true, 'clientes', true, 'caixa', false,
      'ordens_servico', true, 'relatorios', false, 'configuracoes', false, 'backup', false
    );
    RAISE NOTICE '  💡 Permissões TÉCNICO sugeridas (pode alterar depois)';
    
  ELSIF v_funcao_nome ILIKE '%vendedor%' THEN
    NEW.permissoes := jsonb_build_object(
      'vendas', true, 'produtos', true, 'clientes', true, 'caixa', false,
      'ordens_servico', false, 'relatorios', false, 'configuracoes', false, 'backup', false
    );
    RAISE NOTICE '  💡 Permissões VENDEDOR sugeridas (pode alterar depois)';
    
  ELSIF v_funcao_nome ILIKE '%caixa%' THEN
    NEW.permissoes := jsonb_build_object(
      'vendas', true, 'produtos', false, 'clientes', false, 'caixa', true,
      'ordens_servico', false, 'relatorios', false, 'configuracoes', false, 'backup', false
    );
    RAISE NOTICE '  💡 Permissões CAIXA sugeridas (pode alterar depois)';
    
  ELSE
    NEW.permissoes := jsonb_build_object(
      'vendas', true, 'produtos', true, 'clientes', true, 'caixa', false,
      'ordens_servico', true, 'relatorios', false, 'configuracoes', false, 'backup', false
    );
    RAISE NOTICE '  💡 Permissões PADRÃO sugeridas (pode alterar depois)';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS before_insert_funcionario_permissoes ON funcionarios;

CREATE TRIGGER before_insert_funcionario_permissoes
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION trigger_sugerir_permissoes_padrao_novo_funcionario();

SELECT '✅ TRIGGER CRIADO - Sugere permissões padrão (admin pode alterar depois)' as status;

-- =====================================================
-- PARTE 2: FUNÇÃO PARA PERSONALIZAR PERMISSÕES
-- =====================================================
-- Admin usa esta função para personalizar permissões de um funcionário

CREATE OR REPLACE FUNCTION personalizar_permissoes_funcionario(
  p_funcionario_id UUID,
  p_permissoes JSONB
)
RETURNS TABLE(
  sucesso BOOLEAN,
  mensagem TEXT,
  permissoes_atualizadas JSONB
) AS $$
DECLARE
  v_nome TEXT;
BEGIN
  -- Buscar nome do funcionário
  SELECT nome INTO v_nome FROM funcionarios WHERE id = p_funcionario_id;
  
  IF v_nome IS NULL THEN
    RETURN QUERY SELECT false, 'Funcionário não encontrado'::TEXT, NULL::JSONB;
    RETURN;
  END IF;
  
  -- Atualizar permissões (PERSONALIZADAS pelo admin)
  UPDATE funcionarios
  SET 
    permissoes = p_permissoes,
    updated_at = NOW()
  WHERE id = p_funcionario_id;
  
  RETURN QUERY SELECT 
    true, 
    format('Permissões personalizadas para %s', v_nome)::TEXT,
    p_permissoes;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ FUNÇÃO CRIADA - Admin pode personalizar permissões de qualquer funcionário' as status;

-- =====================================================
-- PARTE 3: CORRIGIR FUNCIONÁRIOS SEM PERMISSÕES
-- =====================================================
-- Apenas funcionários que NÃO têm permissões definidas

DO $$
DECLARE
  v_funcionario RECORD;
  v_funcao_nome TEXT;
  v_permissoes JSONB;
  v_count INT := 0;
BEGIN
  RAISE NOTICE '🔄 Sugerindo permissões para funcionários sem permissões...';
  
  FOR v_funcionario IN (
    SELECT f.id, f.nome, f.funcao_id, func.nome as funcao_nome
    FROM funcionarios f
    LEFT JOIN funcoes func ON f.funcao_id = func.id
    WHERE f.permissoes IS NULL 
       OR jsonb_typeof(f.permissoes) != 'object'
       OR jsonb_object_keys(f.permissoes) IS NULL
    ORDER BY f.nome
  )
  LOOP
    v_funcao_nome := v_funcionario.funcao_nome;
    
    -- Sugerir permissões baseado na função
    IF v_funcao_nome ILIKE '%admin%' OR v_funcao_nome ILIKE '%gerente%' THEN
      v_permissoes := jsonb_build_object(
        'vendas', true, 'produtos', true, 'clientes', true, 'caixa', true,
        'ordens_servico', true, 'relatorios', true, 'configuracoes', true, 'backup', true
      );
    ELSIF v_funcao_nome ILIKE '%técnico%' OR v_funcao_nome ILIKE '%tecnico%' THEN
      v_permissoes := jsonb_build_object(
        'vendas', false, 'produtos', true, 'clientes', true, 'caixa', false,
        'ordens_servico', true, 'relatorios', false, 'configuracoes', false, 'backup', false
      );
    ELSIF v_funcao_nome ILIKE '%vendedor%' THEN
      v_permissoes := jsonb_build_object(
        'vendas', true, 'produtos', true, 'clientes', true, 'caixa', false,
        'ordens_servico', false, 'relatorios', false, 'configuracoes', false, 'backup', false
      );
    ELSIF v_funcao_nome ILIKE '%caixa%' THEN
      v_permissoes := jsonb_build_object(
        'vendas', true, 'produtos', false, 'clientes', false, 'caixa', true,
        'ordens_servico', false, 'relatorios', false, 'configuracoes', false, 'backup', false
      );
    ELSE
      v_permissoes := jsonb_build_object(
        'vendas', true, 'produtos', true, 'clientes', true, 'caixa', false,
        'ordens_servico', true, 'relatorios', false, 'configuracoes', false, 'backup', false
      );
    END IF;
    
    -- Atualizar APENAS se não tem permissões
    UPDATE funcionarios
    SET 
      permissoes = v_permissoes,
      ativo = COALESCE(ativo, true),
      status = COALESCE(status, 'ativo'),
      usuario_ativo = COALESCE(usuario_ativo, true),
      senha_definida = COALESCE(senha_definida, true),
      updated_at = NOW()
    WHERE id = v_funcionario.id;
    
    v_count := v_count + 1;
    RAISE NOTICE '  💡 % (%): Permissões padrão sugeridas', v_funcionario.nome, v_funcao_nome;
  END LOOP;
  
  RAISE NOTICE '🎉 Total de funcionários com permissões sugeridas: %', v_count;
  RAISE NOTICE '💡 Admin pode personalizar depois via interface ou SQL';
END;
$$;

-- =====================================================
-- PARTE 4: PERSONALIZAR JENNIFER (EXEMPLO)
-- =====================================================
-- Jennifer é Vendedor mas PRECISA ter OS

SELECT personalizar_permissoes_funcionario(
  (SELECT id FROM funcionarios WHERE nome = 'Jennifer' LIMIT 1),
  jsonb_build_object(
    'vendas', true,
    'produtos', true,
    'clientes', true,
    'caixa', false,
    'ordens_servico', true,  -- ✅ PERSONALIZADO: Vendedor com OS
    'relatorios', false,
    'configuracoes', false,
    'backup', false
  )
) as personalizacao_jennifer;

-- =====================================================
-- PARTE 5: VERIFICAÇÃO FINAL
-- =====================================================

SELECT 
  '📊 RESULTADO FINAL' as titulo,
  f.nome,
  func.nome as funcao,
  f.permissoes->>'vendas' as vendas,
  f.permissoes->>'produtos' as produtos,
  f.permissoes->>'clientes' as clientes,
  f.permissoes->>'caixa' as caixa,
  f.permissoes->>'ordens_servico' as os,
  f.permissoes->>'relatorios' as relatorios,
  CASE 
    WHEN f.permissoes = (
      CASE func.nome
        WHEN 'Administrador' THEN '{"vendas":true,"produtos":true,"clientes":true,"caixa":true,"ordens_servico":true,"relatorios":true,"configuracoes":true,"backup":true}'::jsonb
        WHEN 'Vendedor' THEN '{"vendas":true,"produtos":true,"clientes":true,"caixa":false,"ordens_servico":false,"relatorios":false,"configuracoes":false,"backup":false}'::jsonb
        WHEN 'Técnico' THEN '{"vendas":false,"produtos":true,"clientes":true,"caixa":false,"ordens_servico":true,"relatorios":false,"configuracoes":false,"backup":false}'::jsonb
        ELSE NULL
      END
    ) THEN '📋 Padrão'
    ELSE '⭐ Personalizado'
  END as tipo_permissao
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
ORDER BY f.nome;

COMMIT;

-- =====================================================
-- 📋 COMO FUNCIONA O SISTEMA:
-- =====================================================
-- 
-- 1️⃣ NOVO FUNCIONÁRIO:
--    - Trigger SUGERE permissões baseado na função
--    - Admin pode aceitar ou personalizar
-- 
-- 2️⃣ PERSONALIZAR PERMISSÕES:
--    Via SQL:
--      SELECT personalizar_permissoes_funcionario(
--        'UUID_DO_FUNCIONARIO',
--        '{"vendas": true, "ordens_servico": true, ...}'::jsonb
--      );
--    
--    Via Interface (GerenciarFuncionarios):
--      - Admin marca/desmarca checkboxes
--      - Sistema salva direto no JSONB
-- 
-- 3️⃣ MUDAR FUNÇÃO:
--    - Se mudar a função de um funcionário
--    - Permissões PERSONALIZADAS são MANTIDAS
--    - Sistema NÃO sobrescreve automaticamente
--    - Admin precisa atualizar manualmente se quiser
-- 
-- 4️⃣ EXEMPLOS:
--    Jennifer (Vendedor) + OS personalizado = ✅ Funciona
--    Técnico sem OS = ✅ Admin pode remover
--    Admin sem Configurações = ✅ Admin pode restringir
-- 
-- =====================================================
-- 🎯 REGRA DE OURO:
-- =====================================================
-- 
-- ⭐ FUNÇÃO = SUGESTÃO INICIAL
-- ⭐ ADMIN = CONTROLE TOTAL
-- ⭐ SISTEMA NUNCA SOBRESCREVE PERSONALIZAÇÕES
-- 
-- =====================================================
