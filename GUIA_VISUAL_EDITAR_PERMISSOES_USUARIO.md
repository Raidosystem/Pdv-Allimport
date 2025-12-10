# ?? GUIA VISUAL: Como Editar Permissões de um Funcionário

## ?? Objetivo
Mostrar **EXATAMENTE onde** e **como** editar as permissões de um funcionário já criado (como a Jennifer).

---

## ?? MÉTODO 1: Via Interface (RECOMENDADO)

### Passo 1: Acessar o Painel de Administração

```
1. Faça login como ADMINISTRADOR
2. Clique no menu lateral em "Administração"
3. Selecione "Funções & Permissões"
```

**Caminho Completo:**
```
Dashboard ? Menu Lateral ? Administração ? Funções & Permissões
```

**Localização no Código:**
- Arquivo: `src/pages/admin/AdminRolesPermissionsPageNew.tsx`
- Rota: `/admin/roles-permissions` (ou similar)

---

### Passo 2: Encontrar a Função do Usuário

Você verá uma **tela com cards** mostrando todas as funções:

```
???????????????????????????????????????????????????
?  ???  Funções & Permissões                      ?
?  Gerencie as funções do sistema                ?
?                              [+ Nova Função]    ?
???????????????????????????????????????????????????
?  ?? [Buscar funções...]                         ?
???????????????????????????????????????????????????
?                                                 ?
?  ????????????????  ????????????????           ?
?  ? ??? Vendedor  ?  ? ??? Gerente   ?           ?
?  ?              ?  ?              ?           ?
?  ? Acesso a     ?  ? Acesso       ?           ?
?  ? vendas e     ?  ? gerencial    ?           ?
?  ? clientes     ?  ?              ?           ?
?  ?              ?  ?              ?           ?
?  ? [??? Permissões] ?  ? [??? Permissões] ?     ?
?  ? [??] [???]    ?  ? [??] [???]    ?           ?
?  ????????????????  ????????????????           ?
???????????????????????????????????????????????????
```

**?? IMPORTANTE:**
- A Jennifer tem uma **função atribuída** (ex: "Vendedor", "Funcionário", etc.)
- Você precisa clicar em **"Permissões"** no card da função dela

---

### Passo 3: Clicar no Botão "Permissões"

No card da função que Jennifer possui, clique no botão azul:

```
????????????????????????????
? ??? Vendedor             ?
?                          ?
? Acesso a vendas e        ?
? clientes                 ?
?                          ?
? ??????????????????????  ?
? ?  ???  Permissões    ? ? CLIQUE AQUI
? ??????????????????????  ?
? [??] [???]               ?
????????????????????????????
```

**Código Responsável:**
```typescript
// AdminRolesPermissionsPageNew.tsx - Linha ~445
<button
  onClick={() => handleOpenPermissions(funcao)}
  className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg"
>
  <Eye className="w-4 h-4" />
  Permissões
</button>
```

---

### Passo 4: Modal de Permissões Abre

Um **modal GRANDE** irá abrir mostrando todas as permissões organizadas por categoria:

```
???????????????????????????????????????????????????????????
?  Permissões: Vendedor                                   ?
?  15 permissão(ões) selecionada(s)                  [?]  ?
???????????????????????????????????????????????????????????
?                                                         ?
?  ? ?? Vendas                              3 selecionadas?
?     ???????????????????????????????????????????????   ?
?     ? ?? vendas [ Criar ]                         ?   ?
?     ?    Criar nova venda                         ?   ?
?     ???????????????????????????????????????????????   ?
?     ? ?? vendas [ Visualizar ]                    ?   ?
?     ?    Visualizar vendas                        ?   ?
?     ???????????????????????????????????????????????   ?
?     ? ?? vendas [ Editar ]                        ?   ?
?     ?    Editar vendas                            ?   ?
?     ???????????????????????????????????????????????   ?
?                                                         ?
?  ? ?? Produtos                           2 selecionadas?
?     ???????????????????????????????????????????????   ?
?     ? ?? produtos [ Visualizar ]                  ?   ?
?     ?    Visualizar produtos                      ?   ?
?     ???????????????????????????????????????????????   ?
?     ? ? produtos [ Criar ]                        ?   ?
?     ?    Cadastrar novos produtos                 ?   ?
?     ???????????????????????????????????????????????   ?
?                                                         ?
?  ? ?? Clientes                           0 selecionadas?
?                                                         ?
?  ? ?? Financeiro                         0 selecionadas?
?                                                         ?
???????????????????????????????????????????????????????????
?  [Cancelar]          [? Salvar Permissões (15)]       ?
???????????????????????????????????????????????????????????
```

