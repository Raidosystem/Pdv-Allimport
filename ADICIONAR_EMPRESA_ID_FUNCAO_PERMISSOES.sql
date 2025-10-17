-- ============================================
-- ADICIONAR empresa_id À TABELA funcao_permissoes
-- ============================================

-- 1. VERIFICAR ESTRUTURA ATUAL
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'funcao_permissoes'
ORDER BY ordinal_position;

-- 2. ADICIONAR COLUNA empresa_id SE NÃO EXISTIR
DO $$
BEGIN
  -- Verificar e adicionar empresa_id
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'funcao_permissoes' 
    AND column_name = 'empresa_id'
  ) THEN
    -- Adicionar coluna temporariamente como nullable
    ALTER TABLE funcao_permissoes 
    ADD COLUMN empresa_id uuid;
    
    RAISE NOTICE '✅ Coluna empresa_id adicionada';
    
    -- Preencher empresa_id baseado na funcao_id
    UPDATE funcao_permissoes fp
    SET empresa_id = f.empresa_id
    FROM funcoes f
    WHERE f.id = fp.funcao_id;
    
    RAISE NOTICE '✅ Dados de empresa_id preenchidos';
    
    -- Tornar coluna NOT NULL
    ALTER TABLE funcao_permissoes 
    ALTER COLUMN empresa_id SET NOT NULL;
    
    -- Adicionar foreign key
    ALTER TABLE funcao_permissoes
    ADD CONSTRAINT funcao_permissoes_empresa_id_fkey 
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE;
    
    RAISE NOTICE '✅ Constraint de foreign key adicionada';
  ELSE
    RAISE NOTICE '⚠️  Coluna empresa_id já existe';
  END IF;
END $$;

-- 3. VERIFICAR ESTRUTURA FINAL
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'funcao_permissoes'
ORDER BY ordinal_position;

-- 4. VERIFICAR DADOS
SELECT 
  e.nome as empresa,
  COUNT(DISTINCT fp.funcao_id) as funcoes_com_permissoes,
  COUNT(DISTINCT fp.permissao_id) as permissoes_distintas
FROM funcao_permissoes fp
JOIN empresas e ON e.id = fp.empresa_id
GROUP BY e.id, e.nome
ORDER BY e.nome;
