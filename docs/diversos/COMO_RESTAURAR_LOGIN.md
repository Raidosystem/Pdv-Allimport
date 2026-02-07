# 🔧 INSTRUÇÕES PARA RESTAURAR O SISTEMA DE LOGIN

## PROBLEMA IDENTIFICADO
Os scripts de limpeza de ontem removeram:
- ❌ Função `listar_usuarios_ativos()` - responsável por listar funcionários disponíveis
- ❌ Função `validar_senha_local()` - responsável por validar login local
- ❌ Status e permissões dos funcionários (usuario_ativo, senha_definida)

## SOLUÇÃO IMEDIATA

### 1. Acesse o Supabase Dashboard
- Vá para: https://supabase.com/dashboard
- Entre no projeto PDV Allimport
- Acesse: **SQL Editor**

### 2. Execute o Script de Restauração
- Copie TODO o conteúdo do arquivo: `RESTAURAR_LOGIN_COMPLETO.sql`
- Cole no SQL Editor
- Clique em **RUN** para executar

### 3. O que o script faz:
- ✅ Recria função `listar_usuarios_ativos()`
- ✅ Recria função `validar_senha_local()` 
- ✅ Ativa TODOS os funcionários existentes
- ✅ Define senha como configurada para todos
- ✅ Garante permissões adequadas
- ✅ Testa as funções criadas

## ALTERNATIVA RÁPIDA (Se preferir)

Se quiser algo mais direto, execute apenas estas 3 queries no SQL Editor:

```sql
-- 1. Recriar função principal
CREATE OR REPLACE FUNCTION listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID, nome TEXT, email TEXT, foto_perfil TEXT, 
  tipo_admin TEXT, senha_definida BOOLEAN, primeiro_acesso BOOLEAN
) 
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT f.id, f.nome, COALESCE(f.email, '') as email, f.foto_perfil,
         f.tipo_admin, COALESCE(f.senha_definida, false) as senha_definida,
         COALESCE(f.primeiro_acesso, true) as primeiro_acesso
  FROM funcionarios f
  WHERE f.empresa_id = p_empresa_id
    AND (f.usuario_ativo = true OR f.usuario_ativo IS NULL)
    AND (f.status = 'ativo' OR f.status IS NULL)
    AND f.senha_definida = true
  ORDER BY f.nome;
END;
$$;

-- 2. Ativar todos os funcionários
UPDATE funcionarios 
SET usuario_ativo = true, senha_definida = true, status = 'ativo'
WHERE usuario_ativo IS NULL OR usuario_ativo = false 
   OR senha_definida IS NULL OR senha_definida = false;

-- 3. Dar permissões
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION listar_usuarios_ativos(UUID) TO anon;
```

## APÓS EXECUTAR
1. Teste o login no sistema: https://pdv-allimport-c9c32his2-radiosystem.vercel.app
2. Verifique se aparecem os usuários: admin, técnico, vendas
3. Teste o login de cada tipo de usuário

## SE AINDA DER ERRO
Execute também a função de validação de senha:

```sql
CREATE OR REPLACE FUNCTION validar_senha_local(p_funcionario_id UUID, p_senha TEXT)
RETURNS TABLE (sucesso BOOLEAN, mensagem TEXT, token TEXT, funcionario_id UUID, nome TEXT, email TEXT, tipo_admin TEXT, empresa_id UUID)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE v_funcionario RECORD; v_login RECORD; v_senha_hash TEXT;
BEGIN
  SELECT * INTO v_funcionario FROM funcionarios WHERE id = p_funcionario_id;
  IF NOT FOUND THEN
    RETURN QUERY SELECT false, 'Funcionário não encontrado'::TEXT, ''::TEXT, NULL::UUID, ''::TEXT, ''::TEXT, ''::TEXT, NULL::UUID;
    RETURN;
  END IF;
  SELECT * INTO v_login FROM login_funcionarios WHERE funcionario_id = p_funcionario_id AND ativo = true LIMIT 1;
  IF NOT FOUND THEN
    v_senha_hash := crypt(p_senha, gen_salt('bf'));
    INSERT INTO login_funcionarios (funcionario_id, usuario, senha, ativo) VALUES (p_funcionario_id, v_funcionario.nome, v_senha_hash, true) RETURNING * INTO v_login;
  END IF;
  IF v_login.senha = crypt(p_senha, v_login.senha) THEN
    RETURN QUERY SELECT true, 'Login realizado com sucesso'::TEXT, 'local_token_' || p_funcionario_id::TEXT, v_funcionario.id, v_funcionario.nome, COALESCE(v_funcionario.email, ''), v_funcionario.tipo_admin, v_funcionario.empresa_id;
  ELSE
    RETURN QUERY SELECT false, 'Senha incorreta'::TEXT, ''::TEXT, NULL::UUID, ''::TEXT, ''::TEXT, ''::TEXT, NULL::UUID;
  END IF;
END;
$$;
GRANT EXECUTE ON FUNCTION validar_senha_local(UUID, TEXT) TO authenticated;
```

✅ **Isso deve resolver o problema de login dos funcionários!**