**Código Responsável:**
```typescript
// AdminRolesPermissionsPageNew.tsx - Linha ~550
{showPermissionsModal && selectedFuncao && (
  <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
    {/* Modal de Permissões */}
  </div>
)}
```

---

### Passo 5: Marcar/Desmarcar Permissões

**Como Funciona:**

1. **Expandir Categoria**: Clique na seta `?` ou `?` para abrir/fechar
2. **Marcar Permissão**: Clique na caixa de seleção `?` para virar `??`
3. **Contador**: No topo mostra quantas permissões estão selecionadas

**Exemplos de Permissões:**

```
?? vendas [ Criar ]           ? Permite criar vendas
?? vendas [ Visualizar ]      ? Permite ver vendas
?? vendas [ Editar ]          ? Permite editar vendas
? vendas [ Excluir ]          ? NÃO pode excluir vendas

?? produtos [ Visualizar ]    ? Pode ver produtos
? produtos [ Criar ]          ? NÃO pode criar produtos
? produtos [ Editar ]         ? NÃO pode editar produtos
? produtos [ Excluir ]        ? NÃO pode excluir produtos

?? clientes [ Criar ]         ? Pode cadastrar clientes
?? clientes [ Visualizar ]    ? Pode ver clientes
?? clientes [ Editar ]        ? Pode editar clientes
? clientes [ Excluir ]        ? NÃO pode excluir clientes
```

**Código de Toggle:**
```typescript
// AdminRolesPermissionsPageNew.tsx - Linha ~364
const handleTogglePermissao = (permissaoId: string) => {
  setSelectedPermissoes(prev => 
    prev.includes(permissaoId)
      ? prev.filter(id => id !== permissaoId)
      : [...prev, permissaoId]
  );
};
```

---

### Passo 6: Salvar as Alterações

Clique no botão **"Salvar Permissões (X)"** no rodapé do modal:

```
???????????????????????????????????????????????????????????
?  [Cancelar]          [? Salvar Permissões (15)]       ?
???????????????????????????????????????????????????????????
                           ?
                      CLIQUE AQUI
```

**O que acontece:**
1. ? Deletar permissões antigas da função
2. ? Inserir novas permissões selecionadas
3. ? Atualizar banco de dados (`funcao_permissoes`)
4. ? Mostrar mensagem de sucesso
5. ? Recarregar permissões de todos os usuários

**Código de Salvar:**
```typescript
// AdminRolesPermissionsPageNew.tsx - Linha ~368
const handleSavePermissions = async () => {
  // Deletar permissões antigas
  await supabase
    .from('funcao_permissoes')
    .delete()
    .eq('funcao_id', selectedFuncao.id);

  // Inserir novas permissões
  const inserts = selectedPermissoes.map(permissao_id => ({
    funcao_id: selectedFuncao.id,
    permissao_id,
    empresa_id: empresa_id
  }));

  await supabase
    .from('funcao_permissoes')
    .insert(inserts);

  toast.success('Permissões atualizadas com sucesso!');
};
```

---

### Passo 7: Testar as Permissões

**Para que as novas permissões tenham efeito:**

1. Jennifer precisa fazer **LOGOUT**
2. Jennifer precisa fazer **LOGIN** novamente
3. As permissões serão recarregadas automaticamente

**Por que precisa relogar?**
- As permissões são carregadas no **contexto de autenticação**
- Ficam em cache durante a sessão
- Ao fazer login novamente, o sistema busca as permissões atualizadas

---

## ??? MÉTODO 2: Via SQL (Avançado)

Se você preferir editar permissões direto no banco de dados:

### Passo 1: Verificar Função Atual de Jennifer

