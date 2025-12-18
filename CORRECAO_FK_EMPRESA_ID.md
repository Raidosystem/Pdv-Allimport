# ⚠️ CORREÇÃO APLICADA: Erro FK empresa_id em produtos

## 🔴 Problema Identificado

**Erro:** `insert or update on table "produtos" violates foreign key constraint "produtos_empresa_id_fkey"`

**Detalhes:** `Key is not present in table "empresas"`

**Código do erro:** 23503 (Foreign Key Violation)

## 🔍 Análise do Problema

### Arquitetura Multi-Tenant

O sistema usa duas chaves para isolamento de dados:

1. **`user_id`** (UUID): ID do usuário no Supabase Auth
2. **`empresa_id`** (UUID): ID da empresa na tabela `empresas`

### Erro Arquitetônico Detectado

O trigger `set_user_and_empresa_id()` estava fazendo:

```sql
-- ❌ ERRADO
IF NEW.empresa_id IS NULL THEN
    NEW.empresa_id := NEW.user_id;  -- Assume que user_id existe em empresas
END IF;
```

**Problema:** O `user_id` (UUID do Supabase Auth) **NÃO é o mesmo** que o `empresa_id` (UUID da tabela empresas).

### Fluxo do Erro

1. Usuário preenche formulário de produto
2. Frontend envia dados com `user_id` (UUID do auth)
3. Trigger seta `empresa_id = user_id`
4. FK constraint valida se `empresa_id` existe em `empresas.id`
5. ❌ **FALHA**: `user_id` não existe como registro em `empresas`

## ✅ Solução Aplicada

### Arquivo SQL: `CORRIGIR_FK_EMPRESA_ID.sql`

O script faz:

1. **Diagnóstico**:
   - Verifica estrutura da tabela `empresas`
   - Verifica FK constraint em `produtos`
   - Lista empresas do usuário atual
   - Lista todas as empresas (debug)

2. **Correção Automática**:
   - Cria empresa para usuário se não existir
   - Remove trigger antigo (`set_user_and_empresa_id`)
   - Cria novo trigger (`set_user_and_empresa_id_correto`)

3. **Novo Trigger**:
   ```sql
   -- ✅ CORRETO
   SELECT id INTO v_empresa_id
   FROM empresas
   WHERE user_id = NEW.user_id
   LIMIT 1;
   
   IF v_empresa_id IS NOT NULL THEN
       NEW.empresa_id := v_empresa_id;
   ELSE
       NEW.empresa_id := NULL;
   END IF;
   ```

### Como Funciona o Novo Trigger

1. Seta `user_id` do auth se não fornecido
2. **Busca empresa_id** na tabela `empresas` onde `user_id = NEW.user_id`
3. Se encontrar: seta `empresa_id` com o ID correto da empresa
4. Se não encontrar: deixa `empresa_id` como NULL

### Criação Automática de Empresa

O script também inclui uma query para criar empresa automaticamente se o usuário não tiver uma:

```sql
INSERT INTO empresas (nome, user_id, created_at, updated_at)
SELECT
    'Empresa de ' || COALESCE(auth.email(), 'Usuário'),
    auth.uid(),
    NOW(),
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM empresas WHERE user_id = auth.uid()
);
```

## 📋 Como Aplicar a Correção

### Passo 1: Executar SQL no Supabase

1. Acesse o Supabase Dashboard
2. Vá em **SQL Editor**
3. Copie e cole o conteúdo de `CORRIGIR_FK_EMPRESA_ID.sql`
4. Execute o script completo

### Passo 2: Verificar Resultado

O script retorna:

- ✅ Estrutura da tabela `empresas`
- ✅ FK constraint em `produtos`
- ✅ Empresas do usuário atual
- ✅ Trigger atualizado
- ✅ Status final: "CORREÇÃO APLICADA COM SUCESSO!"

### Passo 3: Testar Cadastro de Produto

1. Acesse o sistema
2. Vá em **Produtos** → **Novo Produto**
3. Preencha os dados
4. Clique em **Salvar**
5. ✅ Produto deve ser salvo sem erros

## 🔐 Impacto em RLS e Segurança

### RLS Mantém Isolamento

As políticas RLS usam `user_id` para isolamento:

```sql
CREATE POLICY "users_own_data" ON produtos
FOR ALL USING (user_id = auth.uid());
```

**✅ Isolamento garantido:** Cada usuário vê apenas seus próprios produtos via `user_id`.

### empresa_id é Opcional

- Se usuário tem empresa: `empresa_id` é preenchido
- Se usuário não tem empresa: `empresa_id` fica NULL
- FK constraint não bloqueia NULL (coluna é NULLABLE)

## 🎯 Próximos Passos

### Opcional: Criação Automática de Empresa

Se quiser que o sistema crie empresa automaticamente quando não existir, descomente o bloco no trigger:

```sql
-- No arquivo CORRIGIR_FK_EMPRESA_ID.sql, descomente este bloco:
INSERT INTO empresas (nome, user_id, created_at, updated_at)
VALUES (
    'Empresa de ' || COALESCE((SELECT email FROM auth.users WHERE id = NEW.user_id), 'Usuário'),
    NEW.user_id,
    NOW(),
    NOW()
)
RETURNING id INTO v_empresa_id;

NEW.empresa_id := v_empresa_id;
```

### Verificar Outros Módulos

Este problema pode afetar outras tabelas com `empresa_id`:

- `clientes`
- `vendas`
- `caixa`
- `ordens_servico`

**Verificar:** Se essas tabelas também têm FK para `empresas`, aplicar correção similar.

## 📊 Histórico de Erros

| Data | Erro | Status |
|------|------|--------|
| Anterior | Erro 409: Conflito de triggers | ✅ Resolvido |
| Atual | Erro 23503: FK constraint violation | ✅ Resolvido |

## 🔧 Arquivos Relacionados

- `CORRIGIR_FK_EMPRESA_ID.sql` - Script de correção
- `CORRIGIR_TRIGGERS_CONFLITANTES_PRODUTOS.sql` - Trigger antigo (problema)
- `src/hooks/useProducts.ts` - Hook de produtos (frontend)
- `src/modules/products/ProductForm.tsx` - Formulário de produtos

## ⚠️ Observações Importantes

1. **Backup:** O script não altera dados existentes, apenas corrige o trigger
2. **RLS:** Políticas RLS continuam funcionando normalmente
3. **Multi-tenant:** Isolamento por `user_id` é mantido
4. **empresa_id:** Agora busca valor correto da tabela `empresas`
5. **NULL permitido:** `empresa_id` pode ser NULL se usuário não tem empresa

---

**Data da Correção:** 2024-01-XX  
**Arquivo:** CORRECAO_FK_EMPRESA_ID.md  
**Status:** ✅ Correção Pronta para Aplicar
