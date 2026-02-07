# 🎯 Instruções para Aplicar as Correções

## ✅ Status Atual

### Correção 1: Permissões do Funcionário ✅ **CONCLUÍDA**

- Script executado: `CORRIGIR_ERRO_PERMISSOES.sql`
- Resultado: Funcionário criado com sucesso
- Status: ✅ Erro corrigido

---

## 📋 Próximos Passos

### Correção 2: RLS da Tabela Empresas (Erro 406)

**1. Execute o script no Supabase:**

```bash
# Arquivo: CORRIGIR_ERRO_406_EMPRESAS.sql
```

**Passos:**

1. Abra: https://supabase.com/dashboard
2. Vá em: **SQL Editor**
3. Abra o arquivo: `CORRIGIR_ERRO_406_EMPRESAS.sql`
4. Copie TODO o conteúdo
5. Cole no editor SQL
6. Clique em **RUN** (ou Ctrl+Enter)
7. Verifique se aparece: `✅ Políticas RLS da tabela empresas criadas com sucesso!`

**Teste após executar:**

```sql
SELECT * FROM empresas WHERE user_id = auth.uid();
```

Se retornar sua empresa, está funcionando! ✅

---

### Correção 3: Erro 400 ao Criar Cliente

**Opção A - Usando Função RPC (RECOMENDADO):**

**1. Execute o script no Supabase:**

```bash
# Arquivo: CORRIGIR_ERRO_400_CLIENTES.sql
```

**2. Atualize o código TypeScript:**

Substitua o código em `src/components/cliente/ClienteFormUnificado.tsx` (linhas 324-328):

**DE:**

```typescript
const { data, error } = await supabase
  .from("clientes")
  .insert([clienteData])
  .select()
  .single();
```

**PARA:**

```typescript
const { data, error } = await supabase.rpc("criar_cliente_seguro", {
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
  p_tipo: clienteData.tipo,
});
```

**Para atualização** (linhas 301-306), substitua:

**DE:**

```typescript
const { data, error } = await supabase
  .from("clientes")
  .update(clienteData)
  .eq("id", clienteParaAtualizar.id)
  .select()
  .single();
```

**PARA:**

```typescript
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

**Opção B - Investigação Profunda (se Opção A não resolver):**

1. Verificar se há extensões do navegador interferindo
2. Testar em modo anônimo/privado
3. Verificar configurações de CORS no Supabase
4. Verificar logs do Supabase em tempo real

---

## 🧪 Como Testar

### Após executar TODOS os scripts:

1. **Limpar cache do navegador:**

   - Ctrl+Shift+Delete
   - Limpar cache e cookies

2. **Fazer logout e login novamente:**

   - Sair do sistema
   - Entrar novamente

3. **Testar criar cliente:**

   - Ir em "Clientes"
   - Clicar em "Novo Cliente"
   - Preencher dados
   - Salvar

4. **Verificar no console:**
   - F12 → Console
   - Não deve aparecer mais os erros 406 e 400

---

## 📊 Checklist Final

```
[ ] Script CORRIGIR_ERRO_406_EMPRESAS.sql executado
[ ] Script CORRIGIR_ERRO_400_CLIENTES.sql executado
[ ] Código TypeScript atualizado (se usar Opção A)
[ ] Cache do navegador limpo
[ ] Logout/Login realizado
[ ] Teste de criação de cliente bem-sucedido
```

---

## ❓ Se Algo Der Errado

1. Verifique os logs no console do navegador (F12)
2. Verifique os logs do Supabase (Dashboard → Logs)
3. Execute os scripts novamente
4. Reinicie o servidor de desenvolvimento (`npm run dev`)

---

## 🎉 Resultado Esperado

Após todas as correções:

- ✅ Nenhum erro 406
- ✅ Nenhum erro 400
- ✅ Clientes sendo criados normalmente
- ✅ Permissões funcionando corretamente
- ✅ Sistema totalmente funcional
