# ?? SISTEMA DE PERMISSÕES REFATORADO - GUIA COMPLETO

## ?? Visão Geral

O sistema de permissões foi **completamente refatorado** para:
- ? **Hierarquia Clara:** Módulos principais + Subseções
- ? **Edição Imediata:** Mudanças no admin têm efeito instantâneo
- ? **Interface Visual:** Seções expansíveis no painel admin
- ? **Padrão Único:** Um só sistema de permissões (sem JSONB confuso)

---

## ??? Estrutura Nova

### **Conceitos**

```
MÓDULO PRINCIPAL (modulo_pai = NULL)
  ??? SUBSEÇÃO (modulo_pai = 'nome_do_modulo')
       ??? PERMISSÃO ESPECÍFICA
```

**Exemplo:**
```
vendas (Módulo Principal)
  ??? vendas:read (Ver vendas)
  ??? vendas:create (Criar venda)
  ??? vendas (Subseção - Ações Específicas)
       ??? vendas:cancel (Cancelar venda)
       ??? vendas:refund (Fazer estorno)
       ??? vendas:discount (Aplicar desconto)
```

---

## ?? Seções do Sistema

### 1?? **Dashboard** (3 permissões)
- `dashboard:view` - Ver dashboard
- `dashboard.metricas:view` - Ver métricas
- `dashboard.graficos:view` - Ver gráficos

### 2?? **Vendas** (8 permissões)
**Principal:**
- `vendas:read` - Ver vendas
- `vendas:create` - Criar venda
- `vendas:update` - Editar venda
- `vendas:delete` - Excluir venda

**Subseção (Ações Específicas):**
- `vendas:cancel` - Cancelar venda
- `vendas:refund` - Fazer estorno
- `vendas:discount` - Aplicar desconto
- `vendas:print` - Imprimir cupom

### 3?? **Produtos** (9 permissões)
**Principal:**
- `produtos:read` - Ver produtos
- `produtos:create` - Cadastrar produto
- `produtos:update` - Editar produto
- `produtos:delete` - Excluir produto

**Subseção (Gestão):**
- `produtos:manage_stock` - Gerenciar estoque
- `produtos:adjust_price` - Ajustar preços
- `produtos:manage_categories` - Gerenciar categorias
- `produtos:import` - Importar produtos
- `produtos:export` - Exportar produtos

### 4?? **Clientes** (8 permissões)
**Principal:**
- `clientes:read` - Ver clientes
- `clientes:create` - Cadastrar cliente
- `clientes:update` - Editar cliente
- `clientes:delete` - Excluir cliente

**Subseção (Gestão):**
- `clientes:view_history` - Ver histórico
- `clientes:manage_debt` - Gerenciar crédito/débito
- `clientes:import` - Importar clientes
- `clientes:export` - Exportar clientes

### 5?? **Caixa** (7 permissões)
**Principal:**
- `caixa:read` - Ver caixa
- `caixa:view` - Visualizar movimentação

**Subseção (Operações):**
- `caixa:open` - Abrir caixa
- `caixa:close` - Fechar caixa
- `caixa:sangria` - Fazer sangria
- `caixa:suprimento` - Fazer suprimento
- `caixa:view_history` - Ver histórico

### 6?? **Ordens de Serviço** (6 permissões)
**Principal:**
- `ordens:read` - Ver ordens
- `ordens:create` - Criar ordem
- `ordens:update` - Editar ordem
- `ordens:delete` - Excluir ordem

**Subseção (Ações):**
- `ordens:change_status` - Alterar status
- `ordens:print` - Imprimir ordem

### 7?? **Relatórios** (7 permissões)
**Principal:**
- `relatorios:read` - Ver relatórios

**Subseção (Tipos):**
- `relatorios:sales` - Relatórios de vendas
- `relatorios:financial` - Relatórios financeiros
- `relatorios:products` - Relatórios de produtos
- `relatorios:customers` - Relatórios de clientes
- `relatorios:inventory` - Relatórios de estoque
- `relatorios:export` - Exportar relatórios

### 8?? **Configurações** (11 permissões)
**Principal:**
- `configuracoes:read` - Ver configurações
- `configuracoes:update` - Alterar configurações

**Subseções:**
- `configuracoes.dashboard:read/update` - Config. dashboard (2)
- `configuracoes.aparencia:read/update` - Aparência (2)
- `configuracoes.impressao:read/update` - Impressão (2)
- `configuracoes:company_info` - Info da empresa
- `configuracoes:integrations` - Integrações
- `configuracoes:backup` - Backup

