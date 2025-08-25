# Configurar Storage de Imagens - Guia Passo a Passo

## Opção 1: Via Interface do Supabase (Recomendado)

1. **Acesse o Dashboard do Supabase**
   - Vá para [supabase.com](https://supabase.com) 
   - Faça login na sua conta
   - Selecione seu projeto

2. **Navegue para Storage**
   - No menu lateral, clique em "Storage"
   - Clique em "Create a new bucket"

3. **Criar o Bucket**
   - **Bucket name:** `product-images`
   - **Public bucket:** ✅ Marcar como público
   - **File size limit:** `5242880` (5MB)
   - **Allowed MIME types:** `image/jpeg,image/png,image/webp,image/gif`
   - Clique em "Create bucket"

4. **Configurar Políticas**
   - Clique no bucket `product-images` criado
   - Vá para a aba "Policies"
   - Clique em "Add policy"
   - **Selecione:** "Custom policy"
   - **Name:** `Public read access`
   - **Command:** `SELECT`
   - **Target roles:** `public`
   - **Using expression:** `true`
   - Salve a política

5. **Política de Upload**
   - Adicione nova política
   - **Name:** `Authenticated upload`
   - **Command:** `INSERT`
   - **Target roles:** `authenticated`
   - **Using expression:** `true`
   - Salve a política

## Opção 2: Via SQL (Se a interface não funcionar)

Execute o script `setup-product-images-bucket-simple.sql`:

```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;
```

## Opção 3: Verificação Manual

Execute esta query para verificar se o bucket existe:

```sql
SELECT * FROM storage.buckets WHERE id = 'product-images';
```

## Testando o Upload

Após configurar o bucket, teste o upload de imagem no sistema:

1. Acesse: http://localhost:5176
2. Vá em **Vendas** → **Cadastrar Novo Produto**
3. Tente fazer upload de uma imagem
4. Abra o **Console do navegador** (F12) para ver os logs
5. O upload deve funcionar sem erros

## Resolução de Problemas

### Erro: "Bucket not found"
- Verifique se o bucket foi criado corretamente
- Execute a query de verificação acima

### Erro: "Permission denied"
- Certifique-se que o bucket está marcado como público
- Verifique se as políticas foram configuradas

### Erro: "File too large"
- O limite atual é 5MB
- Ajuste o `file_size_limit` se necessário

### O sistema salva produto sem imagem
- Isto é normal quando há erro no upload
- O produto não é perdido
- Tente configurar o bucket e fazer upload novamente
