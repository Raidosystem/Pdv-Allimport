# 🚨 DIAGNÓSTICO: POLÍTICAS RLS CONFLITANTES

## ❌ PROBLEMA ENCONTRADO

A tabela `produtos` tinha **8 políticas RLS conflitantes**, causando vazamento de dados entre usuários.

## 📊 Políticas Antigas Encontradas

```
| NOME DA POLÍTICA                           | TIPO   | PROBLEMA                              |
|--------------------------------------------|--------|---------------------------------------|
| Acesso público a produtos de lojas ativas  | SELECT | Permite acesso público sem controle   |
| Users can only see their own produtos      | ALL    | Política "ALL" muito ampla            |
| produtos_empresa_isolation                 | ALL    | Usa empresa_id (conflito com user_id) |
| public_read_produtos_loja_online           | SELECT | Duplica lógica de acesso público      |
| usuarios_podem_atualizar_seus_produtos     | UPDATE | OK, mas duplicada                     |
| usuarios_podem_deletar_seus_produtos       | DELETE | OK, mas duplicada                     |
| usuarios_podem_inserir_seus_produtos       | INSERT | OK, mas duplicada                     |
| usuarios_podem_ver_seus_produtos           | SELECT | OK, mas conflita com outras SELECT    |
```

## ⚠️ Por Que Isso Causava Vazamento?

### Problema 1: Múltiplas Políticas SELECT
Quando há **múltiplas políticas SELECT**, o PostgreSQL usa **OR** (OU) entre elas:
- Se QUALQUER política permitir, o acesso é liberado
- `usuarios_podem_ver_seus_produtos` (correta) **OU**
- `Acesso público a produtos de lojas ativas` (muito permissiva) **OU**
- `public_read_produtos_loja_online` (outra permissiva)
- Resultado: **Produtos de outros usuários ficavam visíveis**

### Problema 2: Políticas "ALL"
```sql
"Users can only see their own produtos" | ALL | (auth.uid() = user_id)
```
Políticas tipo `ALL` aplicam para SELECT, INSERT, UPDATE e DELETE simultaneamente, mas podem conflitar com políticas específicas.

### Problema 3: Conflito user_id vs empresa_id
```sql
"produtos_empresa_isolation" | ALL | (empresa_id = get_user_empresa_id())
```
- Algumas políticas usavam `user_id`
- Outras usavam `empresa_id`
- Isso criava brechas de acesso

## ✅ SOLUÇÃO APLICADA

### Nova Estrutura: 5 Políticas Limpas

#### 1️⃣ Para Usuários Autenticados (4 políticas)
```sql
-- SELECT - Ver apenas seus produtos
CREATE POLICY "produtos_select_own_only"
ON produtos FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- INSERT - Criar apenas com seu user_id
CREATE POLICY "produtos_insert_own_only"
ON produtos FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

-- UPDATE - Atualizar apenas seus produtos
CREATE POLICY "produtos_update_own_only"
ON produtos FOR UPDATE TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- DELETE - Deletar apenas seus produtos
CREATE POLICY "produtos_delete_own_only"
ON produtos FOR DELETE TO authenticated
USING (auth.uid() = user_id);
```

#### 2️⃣ Para Usuários Anônimos (1 política)
```sql
-- SELECT - Ver apenas produtos de lojas online ativas
CREATE POLICY "produtos_public_catalog_read"
ON produtos FOR SELECT TO anon
USING (
    ativo = true 
    AND EXISTS (
        SELECT 1 FROM lojas_online 
        WHERE lojas_online.empresa_id = produtos.user_id 
        AND lojas_online.ativa = true
    )
);
```

## 🎯 Vantagens da Nova Estrutura

### ✅ Isolamento Total
- Cada usuário vê **APENAS** seus produtos
- Nenhuma política conflitante
- Uma política específica por operação

### ✅ Catálogo Público Controlado
- Anônimos veem apenas produtos de lojas **ativas**
- Usa JOIN com `lojas_online` para validar
- Não expõe produtos de lojas inativas

### ✅ Performance
- Políticas otimizadas
- Índices funcionam corretamente
- Sem queries desnecessárias

