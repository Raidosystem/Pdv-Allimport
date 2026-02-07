# ?? GUIA DE EXECUÇÃO: Correção de Permissões Jennifer

## ?? PROBLEMA IDENTIFICADO

Jennifer tem **40 permissões ativas** no banco, mas o sistema **não está reconhecendo** essas permissões porque:

1. ? **Permissões cadastradas**: `vendas:cancel`, `vendas:discount`, `produtos:export`, etc.
2. ? **Sistema verifica**: `vendas:read`, `vendas:create`, `vendas:update`, `vendas:delete` apenas
3. ? **Permissões granulares não mapeadas** para permissões básicas

---

## ?? SOLUÇÃO IMPLEMENTADA

### O que o script faz:

1. **Cria permissões básicas faltando** (`read`, `create`, `update`, `delete`)
2. **Mapeia permissões granulares ? básicas** (ex: `cancel` precisa de `update`)
3. **Adiciona permissões READ automáticas** para módulos com permissões granulares
4. **Garante compatibilidade** com o sistema atual

---

## ?? COMO EXECUTAR

### Passo 1: Abrir Supabase SQL Editor

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Clique em **"SQL Editor"** no menu lateral
4. Clique em **"New Query"**

### Passo 2: Copiar e Colar o SQL

1. Abra o arquivo: `CORRIGIR_PERMISSOES_JENNIFER_COMPLETO.sql`
2. Copie **TODO o conteúdo**
3. Cole no SQL Editor do Supabase
4. Clique em **"Run"** (ou pressione `Ctrl + Enter`)

### Passo 3: Verificar Resultados

Você verá várias tabelas de verificação:

#### ? Resultados Esperados:

```sql
?? PERMISSÕES ATUAIS DE JENNIFER
secao                             | funcao    | recurso  | acao    | descricao
----------------------------------|-----------|----------|---------|------------------
?? PERMISSÕES ATUAIS DE JENNIFER | Vendedor  | vendas   | cancel  | Cancelar vendas
?? PERMISSÕES ATUAIS DE JENNIFER | Vendedor  | vendas   | create  | Criar nova venda
...
```

```sql
? PASSO 2: Permissões básicas criadas/atualizadas
status
--------------------------------
? PASSO 2: Permissões básicas criadas/atualizadas
```

```sql
? PASSO 3: Permissões granulares mapeadas
status
--------------------------------
? PASSO 3: Permissões granulares mapeadas
```

```sql
?? MÓDULOS ACESSÍVEIS
secao              | vendas | produtos | clientes | caixa | ordens_servico | relatorios | configuracoes
-------------------|--------|----------|----------|-------|----------------|------------|---------------
?? MÓDULOS ACESSÍVEIS | ?     | ?       | ?       | ?    | ?             | ?         | ?
```

---

## ?? TESTE NO SISTEMA

### Passo 4: Jennifer Fazer Logout e Login

1. Jennifer acessa o sistema
2. Clica em **"Sair"**
3. Faz **login novamente** com suas credenciais
4. As permissões serão recarregadas automaticamente

### Passo 5: Verificar Módulos Visíveis

Jennifer deve **ver todos os módulos** no menu lateral:

```
? Vendas
? Produtos
? Clientes
? Caixa
? Ordens de Serviço
? Relatórios
? Configurações (se tiver permissão)
```

### Passo 6: Testar Funcionalidades

Jennifer deve conseguir:

#### ?? Vendas
- ? Ver lista de vendas
- ? Criar nova venda
- ? Aplicar descontos
- ? Cancelar vendas
- ? Imprimir cupom
- ? Fazer estorno

#### ?? Produtos
- ? Ver lista de produtos
- ? Criar novo produto
- ? Editar produto
- ? Exportar produtos
- ? Gerenciar categorias
- ? Alterar preços
- ? Gerenciar estoque

#### ?? Clientes
- ? Ver lista de clientes
- ? Criar novo cliente
- ? Editar cliente
- ? Ver histórico de compras

#### ?? Caixa
- ? Visualizar caixa
- ? Abrir caixa
- ? Fechar caixa
- ? Fazer suprimento
- ? Fazer sangria

#### ?? Ordens de Serviço
- ? Ver lista de OS
- ? Criar nova OS
- ? Editar OS
- ? Imprimir OS
- ? Alterar status

#### ?? Relatórios
- ? Ver relatórios gerais

#### ?? Configurações
- ? Ver configurações
- ? Configurar impressão
- ? Configurar aparência

---

## ?? TROUBLESHOOTING

### ? Problema: "Módulos ainda não aparecem"

**Causas Possíveis:**
1. Jennifer não fez logout/login
2. Cache do navegador

**Solução:**
```bash
1. Fazer logout completo
2. Limpar cache do navegador (Ctrl+Shift+Del)
3. Fazer login novamente
```

### ? Problema: "Alguns módulos aparecem, outros não"

**Causa:** Permissões básicas não foram criadas corretamente

