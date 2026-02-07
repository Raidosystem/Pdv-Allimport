# 🔧 ERRO CORRIGIDO: EXECUTAR COMANDOS SEPARADAMENTE

## ❌ PROBLEMA IDENTIFICADO:
```
ERROR: ALTER SYSTEM cannot run inside a transaction block
```

## ✅ SOLUÇÃO:

Execute **CADA COMANDO SEPARADAMENTE** no SQL Editor:

---

## 🎯 PASSO 1:
Copie e execute **APENAS ISTO**:
```sql
ALTER SYSTEM SET cors.allowed_origins = 'https://pdv.crmvsystem.com,http://localhost:3000,http://localhost:5173,https://localhost:5173';
```

## 🎯 PASSO 2:
Depois copie e execute **APENAS ISTO**:
```sql
SELECT pg_reload_conf();
```

## 🎯 PASSO 3:
Para verificar, execute **APENAS ISTO**:
```sql
SHOW cors.allowed_origins;
```

---

## 🚨 IMPORTANTE:
- **NÃO execute tudo junto**
- Execute **um comando por vez**
- Clique em "RUN" após cada comando

---

## 🧪 APÓS EXECUTAR:
1. ⏱️ **Aguarde 2-3 minutos** (propagação)
2. 🧹 **Limpe cache**: `Ctrl + Shift + Delete`
3. 🧪 **Teste**: https://pdv.crmvsystem.com/

---

## 📁 ARQUIVO CRIADO:
- `cors-sql-separado.sql` - Comandos organizados por passo

**Execute os 3 comandos separadamente e deve funcionar!** 🚀
