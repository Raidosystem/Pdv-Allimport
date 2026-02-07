# 🔴 ERRO 403 AO FINALIZAR VENDA - SOLUÇÃO

## Problema Identificado

```
Failed to load resource: the server responded with a status of 403 ()
kmcaaqetxtwkdcczdomw.supabase.co/rest/v1/vendas_itens
```

**Causa:** As políticas de segurança RLS (Row Level Security) do Supabase estão bloqueando a inserção de itens na tabela `vendas_itens`.

## ⚠️ IMPORTANTE

Este erro **NÃO foi causado** pelas alterações no ProductsPage. É um problema de configuração do banco de dados Supabase.

## 🔧 Solução

### Passo 1: Acessar o Editor SQL do Supabase

1. Vá para: https://supabase.com/dashboard
2. Selecione seu projeto: `kmcaaqetxtwkdcczdomw`
3. No menu lateral, clique em **"SQL Editor"**

### Passo 2: Executar o Script de Correção

1. Abra o arquivo: `CORRIGIR_PERMISSOES_VENDAS.sql`
2. Copie todo o conteúdo
3. Cole no editor SQL do Supabase
4. Clique em **"RUN"** ou pressione `Ctrl + Enter`

### Passo 3: Verificar se Funcionou

O script irá:
- ✅ Remover políticas conflitantes
- ✅ Criar novas políticas permissivas para `vendas`
- ✅ Criar novas políticas permissivas para `vendas_itens`
- ✅ Habilitar RLS nas tabelas
- ✅ Mostrar as políticas criadas

### Passo 4: Testar a Venda

1. Volte para o sistema PDV
2. Adicione produtos ao carrinho
3. Informe o pagamento
4. Clique em **"Finalizar Venda"**
5. Deve funcionar sem erro 403! ✅

## 🎯 O que o Script Faz

O script cria políticas RLS mais permissivas que permitem:

```sql
-- Usuários autenticados podem:
- ✅ Criar vendas (INSERT em vendas)
- ✅ Ver vendas (SELECT em vendas)
- ✅ Criar itens de venda (INSERT em vendas_itens)
- ✅ Ver itens de venda (SELECT em vendas_itens)
```

## 🔍 Por que o Erro 403?

O erro 403 (Forbidden) acontece quando:
1. A tabela tem RLS habilitado ✅ (correto)
2. Mas **falta** política de INSERT para usuários autenticados ❌ (problema)
3. O Supabase bloqueia a operação por segurança

## 📊 Estrutura das Tabelas Afetadas

### Tabela: `vendas`
- Armazena informações da venda (total, cliente, pagamento)
- **Precisa de política INSERT para usuários autenticados**

### Tabela: `vendas_itens`
- Armazena os itens (produtos) de cada venda
- **Precisa de política INSERT para usuários autenticados**
- Relaciona com `vendas` através de `venda_id`

## ⚡ Solução Rápida (Se Urgente)

Se precisar de uma solução **temporária** imediata:

```sql
-- Execute APENAS isto no SQL Editor do Supabase:

-- Desabilitar RLS temporariamente (NÃO RECOMENDADO EM PRODUÇÃO)
ALTER TABLE vendas_itens DISABLE ROW LEVEL SECURITY;

-- Depois teste a venda
-- Em seguida, execute o script completo de correção
-- e reabilite o RLS com as políticas corretas
```

⚠️ **AVISO:** Desabilitar RLS é inseguro! Use apenas para teste e depois execute o script completo.

## 📝 Logs do Erro (Referência)

```
❌ Erro ao inserir item: Object
❌ Detalhes do erro item: Object
❌ Dados do item enviados: Object
💥 Erro completo ao criar venda: Object
Erro ao finalizar venda: Object
```

Esses erros param de aparecer após executar o script de correção.

## ✅ Checklist de Verificação

Após executar o script, verifique:

- [ ] Venda finaliza sem erro 403
- [ ] Itens aparecem na venda
- [ ] Recibo é impresso corretamente
- [ ] Estoque é atualizado (se configurado)
- [ ] Movimentação de caixa é registrada

## 🆘 Se Ainda Não Funcionar

1. Verifique se o usuário está autenticado:
   ```javascript
   // No console do navegador (F12)
   const { data } = await supabase.auth.getUser()
   console.log('Usuário:', data.user)
   ```

2. Verifique as políticas criadas:
   ```sql
   SELECT * FROM pg_policies 
   WHERE tablename IN ('vendas', 'vendas_itens');
   ```

3. Veja os logs detalhados no Supabase:
   - Dashboard → Logs → Database

## 📞 Contato

Se o problema persistir após executar o script, entre em contato com o suporte fornecendo:
- Screenshot do erro
- Logs do console (F12)
- Resultado da query de verificação de políticas

---

**Data do erro:** 26/10/2025 01:12:33
**Tabela afetada:** `vendas_itens`
**Status HTTP:** 403 Forbidden
**Solução:** Script SQL de correção de permissões
