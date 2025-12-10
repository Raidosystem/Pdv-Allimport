# ?? GUIA DE EXECUÇÃO - Correção Jennifer

## ?? Resumo do Problema

Jennifer (sousajenifer895@gmail.com) não consegue acessar o sistema completo porque:
1. A coluna `funcao_id` na tabela `funcionarios` não está editável corretamente
2. As permissões da função atribuída podem não estar configuradas
3. Falta uma RPC para atualizar `funcao_id` de forma segura

## ? Solução

Execute o arquivo `CORRECAO_JENNIFER_FUNCOES.sql` no Supabase SQL Editor

### Passo 1: Abrir Supabase SQL Editor

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em **SQL Editor** no menu lateral
4. Clique em **+ New Query**

### Passo 2: Executar o Script

1. Copie todo o conteúdo do arquivo `CORRECAO_JENNIFER_FUNCOES.sql`
2. Cole no editor SQL
3. Clique em **Run** (ou pressione `Ctrl+Enter`)

### Passo 3: Verificar Resultados

O script irá:

#### ? PARTE 1: Verificar Estrutura Atual
- Mostrar os dados atuais de Jennifer
- Listar suas permissões

#### ? PARTE 2: Garantir funcao_id Editável
- Verificar constraints que possam bloquear updates
- Checar triggers conflitantes

#### ? PARTE 3: Criar RPC
Cria a função `atualizar_funcao_funcionario`:
```sql
CREATE OR REPLACE FUNCTION atualizar_funcao_funcionario(
  p_funcionario_id UUID,
  p_funcao_id UUID
)
RETURNS JSON
```

#### ? PARTE 4: Verificar Permissões
- Conta quantas permissões a função de Jennifer tem
- Alerta se não houver permissões

#### ? PARTE 5: Teste de Permissões
- Lista todas as permissões que Jennifer deve ter

#### ? PARTE 6: Verificação Final
- Mostra funcionário
- Mostra função
- Mostra permissões

## ?? Como Editar a Função de Jennifer

### Opção 1: Via SQL (Direto no Editor)

```sql
-- 1. Listar funções disponíveis
SELECT id, nome, descricao 
FROM funcoes 
WHERE empresa_id = (SELECT empresa_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com');

-- 2. Atualizar funcao_id de Jennifer
SELECT atualizar_funcao_funcionario(
  '866ae21a-ba51-4fca-bbba-4d4610017a4e', -- ID de Jennifer
  'COLE_O_FUNCAO_ID_AQUI' -- ID da função desejada do passo 1
);
```

### Opção 2: Via Sistema (AdminUsersPage)

1. Acesse **Administração > Usuários**
2. Clique em **Editar** ao lado de Jennifer
3. Selecione a **Função Principal** desejada no dropdown
4. Clique em **Salvar Alterações**

O código já está preparado no `EditUserModal` do `AdminUsersPage.tsx`:

```typescript
// ? Campo para editar função
<div>
  <label className="block text-sm font-medium text-gray-700 mb-2">
    Função Principal *
  </label>
  <select
    value={funcaoId}
    onChange={(e) => setFuncaoId(e.target.value)}
    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
    required
  >
    <option value="">Selecione uma função</option>
    {funcoes.map((funcao) => (
      <option key={funcao.id} value={funcao.id}>
        {funcao.nome}
      </option>
    ))}
  </select>
</div>
```

## ?? Como Configurar Permissões da Função

### Via Sistema (AdminRolesPermissionsPageNew)

1. Acesse **Administração > Funções & Permissões**
2. Encontre a função de Jennifer
3. Clique em **Permissões**
4. Marque/desmarque as permissões desejadas:
   - ? **Vendas**: `vendas:read`, `vendas:create`
   - ? **Produtos**: `produtos:read`, `produtos:create`
   - ? **Clientes**: `clientes:read`, `clientes:create`
   - ? **Caixa**: `caixa:read`, `caixa:open`
   - ? **Ordens de Serviço**: `ordens_servico:read`, `ordens_servico:create`
   - ? **Relatórios**: `relatorios:read`