```sql
-- Ver qual função Jennifer tem
SELECT 
  f.nome as funcionario,
  func.id as funcao_id,
  func.nome as funcao,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE f.email = 'sousajenifer895@gmail.com'
GROUP BY f.nome, func.id, func.nome;
```

**Resultado Esperado:**
```
funcionario | funcao_id                            | funcao    | total_permissoes
------------|--------------------------------------|-----------|------------------
Jennifer    | 123e4567-e89b-12d3-a456-426614174000 | Vendedor  | 15
```

---

### Passo 2: Listar Permissões Disponíveis

```sql
-- Ver todas as permissões disponíveis
SELECT 
  id,
  recurso,
  acao,
  descricao,
  categoria
FROM permissoes
ORDER BY categoria, recurso, acao;
```

**Resultado Esperado:**
```
id          | recurso   | acao        | descricao              | categoria
------------|-----------|-------------|------------------------|------------
perm-001    | vendas    | create      | Criar nova venda       | vendas
perm-002    | vendas    | read        | Visualizar vendas      | vendas
perm-003    | vendas    | update      | Editar vendas          | vendas
perm-004    | vendas    | delete      | Excluir vendas         | vendas
perm-005    | produtos  | read        | Visualizar produtos    | produtos
...
```

---

### Passo 3: Adicionar Permissão Específica

```sql
-- Adicionar permissão "produtos:create" para a função de Jennifer
INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
VALUES (
  (SELECT funcao_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com'),
  (SELECT id FROM permissoes WHERE recurso = 'produtos' AND acao = 'create'),
  (SELECT empresa_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com')
)
ON CONFLICT DO NOTHING;
```

---

### Passo 4: Remover Permissão Específica

```sql
-- Remover permissão "vendas:delete" da função de Jennifer
DELETE FROM funcao_permissoes
WHERE funcao_id = (SELECT funcao_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com')
AND permissao_id = (SELECT id FROM permissoes WHERE recurso = 'vendas' AND acao = 'delete');
```

---

### Passo 5: Definir Todas as Permissões de Uma Vez

```sql
-- Deletar todas as permissões atuais
DELETE FROM funcao_permissoes
WHERE funcao_id = (SELECT funcao_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com');

-- Adicionar conjunto específico de permissões
INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
SELECT 
  (SELECT funcao_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com'),
  p.id,
  (SELECT empresa_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com')
FROM permissoes p
WHERE 
  -- Vendas
  (p.recurso = 'vendas' AND p.acao IN ('create', 'read', 'update'))
  -- Produtos
  OR (p.recurso = 'produtos' AND p.acao IN ('read'))
  -- Clientes
  OR (p.recurso = 'clientes' AND p.acao IN ('create', 'read', 'update'))
  -- Caixa
  OR (p.recurso = 'caixa' AND p.acao IN ('read'))
  -- Ordens de Serviço
  OR (p.recurso = 'ordens_servico' AND p.acao IN ('create', 'read', 'update'))
ON CONFLICT DO NOTHING;
```

---

## ?? ESTRUTURA DO BANCO

### Fluxo de Permissões

```
funcionarios.funcao_id ? funcoes.id ? funcao_permissoes ? permissoes
```

### Tabelas Envolvidas

#### 1. `funcionarios`
```sql
CREATE TABLE funcionarios (
  id UUID PRIMARY KEY,
  nome TEXT,
  email TEXT,
  funcao_id UUID REFERENCES funcoes(id), ? Aponta para a função
  empresa_id UUID,
  status TEXT
);
```

#### 2. `funcoes`
```sql
CREATE TABLE funcoes (
  id UUID PRIMARY KEY,
  empresa_id UUID,
  nome TEXT,              ? "Vendedor", "Gerente", etc.
  descricao TEXT,
  nivel INTEGER
);
```

#### 3. `funcao_permissoes` (Pivot Table)
```sql
CREATE TABLE funcao_permissoes (
  funcao_id UUID REFERENCES funcoes(id),       ? FK para funções
  permissao_id UUID REFERENCES permissoes(id), ? FK para permissões
  empresa_id UUID,
  PRIMARY KEY (funcao_id, permissao_id)
);
```

