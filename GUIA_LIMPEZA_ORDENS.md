# 🧹 Guia de Limpeza - Ordens de Serviço Incorretas

Criei **2 opções** para limpar as 162 ordens com dados incorretos:

## 🎯 **OPÇÃO 1: SQL Direto no Supabase (Recomendado)**

### **Arquivo:** `limpar-ordens-incorretas.sql`

**Como usar:**
1. **Acesse o Supabase Dashboard**
2. **Vá para "SQL Editor"**
3. **Cole e execute cada seção por vez:**

#### **Passo 1: Verificar quantas serão excluídas**
```sql
SELECT COUNT(*) as total_ordens_para_excluir FROM ordens_servico WHERE...
```

#### **Passo 2: Ver exemplos das ordens**
```sql
SELECT id, numero_os, equipamento, marca... FROM ordens_servico WHERE...
```

#### **Passo 3: Exclusão definitiva**
- Descomente o bloco `DELETE FROM ordens_servico WHERE...`
- Execute apenas se tiver certeza

---

## 💻 **OPÇÃO 2: Script Node.js**

### **Arquivo:** `limpar-ordens-script.js`

**Como usar:**
1. **Configure as credenciais do Supabase** no arquivo
2. **Instale dependências:**
   ```bash
   npm install @supabase/supabase-js
   ```
3. **Execute:**
   ```bash
   node limpar-ordens-script.js
   ```

---

## ⚠️ **CRITÉRIOS DE EXCLUSÃO**

O script remove ordens que atendem **TODOS** os critérios:

✅ **Marca** = null, "Não informado" ou vazio  
✅ **Modelo** = null, "Não informado" ou vazio  
✅ **Valor** = null ou 0  
✅ **Cliente ID** = null  
✅ **Descrição do problema** = "Problema não informado", "Não informado" ou vazio

---

## 🛡️ **MEDIDAS DE SEGURANÇA**

1. **📊 Contagem prévia**: Mostra quantas ordens serão afetadas
2. **👀 Visualização**: Exibe exemplos antes da exclusão
3. **🔒 Comentários**: Exclusão vem comentada (precisa descomentar)
4. **📝 Log detalhado**: Mostra o que está sendo feito

---

## 📋 **FLUXO RECOMENDADO**

### **1. Primeira execução (só visualizar):**
```
🔍 Executar contagem → Ver 162 ordens serão excluídas
📋 Ver exemplos → Confirmar que são as certas
```

### **2. Se estiver correto (executar exclusão):**
```
🗑️ Descomentar bloco DELETE
✅ Executar exclusão → 162 ordens removidas
📊 Verificar resultado → Base limpa
```

### **3. Importar backup correto:**
```
📁 Usar teste-backup-campos-obrigatorios.json
✅ Verificar dados aparecem corretos
🎉 Importar backup completo
```

---

## 🚨 **IMPORTANTE**

- ⚠️ **Não há volta**: Exclusão é permanente
- 💾 **Backup opcional**: Se quiser, exporte antes
- 🎯 **Muito específico**: Só remove ordens realmente vazias
- ✅ **Seguro**: Ordens com qualquer dado válido são preservadas

**Qual opção prefere usar? SQL direto ou script Node.js?**
