-- =====================================================
-- REMOVER FUNCIONÁRIO VITOR
-- =====================================================
-- Este script remove o funcionário Vitor para liberar o acesso
-- e permitir a criação do Admin automático

-- Buscar Vitor
SELECT 
  '🔍 BUSCANDO VITOR' as info,
  f.id,
  f.nome,
  f.email,
  f.empresa_id,
  e.nome as empresa,
  f.funcao_id,
  fn.nome as funcao
FROM funcionarios f
LEFT JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN funcoes fn ON fn.id = f.funcao_id
WHERE LOWER(f.nome) LIKE '%vitor%'
   OR LOWER(f.email) LIKE '%vitor%';

-- Remover Vitor de todas as tabelas
DO $$
DECLARE
  v_funcionario RECORD;
  v_user_id UUID;
BEGIN
  -- Buscar Vitor
  FOR v_funcionario IN (
    SELECT id, nome, email, empresa_id
    FROM funcionarios
    WHERE LOWER(nome) LIKE '%vitor%'
       OR LOWER(email) LIKE '%vitor%'
  )
  LOOP
    RAISE NOTICE '🗑️ Removendo funcionário: % (Email: %)', v_funcionario.nome, v_funcionario.email;
    
    -- Buscar user_id do usuário
    SELECT id INTO v_user_id
    FROM usuarios
    WHERE email = v_funcionario.email;
    
    IF v_user_id IS NOT NULL THEN
      RAISE NOTICE '  📧 User ID encontrado: %', v_user_id;
      
      -- Remover de todas as tabelas relacionadas
      DELETE FROM user_approvals WHERE user_id = v_user_id;
      DELETE FROM funcionarios WHERE id = v_funcionario.id;
      
      -- Remover do auth.users (Supabase Auth)
      -- Nota: Isso precisa ser feito via Dashboard do Supabase ou API
      RAISE NOTICE '  ⚠️ ATENÇÃO: Remova manualmente do Authentication no Dashboard do Supabase';
      RAISE NOTICE '  📧 Email para remover: %', v_funcionario.email;
      
    ELSE
      -- Apenas remover de funcionarios
      DELETE FROM funcionarios WHERE id = v_funcionario.id;
      RAISE NOTICE '  ✅ Funcionário removido (sem user_id)';
    END IF;
  END LOOP;
  
  -- Verificar se foi removido
  IF NOT EXISTS (
    SELECT 1 FROM funcionarios 
    WHERE LOWER(nome) LIKE '%vitor%' 
       OR LOWER(email) LIKE '%vitor%'
  ) THEN
    RAISE NOTICE '✅ Vitor removido com sucesso!';
  ELSE
    RAISE NOTICE '⚠️ Ainda existe algum registro com Vitor';
  END IF;
END $$;

-- Verificar funcionários restantes
SELECT 
  '👥 FUNCIONÁRIOS RESTANTES' as info,
  f.id,
  f.nome,
  f.email,
  e.nome as empresa,
  fn.nome as funcao,
  f.status
FROM funcionarios f
LEFT JOIN empresas e ON e.id = f.empresa_id
LEFT JOIN funcoes fn ON fn.id = f.funcao_id
ORDER BY e.nome, f.nome;
