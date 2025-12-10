-- =========================================================
-- 🔧 ADICIONAR COLUNA funcao_id NA TABELA funcionarios
-- =========================================================
-- Adiciona a coluna funcao_id diretamente na tabela funcionarios
-- para facilitar a atribuição de função única por funcionário

-- 1. ADICIONAR COLUNA funcao_id (SE NÃO EXISTIR)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'funcionarios' 
        AND column_name = 'funcao_id'
    ) THEN
        ALTER TABLE funcionarios 
        ADD COLUMN funcao_id UUID REFERENCES funcoes(id) ON DELETE SET NULL;
        
        RAISE NOTICE '✅ Coluna funcao_id adicionada com sucesso!';
    ELSE
        RAISE NOTICE 'ℹ️ Coluna funcao_id já existe.';
    END IF;
END $$;

-- 2. CRIAR ÍNDICE PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_funcionarios_funcao_id 
ON funcionarios(funcao_id);

-- 3. VERIFICAR ESTRUTURA
SELECT 
    '🔍 VERIFICANDO COLUNA funcao_id' as info,
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public'
AND table_name = 'funcionarios' 
AND column_name = 'funcao_id';

-- 4. MIGRAR DADOS DE funcionario_funcoes PARA funcao_id (SE EXISTIR A TABELA)
-- Pegar a primeira função de cada funcionário se houver múltiplas
DO $$
DECLARE
  v_count_migrados INTEGER := 0;
BEGIN
  -- Verificar se tabela funcionario_funcoes existe
  IF EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'funcionario_funcoes'
  ) THEN
    -- Migrar primeira função de cada funcionário
    UPDATE funcionarios f
    SET funcao_id = ff.funcao_id
    FROM (
      SELECT DISTINCT ON (funcionario_id)
        funcionario_id,
        funcao_id
      FROM funcionario_funcoes
      ORDER BY funcionario_id, created_at ASC
    ) ff
    WHERE f.id = ff.funcionario_id
    AND f.funcao_id IS NULL;
    
    GET DIAGNOSTICS v_count_migrados = ROW_COUNT;
    RAISE NOTICE '✅ % funcionários tiveram suas funções migradas', v_count_migrados;
  ELSE
    RAISE NOTICE 'ℹ️ Tabela funcionario_funcoes não existe, pulando migração';
  END IF;
END $$;

-- 5. VERIFICAR RESULTADO
SELECT 
  '📊 FUNCIONÁRIOS COM FUNÇÕES' as info,
  COUNT(*) as total_funcionarios,
  COUNT(funcao_id) as com_funcao,
  COUNT(*) - COUNT(funcao_id) as sem_funcao
FROM funcionarios;

-- Listar funcionários e suas funções
SELECT 
  '👥 LISTA DE FUNCIONÁRIOS' as info,
  f.id,
  f.nome,
  f.email,
  f.funcao_id,
  func.nome as nome_funcao,
  f.tipo_admin,
  f.status,
  e.nome as empresa_nome
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN empresas e ON e.id = f.empresa_id
ORDER BY f.empresa_id, f.created_at;

-- =========================================================
-- ✅ RESULTADO ESPERADO
-- =========================================================
-- 1. Coluna funcao_id criada na tabela funcionarios
-- 2. Índice criado para performance
-- 3. Dados migrados de funcionario_funcoes (se existir)
-- 4. Pronto para o trigger de atribuição automática
-- =========================================================
