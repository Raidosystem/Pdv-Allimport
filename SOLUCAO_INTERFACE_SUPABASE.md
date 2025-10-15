# 🔧 SOLUÇÃO: Desabilitar RLS via Interface do Supabase

## ❌ Erro que você viu:
```
ERROR: 42501: must be owner of table object
```

**Causa:** Você não tem permissão de owner no SQL Editor para modificar `storage.objects`.

---

## ✅ SOLUÇÃO: Use a Interface Gráfica do Supabase

### 🎯 PASSO A PASSO COMPLETO:

---

### 1️⃣ **Desabilitar RLS na tabela EMPRESAS**

1. Vá para: https://supabase.com/dashboard
2. Selecione seu projeto
3. No menu lateral, clique em **"Table Editor"** (📊)
4. Clique na tabela **`empresas`**
5. Clique no ícone **"⚙️"** (configurações) no canto superior direito
6. Procure por **"Enable Row Level Security (RLS)"**
7. **DESMARQUE** o checkbox (desabilitar RLS)
8. Clique em **"Save"**

✅ **Pronto! RLS desabilitado na tabela empresas**

---

### 2️⃣ **Desabilitar RLS na tabela SUBSCRIPTIONS**

1. Ainda no **Table Editor**
2. Clique na tabela **`subscriptions`**
3. Clique no ícone **"⚙️"** (configurações)
4. **DESMARQUE** "Enable Row Level Security (RLS)"
5. Clique em **"Save"**

✅ **Pronto! RLS desabilitado na tabela subscriptions**

---

### 3️⃣ **Desabilitar RLS na tabela USER_SETTINGS** (se existir)

1. Ainda no **Table Editor**
2. Procure pela tabela **`user_settings`**
3. Se existir, clique nela
4. Clique no ícone **"⚙️"** (configurações)
5. **DESMARQUE** "Enable Row Level Security (RLS)"
6. Clique em **"Save"**

✅ **Pronto! RLS desabilitado na tabela user_settings**

---

### 4️⃣ **Configurar STORAGE (Bucket empresa-assets)**

#### A) Verificar se o bucket existe:

1. No menu lateral, clique em **"Storage"** (📦)
2. Procure pelo bucket **`empresa-assets`**

#### B) Se o bucket NÃO EXISTE:

1. Clique em **"Create a new bucket"**
2. **Name:** `empresa-assets`
3. **Public bucket:** ✅ **MARQUE ESTE CHECKBOX**
4. Clique em **"Create bucket"**

#### C) Se o bucket JÁ EXISTE:

1. Clique no bucket **`empresa-assets`**
2. Clique em **"Settings"** (⚙️) no topo
3. **Public bucket:** ✅ Certifique-se que está **MARCADO**
4. **File size limit:** `2097152` (2MB)
5. **Allowed MIME types:** `image/png, image/jpeg, image/jpg, image/webp, image/gif`
6. Clique em **"Save"**

#### D) Desabilitar RLS no Storage:

1. Ainda nas configurações do bucket `empresa-assets`
2. Role até a seção **"Policies"**
3. **DELETE** todas as políticas existentes (clique no ❌ de cada uma)
4. Ou clique em **"Add Policy"** → **"For full customization"**
5. Cole este código:

```sql
CREATE POLICY "Permitir tudo no bucket empresa-assets"
ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'empresa-assets')
WITH CHECK (bucket_id = 'empresa-assets');
```

6. Clique em **"Review"** e depois **"Save policy"**

---

### 5️⃣ **EXECUTAR SQL SIMPLES** (apenas para tabelas públicas)

Agora execute este SQL mais simples no **SQL Editor**:

```sql
-- Desabilitar RLS nas tabelas públicas
ALTER TABLE empresas DISABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions DISABLE ROW LEVEL SECURITY;

-- Verificar se funcionou
SELECT 
  tablename,
  CASE 
    WHEN rowsecurity = true THEN '🔴 RLS ATIVADO'
    ELSE '✅ RLS DESATIVADO'
  END as status
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('empresas', 'subscriptions')
ORDER BY tablename;

-- Garantir que o bucket existe e é público
INSERT INTO storage.buckets (id, name, public)
VALUES ('empresa-assets', 'empresa-assets', true)
ON CONFLICT (id) 
DO UPDATE SET public = true;

SELECT '✅ Configurações aplicadas!' as resultado;
```

---

## 🧪 **TESTAR**

Depois de fazer TODOS os passos acima:

1. **Feche** e **abra** o sistema novamente (F5)
2. Faça **login** novamente
3. Vá em **Configurações → Empresa**
4. Preencha os dados
5. Faça upload da logo
6. Clique em **Salvar**
7. ✅ **Deve funcionar!**

---

## 📸 **AJUDA VISUAL** (o que você deve ver)

### Na tabela empresas:
```
⚙️ Settings
├── General
│   └── Enable Row Level Security (RLS)
│       └── [ ] ← DEVE ESTAR DESMARCADO
```

### No bucket empresa-assets:
```
📦 Storage > empresa-assets > ⚙️ Settings
├── Public bucket: [✓] ← DEVE ESTAR MARCADO
├── File size limit: 2097152
└── Allowed MIME types: image/png, image/jpeg, image/jpg, image/webp, image/gif
```

---

## ❓ **Se ainda não funcionar**

Me envie:
1. Screenshot da tabela `empresas` com RLS desabilitado
2. Screenshot do bucket `empresa-assets` configurado como público
3. O erro que aparecer no console (F12 → Console)

---

**Tente seguir todos os passos acima e me diga o resultado!** 🚀
