# 🔧 CORRIGIR PROBLEMA DE PRIMEIRO ACESSO

## ❌ PROBLEMA IDENTIFICADO
Quando um administrador cria um novo funcionário, o sistema **NÃO está pedindo para o funcionário trocar a senha** no primeiro login.

## 🔍 CAUSA RAIZ
1. A função `cadastrar_funcionario_simples()` estava definindo `senha_definida = true` ❌
2. A função `cadastrar_funcionario_simples()` **NÃO estava definindo** `primeiro_acesso = true` ❌
3. O arquivo `LocalLoginPage.tsx` estava tentando buscar uma coluna `precisa_trocar_senha` que **NÃO EXISTE** na tabela `login_funcionarios` ❌

## ✅ SOLUÇÃO APLICADA

### 1️⃣ Correção no Banco de Dados (SQL)
Arquivo: `migrations/CORRIGIR_PRIMEIRO_ACESSO.sql`

**Alterações na função `cadastrar_funcionario_simples()`:**
```sql
INSERT INTO funcionarios (
  ...
  senha_definida,
  primeiro_acesso
) VALUES (
  ...
  false,  -- ⭐ Senha ainda NÃO foi definida pelo funcionário
  true    -- ⭐ É o PRIMEIRO ACESSO
)
```

### 2️⃣ Correção no Frontend (TypeScript)
Arquivo: `src/modules/auth/LocalLoginPage.tsx`

**ANTES (❌ ERRADO):**
```typescript
// Buscava coluna que não existe
const { data: loginData, error: loginError } = await supabase
  .from('login_funcionarios')
  .select('precisa_trocar_senha')  // ❌ Coluna não existe
  .eq('funcionario_id', funcionarioData.id)
  .single()

const precisaTrocarSenha = loginData?.precisa_trocar_senha === true
```

**DEPOIS (✅ CORRETO):**
```typescript
// Usa campo primeiro_acesso que já vem no funcionarioData
const isPrimeiroAcesso = funcionarioData.primeiro_acesso === true

if (isPrimeiroAcesso) {
  // Redireciona para tela de troca de senha
  navigate('/trocar-senha', { ... })
}
```

## 📋 COMO EXECUTAR A CORREÇÃO

### Passo 1: Abrir Supabase Dashboard
Acesse: https://vfuglqcyrmgwvrlmmotm.supabase.co

### Passo 2: Abrir SQL Editor
No menu lateral esquerdo, clique em: **SQL Editor**

### Passo 3: Executar o SQL
1. Clique em "New Query"
2. Copie **TODO** o conteúdo do arquivo: `migrations/CORRIGIR_PRIMEIRO_ACESSO.sql`
3. Cole no editor
4. Clique em **RUN** (ou pressione Ctrl+Enter)

### Passo 4: Verificar Resultado
Você deve ver:
```
✅ FUNÇÃO ATUALIZADA
```

## 🧪 COMO TESTAR

1. **Criar novo funcionário:**
   - Vá no painel admin
   - Crie um novo funcionário (ex: "Maria Silva", email: maria@teste.com, senha temporária: "senha123")

2. **Fazer logout:**
   - Sair do sistema

3. **Tentar login com novo funcionário:**
   - Usuário: maria
   - Senha: senha123

4. **Resultado esperado:**
   - ✅ Sistema deve redirecionar para tela de troca de senha
   - ✅ Exibir mensagem: "Login bem-sucedido! Por favor, defina sua senha pessoal."
   - ✅ Funcionário deve poder definir sua própria senha

## 🔍 COMO VERIFICAR SE FUNCIONOU

Execute no SQL Editor do Supabase:
```sql
-- Ver último funcionário criado
SELECT 
  nome,
  email,
  primeiro_acesso,  -- Deve ser TRUE
  senha_definida,   -- Deve ser FALSE
  usuario_ativo,
  created_at
FROM funcionarios
ORDER BY created_at DESC
LIMIT 1;
```

## 📝 RESUMO DAS MUDANÇAS

| Item | Antes | Depois |
|------|-------|--------|
| `senha_definida` | `true` ❌ | `false` ✅ |
| `primeiro_acesso` | `NULL` ❌ | `true` ✅ |
| Verificação no login | Busca coluna inexistente ❌ | Usa `primeiro_acesso` ✅ |
| Fluxo de troca de senha | Não funciona ❌ | Funciona perfeitamente ✅ |

---

**✨ Após aplicar essa correção, o sistema voltará a funcionar normalmente e pedirá para trocar senha no primeiro acesso!**
