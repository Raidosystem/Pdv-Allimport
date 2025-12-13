-- ====================================================================
-- CORRIGIR JENNIFER - Versão Simplificada
-- ====================================================================
-- Execute no SQL Editor do Supabase
-- ====================================================================

-- Habilitar extensão pgcrypto
CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA public;

DO $$
DECLARE
  v_jennifer_id UUID := '866ae21a-ba51-4fca-bbba-4d4610017a4e';
  v_usuario TEXT := 'jennifer';
  v_senha TEXT := 'Senha@123';
BEGIN
  RAISE NOTICE 'Criando login para Jennifer...';

  INSERT INTO login_funcionarios (
    funcionario_id,
    usuario,
    senha_hash,
    ativo,
    precisa_trocar_senha
  ) VALUES (
    v_jennifer_id,
    v_usuario,
    crypt(v_senha, gen_salt('bf')),
    true,
    true
  );

  UPDATE funcionarios 
  SET senha_definida = true, primeiro_acesso = true
  WHERE id = v_jennifer_id;

  RAISE NOTICE 'Login criado com sucesso!';
  RAISE NOTICE 'Usuario: jennifer';
  RAISE NOTICE 'Senha: Senha@123';
END;
$$;

-- Verificar se funcionou
SELECT 
  f.nome,
  lf.usuario,
  lf.ativo,
  CASE 
    WHEN lf.usuario IS NOT NULL AND lf.ativo = true 
    THEN 'VAI APARECER NA TELA'
    ELSE 'NAO VAI APARECER'
  END as status
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.id = '866ae21a-ba51-4fca-bbba-4d4610017a4e';

-- Testar RPC
SELECT nome, usuario, email
FROM listar_usuarios_ativos(
  (SELECT empresa_id FROM funcionarios WHERE id = '866ae21a-ba51-4fca-bbba-4d4610017a4e')
)
WHERE nome ILIKE '%jennifer%';
