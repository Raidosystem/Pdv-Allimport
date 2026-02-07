# 🚨 CORREÇÃO URGENTE - Erro de Recursão Infinita

## 🔥 Problema Identificado

**Erro no Console:**
```
infinite recursion detected in policy for relation "permissoes"
```

**Local:** Página de Administração > Funções e Permissões  
**Impacto:** Impede o carregamento da tela de administração de permissões

---

## ✅ Solução (Passo a Passo)

### **1. Acessar o Supabase**
1. Abra o Supabase: https://supabase.com/dashboard
2. Selecione o projeto: **Pdv-Allimport**
3. No menu lateral, clique em **SQL Editor**

### **2. Executar o Script de Correção**
1. Abra o arquivo: `FIX-RECURSAO-PERMISSOES-AGORA.sql`
2. **Copie TODO o conteúdo** do arquivo
3. No **SQL Editor** do Supabase, cole o conteúdo
4. Clique em **RUN** (ou pressione `Ctrl + Enter`)

### **3. Aguardar Resultado**
Você deve ver:
```
✅ CORREÇÃO APLICADA COM SUCESSO
================================
📊 Total de políticas: 4
📊 Total de permissões: 91
✅ Sem recursão detectada
✅ Sistema funcionando normalmente
```

### **4. Testar no Sistema**
1. Volte para o navegador
2. **Pressione `Ctrl + Shift + R`** (recarregar forçado)
3. Acesse: **Dashboard > Administração > Funções e Permissões**
4. Deve carregar normalmente ✅

---

## 🔍 O Que Foi Corrigido?

### **Problema:**
As políticas RLS da tabela `permissoes` estavam causando **recursão infinita** porque:
- Verificavam permissões dentro da própria tabela `permissoes`
- Isso criava um loop infinito: para ler permissões, precisa verificar permissões, que precisa verificar permissões...

### **Solução:**
Criamos políticas **simples e diretas**:
- ✅ **SELECT:** Todos autenticados podem LER (permissões são metadados públicos)
- ✅ **INSERT/UPDATE/DELETE:** Apenas admins (verifica direto na tabela `empresas`, sem recursão)

---

## 📊 Políticas Criadas

| Política | Comando | Descrição |
|----------|---------|-----------|
| `permissoes_select_all` | SELECT | 📖 Todos autenticados podem ler |
| `permissoes_insert_admin_only` | INSERT | ✏️ Apenas admins podem inserir |
| `permissoes_update_admin_only` | UPDATE | 🔄 Apenas admins podem atualizar |
| `permissoes_delete_admin_only` | DELETE | 🗑️ Apenas admins podem deletar |

---

## ⚠️ Se Ainda Houver Erro

### **Verificar políticas manualmente:**
```sql
-- No SQL Editor do Supabase, execute:
SELECT 
  policyname,
  cmd,
  CASE cmd 
    WHEN 'SELECT' THEN '📖 Leitura'
    WHEN 'INSERT' THEN '✏️ Inserção'
    WHEN 'UPDATE' THEN '🔄 Atualização'
    WHEN 'DELETE' THEN '🗑️ Exclusão'
  END as tipo
FROM pg_policies
WHERE tablename = 'permissoes'
  AND schemaname = 'public'
ORDER BY cmd;
```

**Deve retornar exatamente 4 políticas.**

### **Testar query:**
```sql
-- Deve executar sem erro:
SELECT COUNT(*) FROM public.permissoes;
```

---

## 🎯 Resultado Esperado

Após executar o script:
- ✅ Página de Administração carrega normalmente
- ✅ Funções e Permissões acessível
- ✅ Sem erro 500 no console
- ✅ Sem mensagem de recursão infinita

---

## 📞 Suporte

Se o erro persistir:
1. Tire print do console (F12)
2. Tire print do resultado do SQL
3. Entre em contato com suporte

---

**Data:** 01/12/2025  
**Versão:** 2.2.3  
**Status:** 🔥 URGENTE - Correção Crítica
