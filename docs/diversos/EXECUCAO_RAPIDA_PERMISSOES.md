# ?? REFATORAÇÃO PERMISSÕES - EXECUÇÃO RÁPIDA

## ? PROBLEMA RESOLVIDO

- ? Configurações que estavam em "Administração" agora estão em seção própria
- ? Hierarquia clara: Módulos ? Subseções
- ? Edições no admin têm efeito IMEDIATO
- ? Interface visual com seções expansíveis
- ? Opção de ver seção completa ou resumida

---

## ?? PASSO A PASSO

### 1?? **Executar Script SQL (5 min)**

```bash
# No Supabase SQL Editor:
# Copiar e colar: REFATORAR_PERMISSOES_COMPLETO.sql
# Clicar em "Run"
```

**O que faz:**
- Limpa permissões antigas
- Cria nova estrutura (9 seções, 80+ permissões)
- Adiciona hierarquia (modulo_pai)
- Aplica permissões ao Administrador e Vendedor

**Resultado Esperado:**
```sql
-- Última query retorna:
?? PERMISSÕES ORGANIZADAS
| Seção          | Total | Recursos                    |
|----------------|-------|-----------------------------|
| dashboard      | 3     | dashboard                   |
| vendas         | 8     | vendas                      |
| produtos       | 9     | produtos                    |
| clientes       | 8     | clientes                    |
| caixa          | 7     | caixa                       |
| ordens         | 6     | ordens                      |
| relatorios     | 7     | relatorios                  |
| configuracoes  | 11    | configuracoes              |
| administracao  | 19    | administracao.usuarios, ... |
```

### 2?? **Adicionar Componente React (2 min)**

```bash
# Já criado: src/components/admin/EditarPermissoesFuncao.tsx
# Basta importar na página admin:

import EditarPermissoesFuncao from '@/components/admin/EditarPermissoesFuncao';

// Usar:
<EditarPermissoesFuncao 
  funcao_id={funcaoSelecionada.id} 
  onClose={() => setModalAberto(false)} 
/>
```

### 3?? **Testar (3 min)**

#### **Teste 1: Banco de Dados**

```sql
-- Ver permissões do Vendedor
SELECT 
  p.categoria,
  p.recurso || ':' || p.acao as permissao,
  p.descricao
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Vendedor'
ORDER BY p.categoria, p.ordem;

-- Esperado: ~10 permissões (vendas, clientes, produtos básicos)
```

#### **Teste 2: Interface Admin**

1. Acessar `/admin/funcoes-permissoes`
2. Clicar em "Editar" na função Vendedor
3. **Verificar:**
   - ? Seções aparecendo (Vendas, Clientes, Produtos...)
   - ? Checkboxes marcados corretamente
   - ? Subseções aparecendo ao expandir
   - ? Contador "X de Y permissões"

4. **Testar edição:**
   - Marcar permissão `vendas:cancel`
   - Clicar "Salvar"
   - **Verificar no console:** `? Permissões salvas`

5. **Fazer login com vendedor:**
   - Verificar que botão "Cancelar Venda" aparece IMEDIATAMENTE

#### **Teste 3: Frontend**

```javascript
// Console do navegador (F12) como Vendedor
const { can } = usePermissions();

console.log('vendas:read', can('vendas', 'read'));    // true
console.log('vendas:cancel', can('vendas', 'cancel'));  // true (se marcou)
console.log('vendas:delete', can('vendas', 'delete'));  // false
console.log('produtos:delete', can('produtos', 'delete')); // false
console.log('configuracoes:read', can('configuracoes', 'read')); // false
```

---

## ?? ESTRUTURA FINAL

### **9 Seções Principais**

```
?? Dashboard (3)
  ?? view, metricas, graficos

?? Vendas (8)
  ?? read, create, update, delete
  ?? Ações Específicas: cancel, refund, discount, print

?? Produtos (9)
  ?? read, create, update, delete
  ?? Gestão: manage_stock, adjust_price, categories, import, export

?? Clientes (8)
  ?? read, create, update, delete
  ?? Gestão: view_history, manage_debt, import, export

?? Caixa (7)
  ?? read, view
  ?? Operações: open, close, sangria, suprimento, view_history

?? Ordens (6)
  ?? read, create, update, delete
  ?? Ações: change_status, print

?? Relatórios (7)
  ?? read
  ?? Tipos: sales, financial, products, customers, inventory, export

?? Configurações (11) ? ? SEÇÃO SEPARADA AGORA!
  ?? read, update
  ?? Subseções:
      ?? dashboard (read, update)
      ?? aparencia (read, update)
      ?? impressao (read, update)
      ?? company_info
      ?? integrations
      ?? backup

?? Administração (19)
  ?? read, full_access
  ?? Subseções:
      ?? usuarios (create, read, update, delete)
      ?? funcoes (create, read, update, delete)
      ?? permissoes (read, update)
      ?? sistema (read, update)
      ?? logs (read)
      ?? assinatura (read, update)
      ?? backup (read, create)
```