#### 4. `permissoes`
```sql
CREATE TABLE permissoes (
  id UUID PRIMARY KEY,
  recurso TEXT,    ? "vendas", "produtos", "clientes", etc.
  acao TEXT,       ? "create", "read", "update", "delete"
  descricao TEXT,
  categoria TEXT
);
```

---

## ?? VERIFICAR PERMISSÕES ATUAIS

### Query Completa de Diagnóstico

```sql
-- Ver todas as informações de Jennifer em uma query
SELECT 
  '?? FUNCIONÁRIO' as secao,
  f.id,
  f.nome,
  f.email,
  f.funcao_id,
  NULL as recurso,
  NULL as acao
FROM funcionarios f
WHERE f.email = 'sousajenifer895@gmail.com'

UNION ALL

SELECT 
  '?? FUNÇÃO' as secao,
  func.id,
  func.nome,
  func.descricao,
  NULL,
  NULL,
  NULL
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
WHERE f.email = 'sousajenifer895@gmail.com'

UNION ALL

SELECT 
  '? PERMISSÕES' as secao,
  p.id,
  p.recurso,
  p.acao,
  p.descricao,
  p.categoria,
  NULL
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
ORDER BY secao, recurso, acao;
```

---

## ? CHECKLIST DE VALIDAÇÃO

Após editar as permissões, verifique:

- [ ] Função está atribuída ao funcionário (`funcao_id` não-nulo)
- [ ] Função tem permissões configuradas (`funcao_permissoes` > 0)
- [ ] Funcionário fez logout e login novamente
- [ ] Módulos esperados aparecem no menu lateral
- [ ] Funcionário consegue executar ações permitidas
- [ ] Ações NÃO permitidas exibem mensagem de erro

---

## ?? TROUBLESHOOTING

### Problema: "Permissões não mudaram após editar"
**Solução**: Funcionário precisa fazer **logout e login** novamente

### Problema: "Modal de permissões não abre"
**Solução**: Verifique se você tem permissão `administracao.funcoes:read`

### Problema: "Não consigo salvar permissões"
**Solução**: Verifique RLS da tabela `funcao_permissoes`

```sql
-- Verificar políticas RLS
SELECT * FROM pg_policies 
WHERE tablename = 'funcao_permissoes';
```

### Problema: "Funcionário não vê módulos após adicionar permissões"
**Causas Possíveis:**
1. Não fez logout/login
2. Permissões com nome errado (ex: `venda` ao invés de `vendas`)
3. RLS bloqueando consulta
4. Cache do navegador (Ctrl+Shift+R para limpar)

---

## ?? RESUMO VISUAL

```
?? Sistema PDV
   ?
   ?? ?? Funcionários (Jennifer)
   ?     ?? funcao_id ?????????????
   ?                               ?
   ?? ?? Funções (Vendedor)       ??
   ?     ?? id ??????????????
   ?                         ?
   ?? ?? funcao_permissoes  ??
   ?     ?? funcao_id
   ?     ?? permissao_id ?????
   ?                          ?
   ?? ? Permissões          ??
         ?? vendas:create
         ?? vendas:read
         ?? produtos:read
         ?? clientes:create
```

---

## ?? CONCLUSÃO

**Para editar permissões de Jennifer:**

1. ? **Via Interface** (Recomendado):
   - Acesse: `Administração ? Funções & Permissões`
   - Encontre a função dela (ex: "Vendedor")
   - Clique no botão **"??? Permissões"**
   - Marque/desmarque as permissões desejadas
   - Clique em **"Salvar Permissões"**
   - Jennifer faz **logout e login**

2. ? **Via SQL** (Avançado):
   - Execute queries do **MÉTODO 2** deste guia
   - Insira/remova permissões em `funcao_permissoes`
   - Jennifer faz **logout e login**

**Tempo Estimado**: 2-5 minutos  
**Complexidade**: Baixa  
**Impacto**: Apenas na função editada (não afeta outras funções)

---

**Arquivo**: `src/pages/admin/AdminRolesPermissionsPageNew.tsx`  
**Rota**: `/admin/roles-permissions`  
**Versão**: 1.0  
**Data**: {{DATE}}
