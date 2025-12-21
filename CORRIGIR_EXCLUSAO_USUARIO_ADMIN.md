# 🔧 Como Corrigir Erro ao Excluir Usuário no Admin

## 🚨 Problema
```
AuthApiError: User not allowed (403)
```

Ao tentar excluir usuário no painel admin, o sistema retorna erro 403 porque a API `supabase.auth.admin.deleteUser()` requer **service_role key**, não pode usar **anon key**.

## ✅ Solução

### 1️⃣ Criar Função SQL no Supabase

1. Acesse o **SQL Editor** do Supabase
2. Execute o arquivo `CRIAR_FUNCAO_DELETE_USER.sql`

```sql
-- Esta função usa SECURITY DEFINER para ter acesso privilegiado
CREATE OR REPLACE FUNCTION delete_user_account(target_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Apenas novaradiosystem@outlook.com pode executar
  IF NOT EXISTS (
    SELECT 1 FROM auth.users
    WHERE id = auth.uid()
    AND email = 'novaradiosystem@outlook.com'
  ) THEN
    RAISE EXCEPTION 'Acesso negado';
  END IF;

  DELETE FROM auth.users WHERE id = target_user_id;
  
  RETURN json_build_object('success', true);
END;
$$;
```

### 2️⃣ Código Frontend Atualizado

O código já foi atualizado em `src/components/admin/AdminDashboard.tsx`:

```typescript
// ❌ ANTES (não funciona - precisa service_role)
await supabase.auth.admin.deleteUser(subscriber.user_id)

// ✅ DEPOIS (funciona - usa RPC com SECURITY DEFINER)
await supabase.rpc('delete_user_account', {
  target_user_id: subscriber.user_id
})
```

### 3️⃣ Fluxo de Exclusão

1. Frontend solicita exclusão
2. Supabase verifica se usuário é `novaradiosystem@outlook.com`
3. Se sim, executa DELETE no `auth.users` com privilégios elevados
4. Retorna sucesso/erro

## 🛡️ Segurança

- ✅ Apenas super admin pode executar
- ✅ Função usa `SECURITY DEFINER` (owner privileges)
- ✅ Validação no SQL antes de deletar
- ✅ Service role key NÃO exposta no frontend

## 🧪 Teste

1. Login como `novaradiosystem@outlook.com`
2. Acesse Admin > Painel de Assinaturas
3. Clique em "Excluir" em qualquer usuário
4. Digite o email para confirmar
5. ✅ Deve excluir com sucesso

## 📝 Ordem de Execução

1. ✅ Execute `CRIAR_FUNCAO_DELETE_USER.sql` no Supabase
2. ✅ Deploy do código frontend (já feito)
3. ✅ Teste a exclusão
