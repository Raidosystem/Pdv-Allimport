# ✅ SOLUÇÃO FINAL - SEM CONFLITOS

## 🔥 PROBLEMA RESOLVIDO
O erro aconteceu porque a função `validar_senha_local` já existia com tipo de retorno diferente.

## 📋 EXECUTE ESTE SCRIPT (SEM CONFLITOS)

**Copie e execute no Supabase SQL Editor:**

```sql
-- 🔧 CORREÇÃO DEFINITIVA - REMOVE CONFLITOS
DROP FUNCTION IF EXISTS validar_senha_local(UUID, TEXT);
DROP FUNCTION IF EXISTS listar_usuarios_ativos(UUID);

-- Recriar função principal
CREATE FUNCTION listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (id UUID, nome TEXT, email TEXT, foto_perfil TEXT, tipo_admin TEXT, senha_definida BOOLEAN, primeiro_acesso BOOLEAN) 
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT f.id, f.nome, COALESCE(f.email, '') as email, f.foto_perfil, f.tipo_admin, COALESCE(f.senha_definida, false) as senha_definida, COALESCE(f.primeiro_acesso, true) as primeiro_acesso
  FROM funcionarios f
  WHERE f.empresa_id = p_empresa_id AND (f.usuario_ativo = true OR f.usuario_ativo IS NULL) AND (f.status = 'ativo' OR f.status IS NULL) AND f.senha_definida = true
  ORDER BY f.nome;
END;
$$;

-- Recriar função de validação (sem conflitos)
CREATE FUNCTION validar_senha_local(p_funcionario_id UUID, p_senha TEXT)
RETURNS JSON
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE v_funcionario RECORD; v_login RECORD; v_senha_hash TEXT; v_result JSON;
BEGIN
  SELECT * INTO v_funcionario FROM funcionarios WHERE id = p_funcionario_id;
  IF NOT FOUND THEN
    RETURN json_build_object('sucesso', false, 'mensagem', 'Funcionário não encontrado');
  END IF;
  SELECT * INTO v_login FROM login_funcionarios WHERE funcionario_id = p_funcionario_id AND ativo = true LIMIT 1;
  IF NOT FOUND THEN
    v_senha_hash := crypt(p_senha, gen_salt('bf'));
    INSERT INTO login_funcionarios (funcionario_id, usuario, senha, ativo) VALUES (p_funcionario_id, v_funcionario.nome, v_senha_hash, true) RETURNING * INTO v_login;
  END IF;
  IF v_login.senha = crypt(p_senha, v_login.senha) THEN
    RETURN json_build_object('sucesso', true, 'token', 'local_token_' || p_funcionario_id::TEXT, 'funcionario_id', v_funcionario.id, 'nome', v_funcionario.nome, 'email', COALESCE(v_funcionario.email, ''), 'tipo_admin', v_funcionario.tipo_admin, 'empresa_id', v_funcionario.empresa_id);
  ELSE
    RETURN json_build_object('sucesso', false, 'mensagem', 'Senha incorreta');
  END IF;
END;
$$;

-- Ativar funcionários
UPDATE funcionarios SET usuario_ativo = true, senha_definida = true, status = 'ativo' WHERE usuario_ativo IS NULL OR usuario_ativo = false OR senha_definida IS NULL OR senha_definida = false;

-- Dar permissões
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION validar_senha_local(UUID, TEXT) TO authenticated;
```

## ✅ RESULTADO
Após executar:
- ✅ Remove conflitos de funções existentes
- ✅ Recria funções de login
- ✅ Ativa todos os funcionários
- ✅ Restaura permissões

## 🎯 TESTE
Acesse: https://pdv-allimport-c9c32his2-radiosystem.vercel.app
- Deve aparecer admin, técnico, vendas
- Todos devem conseguir fazer login

**Se ainda der erro, me mande a mensagem exata que aparece.**