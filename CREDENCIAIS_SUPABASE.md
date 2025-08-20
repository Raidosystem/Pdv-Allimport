# 🔑 COMO ENCONTRAR SUAS CREDENCIAIS DO SUPABASE

## Passo a Passo para Acessar Diretamente:

### 1. Acessar o Dashboard
- Vá para: https://supabase.com/dashboard
- Faça login na sua conta
- Selecione seu projeto (PDV AllImport)

### 2. Encontrar as Credenciais

#### Opção A - API Keys:
1. No menu lateral, clique em **"Settings"**
2. Clique em **"API"**
3. Copie:
   - **Project URL**: `https://seu-project-ref.supabase.co`
   - **anon/public key**: Para acesso normal
   - **service_role key**: Para bypass do RLS (mais poderoso)

#### Opção B - String de Conexão PostgreSQL:
1. No menu lateral, clique em **"Settings"**  
2. Clique em **"Database"**
3. Role até **"Connection parameters"**
4. Copie a **Connection string**

### 3. Usar o SQL Editor (MAIS FÁCIL)
1. No dashboard do Supabase
2. Clique em **"SQL Editor"** no menu lateral
3. Clique em **"New Query"**
4. Cole este SQL:

```sql
-- VERIFICAR DADOS INSERIDOS
SELECT 'Total produtos:' as info, COUNT(*) as quantidade FROM products;
SELECT 'Produtos ALLIMPORT:' as info, COUNT(*) as quantidade FROM products WHERE name LIKE 'ALLIMPORT%';

-- LISTAR ALGUNS PRODUTOS
SELECT name FROM products ORDER BY created_at DESC LIMIT 10;

-- VERIFICAR SE RLS ESTÁ BLOQUEANDO
SELECT tablename, rowsecurity as rls_ativo FROM pg_tables WHERE tablename = 'products';
```

### 4. Se os dados não aparecem no PDV mas existem no SQL:

**Problema = RLS (Row Level Security)**

Execute este SQL para desabilitar temporariamente:
```sql
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE clients DISABLE ROW LEVEL SECURITY;
ALTER TABLE categories DISABLE ROW LEVEL SECURITY;
```

## 🎯 Me diga o resultado do SQL acima!

Depois que executar no SQL Editor, me mande o resultado para eu entender se:
1. Os dados estão no banco ✅
2. RLS está bloqueando ❌  
3. Problema está no frontend ❌
