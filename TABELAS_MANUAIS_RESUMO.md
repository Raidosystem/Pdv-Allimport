# 📋 RESUMO: Tabelas para Inserir Manualmente no Supabase

## 🚨 IMPORTANTE: Execute na ORDEM CORRETA!

### **ORDEM 1: Tabelas Obrigatórias** 
**(Execute PRIMEIRO - arquivo: `create-missing-tables-required.sql`)**

#### 1. **Tabela CAIXA**
```sql
CREATE TABLE public.caixa (
    id UUID PRIMARY KEY,
    data_abertura TIMESTAMP WITH TIME ZONE,
    data_fechamento TIMESTAMP WITH TIME ZONE,
    saldo_inicial DECIMAL(10,2),
    saldo_final DECIMAL(10,2),
    status VARCHAR(20), -- 'aberto', 'fechado'
    user_id UUID REFERENCES auth.users(id)
);
```

#### 2. **Tabela MOVIMENTAÇÕES CAIXA**
```sql
CREATE TABLE public.movimentacoes_caixa (
    id UUID PRIMARY KEY,
    caixa_id UUID REFERENCES caixa(id),
    tipo VARCHAR(20), -- 'entrada', 'saida', 'venda'
    valor DECIMAL(10,2),
    descricao TEXT,
    user_id UUID REFERENCES auth.users(id)
);
```

#### 3. **Tabela CONFIGURAÇÕES**
```sql
CREATE TABLE public.configuracoes (
    id UUID PRIMARY KEY,
    chave VARCHAR(100), -- 'nome_loja', 'logo_url'
    valor TEXT,
    descricao TEXT,
    user_id UUID REFERENCES auth.users(id),
    UNIQUE(chave, user_id)
);
```

#### 4. **Tabela CLIENTES** (se não existir)
```sql
CREATE TABLE public.clientes (
    id UUID PRIMARY KEY,
    nome VARCHAR(255),
    email VARCHAR(255),
    telefone VARCHAR(20),
    cpf VARCHAR(14),
    endereco TEXT,
    user_id UUID REFERENCES auth.users(id)
);
```

---

### **ORDEM 2: Script Principal**
**(Execute DEPOIS - arquivo: `create-missing-tables.sql`)**

#### Cria automaticamente:
- ✅ `categorias` - Categorias de produtos
- ✅ `produtos` - Produtos do estoque
- ✅ `vendas` - Vendas realizadas
- ✅ `itens_venda` - Itens das vendas
- ✅ `user_backups` - Backups dos usuários

#### Configura automaticamente:
- 🔒 **RLS** em todas as tabelas
- 🔄 **Triggers** para user_id automático
- 📦 **Funções de backup/restore**
- 🛡️ **Permissões de segurança**

---

## 🎯 Por que essa ordem?

### ❌ **Se executar na ordem errada:**
- Erro: "relation caixa does not exist"
- Erro: "function set_user_id() does not exist"
- Backup não funcionará corretamente

### ✅ **Executando na ordem correta:**
- Todas as dependências resolvidas
- Sistema funciona completamente
- Backup e privacidade ativos

---

## 🚀 Comandos de Deploy

### 1. **Acesse Supabase Dashboard:**
```
https://supabase.com/dashboard/project/[SEU_PROJECT_ID]
```

### 2. **Vá para SQL Editor**

### 3. **Execute PRIMEIRO:**
Copie e cole todo conteúdo de: `create-missing-tables-required.sql`

### 4. **Execute DEPOIS:**
Copie e cole todo conteúdo de: `create-missing-tables.sql`

### 5. **Execute para backup automático (opcional):**
```sql
SELECT cron.schedule('daily-user-backup', '0 2 * * *', 'SELECT public.daily_backup_all_users();');
```

---

## ✅ Verificação Final

Execute para confirmar que tudo funcionou:

```sql
-- Verificar tabelas criadas
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'caixa', 'movimentacoes_caixa', 'configuracoes', 
    'clientes', 'categorias', 'produtos', 'vendas', 
    'itens_venda', 'user_backups'
);

-- Testar backup
SELECT public.save_backup_to_database();

-- Verificar resultado
SELECT 'Sistema PDV configurado com sucesso!' as status;
```

---

**🎉 Pronto! Seu PDV terá privacidade total e backup automático funcionando!**
