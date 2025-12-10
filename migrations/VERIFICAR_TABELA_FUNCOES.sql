-- ========================================
-- DIAGNÓSTICO: Verificar estrutura da tabela funcoes
-- ========================================

-- 1. VERIFICAR se a coluna empresa_id existe
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcoes'
ORDER BY ordinal_position;

-- 2. VERIFICAR se há registros na tabela
SELECT COUNT(*) as total_funcoes FROM funcoes;

-- 3. ADICIONAR coluna empresa_id se não existir
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'funcoes' 
    AND column_name = 'empresa_id'
  ) THEN
    ALTER TABLE funcoes ADD COLUMN empresa_id UUID REFERENCES empresas(id);
    RAISE NOTICE '✅ Coluna empresa_id adicionada à tabela funcoes';
  ELSE
    RAISE NOTICE '✅ Coluna empresa_id já existe';
  END IF;
END $$;

-- 4. TORNAR empresa_id NOT NULL (após adicionar) - CUIDADO!
-- SOMENTE execute isso se já houver dados e quiser tornar obrigatório
-- ALTER TABLE funcoes ALTER COLUMN empresa_id SET NOT NULL;

-- 5. VERIFICAR estrutura final
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'funcoes'
AND column_name IN ('id', 'empresa_id', 'nome', 'descricao')
ORDER BY ordinal_position;

-- ========================================
-- RESULTADO ESPERADO
-- ========================================
-- ✅ Coluna empresa_id existe na tabela funcoes
-- ✅ Tipo UUID com referência para empresas
-- ✅ Pode ser NULL ou NOT NULL conforme necessidade
