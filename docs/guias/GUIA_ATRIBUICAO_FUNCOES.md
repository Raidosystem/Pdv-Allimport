# 🎯 GUIA: Como Atribuir Funções Corretamente

## 🚨 PROBLEMA IDENTIFICADO

**Jennifer estava com acesso de TÉCNICO quando deveria ser VENDEDOR**

**Causa**: Script SQL aplicou função errada no banco de dados

---

## ✅ COMO ATRIBUIR FUNÇÕES CORRETAMENTE

### 📋 Funções Disponíveis no Sistema

| Função | Tipo Admin | Acesso |
|--------|------------|--------|
| **Admin** | `admin_empresa` | 🔴 Acesso TOTAL (dono da empresa) |
| **Gerente** | `funcionario` | 🟣 Gerenciar operações, relatórios |
| **Vendedor** | `funcionario` | 🔵 Vendas, clientes, produtos (leitura) |
| **Técnico** | `funcionario` | 🟢 Ordens de Serviço + vendas básicas |
| **Caixa** | `funcionario` | 🟡 Caixa + vendas básicas |

---

## 🎯 REGRAS CRÍTICAS

### ⚠️ NUNCA FAÇA ISSO:

1. ❌ Alterar `tipo_admin` de funcionário para `admin_empresa`
   - Isso dá acesso total ao sistema!
   - Apenas o DONO deve ter `tipo_admin = 'admin_empresa'`

2. ❌ Aplicar múltiplas funções ao mesmo funcionário
   - Cada funcionário deve ter APENAS 1 função (`funcao_id`)

3. ❌ Modificar permissões diretamente no banco sem testar
   - Use a interface web: **Administração → Funções & Permissões**

---

## ✅ PROCESSO CORRETO

### Via Interface Web (RECOMENDADO)

1. **Login como Admin** (Cristiano - `cris-ramos30@hotmail.com`)
2. Ir em **Administração → Usuários**
3. Clicar no funcionário (ex: Jennifer)
4. Selecionar a **função correta** no dropdown
5. Salvar

### Via SQL (Apenas se necessário)

```sql
-- 1. Verificar funcionário
SELECT id, nome, email, funcao_id 
FROM funcionarios 
WHERE email = 'sousajenifer895@gmail.com';

-- 2. Ver funções disponíveis
SELECT id, nome FROM funcoes 
WHERE empresa_id = (SELECT empresa_id FROM funcionarios WHERE email = 'sousajenifer895@gmail.com');

-- 3. Atualizar função
UPDATE funcionarios
SET funcao_id = '[UUID_DA_FUNCAO_VENDEDOR]'
WHERE email = 'sousajenifer895@gmail.com';
```

---

## 🔍 COMO DIAGNOSTICAR PROBLEMAS

### Funcionário tem acesso errado?

```sql
-- Ver função atual do funcionário
SELECT 
  f.nome,
  f.email,
  f.tipo_admin,
  func.nome as funcao,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN funcao_permissoes fp ON fp.funcao_id = func.id
WHERE f.email = 'EMAIL_DO_FUNCIONARIO'
GROUP BY f.id, f.nome, f.email, f.tipo_admin, func.nome;
```

### Listar permissões de um funcionário:

```sql
SELECT 
  f.nome as funcionario,
  func.nome as funcao,
  p.recurso,
  p.acao
FROM funcionarios f
JOIN funcoes func ON func.id = f.funcao_id
JOIN funcao_permissoes fp ON fp.funcao_id = func.id
JOIN permissoes p ON p.id = fp.permissao_id
WHERE f.email = 'EMAIL_DO_FUNCIONARIO'
ORDER BY p.recurso, p.acao;
```

---

## 📊 MATRIZ DE PERMISSÕES PADRÃO

### 🔵 VENDEDOR (Jennifer deveria ter isto)
- ✅ `vendas:read`, `vendas:create`, `vendas:update`
- ✅ `clientes:read`, `clientes:create`, `clientes:update`
- ✅ `produtos:read`
- ✅ `caixa:read`
- ✅ `relatorios:read`
- ❌ `ordens_servico:*` (NÃO!)
- ❌ `configuracoes:*` (NÃO!)
- ❌ `produtos:delete` (NÃO!)

### 🟢 TÉCNICO (O que Jennifer tinha ERRADO)
- ✅ `ordens_servico:read`, `ordens_servico:create`, `ordens_servico:update`
- ✅ `vendas:read`, `vendas:create` (limitado)
- ✅ `clientes:read`
- ✅ `produtos:read`
- ❌ `caixa:*` (NÃO!)
- ❌ `configuracoes:*` (NÃO!)

---

## 🛠️ CORREÇÃO APLICADA

**Arquivo SQL criado**: `CORRIGIR_FUNCAO_JENNIFER.sql`

Execute este arquivo no Supabase SQL Editor para:
1. Diagnosticar situação atual
2. Corrigir função da Jennifer para VENDEDOR
3. Verificar que a correção funcionou
4. Listar permissões finais

---

## 🎯 CHECKLIST PARA NOVOS FUNCIONÁRIOS

Ao cadastrar um novo funcionário:

- [ ] Definir qual será a função (Vendedor, Técnico, Caixa, etc)
- [ ] NO BANCO: `funcao_id` = UUID da função escolhida
- [ ] NO BANCO: `tipo_admin` = **'funcionario'** (SEMPRE para funcionários)
- [ ] Testar login e verificar permissões
- [ ] Confirmar que NÃO tem acesso a áreas administrativas

---

## 🔐 VALIDAÇÃO FINAL

Depois de atribuir/corrigir função:

1. **Fazer logout do sistema**
2. **Login com o email do funcionário**
3. **Verificar menu lateral**:
   - ✅ Deve ver apenas os módulos permitidos
   - ❌ NÃO deve ver "Administração"
4. **Tentar acessar**: `/admin/dashboard`
   - ❌ Deve ver: "Acesso Administrativo Restrito"

---

## 📞 SUPORTE

Se um funcionário continuar com acesso errado após correção:

1. Verificar cache do navegador (Ctrl+Shift+R)
2. Fazer logout completo
3. Verificar no banco se `funcao_id` está correto
4. Verificar se `tipo_admin` = 'funcionario' (não 'admin_empresa')
5. Executar: `CORRIGIR_FUNCAO_JENNIFER.sql` (seção de diagnóstico)
