# 🔧 Como Corrigir Erro de Upload de Logo

## ❌ Erro que você está vendo:
```
new row violates row-level security policy
```

## 🎯 Causa do problema:
O bucket `empresa-assets` no Supabase Storage está com políticas de RLS (Row Level Security) muito restritivas que bloqueiam o upload de arquivos.

---

## ✅ SOLUÇÃO RÁPIDA (Execute este SQL no Supabase):

### Passo 1: Acesse o SQL Editor do Supabase
1. Vá para https://supabase.com/dashboard
2. Selecione seu projeto
3. Clique em **SQL Editor** (menu lateral esquerdo)

### Passo 2: Cole e Execute este SQL:

```sql
-- REMOVER POLÍTICAS ANTIGAS QUE ESTÃO BLOQUEANDO
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'objects' 
      AND schemaname = 'storage'
      AND policyname LIKE '%empresa%'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', pol.policyname);
  END LOOP;
END $$;

-- CRIAR POLÍTICAS PERMISSIVAS SIMPLES
CREATE POLICY "empresa_assets_insert"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'empresa-assets');

CREATE POLICY "empresa_assets_update"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'empresa-assets')
WITH CHECK (bucket_id = 'empresa-assets');

CREATE POLICY "empresa_assets_select"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'empresa-assets');

CREATE POLICY "empresa_assets_delete"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'empresa-assets');

-- VERIFICAR SE FUNCIONOU
SELECT 
  policyname,
  cmd as operacao,
  CASE 
    WHEN roles::text = '{authenticated}' THEN '🔐 Autenticados'
    WHEN roles::text = '{public}' THEN '🌐 Público'
    ELSE roles::text 
  END as quem_pode
FROM pg_policies 
WHERE tablename = 'objects' 
  AND schemaname = 'storage'
  AND policyname LIKE '%empresa%'
ORDER BY policyname;
```

### Passo 3: Verificar o resultado
Você deve ver 4 políticas criadas:
- ✅ `empresa_assets_insert` - INSERT - 🔐 Autenticados
- ✅ `empresa_assets_update` - UPDATE - 🔐 Autenticados  
- ✅ `empresa_assets_select` - SELECT - 🌐 Público
- ✅ `empresa_assets_delete` - DELETE - 🔐 Autenticados

---

## 🧪 Testar após executar o SQL:

1. Volte para o sistema PDV
2. Vá em **Configurações → Empresa**
3. Clique em **"Escolher arquivo"** para logo
4. Selecione uma imagem (PNG, JPG ou GIF - máx 2MB)
5. Deve funcionar! ✅

---

## 📋 O que as políticas fazem:

| Operação | Quem pode | O que faz |
|----------|-----------|-----------|
| **INSERT** | Usuários autenticados | Fazer upload de novas logos |
| **UPDATE** | Usuários autenticados | Atualizar/sobrescrever logos existentes |
| **SELECT** | Qualquer pessoa (público) | Ver/baixar as logos |
| **DELETE** | Usuários autenticados | Deletar logos antigas |

---

## 🔍 Se ainda não funcionar:

### Opção 1: Verificar se o bucket existe
```sql
SELECT name, public, file_size_limit, allowed_mime_types 
FROM storage.buckets 
WHERE name = 'empresa-assets';
```

**Deve retornar:**
- `name`: empresa-assets
- `public`: true
- `file_size_limit`: 2097152 (2MB)
- `allowed_mime_types`: {image/png,image/jpeg,image/webp}

### Opção 2: Recriar o bucket (se não existir)
```sql
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'empresa-assets',
  'empresa-assets',
  true,
  2097152,
  ARRAY['image/png', 'image/jpeg', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO NOTHING;
```

### Opção 3: Desabilitar RLS temporariamente (APENAS PARA TESTES!)
```sql
-- ⚠️ Use apenas para testar! Não deixe assim em produção!
ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- Testar upload...

-- Depois reative:
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
```

---

## 📝 Arquivo SQL completo:
Veja o arquivo `CORRIGIR_RLS_BUCKET_LOGO.sql` para todas as opções.

---

## 💡 Dica:
As políticas RLS são importantes para segurança, mas precisam ser configuradas corretamente. As políticas que criamos acima são:
- ✅ Seguras (apenas autenticados podem fazer upload)
- ✅ Permissivas o suficiente (não bloqueiam uploads legítimos)
- ✅ Públicas para leitura (logos precisam ser vistas por todos)

**Dúvidas?** Teste e me diga o resultado! 🚀
