# 🔄 CORS VIA SQL NÃO FUNCIONA NO SUPABASE

## ❌ PROBLEMA:
```
ERROR: ALTER SYSTEM cannot run inside a transaction block
```

**Explicação**: O Supabase não permite `ALTER SYSTEM` porque é PostgreSQL gerenciado.

---

## 🎯 NOVA ESTRATÉGIA: TESTAR SEM RLS

O problema pode não ser CORS, mas **RLS (Row Level Security)** bloqueando acesso.

### 🚀 EXECUTE NO SQL EDITOR:

**PASSO 1** - Desabilitar RLS temporariamente:
```sql
ALTER TABLE public.clientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_venda DISABLE ROW LEVEL SECURITY;
```

**PASSO 2** - Limpar sessões:
```sql
DELETE FROM auth.sessions;
DELETE FROM auth.refresh_tokens;
```

**PASSO 3** - Confirmar emails:
```sql
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email_confirmed_at IS NULL;
```

---

## 🧪 TESTE:

1. **Execute os comandos acima**
2. **Aguarde 2 minutos**
3. **Limpe cache**: `Ctrl + Shift + Delete`
4. **Teste**: https://pdv.crmvsystem.com/

---

## 💡 SE FUNCIONAR:

O problema era **RLS**, não CORS! Aí reabilitamos RLS com políticas corretas.

## 💡 SE NÃO FUNCIONAR:

Tentamos configurar CORS via arquivo de configuração do projeto.

---

## 📁 ARQUIVOS:
- `alternativa-rls.sql` - Comandos para testar sem RLS

**Teste primeiro desabilitando RLS!** 🚀