## 🔧 Como o Script Corrige

### Passo 1: Limpeza Total
```sql
-- Remove TODAS as políticas antigas
DROP POLICY IF EXISTS "Acesso público a produtos de lojas ativas" ON produtos;
DROP POLICY IF EXISTS "Users can only see their own produtos" ON produtos;
DROP POLICY IF EXISTS "produtos_empresa_isolation" ON produtos;
-- ... (todas as 8 políticas)

-- Loop para garantir que nada sobrou
DO $$
DECLARE pol RECORD;
BEGIN
    FOR pol IN 
        SELECT policyname FROM pg_policies 
        WHERE tablename = 'produtos'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON produtos', pol.policyname);
    END LOOP;
END $$;
```

### Passo 2: Criação Limpa
Cria apenas as 5 políticas necessárias, sem conflitos.

### Passo 3: Verificação
Valida que apenas as políticas corretas existem.

## 📋 Checklist de Validação

Após executar o script, verifique:

```sql
-- ✅ Deve retornar EXATAMENTE 5 políticas
SELECT COUNT(*) FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'produtos';
-- Resultado esperado: 5

-- ✅ Listar as políticas criadas
SELECT policyname, cmd FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'produtos'
ORDER BY cmd, policyname;
-- Resultado esperado:
-- produtos_delete_own_only    | DELETE
-- produtos_insert_own_only    | INSERT
-- produtos_public_catalog_read | SELECT
-- produtos_select_own_only    | SELECT
-- produtos_update_own_only    | UPDATE
```

## 🧪 Teste de Isolamento

### Teste 1: Usuário A não vê produtos do Usuário B
```sql
-- Login como usuário A
SELECT COUNT(*), user_id FROM produtos GROUP BY user_id;
-- Deve retornar APENAS 1 linha com user_id do usuário A
```

### Teste 2: Anônimos veem apenas lojas ativas
```sql
-- Sem autenticação
SELECT COUNT(*) FROM produtos;
-- Deve retornar apenas produtos de lojas online ativas
```

### Teste 3: Inserção bloqueada para outro user_id
```sql
-- Tentar inserir produto com user_id diferente (deve falhar)
INSERT INTO produtos (nome, user_id) 
VALUES ('Teste', 'outro-user-id-qualquer');
-- Erro esperado: nova linha viola política
```

## 🚨 Sinais de Políticas Conflitantes

Se você ver estes sintomas, pode ter políticas conflitantes:

- ❌ Usuário vê produtos que não cadastrou
- ❌ Contagem de produtos maior que esperado
- ❌ Produtos aparecem e somem aleatoriamente
- ❌ Erros de permissão inconsistentes

## 🔍 Como Diagnosticar no Futuro

```sql
-- Ver todas as políticas de uma tabela
SELECT 
    policyname,
    cmd,
    roles,
    qual AS using_expression,
    with_check
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'produtos'
ORDER BY cmd, policyname;

-- Contar políticas por comando
SELECT cmd, COUNT(*) 
FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'produtos'
GROUP BY cmd;
-- Se SELECT tiver mais de 2 políticas (auth + anon), investigar!
```

## ✅ Estado Final Esperado

Após executar `CORRIGIR_RLS_PRODUTOS_URGENTE.sql`:

```
TABELA: produtos
├── RLS: ✅ HABILITADO
├── Políticas: 5 (limpas e sem conflitos)
│   ├── produtos_delete_own_only (DELETE - authenticated)
│   ├── produtos_insert_own_only (INSERT - authenticated)
│   ├── produtos_select_own_only (SELECT - authenticated)
│   ├── produtos_public_catalog_read (SELECT - anon)
│   └── produtos_update_own_only (UPDATE - authenticated)
└── Isolamento: ✅ TOTAL (testado)

TABELA: lojas_online
├── RLS: ✅ HABILITADO
├── Políticas: 5 (para catálogo funcionar)
└── Isolamento: ✅ TOTAL por empresa_id
```

---

**Data:** 17/12/2025  
**Status:** 🔴 CRÍTICO - Aplicar correção imediatamente  
**Script:** `CORRIGIR_RLS_PRODUTOS_URGENTE.sql`
