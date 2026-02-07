# 🔧 Problema: "User already registered" após deletar usuário

## 🎯 Situação
- **CPF**: 28219618809
- **Email**: cris-ramos30@hotmail.com
- **Erro**: `User already registered` (código: `user_already_exists`)
- **Problema**: Sistema diz que email já está cadastrado

## 🔍 Causa Raiz

O erro **"User already registered"** significa que o email **AINDA EXISTE** na tabela `auth.users` do Supabase.

**Possíveis cenários:**

1. **Usuário não foi deletado** - Ainda existe no auth.users
2. **Soft delete** - Usuário foi "deletado" mas não removido fisicamente
3. **Registro órfão** - Existe em `empresas` sem usuário em `auth.users`

**O que precisa ser limpo:**
- ❌ Registro em `auth.users` (bloqueia email)
- ❌ Registro em `empresas` (bloqueia CPF)
- ❌ Registros relacionados (vendas, produtos, etc.)

## 🛠️ Solução

### Opção 1: SQL Editor do Supabase (Recomendado)

1. Acesse: https://supabase.com/dashboard/project/byjwcuqecojxqcvrljjv/sql/new
2. Cole o script `limpar-cpf-28219618809.sql`
3. Execute (clique em "RUN")
4. Tente cadastrar novamente

### Opção 2: Via Tabela Manual

1. Acesse: https://supabase.com/dashboard/project/byjwcuqecojxqcvrljjv/editor
2. Abra a tabela `empresas`
3. Procure por CPF: `28219618809`
4. Delete todas as linhas encontradas
5. Tente cadastrar novamente

## ✅ Verificação

Após executar a limpeza, teste:

```sql
SELECT validate_document_uniqueness('28219618809');
```

**Resultado esperado:**
```json
{
  "valid": true,
  "document_type": "CPF",
  "message": "CPF disponível para cadastro"
}
```

## 🚨 Prevenção Futura

### Para deletar usuários CORRETAMENTE:

**❌ NÃO faça assim:**
- Dashboard do Supabase → Authentication → Delete User (deleta só do auth)

**✅ FAÇA assim:**

1. **Via SQL Editor** (deleta de tudo):
```sql
-- Encontrar user_id
SELECT user_id, email, nome FROM empresas 
WHERE LOWER(email) = LOWER('email@exemplo.com');

-- Deletar TUDO relacionado
DELETE FROM vendas WHERE empresa_id = 'USER_ID_AQUI';
DELETE FROM produtos WHERE empresa_id = 'USER_ID_AQUI';
DELETE FROM clientes WHERE empresa_id = 'USER_ID_AQUI';
DELETE FROM funcionarios WHERE empresa_id = 'USER_ID_AQUI';
DELETE FROM empresas WHERE user_id = 'USER_ID_AQUI';

-- Por último, deletar do auth
-- (Só no Dashboard: Authentication → Users → Delete)
```

2. **Ou criar uma função RPC** para deletar tudo de uma vez:

```sql
CREATE OR REPLACE FUNCTION delete_company_cascade(p_email text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Buscar user_id
  SELECT user_id INTO v_user_id
  FROM empresas
  WHERE LOWER(TRIM(email)) = LOWER(TRIM(p_email))
  LIMIT 1;
  
  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'message', 'Empresa não encontrada'
    );
  END IF;
  
  -- Deletar tudo em cascata
  DELETE FROM vendas WHERE empresa_id = v_user_id;
  DELETE FROM produtos WHERE empresa_id = v_user_id;
  DELETE FROM clientes WHERE empresa_id = v_user_id;
  DELETE FROM funcionarios WHERE empresa_id = v_user_id;
  DELETE FROM empresas WHERE user_id = v_user_id;
  
  RETURN json_build_object(
    'success', true,
    'message', 'Empresa deletada com sucesso',
    'user_id', v_user_id
  );
END;
$$;

-- Usar assim:
SELECT delete_company_cascade('cris-ramos30@hotmail.com');
```

## 📊 Verificar Registros Órfãos no Sistema

```sql
-- Ver TODOS os registros órfãos
SELECT 
  e.user_id,
  e.email,
  e.nome,
  e.cnpj,
  e.created_at
FROM empresas e
LEFT JOIN auth.users u ON u.id = e.user_id
WHERE u.id IS NULL
ORDER BY e.created_at DESC;

-- Limpar TODOS os órfãos (CUIDADO!)
DELETE FROM empresas 
WHERE user_id NOT IN (SELECT id FROM auth.users);
```

## 🎯 Resumo

1. ✅ Execute `limpar-cpf-28219618809.sql`
2. ✅ Tente cadastrar novamente
3. ✅ Use a função `delete_company_cascade` para deletar no futuro
4. ✅ Monitore registros órfãos periodicamente
