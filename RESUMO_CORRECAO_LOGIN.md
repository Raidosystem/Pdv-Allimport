# 🔧 Correção do Sistema de Login Local

## 🐛 Problema Identificado

O erro no console mostrava:

```
POST .../rpc/validar_senha_local 404 (Not Found)
Could not find the function public.validar_senha_local(p_funcionario_id, p_senha)
Perhaps you meant to call public.validar_senha_local(p_senha, p_usuario)
```

### Causa Raiz

Havia um **desalinhamento arquitetural** entre as funções SQL e o código TypeScript:

1. **`listar_usuarios_ativos()`** retornava campos da tabela `funcionarios` (sem campo `usuario`)
2. **`validar_senha_local()`** esperava o campo `usuario` da tabela `login_funcionarios`
3. **TypeScript** estava enviando `p_funcionario_id` (UUID) ao invés de `p_usuario` (TEXT)

## ✅ Soluções Aplicadas

### 1. SQL: Adicionar campo 'usuario' em `listar_usuarios_ativos()`

**Arquivo:** `CORRIGIR_LOGIN_USUARIO_CAMPO.sql`

```sql
CREATE OR REPLACE FUNCTION public.listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  email TEXT,
  foto_perfil TEXT,
  tipo_admin TEXT,
  senha_definida BOOLEAN,
  primeiro_acesso BOOLEAN,
  usuario TEXT  -- ⭐ NOVO CAMPO
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id,
    f.nome,
    f.email,
    f.foto_perfil,
    f.tipo_admin,
    f.senha_definida,
    f.primeiro_acesso,
    COALESCE(lf.usuario, f.email) as usuario  -- ⭐ JOIN com login_funcionarios
  FROM public.funcionarios f
  LEFT JOIN public.login_funcionarios lf ON lf.funcionario_id = f.id AND lf.ativo = true
  WHERE f.empresa_id = p_empresa_id
    AND f.usuario_ativo = true
    AND f.senha_definida = true
  ORDER BY 
    CASE WHEN f.tipo_admin = 'admin_empresa' THEN 0 ELSE 1 END,
    f.nome;
END;
$$;
```

### 2. TypeScript: Atualizar interface `LocalUser`

**Arquivo:** `src/modules/auth/LocalLoginPage.tsx`

```typescript
interface LocalUser {
  id: string
  nome: string
  email: string
  foto_perfil: string | null
  tipo_admin: string
  senha_definida: boolean
  primeiro_acesso: boolean
  usuario: string  // ⭐ NOVO CAMPO
}
```

### 3. TypeScript: Corrigir chamada RPC `validar_senha_local`

**Antes:**
```typescript
const { data, error } = await supabase
  .rpc('validar_senha_local', {
    p_funcionario_id: usuarioSelecionado.id,  // ❌ ERRADO
    p_senha: senha
  })
```

**Depois:**
```typescript
const { data, error } = await supabase
  .rpc('validar_senha_local', {
    p_usuario: usuarioSelecionado.usuario,  // ✅ CORRETO
    p_senha: senha
  })
```

### 4. TypeScript: Corrigir tratamento da resposta

**Antes:**
```typescript
if (!data || !data.sucesso) {  // ❌ Campo errado
  toast.error(data?.mensagem || 'Senha incorreta')
  // ...
}

const userData = data
toast.success(`Bem-vindo, ${userData.nome}!`)  // ❌ Estrutura errada
```

**Depois:**
```typescript
if (!data || !data.success) {  // ✅ Campo correto
  toast.error(data?.error || 'Senha incorreta')
  // ...
}

const funcionarioData = data.funcionario  // ✅ Extrair objeto 'funcionario'
toast.success(`Bem-vindo, ${funcionarioData.nome}!`)
```

## 📋 Estrutura de Retorno de `validar_senha_local()`

```json
{
  "success": true,
  "funcionario": {
    "id": "uuid",
    "empresa_id": "uuid",
    "nome": "string",
    "email": "string",
    "telefone": "string",
    "cargo": "string",
    "funcao_id": "uuid",
    "funcao_nome": "string",
    "funcao_nivel": number,
    "permissoes": []
  },
  "login_id": "uuid"
}
```

Ou em caso de erro:

```json
{
  "success": false,
  "error": "Mensagem de erro"
}
```

## 🚀 Passos para Aplicar

1. **Executar no Supabase SQL Editor:**
   ```bash
   # Executar arquivo CORRIGIR_LOGIN_USUARIO_CAMPO.sql
   ```

2. **O código TypeScript já foi atualizado automaticamente**

3. **Testar o fluxo de login:**
   - Acessar página de login local
   - Selecionar usuário
   - Inserir senha
   - Verificar se login é bem-sucedido

## 🔍 Verificação

Após aplicar as correções, o fluxo correto será:

1. `listar_usuarios_ativos()` retorna lista com campo `usuario`
2. Frontend envia `{ p_usuario: "nome_usuario", p_senha: "123456" }`
3. `validar_senha_local()` valida credenciais
4. Retorna `{ success: true, funcionario: {...} }`
5. Frontend salva sessão e redireciona para dashboard

## ⚠️ Observações Importantes

- O campo `usuario` vem da tabela `login_funcionarios` (não de `funcionarios`)
- Se não houver registro em `login_funcionarios`, usa `email` como fallback
- A função SQL usa `crypt()` para validar senha com bcrypt
- O retorno usa `success` (não `sucesso`) e `error` (não `mensagem`)
