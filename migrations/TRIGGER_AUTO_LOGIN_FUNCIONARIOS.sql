-- =============================================
-- ?? TRIGGER: Criar login automaticamente para novos funcionários
-- =============================================
-- Este trigger garante que TODO funcionário cadastrado
-- já tenha um login criado em login_funcionarios
-- =============================================

-- 1?? Função do Trigger
CREATE OR REPLACE FUNCTION auto_criar_login_funcionario()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_usuario TEXT;
  v_senha_padrao TEXT := '123456'; -- Senha padrão para novos funcionários
BEGIN
  -- Gerar username baseado no nome (remove espaços e caracteres especiais)
  v_usuario := lower(regexp_replace(NEW.nome, '[^a-zA-Z0-9]', '', 'g'));
  
  -- Criar registro em login_funcionarios
  INSERT INTO login_funcionarios (
    funcionario_id,
    usuario,
    senha_hash,
    senha,
    ativo,
    precisa_trocar_senha,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id,
    v_usuario,
    crypt(v_senha_padrao, gen_salt('bf')),
    crypt(v_senha_padrao, gen_salt('bf')),
    TRUE,
    TRUE, -- Força troca de senha no primeiro login
    NOW(),
    NOW()
  )
  ON CONFLICT (funcionario_id) DO UPDATE
  SET 
    usuario = EXCLUDED.usuario,
    ativo = TRUE,
    updated_at = NOW();
  
  -- Garantir que senha_definida = TRUE
  NEW.senha_definida := TRUE;
  NEW.usuario_ativo := TRUE;
  NEW.primeiro_acesso := TRUE;
  
  RAISE NOTICE '? Login automático criado para: % (usuario: %, senha: %)', NEW.nome, v_usuario, v_senha_padrao;
  
  RETURN NEW;
END;
$$;

-- 2?? Criar o Trigger
DROP TRIGGER IF EXISTS trigger_auto_criar_login ON funcionarios;

CREATE TRIGGER trigger_auto_criar_login
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION auto_criar_login_funcionario();

-- 3?? Trigger para UPDATE (caso admin altere o nome)
CREATE OR REPLACE FUNCTION auto_atualizar_login_funcionario()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_usuario TEXT;
BEGIN
  -- Se o nome mudou, atualizar username
  IF OLD.nome != NEW.nome THEN
    v_usuario := lower(regexp_replace(NEW.nome, '[^a-zA-Z0-9]', '', 'g'));
    
    UPDATE login_funcionarios
    SET 
      usuario = v_usuario,
      updated_at = NOW()
    WHERE funcionario_id = NEW.id;
    
    RAISE NOTICE '? Username atualizado para: %', v_usuario;
  END IF;
  
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_auto_atualizar_login ON funcionarios;

CREATE TRIGGER trigger_auto_atualizar_login
  AFTER UPDATE ON funcionarios
  FOR EACH ROW
  WHEN (OLD.nome IS DISTINCT FROM NEW.nome)
  EXECUTE FUNCTION auto_atualizar_login_funcionario();

-- =============================================
-- ? VERIFICAÇÃO DO TRIGGER
-- =============================================

-- Ver triggers ativos
SELECT 
  '? TRIGGERS ATIVOS' as secao,
  trigger_name,
  event_manipulation,
  event_object_table,
  action_timing,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'funcionarios'
  AND trigger_name LIKE '%auto%login%';

-- =============================================
-- ?? TESTE: Criar funcionário de teste
-- =============================================

-- Inserir funcionário de teste
INSERT INTO funcionarios (
  empresa_id,
  nome,
  email,
  cpf,
  telefone,
  tipo_admin,
  ativo,
  status
)
VALUES (
  'f7fdf4cf-7101-45ab-86db-5248a7ac58c1',
  'Maria Silva Teste',
  'maria.teste@example.com',
  '12345678900',
  '11999999999',
  'funcionario',
  TRUE,
  'ativo'
);

-- Verificar se login foi criado automaticamente
SELECT 
  '?? TESTE: Login criado automaticamente?' as secao,
  f.nome,
  f.senha_definida,
  f.usuario_ativo,
  lf.usuario,
  lf.ativo as login_ativo,
  lf.precisa_trocar_senha,
  CASE 
    WHEN lf.id IS NOT NULL THEN '? LOGIN CRIADO AUTOMATICAMENTE'
    ELSE '? FALHOU'
  END as resultado
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.nome = 'Maria Silva Teste'
  AND f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- Limpar teste (opcional - descomente para executar)
-- DELETE FROM login_funcionarios WHERE usuario = 'mariasilvateste';
-- DELETE FROM funcionarios WHERE nome = 'Maria Silva Teste';

-- =============================================
-- ?? INSTRUÇÕES DE USO
-- =============================================
-- 
-- ? O QUE O TRIGGER FAZ:
-- 
-- 1. Quando um novo funcionário é cadastrado:
--    ? Cria automaticamente registro em login_funcionarios
--    ? Gera username baseado no nome (sem espaços)
--    ? Define senha padrão: 123456
--    ? Marca precisa_trocar_senha = TRUE
--    ? Define senha_definida = TRUE
-- 
-- 2. Quando o nome de um funcionário é alterado:
--    ? Atualiza o username automaticamente
-- 
-- ?? IMPORTANTE:
-- - Senha padrão: 123456
-- - Funcionário DEVE trocar senha no primeiro login
-- - Se quiser mudar senha padrão, edite v_senha_padrao
-- 
-- ?? ALTERAR SENHA PADRÃO:
-- 
-- ALTER FUNCTION auto_criar_login_funcionario()
-- Mudar linha: v_senha_padrao TEXT := '123456';
-- Para: v_senha_padrao TEXT := 'SuaNovaSenha';
-- 
-- =============================================

SELECT '?? TRIGGER INSTALADO COM SUCESSO!' as status,
       'Todos os novos funcionários terão login automático' as mensagem,
       'Senha padrão: 123456' as info;
