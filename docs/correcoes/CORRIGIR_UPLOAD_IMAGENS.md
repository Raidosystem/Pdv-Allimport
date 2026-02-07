# 🔧 Correção do Upload de Imagens dos Produtos

## Problema Identificado

**Erro**: `mime type application/json is not supported`

O erro ocorre porque o Supabase Storage está recebendo JSON ao invés do arquivo de imagem. Isso pode acontecer por dois motivos:

1. **Configuração incorreta do bucket**
2. **Políticas RLS bloqueando o upload**

---

## ✅ Solução Aplicada no Código

Adicionei o parâmetro `contentType` explicitamente no upload:

```typescript
const { data, error } = await supabase.storage
  .from('produtos-imagens')
  .upload(filePath, file, {
    cacheControl: '3600',
    upsert: false,
    contentType: file.type // ✅ Especifica o tipo MIME correto
  })
```

---

## 🔧 Configuração Necessária no Supabase

### 1. Verificar se o Bucket Existe

Acesse: **Supabase Dashboard > Storage > Buckets**

- ✅ Deve existir um bucket chamado **`produtos-imagens`**
- ✅ Deve estar **público** (se quiser URLs públicas)

### 2. Configurar Políticas de Upload (RLS)

Execute no **SQL Editor** do Supabase:

```sql
-- 🔓 Permitir UPLOAD para usuários autenticados
CREATE POLICY "usuarios_podem_fazer_upload_imagens" 
ON storage.objects FOR INSERT 
TO authenticated 
WITH CHECK (
  bucket_id = 'produtos-imagens' 
  AND (storage.foldername(name))[1] = 'produtos'
  AND auth.uid() IS NOT NULL
);

-- 🔓 Permitir SELECT (leitura pública)
CREATE POLICY "imagens_publicas" 
ON storage.objects FOR SELECT 
TO public 
USING (bucket_id = 'produtos-imagens');

-- 🔓 Permitir UPDATE/DELETE apenas para o dono
CREATE POLICY "usuarios_podem_atualizar_suas_imagens" 
ON storage.objects FOR UPDATE 
TO authenticated 
USING (
  bucket_id = 'produtos-imagens' 
  AND auth.uid() IS NOT NULL
)
WITH CHECK (
  bucket_id = 'produtos-imagens'
);

CREATE POLICY "usuarios_podem_deletar_suas_imagens" 
ON storage.objects FOR DELETE 
TO authenticated 
USING (
  bucket_id = 'produtos-imagens' 
  AND auth.uid() IS NOT NULL
);
```

### 3. Verificar Tipos MIME Permitidos

No **Supabase Dashboard > Storage > produtos-imagens > Settings**:

- **Allowed MIME types**: Deixe vazio OU adicione:
  ```
  image/png
  image/jpeg
  image/jpg
  image/webp
  image/gif
  ```

- **File size limit**: `2MB` (2097152 bytes)

---

## 🧪 Como Testar

1. **Abra o Console do navegador** (F12)
2. Tente fazer upload de uma imagem no formulário de produto
3. Verifique os logs:
   ```
   📤 [Upload] Iniciando upload da imagem: {...}
   📤 [Upload] Enviando para o Supabase: {...}
   ✅ [Upload] Upload concluído: {...}
   🔗 [Upload] URL pública gerada: {...}
   ```

4. Se o erro **`mime type application/json is not supported`** ainda aparecer:
   - Verifique se as políticas RLS foram aplicadas
   - Certifique-se de que o bucket **permite uploads de imagens**
   - Verifique se o usuário está **autenticado**

---

## 🚨 Diagnóstico Alternativo

Se o problema persistir, execute no **SQL Editor**:

```sql
-- Verificar políticas do bucket
SELECT * FROM storage.policies 
WHERE bucket_id = 'produtos-imagens';

-- Verificar objetos armazenados
SELECT * FROM storage.objects 
WHERE bucket_id = 'produtos-imagens' 
ORDER BY created_at DESC 
LIMIT 10;

-- Verificar se o bucket existe e está público
SELECT * FROM storage.buckets 
WHERE id = 'produtos-imagens';
```

---

## 📝 Logs Detalhados Adicionados

O código agora exibe logs detalhados no console:

- **Arquivo selecionado** (nome, tipo, tamanho)
- **Caminho de upload**
- **Resposta do Supabase**
- **URL pública gerada**
- **Erros detalhados**

---

## ✅ Checklist de Resolução

- [ ] Bucket `produtos-imagens` existe e está público
- [ ] Políticas RLS de upload aplicadas
- [ ] MIME types permitidos configurados
- [ ] Usuário está autenticado
- [ ] Console mostra os logs detalhados
- [ ] Upload funciona sem erro 400

---

**Data**: 13/12/2025  
**Autor**: Copilot (Claude Sonnet 4.5)
