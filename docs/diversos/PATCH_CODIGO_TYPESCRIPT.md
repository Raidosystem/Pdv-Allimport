# 📝 PATCH - Correção do Erro 400 ao Criar Clientes

## ⚠️ IMPORTANTE

Este arquivo contém as alterações exatas que devem ser feitas no código TypeScript.
O arquivo foi revertido ao estado original porque a edição automática causou corrupção.

## 📍 Arquivo: `src/components/cliente/ClienteFormUnificado.tsx`

---

## ✏️ MUDANÇA 1: Atualizar Cliente (linhas 301-307)

### LOCALIZAR:

Procure por esta linha exata:

```typescript
// Atualizar cliente existente
```

### ENCONTRAR ESTE BLOCO:

```typescript
// Atualizar cliente existente
const { data, error } = await supabase
  .from("clientes")
  .update(clienteData)
  .eq("id", clienteParaAtualizar.id)
  .select()
  .single();
```

### SUBSTITUIR POR:

```typescript
// Atualizar cliente existente usando função RPC segura
const { data, error } = await supabase.rpc("atualizar_cliente_seguro", {
  p_cliente_id: clienteParaAtualizar.id,
  p_nome: clienteData.nome,
  p_cpf_cnpj: clienteData.cpf_cnpj,
  p_cpf_digits: clienteData.cpf_digits,
  p_email: clienteData.email,
  p_telefone: clienteData.telefone,
  p_rua: clienteData.rua,
  p_numero: clienteData.numero,
  p_cidade: clienteData.cidade,
  p_estado: clienteData.estado,
  p_cep: clienteData.cep,
  p_tipo: clienteData.tipo,
});
```

---

## ✏️ MUDANÇA 2: Criar Cliente (linhas 325-338)

### LOCALIZAR:

Procure por esta linha exata:

```typescript
// Criar novo cliente
```

### ENCONTRAR ESTE BLOCO:

```typescript
        const { data, error } = await supabase
          .from('clientes')
          .insert([clienteData])
          .select()
          .single()

        console.log('📊 [DEBUG] Resultado da inserção:', { data, error })

        if (error) {
          // Verificar se é erro de duplicação
          if (error.code === '23505') { // Unique violation
            toast.error('Este CPF já está cadastrado.')
            return
          }
```

### SUBSTITUIR POR:

```typescript
        const { data, error } = await supabase.rpc('criar_cliente_seguro', {
          p_nome: clienteData.nome,
          p_cpf_cnpj: clienteData.cpf_cnpj,
          p_cpf_digits: clienteData.cpf_digits,
          p_email: clienteData.email,
          p_telefone: clienteData.telefone,
          p_rua: clienteData.rua,
          p_numero: clienteData.numero,
          p_cidade: clienteData.cidade,
          p_estado: clienteData.estado,
          p_cep: clienteData.cep,
          p_empresa_id: clienteData.empresa_id,
          p_tipo: clienteData.tipo
        })

        console.log('📊 [DEBUG] Resultado da inserção:', { data, error })

        if (error) {
          // Verificar se é erro de duplicação
          if (error.message && error.message.includes('duplicate')) {
            toast.error('Este CPF já está cadastrado.')
            return
          }
```

---

## 🎯 Resumo das Mudanças

**Antes:** Usava `.from('clientes').insert()` e `.update()` direto
**Depois:** Usa funções RPC `criar_cliente_seguro` e `atualizar_cliente_seguro`

**Benefício:** Evita o erro 400 causado pelo parâmetro `columns=` malformado na URL

---

## ✅ Como Aplicar

1. Abra: `src/components/cliente/ClienteFormUnificado.tsx`
2. Use Ctrl+F para encontrar: `// Atualizar cliente existente`
3. Aplique a Mudança 1
4. Use Ctrl+F para encontrar: `// Criar novo cliente`
5. Aplique a Mudança 2
6. Salve o arquivo (Ctrl+S)
7. Verifique que não há erros de sintaxe

---

## ⚠️ ATENÇÃO

**ANTES de aplicar este patch, você DEVE:**

1. ✅ Executar `CORRIGIR_ERRO_406_EMPRESAS.sql` no Supabase
2. ✅ Executar `CORRIGIR_ERRO_400_CLIENTES.sql` no Supabase

Sem as funções RPC criadas, o código vai falhar!

---

**Data:** 20/11/2025 15:26
**Status:** Patch pronto para ser aplicado manualmente
