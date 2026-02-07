# 🔧 Como Corrigir Erro 403 ao Criar Clientes

## Problema Identificado
Erro: **403 Forbidden** ao tentar inserir cliente
Causa: **Políticas RLS (Row Level Security)** muito restritivas no Supabase

## ✅ Solução

### Passo 1: Acessar o Supabase
1. Acesse: https://supabase.com/dashboard
2. Faça login
3. Selecione seu projeto: **Pdv-Allimport**

### Passo 2: Executar o Script SQL
1. No menu lateral, clique em **SQL Editor**
2. Clique em **New Query**
3. Abra o arquivo: `CORRIGIR_RLS_CLIENTES.sql`
4. Copie TODO o conteúdo do arquivo
5. Cole no editor SQL do Supabase
6. Clique em **Run** (ou pressione Ctrl+Enter)

### Passo 3: Verificar se Funcionou
1. Volte para a aplicação
2. Tente cadastrar um novo cliente
3. Deve funcionar normalmente agora! ✅

## 🔍 O que o script faz?

1. **Remove políticas antigas** que estavam bloqueando
2. **Cria políticas permissivas** para usuários autenticados:
   - ✅ INSERT: Permitir criar clientes
   - ✅ SELECT: Permitir ler clientes
   - ✅ UPDATE: Permitir editar clientes
   - ✅ DELETE: Permitir excluir clientes

3. **Adiciona coluna `user_id`** (se não existir)
4. **Cria trigger automático** para associar clientes ao usuário

## ⚠️ Importante
- Execute o script UMA VEZ apenas
- Se der erro, não se preocupe - pode executar novamente
- O script é seguro e não apaga dados

## 🆘 Se não funcionar
Abra o console do navegador (F12) e me envie o erro completo que aparecer
