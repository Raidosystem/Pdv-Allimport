# 🧹 Guia: Limpar Usuários Deletados (Manter Ativos)

## 🎯 Objetivo
Remover **TODOS** os usuários deletados, órfãos e inativos do sistema, mantendo **APENAS** os usuários ativos intactos.

## ⚠️ O QUE SERÁ DELETADO

### ❌ Serão Removidos:
1. **Usuários deletados** - `auth.users` com `deleted_at != NULL`
2. **Empresas órfãs** - Registros em `empresas` sem usuário em `auth.users`
3. **Empresas inativas** - `empresas.ativo = false`
4. **Empresas soft-deleted** - `empresas.deleted_at != NULL`
5. **Todos os dados relacionados**:
   - Vendas
   - Produtos
   - Clientes
   - Funcionários
   - Caixas
   - Ordens de Serviço
   - Funções/Roles

### ✅ Serão Preservados:
- **Usuários ativos** - `empresas.ativo = true` E `auth.users.deleted_at = NULL`
- **Todos os seus dados** - Vendas, produtos, clientes, etc.

---

## 📋 PASSO 1: Verificar o que será deletado

**Execute PRIMEIRO este script para revisar:**

```sql
-- Arquivo: VERIFICAR_ANTES_DE_LIMPAR.sql
```

1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql/new
2. Copie e cole o conteúdo de `VERIFICAR_ANTES_DE_LIMPAR.sql`
3. Clique em **RUN**
4. **Revise cuidadosamente** as listas:
   - ❌ O que será deletado
   - ✅ O que será preservado

---

## 🗑️ PASSO 2: Executar a limpeza

**⚠️ ATENÇÃO: Esta ação é IRREVERSÍVEL!**

Somente execute se você revisou o PASSO 1 e confirmou que está correto.

```sql
-- Arquivo: LIMPAR_DELETADOS_MANTER_ATIVOS.sql
```

1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/sql/new
2. Copie e cole o conteúdo de `LIMPAR_DELETADOS_MANTER_ATIVOS.sql`
3. Clique em **RUN**
4. Aguarde a conclusão (pode levar alguns segundos)
5. Leia as mensagens de log no output

---

## ✅ PASSO 3: Verificação final

Após executar a limpeza, verifique os resultados:

```sql
-- 1️⃣ Deve retornar 0 órfãos
SELECT COUNT(*) as orfaos FROM empresas e
LEFT JOIN auth.users u ON u.id = e.user_id
WHERE u.id IS NULL;

-- 2️⃣ Deve retornar 0 deletados
SELECT COUNT(*) as deletados FROM auth.users 
WHERE deleted_at IS NOT NULL;

-- 3️⃣ Deve retornar 0 inativos
SELECT COUNT(*) as inativos FROM empresas
WHERE ativo = false OR deleted_at IS NOT NULL;

-- 4️⃣ Ver usuários ativos mantidos
SELECT 
  u.email,
  e.nome,
  e.ativo,
  u.created_at
FROM empresas e
JOIN auth.users u ON u.id = e.user_id
WHERE e.ativo = true 
  AND e.deleted_at IS NULL
  AND u.deleted_at IS NULL
ORDER BY u.created_at DESC;
```

---

## 🎯 Casos Específicos

### Limpar um usuário específico por email

Se precisar limpar **apenas um email específico** (como `cris-ramos30@hotmail.com`):

```sql
-- Use o script: LIMPAR_USUARIO_COMPLETO.sql
```

### Testar disponibilidade de CPF após limpeza

```sql
SELECT validate_document_uniqueness('28219618809');
```

**Resultado esperado:**
```json
{
  "valid": true,
  "document_type": "CPF",
  "message": "CPF disponível para cadastro"
}
```

---

## 🔒 Segurança

### ✅ Garantias do Script:

1. **Não toca em usuários ativos** - `WHERE ativo = true`
2. **Verifica deleted_at** - Só remove se marcado como deletado
3. **Limpa em cascata** - Remove todos os dados relacionados
4. **Logs detalhados** - Mostra tudo que está sendo removido
5. **Verificação final** - Confirma que limpeza foi bem-sucedida

### ⚠️ Atenção:

- **BACKUP**: Recomendado fazer backup antes de executar
- **IRREVERSÍVEL**: Dados deletados não podem ser recuperados
- **TESTE PRIMEIRO**: Execute `VERIFICAR_ANTES_DE_LIMPAR.sql` antes

---

## 📞 Suporte

Se algo der errado:

1. **NÃO ENTRE EM PÂNICO** - Usuários ativos estão protegidos
2. Verifique os logs de execução
3. Execute a verificação final (PASSO 3)
4. Se necessário, restaure do backup

---

## 📝 Resumo dos Arquivos

| Arquivo | Descrição | Quando Usar |
|---------|-----------|-------------|
| `VERIFICAR_ANTES_DE_LIMPAR.sql` | Ver o que será deletado | **PRIMEIRO** - Sempre |
| `LIMPAR_DELETADOS_MANTER_ATIVOS.sql` | Executar limpeza | **SEGUNDO** - Após revisar |
| `LIMPAR_USUARIO_COMPLETO.sql` | Limpar email específico | Caso específico |
| `SOLUCAO_CPF_JA_CADASTRADO.md` | Documentação do problema | Referência |

---

## ✅ Checklist

- [ ] Li e entendi o que será deletado
- [ ] Executei `VERIFICAR_ANTES_DE_LIMPAR.sql`
- [ ] Revisei as listas de usuários
- [ ] Confirmei que usuários ativos estão corretos
- [ ] Executei `LIMPAR_DELETADOS_MANTER_ATIVOS.sql`
- [ ] Executei verificação final (PASSO 3)
- [ ] Testei cadastro de novo usuário
- [ ] ✅ Tudo funcionando!