5. Clique em **Salvar Permissões**

### Via SQL (Adicionar Permissões Manualmente)

```sql
-- 1. Pegar ID da função de Jennifer
SELECT funcao_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com';

-- 2. Listar permissões disponíveis
SELECT id, recurso, acao, descricao FROM permissoes ORDER BY recurso, acao;

-- 3. Adicionar permissões à função (exemplo: Vendedor completo)
INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
SELECT 
  '{{ funcao_id }}', -- ID da função
  p.id,
  (SELECT empresa_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com')
FROM permissoes p
WHERE p.recurso IN ('vendas', 'produtos', 'clientes')
AND p.acao IN ('create', 'read', 'update')
ON CONFLICT DO NOTHING;
```

## ?? Testar Após Configuração

1. Jennifer faz **logout** do sistema
2. Jennifer faz **login** novamente
3. Verificar se tem acesso aos módulos esperados

Se ainda não funcionar:

```sql
-- Diagnosticar permissões de Jennifer
SELECT 
  f.nome as funcionario,
  func.nome as funcao,
  COUNT(fp.permissao_id) as total_permissoes,
  STRING_AGG(p.recurso || ':' || p.acao, ', ') as permissoes
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
LEFT JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
GROUP BY f.id, f.nome, func.nome;
```

## ?? Estrutura do Banco

### Tabela: `funcionarios`
```sql
CREATE TABLE funcionarios (
  id UUID PRIMARY KEY,
  empresa_id UUID REFERENCES empresas(id),
  funcao_id UUID REFERENCES funcoes(id), -- ? Coluna que vamos editar
  nome TEXT,
  email TEXT,
  status TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
);
```

### Tabela: `funcoes`
```sql
CREATE TABLE funcoes (
  id UUID PRIMARY KEY,
  empresa_id UUID,
  nome TEXT,
  descricao TEXT,
  created_at TIMESTAMPTZ
);
```

### Tabela: `funcao_permissoes`
```sql
CREATE TABLE funcao_permissoes (
  funcao_id UUID REFERENCES funcoes(id),
  permissao_id UUID REFERENCES permissoes(id),
  empresa_id UUID,
  created_at TIMESTAMPTZ,
  PRIMARY KEY (funcao_id, permissao_id)
);
```

## ?? Troubleshooting

### Problema: "Função não tem permissões"

**Solução**: Execute o script de popular permissões padrão
```sql
-- Ver arquivo: ATIVAR_PERMISSOES_PADRAO_FUNCOES_CORRIGIDO.sql
```

### Problema: "funcao_id não atualiza"

**Causa**: RLS bloqueando update  
**Solução**: Usar a RPC `atualizar_funcao_funcionario` que tem `SECURITY DEFINER`

### Problema: "Jennifer não aparece na lista de usuários"

**Causa**: RLS filtrando por empresa_id diferente  
**Solução**: Verificar empresa_id
```sql
SELECT empresa_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com';
```

## ?? Suporte

Se após executar este guia Jennifer ainda não conseguir acessar:

1. Execute o diagnóstico completo:
```sql
-- Cole aqui o conteúdo de DIAGNOSTICO_COMPLETO_SISTEMA.sql
```

2. Verifique logs do console do navegador (F12)
3. Verifique logs do Supabase Dashboard > Logs & Reports

## ? Checklist Final

- [ ] Script `CORRECAO_JENNIFER_FUNCOES.sql` executado
- [ ] RPC `atualizar_funcao_funcionario` criada
- [ ] `funcao_id` de Jennifer atualizado
- [ ] Permissões da função configuradas
- [ ] Jennifer testou login e acesso aos módulos
- [ ] Todos os módulos esperados estão visíveis

---

**Última atualização**: {{DATE}}  
**Autor**: Sistema PDV Allimport  
**Versão**: 1.0
