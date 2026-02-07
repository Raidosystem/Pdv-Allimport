# 🔐 Configurar Políticas RLS do Bucket

Após criar o bucket com o SQL, configure as políticas RLS via interface do Supabase.

## Passo 1: Acessar Storage Policies

1. Vá em: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/storage/policies
2. Ou no menu lateral: **Storage** → **Policies**
3. Selecione o bucket **`empresa-assets`**

## Passo 2: Adicionar Políticas

### Política 1: Public Access (Visualização)
- Clique em **"New Policy"**
- Nome: `Public Access`
- Allowed operation: **SELECT**
- Policy definition: `true`
- Clique em **"Save policy"**

### Política 2: Authenticated Upload
- Clique em **"New Policy"**
- Nome: `Authenticated users can upload`
- Allowed operation: **INSERT**
- Policy definition:
```sql
auth.uid()::text = (storage.foldername(name))[1]
```
- Clique em **"Save policy"**

### Política 3: Authenticated Update
- Clique em **"New Policy"**
- Nome: `Authenticated users can update own files`
- Allowed operation: **UPDATE**
- Policy definition:
```sql
auth.uid()::text = (storage.foldername(name))[1]
```
- Clique em **"Save policy"**

### Política 4: Authenticated Delete
- Clique em **"New Policy"**
- Nome: `Authenticated users can delete own files`
- Allowed operation: **DELETE**
- Policy definition:
```sql
auth.uid()::text = (storage.foldername(name))[1]
```
- Clique em **"Save policy"**

## ✅ Verificação

Após configurar, você deve ter 4 políticas:
1. ✅ Public Access (SELECT) 
2. ✅ Authenticated users can upload (INSERT)
3. ✅ Authenticated users can update own files (UPDATE)
4. ✅ Authenticated users can delete own files (DELETE)

## 🧪 Teste

1. Recarregue o sistema
2. Vá em "Configurações do Sistema" → "Dados da Empresa"
3. Faça upload de uma logo
4. Deve funcionar! 🎉

## ⚠️ Nota

As políticas garantem que:
- ✅ Qualquer um pode **ver** as logos (público)
- ✅ Usuários logados podem **fazer upload** apenas para suas pastas
- ✅ Usuários só podem **atualizar/deletar** seus próprios arquivos