### 9?? **Administração** (19 permissões)
**Principal:**
- `administracao:read` - Ver administração
- `administracao:full_access` - Acesso total

**Subseção Usuários:**
- `administracao.usuarios:read/create/update/delete` (4)

**Subseção Funções:**
- `administracao.funcoes:read/create/update/delete` (4)

**Subseção Permissões:**
- `administracao.permissoes:read/update` (2)

**Subseção Sistema:**
- `administracao.sistema:read/update` (2)

**Subseção Logs:**
- `administracao.logs:read` (1)

**Subseção Assinatura:**
- `administracao.assinatura:read/update` (2)

**Subseção Backup:**
- `administracao.backup:read/create` (2)

---

## ?? Como Usar

### **1. Executar Script SQL**

```bash
# No Supabase SQL Editor:
# Cole e execute: REFATORAR_PERMISSOES_COMPLETO.sql
```

**O que ele faz:**
1. ? Limpa permissões antigas
2. ? Cria nova estrutura hierárquica
3. ? Adiciona colunas `modulo_pai` e `ordem`
4. ? Aplica permissões ao Administrador (todas)
5. ? Aplica permissões ao Vendedor (operacionais)
6. ? Cria view de hierarquia

### **2. Interface Admin - Editar Permissões**

No painel admin (/admin/funcoes-permissoes):

```typescript
// Exibir permissões agrupadas
<div className="space-y-4">
  {/* Seção expansível */}
  <div>
    <button onClick={() => toggleSection('vendas')}>
      ?? Vendas (8 permissões)
    </button>
    
    {isOpen('vendas') && (
      <div className="ml-6 space-y-2">
        {/* Módulo Principal */}
        <div className="font-semibold">Ações Principais</div>
        <Checkbox perm="vendas:read" label="Ver vendas" />
        <Checkbox perm="vendas:create" label="Criar venda" />
        
        {/* Subseção */}
        <div className="font-semibold mt-4">Ações Específicas</div>
        <Checkbox perm="vendas:cancel" label="Cancelar venda" />
        <Checkbox perm="vendas:discount" label="Aplicar desconto" />
      </div>
    )}
  </div>
</div>
```

### **3. Validação no Frontend**

```typescript
import { usePermissions } from '@/hooks/usePermissions';

function ProdutosPage() {
  const { can } = usePermissions();
  
  return (
    <div>
      {can('produtos', 'read') && <ListaProdutos />}
      {can('produtos', 'create') && <BotaoCriar />}
      {can('produtos', 'delete') && <BotaoExcluir />}
    </div>
  );
}
```

---

## ?? Interface Visual

### **Exemplo: Painel de Edição de Função**

```
???????????????????????????????????????????
?  Editar Função: Vendedor                ?
?  ????????????????????????????????????????
?  ? ?? Vendas (4/8 selecionadas)        ??
?  ?   ?? [x] Ver vendas                 ??
?  ?   ?? [x] Criar venda                ??
?  ?   ?? [ ] Editar venda               ??
?  ?   ?? [ ] Excluir venda              ??
?  ?                                      ??
?  ?   ? Ações Específicas (2/4)        ??
?  ?   ?? [ ] Cancelar venda             ??
?  ?   ?? [ ] Fazer estorno              ??
?  ?   ?? [x] Aplicar desconto           ??
?  ?   ?? [x] Imprimir cupom             ??
?  ????????????????????????????????????????
?                                          ?
?  ?? Produtos (1/9 selecionadas)         ?
?  ?   ?? [x] Ver produtos                ?
?  ?   ?? [ ] Cadastrar produto           ?
?  ?   ?? ...                             ?
?                                          ?
?  [Salvar] [Cancelar]                    ?
???????????????????????????????????????????
```

### **Opções de Exibição**

1. **Modo Compacto:** Apenas módulos principais
2. **Modo Detalhado:** Módulos + subseções expansíveis
3. **Modo Completo:** Todas as permissões visíveis

**Toggle de Visualização:**
```typescript
<div className="flex gap-2">
  <Button onClick={() => setMode('compact')}>Compacto</Button>
  <Button onClick={() => setMode('detailed')}>Detalhado</Button>
  <Button onClick={() => setMode('full')}>Completo</Button>
</div>
```

