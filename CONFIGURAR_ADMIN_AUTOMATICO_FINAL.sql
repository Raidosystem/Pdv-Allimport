-- =====================================================
-- CONFIGURAR ADMIN AUTOMÁTICO - VERSÃO FINAL
-- =====================================================
-- Este script:
-- 1. Adiciona coluna funcao_id em funcionarios
-- 2. Vincula funcionários órfãos às empresas
-- 3. Atribui Admin automaticamente ao primeiro usuário
-- 4. Cria trigger para novos usuários
-- =====================================================

-- =====================================================
-- PARTE 1: ADICIONAR COLUNA funcao_id
-- =====================================================
DO $$
BEGIN
  -- Verificar se a coluna já existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'funcionarios' AND column_name = 'funcao_id'
  ) THEN
    -- Adicionar coluna funcao_id
    ALTER TABLE funcionarios 
    ADD COLUMN funcao_id UUID REFERENCES funcoes(id) ON DELETE SET NULL;
    
    -- Criar índice para performance
    CREATE INDEX IF NOT EXISTS idx_funcionarios_funcao_id ON funcionarios(funcao_id);
    CREATE INDEX IF NOT EXISTS idx_funcionarios_empresa_funcao ON funcionarios(empresa_id, funcao_id);
    
    RAISE NOTICE '✅ Coluna funcao_id adicionada com sucesso!';
  ELSE
    RAISE NOTICE '⚠️ Coluna funcao_id já existe';
  END IF;
END $$;

-- =====================================================
-- PARTE 2: VINCULAR FUNCIONÁRIOS ÓRFÃOS ÀS EMPRESAS
-- =====================================================
DO $$
DECLARE
  v_funcionario RECORD;
  v_primeira_empresa_id UUID;
  v_count INT := 0;
BEGIN
  RAISE NOTICE '🔗 Vinculando funcionários órfãos às empresas...';
  
  -- Pegar a primeira empresa (mais antiga)
  SELECT id INTO v_primeira_empresa_id
  FROM empresas
  ORDER BY created_at ASC
  LIMIT 1;
  
  IF v_primeira_empresa_id IS NULL THEN
    RAISE NOTICE '⚠️ Nenhuma empresa encontrada!';
    RETURN;
  END IF;
  
  -- Processar cada funcionário sem empresa_id
  FOR v_funcionario IN (
    SELECT f.id, f.nome, f.email
    FROM funcionarios f
    WHERE f.empresa_id IS NULL
  )
  LOOP
    -- Vincular à primeira empresa
    UPDATE funcionarios 
    SET empresa_id = v_primeira_empresa_id
    WHERE id = v_funcionario.id;
    
    v_count := v_count + 1;
    RAISE NOTICE '  ✅ % vinculado à empresa', v_funcionario.nome;
  END LOOP;
  
  RAISE NOTICE '✅ % funcionários vinculados', v_count;
END $$;

-- =====================================================
-- PARTE 3: ATRIBUIR ADMIN AO PRIMEIRO USUÁRIO
-- =====================================================
DO $$
DECLARE
  v_empresa RECORD;
  v_primeiro_funcionario RECORD;
  v_funcao_admin_id UUID;
  v_count INT := 0;
BEGIN
  RAISE NOTICE '👑 Atribuindo Admin ao primeiro usuário de cada empresa...';
  
  -- Processar cada empresa
  FOR v_empresa IN (SELECT id, nome FROM empresas ORDER BY created_at)
  LOOP
    -- Buscar função Administrador da empresa
    SELECT id INTO v_funcao_admin_id
    FROM funcoes
    WHERE empresa_id = v_empresa.id
    AND nome = 'Administrador'
    LIMIT 1;
    
    IF v_funcao_admin_id IS NULL THEN
      RAISE NOTICE '  ⚠️ Empresa % não tem função Administrador', v_empresa.nome;
      CONTINUE;
    END IF;
    
    -- Buscar primeiro funcionário da empresa (por data de criação no auth.users)
    SELECT f.id, f.nome, f.email INTO v_primeiro_funcionario
    FROM funcionarios f
    JOIN auth.users au ON au.email = f.email
    WHERE f.empresa_id = v_empresa.id
    ORDER BY au.created_at ASC
    LIMIT 1;
    
    IF v_primeiro_funcionario.id IS NOT NULL THEN
      -- Atribuir função Admin
      UPDATE funcionarios
      SET funcao_id = v_funcao_admin_id
      WHERE id = v_primeiro_funcionario.id;
      
      v_count := v_count + 1;
      RAISE NOTICE '  👑 % agora é Admin de %', v_primeiro_funcionario.nome, v_empresa.nome;
    ELSE
      RAISE NOTICE '  ⚠️ Empresa % não tem funcionários', v_empresa.nome;
    END IF;
  END LOOP;
  
  RAISE NOTICE '✅ % admins configurados', v_count;
END $$;

-- =====================================================
-- PARTE 4: CRIAR TRIGGER PARA NOVOS USUÁRIOS
-- =====================================================

-- Função que atribui Admin automaticamente
CREATE OR REPLACE FUNCTION atribuir_admin_primeiro_usuario()
RETURNS TRIGGER AS $$
DECLARE
  v_funcao_admin_id UUID;
  v_total_funcionarios INT;
BEGIN
  -- Verificar se a empresa já tem funcionários
  SELECT COUNT(*) INTO v_total_funcionarios
  FROM funcionarios
  WHERE empresa_id = NEW.empresa_id;
  
  -- Se for o primeiro funcionário da empresa
  IF v_total_funcionarios = 0 THEN
    -- Buscar função Administrador
    SELECT id INTO v_funcao_admin_id
    FROM funcoes
    WHERE empresa_id = NEW.empresa_id
    AND nome = 'Administrador'
    LIMIT 1;
    
    IF v_funcao_admin_id IS NOT NULL THEN
      -- Atribuir Admin ao novo funcionário
      NEW.funcao_id := v_funcao_admin_id;
      RAISE NOTICE '👑 Primeiro usuário % recebeu Admin automaticamente', NEW.nome;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger
DROP TRIGGER IF EXISTS trigger_atribuir_admin_primeiro_usuario ON funcionarios;
CREATE TRIGGER trigger_atribuir_admin_primeiro_usuario
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION atribuir_admin_primeiro_usuario();

-- Confirmar criação do trigger
DO $$
BEGIN
  RAISE NOTICE '✅ Trigger criado com sucesso!';
END $$;

-- =====================================================
-- VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar funcionários com suas funções
SELECT 
  '👥 FUNCIONÁRIOS COM FUNÇÕES' as info,
  f.nome,
  f.email,
  e.nome as empresa,
  fn.nome as funcao,
  CASE 
    WHEN fn.nome = 'Administrador' THEN '👑 ADMIN'
    ELSE '👤'
  END as badge
FROM funcionarios f
LEFT JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN funcoes fn ON fn.id = f.funcao_id
ORDER BY e.nome, 
  CASE WHEN fn.nome = 'Administrador' THEN 1 ELSE 2 END,
  f.nome;

-- Verificar empresas sem admin
SELECT 
  '⚠️ EMPRESAS SEM ADMIN' as alerta,
  e.nome as empresa,
  COUNT(f.id) as total_funcionarios
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
WHERE NOT EXISTS (
  SELECT 1 FROM funcionarios f2
  JOIN funcoes fn ON fn.id = f2.funcao_id
  WHERE f2.empresa_id = e.id
  AND fn.nome = 'Administrador'
)
GROUP BY e.id, e.nome;
