# 🔧 GUIA COMPLETO: Conectar Supabase ao PDV Allimport

## 🎯 Objetivo
Desabilitar o Row Level Security (RLS) e conectar o PDV aos produtos reais do banco de dados.

## 📋 Passo a Passo

### 1. **Acessar o Dashboard do Supabase**
- URL: https://app.supabase.com/project/kmcaaqetxtwkdcczdomw
- Faça login com sua conta

### 2. **Navegar para o SQL Editor**
- No menu lateral esquerdo, clique em **"SQL Editor"**
- Ou use a URL direta: https://app.supabase.com/project/kmcaaqetxtwkdcczdomw/sql

### 3. **Executar o Script de Correção**
- Copie todo o conteúdo do arquivo `SUPABASE_FIX_COMPLETE.sql`
- Cole no editor SQL
- Clique em **"Run"** ou pressione **Ctrl+Enter**

### 4. **Verificar os Resultados**
Você deve ver algo como:
```
produtos | 5
clientes | 0
categorias | 5
```

### 5. **Testar no PDV**
- Volte ao PDV em desenvolvimento
- Tente buscar por "Produto" ou "123456789"
- Os produtos reais devem aparecer!

## 🚨 **Script Alternativo Simples** (se o completo não funcionar)

```sql
-- Apenas desabilitar RLS
ALTER TABLE produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE categorias DISABLE ROW LEVEL SECURITY;
```

## ✅ **Como Verificar se Funcionou**

1. **No terminal do projeto:**
```bash
node test-supabase.mjs
```

2. **No PDV (navegador):**
- Abra as **Ferramentas do Desenvolvedor** (F12)
- Vá na aba **Console**
- Procure por mensagens como "✅ Produtos encontrados: X"

## 🔍 **Solução de Problemas**

### Se ainda aparecer "permission denied":
```sql
-- Tentar com GRANT
GRANT ALL ON produtos TO anon;
GRANT ALL ON clientes TO anon;
GRANT ALL ON categorias TO anon;
```

### Se as tabelas não existirem:
```sql
-- Verificar quais tabelas existem
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';
```

## 🎉 **Resultado Esperado**
Após executar o script, o PDV deve mostrar os produtos reais em vez dos produtos de teste (TEST001, TEST002, TEST003).

---
**📞 Se precisar de ajuda:** As mensagens no console do navegador e no terminal te darão mais detalhes sobre qualquer erro.