---

## ?? VALIDAÇÃO FINAL

### ? **Checklist Completo**

- [ ] Script SQL executado sem erros
- [ ] Tabela `permissoes` tem 80+ registros
- [ ] View `v_permissoes_hierarquia` criada
- [ ] Função Administrador tem ~80 permissões
- [ ] Função Vendedor tem ~10 permissões
- [ ] Componente React renderiza sem erros
- [ ] Seções expansíveis funcionando
- [ ] Checkboxes marcando/desmarcando
- [ ] Botão "Salvar" atualiza banco
- [ ] Mudanças aparecem IMEDIATAMENTE no frontend
- [ ] Vendedor NÃO vê configurações
- [ ] Vendedor NÃO pode deletar produtos/clientes
- [ ] Admin vê TUDO

---

## ?? INTERFACE FINAL

### **Modo Detalhado (Padrão)**

```
??????????????????????????????????????????
? Editar Permissões: Vendedor            ?
? 10 de 80 permissões selecionadas       ?
??????????????????????????????????????????
? [Compacto] [Detalhado] [Completo]      ?
?         [Marcar Todas] [Desmarcar]     ?
??????????????????????????????????????????
?                                        ?
? ?? Vendas (4/8 permissões)      [?]   ?
?   Ações Principais                     ?
?   [x] Ver vendas                       ?
?   [x] Criar venda                      ?
?   [x] Editar venda                     ?
?   [ ] Excluir venda                    ?
?                                        ?
?   ? Ações Específicas (2/4)           ?
?   [ ] Cancelar venda                   ?
?   [ ] Fazer estorno                    ?
?   [x] Aplicar desconto                 ?
?   [x] Imprimir cupom                   ?
?                                        ?
? ?? Produtos (1/9 permissões)    [?]   ?
?                                        ?
? ?? Clientes (3/8 permissões)    [?]   ?
?                                        ?
??????????????????????????????????????????
? 10 permissões selecionadas             ?
?           [Cancelar] [Salvar] ?       ?
??????????????????????????????????????????
```

### **Modo Compacto**

```
??????????????????????????????????????????
? ?? Vendas (4/8)              [Todas]   ?
?   [x] Ver vendas                       ?
?   [x] Criar venda                      ?
?   [x] Editar venda                     ?
?   [ ] Excluir venda                    ?
??????????????????????????????????????????
```

### **Modo Completo**

```
??????????????????????????????????????????
? ?? Vendas (4/8 permissões)             ?
?                                        ?
? Ações Principais                       ?
? [x] Ver vendas (vendas:read)           ?
? [x] Criar venda (vendas:create)        ?
? [x] Editar venda (vendas:update)       ?
? [ ] Excluir venda (vendas:delete)      ?
?                                        ?
? Ações Específicas                      ?
? [ ] Cancelar venda (vendas:cancel)     ?
? [ ] Fazer estorno (vendas:refund)      ?
? [x] Aplicar desconto (vendas:discount) ?
? [x] Imprimir cupom (vendas:print)      ?
??????????????????????????????????????????
```

---

## ?? RESOLUÇÃO DE PROBLEMAS

### **Erro: Permissões não aparecem**

```sql
-- Verificar se tabela foi populada
SELECT COUNT(*) FROM permissoes;
-- Esperado: 80+

-- Ver se colunas existem
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'permissoes';
-- Esperado: incluir 'modulo_pai' e 'ordem'
```

### **Erro: Mudanças não aplicam**

```javascript
// Verificar evento de reload
window.addEventListener('pdv_permissions_reload', (e) => {
  console.log('?? Permissões recarregando:', e.detail);
});

// Forçar reload
window.dispatchEvent(new CustomEvent('pdv_permissions_reload', {
  detail: { funcao_id: 'xxx', total: 10 }
}));
```

### **Erro: Interface não renderiza**

```bash
# Verificar imports
grep -r "EditarPermissoesFuncao" src/

# Build
npm run build

# Verificar erros
npm run type-check
```

---

## ? PRONTO PARA USAR!

### **Tempo Total:** ~10 minutos

1. ? **5 min:** Executar SQL
2. ? **2 min:** Verificar componente React
3. ? **3 min:** Testar interface

### **Resultado:**

- ? Permissões organizadas por seções
- ? Configurações em seção própria (fora de Administração)
- ? Edição visual intuitiva
- ? Efeito IMEDIATO ao salvar
- ? 3 modos de visualização
- ? Funciona com Jennifer e todos os vendedores

**Deploy e teste agora!** ??