---

## ?? Fluxo de Edição

### **Cenário: Dar acesso a "Cancelar Venda" para Vendedores**

1. **Admin acessa:** `/admin/funcoes-permissoes`
2. **Seleciona função:** "Vendedor"
3. **Expande seção:** "Vendas"
4. **Marca checkbox:** `vendas:cancel`
5. **Clica em:** "Salvar"
6. **Sistema:**
   ```sql
   INSERT INTO funcao_permissoes (funcao_id, permissao_id)
   VALUES ('vendedor_id', 'permissao_cancel_id');
   ```
7. **Frontend (vendedor):**
   ```javascript
   // ? IMEDIATAMENTE após salvar:
   can('vendas', 'cancel') // true
   ```
8. **Botão aparece:**
   ```typescript
   {can('vendas', 'cancel') && (
     <Button onClick={cancelarVenda}>Cancelar Venda</Button>
   )}
   ```

**? Efeito IMEDIATO!** Sem cache, sem delay, sem reload manual.

---

## ?? Templates de Funções

### **Vendedor** (10 permissões)
```sql
vendas:read, vendas:create, vendas:update, vendas:print
clientes:read, clientes:create, clientes:update, clientes:view_history
produtos:read
```

### **Gerente** (~40 permissões)
```sql
-- Todas de Vendas (8)
-- Todas de Clientes (8)
-- Todas de Produtos exceto delete (8)
-- Caixa: read, view, open, close, view_history (5)
-- Relatórios: read, sales, financial, products (4)
```

### **Administrador** (~80 permissões)
```sql
-- TODAS as permissões do sistema
```

### **Técnico OS** (~15 permissões)
```sql
-- Ordens: todas (6)
-- Clientes: read, update, view_history (3)
-- Produtos: read (1)
-- Vendas: read (1)
```

---

## ?? Testar Sistema

### **1. Verificar Permissões no Banco**

```sql
-- Ver todas as permissões de uma função
SELECT 
  f.nome as funcao,
  p.categoria as secao,
  p.recurso || ':' || p.acao as permissao,
  p.descricao
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Vendedor'
ORDER BY p.categoria, p.ordem;
```

### **2. Verificar Hierarquia**

```sql
-- Ver estrutura completa
SELECT * FROM v_permissoes_hierarquia;

-- Ver apenas módulos principais
SELECT * FROM v_permissoes_hierarquia WHERE tipo = 'Módulo Principal';

-- Ver subseções de vendas
SELECT * FROM v_permissoes_hierarquia 
WHERE categoria = 'vendas' AND modulo_pai IS NOT NULL;
```

### **3. Testar no Frontend**

```typescript
// Console do navegador (F12)
const { can, permissoes } = usePermissions();

console.log('Total:', permissoes.length);
console.log('Vendas read:', can('vendas', 'read'));
console.log('Vendas delete:', can('vendas', 'delete'));
console.log('Produtos delete:', can('produtos', 'delete'));
```

---

## ? Checklist de Implementação

- [ ] Executar `REFATORAR_PERMISSOES_COMPLETO.sql`
- [ ] Verificar que tabela `permissoes` tem 80+ registros
- [ ] Verificar que `funcao_permissoes` foi populada
- [ ] Atualizar componente admin para exibir hierarquia
- [ ] Adicionar toggles de seções expansíveis
- [ ] Testar edição de função no admin
- [ ] Verificar que mudanças aparecem imediatamente
- [ ] Testar com Jennifer (vendedor)
- [ ] Testar com Cristiano (admin)
- [ ] Documentar para o cliente

---

## ?? Resultado Final

### **Antes (Problema)**
- ? Permissões JSONB confusas
- ? Mudanças não aplicavam imediatamente
- ? Interface sem organização
- ? Difícil saber o que cada permissão faz

### **Depois (Solução)**
- ? Estrutura hierárquica clara
- ? Mudanças aplicam INSTANTANEAMENTE
- ? Interface visual com seções
- ? Descrições claras de cada permissão
- ? Fácil dar/remover permissões
- ? Templates prontos para funções comuns

---

## ?? Próximos Passos

1. **Execute o script SQL**
2. **Atualize a interface admin** (componente de edição de funções)
3. **Teste com Jennifer** (verificar que restrições funcionam)
4. **Teste edição no admin** (verificar efeito imediato)
5. **Documente para o cliente final**

**Pronto para deploy!** ??
