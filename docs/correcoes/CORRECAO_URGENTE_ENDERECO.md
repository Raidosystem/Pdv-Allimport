# ⚠️ CORREÇÃO URGENTE - Estrutura da Tabela Clientes

## Problema Encontrado

O erro `column "rua" of relation "clientes" does not exist` indica que a tabela `clientes` **NÃO TEM** as colunas separadas de endereço.

## Estrutura Real da Tabela

A tabela `clientes` tem apenas:

- `endereco` (TEXT) - endereço completo em um único campo

**NÃO TEM:**

- ~~`rua`~~
- ~~`numero`~~
- ~~`cidade`~~
- ~~`estado`~~
- ~~`cep`~~

## Correções Necessárias

### 1️⃣ Executar Novo Script SQL

**Execute no Supabase:** `CORRIGIR_ERRO_400_CLIENTES_V2.sql`

Este script cria as funções RPC corretas que usam apenas `endereco`.

### 2️⃣ Corrigir Código TypeScript

No arquivo `src/components/cliente/ClienteFormUnificado.tsx`, substitua as chamadas RPC:

**Linha ~302 (Atualizar Cliente):**

```typescript
const { data, error } = await supabase.rpc("atualizar_cliente_seguro", {
  p_cliente_id: clienteParaAtualizar.id,
  p_nome: clienteData.nome,
  p_cpf_cnpj: clienteData.cpf_cnpj,
  p_cpf_digits: clienteData.cpf_digits,
  p_email: clienteData.email,
  p_telefone: clienteData.telefone,
  p_endereco: clienteData.endereco, // ← USAR APENAS ENDERECO
  p_tipo: clienteData.tipo,
});
```

**Linha ~332 (Criar Cliente):**

```typescript
const { data, error } = await supabase.rpc("criar_cliente_seguro", {
  p_nome: clienteData.nome,
  p_cpf_cnpj: clienteData.cpf_cnpj,
  p_cpf_digits: clienteData.cpf_digits,
  p_email: clienteData.email,
  p_telefone: clienteData.telefone,
  p_endereco: clienteData.endereco, // ← USAR APENAS ENDERECO
  p_empresa_id: clienteData.empresa_id,
  p_tipo: clienteData.tipo,
});
```

## Passos para Corrigir

1. ✅ **Execute** `CORRIGIR_ERRO_400_CLIENTES_V2.sql` no Supabase
2. ✅ **Edite** `ClienteFormUnificado.tsx` conforme acima
3. ✅ **Teste** criando um cliente

## Observação

O formulário continua mostrando campos separados (`rua`, `numero`, etc.) para o usuário, mas internamente eles são combinados no campo `endereco` antes de salvar (veja linha 282 do código: `montarEnderecoCompleto()`).