**Solução:**
```sql
-- Verificar se permissões READ existem
SELECT * FROM permissoes 
WHERE acao = 'read' 
AND recurso IN ('vendas', 'produtos', 'clientes', 'caixa', 'ordens', 'relatorios', 'configuracoes');

-- Se não existirem, criar manualmente
INSERT INTO permissoes (recurso, acao, descricao, categoria)
VALUES
  ('vendas', 'read', 'Visualizar vendas', 'vendas'),
  ('produtos', 'read', 'Visualizar produtos', 'produtos'),
  ('clientes', 'read', 'Visualizar clientes', 'clientes'),
  ('caixa', 'read', 'Visualizar caixa', 'financeiro'),
  ('ordens', 'read', 'Visualizar ordens', 'ordens'),
  ('relatorios', 'read', 'Visualizar relatórios', 'relatorios'),
  ('configuracoes', 'read', 'Visualizar configurações', 'configuracoes')
ON CONFLICT (recurso, acao) DO NOTHING;
```

### ? Problema: "Erro ao executar script"

**Causa:** Políticas RLS bloqueando inserção

**Solução:**
```sql
-- Executar como service_role (modo admin)
-- OU desabilitar RLS temporariamente
ALTER TABLE funcao_permissoes DISABLE ROW LEVEL SECURITY;
-- Executar script
ALTER TABLE funcao_permissoes ENABLE ROW LEVEL SECURITY;
```

### ? Problema: "Permissões não salvam"

**Causa:** `funcao_id` ou `empresa_id` incorretos

**Solução:**
```sql
-- Verificar IDs de Jennifer
SELECT 
  f.id as funcionario_id,
  f.funcao_id,
  f.empresa_id,
  func.nome as funcao_nome
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
WHERE f.email = 'sousajenifer895@gmail.com';

-- Se funcao_id for NULL, atribuir uma função
UPDATE funcionarios
SET funcao_id = (SELECT id FROM funcoes WHERE nome = 'Vendedor' LIMIT 1)
WHERE email = 'sousajenifer895@gmail.com' AND funcao_id IS NULL;
```

---

## ?? VERIFICAÇÕES ADICIONAIS

### Query 1: Ver todas as permissões de Jennifer

```sql
SELECT 
  p.categoria,
  p.recurso,
  STRING_AGG(p.acao, ', ' ORDER BY p.acao) as acoes
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
GROUP BY p.categoria, p.recurso
ORDER BY p.categoria, p.recurso;
```

### Query 2: Comparar permissões cadastradas vs funcionando

```sql
-- Permissões cadastradas
SELECT 
  'Cadastradas' as tipo,
  COUNT(*) as total
FROM funcao_permissoes fp
JOIN funcionarios f ON f.funcao_id = fp.funcao_id
WHERE f.email = 'sousajenifer895@gmail.com'

UNION ALL

-- Permissões básicas (que o sistema usa)
SELECT 
  'Básicas (read/create/update/delete)' as tipo,
  COUNT(*) as total
FROM funcao_permissoes fp
JOIN funcionarios f ON f.funcao_id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
AND p.acao IN ('read', 'create', 'update', 'delete');
```

### Query 3: Verificar módulos acessíveis

```sql
SELECT 
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'vendas'
      AND p2.acao = 'read'
    ) THEN '? Vendas' ELSE '? Vendas'
  END as modulo_vendas,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'produtos'
      AND p2.acao = 'read'
    ) THEN '? Produtos' ELSE '? Produtos'
  END as modulo_produtos,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM funcao_permissoes fp2
      JOIN permissoes p2 ON p2.id = fp2.permissao_id
      WHERE fp2.funcao_id = func.id
      AND p2.recurso = 'clientes'
      AND p2.acao = 'read'
    ) THEN '? Clientes' ELSE '? Clientes'
  END as modulo_clientes
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
WHERE f.email = 'sousajenifer895@gmail.com';
```

---

## ? CHECKLIST FINAL

- [ ] Script SQL executado sem erros
- [ ] Verificações mostraram ? nos módulos
- [ ] Jennifer fez logout completo
- [ ] Jennifer fez login novamente
- [ ] Todos os módulos aparecem no menu
- [ ] Funcionalidades testadas e funcionando
- [ ] Permissões granulares funcionando (cancelar, descontos, etc.)

---

## ?? CONCLUSÃO

Após executar este script:

1. ? **Todas as 40 permissões** de Jennifer estarão **funcionando**
2. ? **Permissões granulares** (cancel, discount, export) estarão **mapeadas**
3. ? **Novos funcionários** criados com essas permissões **não terão problemas**
4. ? **Sistema funcionará perfeitamente** com permissões básicas e granulares

---

**?? Arquivos Relacionados:**
- `CORRIGIR_PERMISSOES_JENNIFER_COMPLETO.sql` - Script SQL completo
- `GUIA_VISUAL_EDITAR_PERMISSOES_USUARIO.md` - Guia de edição via interface
- `GUIA_RAPIDO_PERMISSOES.md` - Guia rápido de referência

**?? Suporte:**
Se ainda tiver problemas, verifique:
1. Logs do console do navegador (F12)
2. Query `SELECT * FROM funcao_permissoes WHERE funcao_id = 'FUNCAO_ID'`
3. Verificar RLS com `SELECT * FROM pg_policies WHERE tablename = 'funcao_permissoes'`
