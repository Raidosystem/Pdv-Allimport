# 🔧 SOLUÇÃO: Erro "Could not find the function trocar_senha_propria"

## 📋 Problema

```
Could not find the function public.trocar_senha_propria(p_funcionario_id, p_senha_antiga, p_senha_nova) in the schema cache
```

## ✅ Solução

A função RPC `trocar_senha_propria` não existe no banco de dados. Siga os passos abaixo:

---

## 🚀 Passo a Passo

### 1. Abra o Supabase SQL Editor
- Acesse: https://supabase.com/dashboard
- Vá em **SQL Editor**

### 2. Execute o SQL de criação
- Abra o arquivo: **`CRIAR_RPC_TROCAR_SENHA_PROPRIA.sql`**
- Copie todo o conteúdo
- Cole no SQL Editor do Supabase
- Clique em **RUN** ou pressione `Ctrl+Enter`

### 3. Verifique se funcionou
A última query do SQL vai mostrar:

```
routine_name          | routine_type | return_type
---------------------|--------------|------------
trocar_senha_propria | FUNCTION     | json
```

Se aparecer esta linha, a função foi criada com sucesso! ✅

---

## 🧪 Testar a Função (Opcional)

Após criar a função, você pode testá-la manualmente no SQL Editor:

```sql
SELECT * FROM public.trocar_senha_propria(
    'd2b6d25d-129e-4fa5-b963-d70fd3a95a87'::UUID,  -- ID do funcionário
    '123456',                                        -- Senha atual
    'novaSenha123'                                   -- Nova senha
);
```

**Resposta esperada:**
```json
{
  "success": true,
  "message": "Senha atualizada com sucesso"
}
```

---

## 📝 O que a função faz?

1. **Valida** se todos os campos foram preenchidos
2. **Verifica** se a nova senha tem pelo menos 6 caracteres
3. **Busca** o funcionário no `login_funcionarios`
4. **Valida** a senha atual usando `crypt()`
5. **Atualiza** a senha com hash bcrypt seguro
6. **Marca** `precisa_trocar_senha = FALSE`
7. **Retorna** JSON com sucesso ou erro

---

## 🔐 Parâmetros da Função

| Parâmetro          | Tipo | Descrição                           |
|--------------------|------|-------------------------------------|
| `p_funcionario_id` | UUID | ID do funcionário (tabela `funcionarios`) |
| `p_senha_antiga`   | TEXT | Senha atual para validação          |
| `p_senha_nova`     | TEXT | Nova senha (mínimo 6 caracteres)   |

---

## ⚡ Fluxo Completo no Sistema

1. **Funcionário faz login** com senha temporária
2. Sistema detecta `precisa_trocar_senha = TRUE`
3. **Redireciona** para tela de troca de senha
4. Funcionário preenche:
   - Senha atual (temporária)
   - Nova senha
   - Confirmar nova senha
5. **Frontend chama** `supabase.rpc('trocar_senha_propria', {...})`
6. **RPC valida** senha antiga e atualiza
7. **Sucesso**: Redireciona para dashboard

---

## 🚨 Erros Comuns

### Erro: "Senha atual incorreta"
- O funcionário digitou a senha temporária errada
- Verifique no banco: `SELECT senha FROM login_funcionarios WHERE funcionario_id = 'id'`

### Erro: "Funcionário não encontrado"
- O `funcionario_id` não existe ou está inativo
- Verifique: `SELECT * FROM login_funcionarios WHERE funcionario_id = 'id'`

### Erro: "A nova senha deve ter pelo menos 6 caracteres"
- Nova senha muito curta
- Validação de frontend + backend

---

## 📊 Verificar Status da Função

```sql
-- Ver todas as funções do sistema
SELECT 
    routine_name,
    routine_type,
    data_type as return_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%senha%'
ORDER BY routine_name;
```

**Funções esperadas:**
- `atualizar_senha_funcionario` - Admin atualiza senha do funcionário
- `autenticar_funcionario` - Login do funcionário
- `autenticar_funcionario_local` - Login local detalhado
- `trocar_senha_propria` - ✅ **ESTA FUNÇÃO** (funcionário troca própria senha)

---

## ✅ Checklist Final

- [ ] Executei `CRIAR_RPC_TROCAR_SENHA_PROPRIA.sql` no Supabase
- [ ] A função aparece na lista de funções
- [ ] Testei a função manualmente (opcional)
- [ ] O sistema permite trocar senha sem erros

---

## 🆘 Precisa de Ajuda?

Se o erro persistir:

1. Verifique o nome exato da função no Supabase
2. Execute: `DROP FUNCTION IF EXISTS public.trocar_senha_propria;` e recrie
3. Limpe o cache do navegador (`Ctrl+Shift+R`)
4. Verifique as permissões: `GRANT EXECUTE ON FUNCTION trocar_senha_propria TO authenticated;`

---

## 📚 Arquivos Relacionados

- **SQL**: `CRIAR_RPC_TROCAR_SENHA_PROPRIA.sql` (criar função)
- **Frontend**: `src/pages/TrocarSenhaPage.tsx` (chama a função)
- **Service**: Chama via `supabase.rpc('trocar_senha_propria', {...})`

---

🎯 **Execute o SQL agora e o erro será resolvido!**
