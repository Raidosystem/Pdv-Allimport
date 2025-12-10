-- ========================================
-- CRIAR LOGIN LOCAL PARA JENNIFER
-- ========================================
-- Jennifer foi criada mas falta o registro em login_funcionarios

DO $$
DECLARE
  v_jennifer_id uuid;
  v_usuario text := 'jennifer';
BEGIN
  -- Buscar ID da Jennifer
  SELECT id INTO v_jennifer_id
  FROM funcionarios
  WHERE nome = 'Jennifer'
    AND email = 'sousajenifer895@gmail.com'
  LIMIT 1;

  IF v_jennifer_id IS NULL THEN
    RAISE EXCEPTION 'Jennifer não encontrada';
  END IF;

  -- Verificar se já existe login
  IF EXISTS (SELECT 1 FROM login_funcionarios WHERE funcionario_id = v_jennifer_id) THEN
    RAISE NOTICE 'Login já existe para Jennifer';
  ELSE
    -- Criar login local para Jennifer
    INSERT INTO login_funcionarios (
      funcionario_id,
      usuario,
      senha,
      ativo,
      primeiro_acesso
    ) VALUES (
      v_jennifer_id,
      v_usuario,
      crypt('123456', gen_salt('bf')),  -- Senha padrão: 123456
      true,
      true
    );

    RAISE NOTICE '✅ Login criado para Jennifer - Usuário: % | Senha: 123456', v_usuario;
  END IF;

END $$;

-- Verificar resultado
SELECT 
  f.nome,
  f.email,
  lf.usuario,
  lf.ativo,
  lf.primeiro_acesso,
  fc.nome as funcao
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
LEFT JOIN funcoes fc ON fc.id = f.funcao_id
WHERE f.email = 'sousajenifer895@gmail.com';
