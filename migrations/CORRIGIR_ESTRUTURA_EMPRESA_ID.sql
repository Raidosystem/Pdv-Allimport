-- ============================================
-- CORRIGIR ESTRUTURA COMPLETA - ADICIONAR empresa_id
-- ============================================

-- PARTE 1: funcao_permissoes
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '🔧 Verificando tabela funcao_permissoes...';
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'funcao_permissoes' 
    AND column_name = 'empresa_id'
  ) THEN
    RAISE NOTICE '📝 Adicionando coluna empresa_id...';
    
    ALTER TABLE funcao_permissoes 
    ADD COLUMN empresa_id uuid;
    
    UPDATE funcao_permissoes fp
    SET empresa_id = f.empresa_id
    FROM funcoes f
    WHERE f.id = fp.funcao_id;
    
    ALTER TABLE funcao_permissoes 
    ALTER COLUMN empresa_id SET NOT NULL;
    
    ALTER TABLE funcao_permissoes
    ADD CONSTRAINT funcao_permissoes_empresa_id_fkey 
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE;
    
    RAISE NOTICE '✅ funcao_permissoes.empresa_id adicionada';
  ELSE
    RAISE NOTICE '⚠️  funcao_permissoes.empresa_id já existe';
  END IF;
END $$;

-- PARTE 2: funcionario_funcoes
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '🔧 Verificando tabela funcionario_funcoes...';
  
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'funcionario_funcoes' 
    AND column_name = 'empresa_id'
  ) THEN
    RAISE NOTICE '📝 Adicionando coluna empresa_id...';
    
    ALTER TABLE funcionario_funcoes 
    ADD COLUMN empresa_id uuid;
    
    UPDATE funcionario_funcoes ff
    SET empresa_id = func.empresa_id
    FROM funcoes func
    WHERE func.id = ff.funcao_id;
    
    ALTER TABLE funcionario_funcoes 
    ALTER COLUMN empresa_id SET NOT NULL;
    
    ALTER TABLE funcionario_funcoes
    ADD CONSTRAINT funcionario_funcoes_empresa_id_fkey 
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE;
    
    RAISE NOTICE '✅ funcionario_funcoes.empresa_id adicionada';
  ELSE
    RAISE NOTICE '⚠️  funcionario_funcoes.empresa_id já existe';
  END IF;
END $$;

-- PARTE 3: Verificar estruturas
-- ============================================

SELECT '=== funcao_permissoes ===' as tabela;
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'funcao_permissoes'
ORDER BY ordinal_position;

SELECT '=== funcionario_funcoes ===' as tabela;
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'funcionario_funcoes'
ORDER BY ordinal_position;

-- PARTE 4: Verificar dados
-- ============================================

SELECT 
  e.nome as empresa,
  COUNT(DISTINCT func.id) as total_funcoes,
  COUNT(DISTINCT ff.funcionario_id) as funcionarios_com_funcao,
  COUNT(DISTINCT fp.permissao_id) as permissoes_atribuidas
FROM empresas e
LEFT JOIN funcoes func ON func.empresa_id = e.id
LEFT JOIN funcionario_funcoes ff ON ff.empresa_id = e.id
LEFT JOIN funcao_permissoes fp ON fp.empresa_id = e.id
GROUP BY e.id, e.nome
ORDER BY e.nome;

RAISE NOTICE '';
RAISE NOTICE '✅ Estrutura corrigida! Agora execute CRIAR_FUNCOES_PERMISSOES_DIRETO.sql';
