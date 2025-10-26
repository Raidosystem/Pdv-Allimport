-- =====================================================
-- CORRIGIR EMPRESA DO ADMIN
-- =====================================================
-- Vincular Cristiano (Admin) à empresa Assistência All-Import

DO $$
DECLARE
  v_empresa_id UUID;
  v_cristiano_id UUID;
BEGIN
  -- Buscar empresa Assistência All-Import
  SELECT id INTO v_empresa_id
  FROM empresas
  WHERE nome = 'Assistência All-Import'
  LIMIT 1;
  
  -- Buscar Cristiano
  SELECT id INTO v_cristiano_id
  FROM funcionarios
  WHERE email = 'assistenciaallimport10@gmail.com'
  LIMIT 1;
  
  IF v_empresa_id IS NOT NULL AND v_cristiano_id IS NOT NULL THEN
    -- Vincular Cristiano à empresa
    UPDATE funcionarios
    SET empresa_id = v_empresa_id
    WHERE id = v_cristiano_id;
    
    RAISE NOTICE '✅ Cristiano vinculado à Assistência All-Import';
  ELSE
    RAISE NOTICE '⚠️ Empresa ou funcionário não encontrado';
  END IF;
  
  -- Vincular outros funcionários sem empresa
  UPDATE funcionarios
  SET empresa_id = v_empresa_id
  WHERE empresa_id IS NULL
  AND v_empresa_id IS NOT NULL;
  
  RAISE NOTICE '✅ Todos os funcionários órfãos vinculados';
END $$;

-- Verificar resultado
SELECT 
  '👥 FUNCIONÁRIOS ATUALIZADOS' as info,
  f.nome,
  f.email,
  e.nome as empresa,
  fn.nome as funcao,
  CASE 
    WHEN fn.nome = 'Administrador' THEN '👑 ADMIN'
    WHEN fn.nome = 'Técnico' THEN '🔧 TEC'
    ELSE '👤'
  END as badge
FROM funcionarios f
LEFT JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN funcoes fn ON fn.id = f.funcao_id
ORDER BY e.nome, 
  CASE WHEN fn.nome = 'Administrador' THEN 1 ELSE 2 END,
  f.nome;
