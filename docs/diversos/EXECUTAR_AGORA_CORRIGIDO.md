# ?? GUIA RÁPIDO - EXECUTAR AGORA

## ? ERRO IDENTIFICADO

O script original tinha a **ordem errada**:
1. ? Tentava usar colunas `modulo_pai` e `ordem`
2. ? Só DEPOIS tentava criá-las
3. ? Resultado: Erro SQL

## ? SOLUÇÃO APLICADA

Novo script: **REFATORAR_PERMISSOES_CORRIGIDO.sql**

**Ordem correta:**
1. ? Cria colunas PRIMEIRO
2. ? Limpa dados antigos
3. ? Insere novas permissões
4. ? Aplica às funções
5. ? Cria view de hierarquia

---

## ?? EXECUTAR AGORA (5 minutos)

### 1?? **Abrir Supabase SQL Editor**

```
https://supabase.com/dashboard/project/[seu-projeto]/sql
```

### 2?? **Copiar e Colar o Script**

```bash
# Arquivo: REFATORAR_PERMISSOES_CORRIGIDO.sql
# Copiar TODO o conteúdo
```

### 3?? **Executar (RUN)**

Clique no botão **RUN** ou pressione `Ctrl+Enter`

### 4?? **Verificar Resultado**

**Esperado:**
```sql
? Coluna modulo_pai adicionada (ou já existe)
? Coluna ordem adicionada (ou já existe)
??? Permissões antigas removidas
? 78 permissões criadas com sucesso
? Administrador: 78 permissões aplicadas
? Vendedor: 9 permissões aplicadas
? View v_permissoes_hierarquia criada

?? PERMISSÕES POR SEÇÃO
| Seção          | Total |
|----------------|-------|
| dashboard      | 3     |
| vendas         | 8     |
| produtos       | 9     |
| clientes       | 8     |
| caixa          | 7     |
| ordens         | 6     |
| relatorios     | 7     |
| configuracoes  | 11    |
| administracao  | 19    |

?? PERMISSÕES POR FUNÇÃO
| Função        | Total |
|---------------|-------|
| Administrador | 78    |
| Vendedor      | 9     |
```

---

## ?? TESTAR (3 minutos)

### **Teste 1: Verificar no Banco**

```sql
-- Contar permissões
SELECT COUNT(*) FROM permissoes;
-- Esperado: 78

-- Ver colunas novas
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'permissoes' 
AND column_name IN ('modulo_pai', 'ordem');
-- Esperado: 2 linhas

-- Ver permissões do Vendedor
SELECT 
  p.categoria,
  p.recurso || ':' || p.acao as permissao
FROM funcao_permissoes fp
JOIN funcoes f ON f.id = fp.funcao_id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.nome = 'Vendedor'
ORDER BY p.categoria;
-- Esperado: 9 linhas (vendas, clientes, produtos)
```

### **Teste 2: Login com Jennifer**

1. Fazer **logout**
2. Fazer **login** como Jennifer
3. Verificar console (F12):
   ```javascript
   ?? [usePermissions] Total de permissões: 9
   ?? Total módulos visíveis: 3 (Vendas, Clientes, Produtos)
   ```

### **Teste 3: Verificar Restrições**

```javascript
// Console do navegador (F12)
const { can } = usePermissions();

console.log('vendas:read', can('vendas', 'read'));      // true
console.log('vendas:delete', can('vendas', 'delete'));  // false ?
console.log('produtos:delete', can('produtos', 'delete')); // false ?
console.log('configuracoes:read', can('configuracoes', 'read')); // false ?
```

---

## ? CHECKLIST RÁPIDO

- [ ] Script executado sem erros
- [ ] 78 permissões criadas
- [ ] Colunas `modulo_pai` e `ordem` existem
- [ ] View `v_permissoes_hierarquia` criada
- [ ] Administrador tem 78 permissões
- [ ] Vendedor tem 9 permissões
- [ ] Jennifer não vê botões de exclusão
- [ ] Jennifer não acessa Configurações

---

## ?? PRÓXIMOS PASSOS

### **1. Interface Admin (Opcional)**

Se quiser interface visual de edição:
- Usar componente: `src/components/admin/EditarPermissoesFuncao.tsx`
- Importar na página admin
- Adicionar botão "Editar Permissões"

### **2. Testar Edição no Admin**

1. Acessar `/admin/funcoes-permissoes`
2. Editar função Vendedor
3. Marcar permissão `vendas:cancel`
4. Salvar
5. Fazer login com Jennifer
6. Verificar que botão "Cancelar Venda" aparece

### **3. Criar Novas Funções**

Exemplos:
- **Gerente:** Todas exceto administração
- **Técnico OS:** Apenas ordens de serviço
- **Caixa:** Apenas caixa e vendas

---

## ?? SE DER ERRO

### **Erro: "column already exists"**

```sql
-- Normal! Significa que já executou antes
-- Script detecta e pula automaticamente
```

### **Erro: "function Administrador not found"**

```sql
-- Criar função primeiro:
INSERT INTO funcoes (nome, descricao, empresa_id)
VALUES ('Administrador', 'Acesso total ao sistema', NULL);
```

### **Erro: Permissões não aparecem**

```bash
# Limpar cache do navegador
Ctrl+Shift+Del ? Limpar cache ? Recarregar
```

---

## ?? SUPORTE

**Dúvidas?** Consulte os arquivos:
- `GUIA_SISTEMA_PERMISSOES_REFATORADO.md` - Documentação completa
- `EXECUCAO_RAPIDA_PERMISSOES.md` - Guia detalhado
- `RESUMO_EXECUTIVO_PERMISSOES.md` - Visão geral

---

## ?? PRONTO!

? Sistema de permissões refatorado
? Hierarquia organizada
? Interface preparada
? Documentação completa

**Execute o script e teste agora!** ??

---

**Tempo Total:** ~5 minutos
**Dificuldade:** Fácil
**Resultado:** Sistema profissional de permissões
