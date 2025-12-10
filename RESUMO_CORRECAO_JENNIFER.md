# ? RESUMO - Correção Jennifer

## ?? Objetivo
Permitir que Jennifer (sousajenifer895@gmail.com) tenha acesso completo ao sistema PDV através da edição de sua função e permissões.

## ?? Arquivos Relevantes

### 1. **CORRECAO_JENNIFER_FUNCOES.sql** (Principal)
- ? Script SQL completo para executar no Supabase
- ? Verifica estrutura atual de Jennifer
- ? Cria RPC `atualizar_funcao_funcionario`
- ? Verifica e diagnóstica permissões
- ? Fornece queries de teste

### 2. **GUIA_EXECUCAO_JENNIFER.md** (Passo a Passo)
- ? Guia completo de execução
- ? Opções via SQL e via Sistema
- ? Troubleshooting detalhado
- ? Exemplos práticos

### 3. **Código TypeScript Atualizado**
- ? `src/types/admin.ts` - Adiciona `empresa_id` ao `UsePermissionsReturn`
- ? `src/hooks/usePermissions.tsx` - Retorna `empresa_id` do contexto
- ? `src/pages/admin/AdminUsersPage.tsx` - Modal de edição com campo de função
- ? `src/pages/admin/AdminRolesPermissionsPageNew.tsx` - Gerenciamento de permissões

## ?? Como Usar

### Passo 1: Executar SQL
```bash
# No Supabase SQL Editor
1. Cole o conteúdo de CORRECAO_JENNIFER_FUNCOES.sql
2. Execute (Ctrl+Enter)
3. Verifique os resultados
```

### Passo 2: Editar Função de Jennifer

**Opção A: Via Sistema (Recomendado)**
```
1. Acesse Administração > Usuários
2. Clique em Editar ao lado de Jennifer
3. Selecione a Função Principal desejada
4. Salve
```

**Opção B: Via SQL**
```sql
-- Listar funções disponíveis
SELECT id, nome FROM funcoes WHERE empresa_id = (
  SELECT empresa_id FROM funcionarios 
  WHERE email = 'sousajenifer895@gmail.com'
);

-- Atualizar (substitua o ID)
SELECT atualizar_funcao_funcionario(
  '866ae21a-ba51-4fca-bbba-4d4610017a4e',
  'FUNCAO_ID_AQUI'
);
```

### Passo 3: Configurar Permissões da Função

**Via Sistema:**
```
1. Acesse Administração > Funções & Permissões
2. Encontre a função de Jennifer
3. Clique em Permissões
4. Marque as permissões desejadas
5. Salve
```

## ?? Estrutura do Sistema

### Fluxo de Permissões
```
funcionarios.funcao_id ? funcoes.id ? funcao_permissoes ? permissoes
```

### Tabelas Principais
- `funcionarios`: Dados do funcionário + referência à função
- `funcoes`: Funções/cargos da empresa
- `funcao_permissoes`: Relacionamento função ? permissões
- `permissoes`: Catálogo de permissões do sistema

### RPC Criada
```sql
atualizar_funcao_funcionario(
  p_funcionario_id UUID,
  p_funcao_id UUID
) RETURNS JSON
```

## ? Verificações

### Diagnóstico Rápido
```sql
-- Ver função atual de Jennifer
SELECT 
  f.nome as funcionario,
  func.nome as funcao,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE f.email = 'sousajenifer895@gmail.com'
GROUP BY f.nome, func.nome;
```

### Teste de Login
```
1. Jennifer faz logout
2. Jennifer faz login novamente
3. Verificar se módulos esperados estão visíveis
```

## ?? Código TypeScript

### Hook usePermissions
```typescript
const { can, empresa_id } = usePermissions()

// Verificar permissão
if (can('vendas', 'create')) {
  // Permitir criar venda
}
```

### EditUserModal (AdminUsersPage)
```typescript
// Campo de seleção de função
<select
  value={funcaoId}
  onChange={(e) => setFuncaoId(e.target.value)}
>
  <option value="">Selecione uma função</option>
  {funcoes.map((funcao) => (
    <option key={funcao.id} value={funcao.id}>
      {funcao.nome}
    </option>
  ))}
</select>
```

## ?? Problemas Comuns

### 1. "Função não tem permissões"
**Solução**: Configure permissões em Funções & Permissões

### 2. "funcao_id não atualiza"
**Solução**: Use a RPC `atualizar_funcao_funcionario`

### 3. "Jennifer não aparece na lista"
**Solução**: Verifique RLS e empresa_id

### 4. "Login funciona mas não vê módulos"
**Solução**: Verifique se a função tem permissões configuradas

## ?? Testes

### Checklist de Validação
- [ ] Script SQL executado sem erros
- [ ] RPC `atualizar_funcao_funcionario` existe
- [ ] Jennifer tem `funcao_id` não-nulo
- [ ] Função tem permissões configuradas
- [ ] Login de Jennifer funciona
- [ ] Jennifer vê os módulos esperados
- [ ] Jennifer consegue executar ações permitidas

### Query de Validação Completa
```sql
-- Executar para ver tudo de Jennifer
SELECT 
  '?? FUNCIONÁRIO' as secao,
  f.id,
  f.nome,
  f.email,
  f.funcao_id,
  f.status
FROM funcionarios f
WHERE f.email = 'sousajenifer895@gmail.com'

UNION ALL

SELECT 
  '?? FUNÇÃO' as secao,
  func.id,
  func.nome,
  func.descricao,
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
  NULL
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'sousajenifer895@gmail.com'
ORDER BY secao, nome;
```

## ?? Documentação Adicional

- `CORRECAO_JENNIFER_FUNCOES.sql` - Script SQL principal
- `GUIA_EXECUCAO_JENNIFER.md` - Guia passo a passo detalhado
- `src/pages/admin/AdminUsersPage.tsx` - Interface de edição de usuários
- `src/pages/admin/AdminRolesPermissionsPageNew.tsx` - Interface de funções e permissões
- `src/hooks/usePermissions.tsx` - Hook de verificação de permissões

## ?? Conclusão

Após executar os passos acima:
- ? Jennifer terá uma função atribuída
- ? A função terá permissões configuradas
- ? Jennifer poderá acessar os módulos permitidos
- ? O sistema respeitará as permissões configuradas

**Tempo estimado de correção**: 5-10 minutos  
**Complexidade**: Baixa (apenas configuração, sem alterações estruturais)  
**Impacto**: Zero (não afeta outros usuários)

---

**Data**: {{DATE}}  
**Versão**: 1.0  
**Autor**: Sistema PDV Allimport
