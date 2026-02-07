# 🔗 CONECTAR DIRETAMENTE AO SUPABASE - VERIFICAR TABELAS

## Opção 1: Via psql (PostgreSQL CLI)

### Instalar psql (se não tiver):
```powershell
# Windows - via Chocolatey
choco install postgresql

# Ou baixar do site oficial PostgreSQL
```

### Conectar usando a string de conexão do Supabase:
```bash
# Formato da string de conexão:
psql "postgresql://postgres.SEU_PROJECT_REF:SUA_SENHA@aws-0-us-east-1.pooler.supabase.com:5432/postgres"

# Exemplo:
psql "postgresql://postgres.abcdefghijklmnop:sua_senha_aqui@aws-0-us-east-1.pooler.supabase.com:5432/postgres"
```

### Onde encontrar as credenciais:
1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em **Settings** → **Database**
4. Copie a **Connection string** na seção "Connection parameters"

## Opção 2: Via Node.js (script direto)

Crie um arquivo `.env` com suas credenciais:
```env
SUPABASE_URL=https://seu-project-ref.supabase.co
SUPABASE_ANON_KEY=sua_anon_key_aqui
SUPABASE_SERVICE_KEY=sua_service_key_aqui
```

## Opção 3: Usar o SQL Editor do Supabase (mais fácil)

1. Acesse https://supabase.com/dashboard
2. Selecione seu projeto  
3. Clique em **SQL Editor** no menu lateral
4. Cole e execute este SQL:

```sql
-- VERIFICAÇÃO COMPLETA DAS TABELAS
SELECT 'PRODUTOS:' as tabela, COUNT(*) as total FROM products
UNION ALL  
SELECT 'CLIENTES:', COUNT(*) FROM clients
UNION ALL
SELECT 'CATEGORIAS:', COUNT(*) FROM categories;

-- LISTAR PRODUTOS RECENTES
SELECT name, created_at FROM products 
ORDER BY created_at DESC LIMIT 10;

-- VERIFICAR RLS
SELECT tablename, rowsecurity FROM pg_tables 
WHERE tablename IN ('products', 'clients', 'categories');
```

## 🚀 Qual método prefere usar?

1. **psql** (linha de comando) - precisa instalar
2. **SQL Editor do Supabase** (mais fácil) - via browser
3. **Script Node.js** - precisa das credenciais

Me diga qual prefere e eu te ajudo com os próximos passos!
