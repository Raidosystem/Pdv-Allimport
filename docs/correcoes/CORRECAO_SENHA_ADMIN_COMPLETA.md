# 🔧 CORREÇÃO: Sistema de Troca de Senha pelo Admin

## 🚨 Problema Identificado

Quando o admin trocava a senha de um funcionário na seção "Usuários":

1. ✅ A senha era atualizada corretamente no banco (bcrypt)
2. ❌ **A flag `precisa_trocar_senha` NÃO era definida como `TRUE`**
3. ❌ O funcionário conseguia fazer login com a senha "123456" sem ser forçado a trocar
4. ❌ Nenhum modal de "definir nova senha" era exibido

## 🔍 Causa Raiz

A função RPC `atualizar_senha_funcionario` estava assim:

```sql
UPDATE login_funcionarios
SET 
    senha_hash = crypt(p_nova_senha, gen_salt('bf')),
    updated_at = NOW()
WHERE funcionario_id = p_funcionario_id;
```

**Faltava:** `precisa_trocar_senha = TRUE`

## ✅ Solução Implementada

### 1. **Atualizar RPC no Banco de Dados**

Executar o script: `CORRIGIR_RPC_ATUALIZAR_SENHA_COM_FLAG.sql`

```sql
UPDATE login_funcionarios
SET 
    senha_hash = crypt(p_nova_senha, gen_salt('bf')),
    precisa_trocar_senha = TRUE,  -- 🔑 ADICIONAR ESTA LINHA
    updated_at = NOW()
WHERE funcionario_id = p_funcionario_id;
```

### 2. **Atualizar Interface do Admin** (`AdminUsersPage.tsx`)

#### Mudanças:

1. **Label do checkbox:**
   - ❌ Antes: "Alterar senha"
   - ✅ Agora: "Definir nova senha temporária"

2. **Label do campo:**
   - ❌ Antes: "Nova Senha"
   - ✅ Agora: "Nova Senha Temporária"

3. **Aviso visual adicionado:**
   ```
   ⚠️ Senha Temporária: O funcionário será obrigado a trocar a senha 
   no próximo login por uma senha pessoal e segura.
   ```

4. **Mensagem de sucesso:**
   - ❌ Antes: "Usuário e senha atualizados com sucesso!"
   - ✅ Agora: "Senha temporária definida! O funcionário deverá trocar a senha no próximo login."

## 🔄 Fluxo Correto Agora

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Admin acessa "Usuários" → Editar Funcionário            │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Admin marca "Definir nova senha temporária"             │
│    Digite: "123456" (exemplo)                               │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Sistema executa RPC atualizar_senha_funcionario         │
│    • senha_hash = crypt('123456', gen_salt('bf'))           │
│    • precisa_trocar_senha = TRUE  ✅                        │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Mensagem: "Senha temporária definida! O funcionário     │
│    deverá trocar a senha no próximo login."                 │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Funcionário faz login com "123456"                       │
│    • Sistema verifica: precisa_trocar_senha = TRUE          │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. 🔄 REDIRECIONA PARA /trocar-senha                        │
│    • Modal exibido: "Defina sua senha pessoal"             │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. Funcionário define senha nova (ex: "minhasenha@2024")   │
│    • Sistema valida senha antiga ("123456")                 │
│    • Atualiza com nova senha                                │
│    • precisa_trocar_senha = FALSE ✅                        │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 8. ✅ SUCESSO! Funcionário redirecionado para /login       │
│    Faz login com a senha pessoal e segura                   │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Checklist de Execução

### No Supabase (SQL Editor):

- [ ] 1. Executar `CORRIGIR_RPC_ATUALIZAR_SENHA_COM_FLAG.sql`
- [ ] 2. Verificar se a função foi atualizada:
  ```sql
  SELECT routine_name, routine_definition 
  FROM information_schema.routines 
  WHERE routine_name = 'atualizar_senha_funcionario';
  ```

### No Frontend:

- [x] 3. Arquivo `AdminUsersPage.tsx` já atualizado
- [x] 4. Arquivo `CRIAR_RPC_ATUALIZAR_SENHA.sql` já corrigido

### Teste Completo:

- [ ] 5. Admin troca senha de funcionário para "teste123"
- [ ] 6. Verificar no banco:
  ```sql
  SELECT 
      f.nome,
      lf.precisa_trocar_senha,
      lf.updated_at
  FROM login_funcionarios lf
  INNER JOIN funcionarios f ON f.id = lf.funcionario_id
  WHERE lf.usuario = 'usuario_teste';
  ```
  **Esperado:** `precisa_trocar_senha = TRUE`

- [ ] 7. Funcionário faz login com "teste123"
- [ ] 8. **Esperado:** Redirecionamento para `/trocar-senha`
- [ ] 9. Funcionário define nova senha "minhasenha@2024"
- [ ] 10. **Esperado:** Logout automático e redirecionamento para `/login`
- [ ] 11. Funcionário faz login com "minhasenha@2024"
- [ ] 12. **Esperado:** Acesso direto ao dashboard (sem modal de troca)

## 📝 Arquivos Modificados

1. ✅ `CRIAR_RPC_ATUALIZAR_SENHA.sql` - Corrigida função RPC
2. ✅ `CORRIGIR_RPC_ATUALIZAR_SENHA_COM_FLAG.sql` - Script de correção
3. ✅ `src/pages/admin/AdminUsersPage.tsx` - Interface melhorada

## 🔑 Pontos Críticos

1. **A flag `precisa_trocar_senha` DEVE ser `TRUE` após admin trocar senha**
2. **LocalLoginPage.tsx já verifica esta flag e redireciona corretamente**
3. **TrocarSenhaPage.tsx já funciona corretamente**
4. **A única parte faltando era a função RPC não definir a flag**

## ⚠️ Importante

- **Após aplicar a correção no banco**, teste imediatamente com um funcionário real
- Se ainda não funcionar, verifique logs do console no navegador
- Confirme que a flag está sendo setada no banco com a query de verificação

---

**Data:** 07/12/2025  
**Status:** ✅ CORRIGIDO
