# ?? CORRIGIR PROBLEMA DE PERMISSÕES - PASSO A PASSO

## ? PROBLEMA IDENTIFICADO

Jennifer está logando, mas o sistema carrega as permissões do **Cristiano** (admin_empresa) ao invés das permissões dela (funcionário/vendedor).

**Causa**: O `AuthContext` estava pegando o primeiro login local encontrado no localStorage, que era o do Cristiano.

---

## ? CORREÇÃO APLICADA

1. **AuthContext agora busca o login MAIS RECENTE** baseado no `created_at`
2. **Login local salva timestamp** para identificar qual é o mais novo

---

## ?? PASSOS PARA TESTAR

### 1?? Limpar Todo o Cache

Abra o **Console do Navegador** (F12) e execute:

```javascript
// Limpar TODOS os logins locais
Object.keys(localStorage)
  .filter(key => key.startsWith('pdv_login_local_'))
  .forEach(key => {
    console.log('??? Removendo:', key)
    localStorage.removeItem(key)
  })

// Limpar cache do Supabase também
localStorage.removeItem('supabase.auth.token')

// Recarregar página
location.reload()
```

### 2?? Fazer Logout Completo

1. Clique em **"Sair"** no sistema
2. **Feche TODAS as abas** do navegador
3. **Limpe o cache** do navegador:
   - `Ctrl + Shift + Del`
   - Marque "Cookies e dados de sites"
   - Marque "Imagens e arquivos em cache"
   - Clique em "Limpar dados"

### 3?? Logar como Cristiano (Admin)

1. Abra o navegador novamente
2. Acesse: `http://localhost:5174/login-local` (ou a porta que você usa)
3. Clique no card do **Cristiano**
4. Digite a senha do admin
5. Verifique que está logado como admin

### 4?? FAZER LOGOUT

**IMPORTANTE**: Antes de testar a Jennifer, **faça logout do Cristiano**!

1. Clique em "Sair"
2. Deve voltar para `/login-local`

### 5?? Logar como Jennifer

1. Na tela `/login-local`, clique no card da **Jennifer**
2. Digite a senha da Jennifer
3. Clique em "Entrar"
4. Aguarde o redirecionamento para o dashboard

### 6?? Verificar Permissões da Jennifer

Abra o **Console do Navegador** (F12) e procure por:

```
? [usePermissions] Funcionário encontrado: Jennifer
?? [usePermissions] funcao_permissoes: Array(34)
?? [usePermissions] Total de permissões extraídas: 34
```

**Resultado esperado:**
- Total de permissões: **34** (não 73 ou 78)
- Tipo admin: **funcionario** (não admin_empresa)
- Módulos visíveis: **6** (Vendas, Produtos, Clientes, Caixa, Ordens, Configurações)

### 7?? Verificar Módulos Visíveis

No dashboard, Jennifer deve ver:
- ? Vendas
- ? Produtos
- ? Clientes
- ? Caixa
- ? Ordens de Serviço
- ? Configurações

Jennifer **NÃO** deve ver:
- ? Relatórios (não tem permissão)
- ? Administração (não tem permissão)

---

## ?? SE AINDA NÃO FUNCIONAR

### Diagnóstico 1: Verificar localStorage

Console do navegador:

```javascript
// Ver todos os logins salvos
Object.keys(localStorage)
  .filter(key => key.startsWith('pdv_login_local_'))
  .forEach(key => {
    console.log(key, JSON.parse(localStorage.getItem(key)))
  })
```

**Esperado**: Deve ter APENAS 1 login (da Jennifer ou do Cristiano, dependendo de quem está logado)

### Diagnóstico 2: Verificar Banco de Dados

Execute no **Supabase SQL Editor**:

```sql
-- Ver permissões da Jennifer
SELECT 
  p.recurso,
  p.acao,
  COUNT(*) as vezes
FROM funcao_permissoes fp
JOIN permissoes p ON p.id = fp.permissao_id
JOIN funcoes f ON f.id = fp.funcao_id
JOIN funcionarios func ON func.funcao_id = f.id
WHERE func.email = 'sousajenifer895@gmail.com'
GROUP BY p.recurso, p.acao
ORDER BY p.recurso, p.acao;
```

**Esperado**: Deve ter exatamente **34 permissões únicas** (sem duplicatas)

### Diagnóstico 3: Verificar Script V2

Se ainda houver duplicatas no banco, **execute o script V2**:

`CORRIGIR_PERMISSOES_V2_FINAL.sql`

Isso vai:
1. Remover duplicatas
2. Recriar as 34 permissões corretas da Jennifer
3. Adicionar constraint para prevenir duplicatas futuras

---

## ?? TESTE FINAL

Após seguir todos os passos, o comportamento correto é:

| Usuário | Total Permissões | Tipo Admin | Módulos Visíveis |
|---------|------------------|------------|------------------|
| Cristiano (Admin) | 78 | `admin_empresa` | Todos (7) |
| Jennifer (Vendedor) | 34 | `funcionario` | 6 módulos |

---

## ?? PRÓXIMOS PASSOS APÓS CORREÇÃO

1. **Jennifer testa todos os módulos** que ela tem acesso
2. **Verificar se não consegue acessar** Administração e Relatórios
3. **Testar criação de venda, cliente, produto** etc.
4. **Confirmar que permissões estão corretas** (pode editar mas não excluir, etc.)

---

## ?? RESUMO DA CORREÇÃO

**Arquivo corrigido**: `src/modules/auth/AuthContext.tsx`

**O que mudou**:
```diff
- // Pegar o PRIMEIRO login encontrado
+ // Pegar o login MAIS RECENTE (baseado em timestamp)
```

**Impacto**:
- ? Sistema sempre usa o login do usuário que fez login por último
- ? Não mistura permissões entre Cristiano e Jennifer
- ? Multi-tenant funciona corretamente

---

**?? Após seguir estes passos, Jennifer deve ter apenas as 34 permissões corretas!**
