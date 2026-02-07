# 🔧 SOLUÇÃO: Erro "senha_hash" não existe

## ❌ Problema

```
Erro ao atualizar senha: column "senha_hash" of relation "login_funcionarios" does not exist
```

## 🎯 Causa

A tabela `login_funcionarios` usa a coluna `senha` (texto), mas as RPCs (funções do banco) estão tentando usar `senha_hash` (criptografada).

## ✅ Solução (Execute em Ordem)

### 📋 Passo 1: Verificar Estrutura Atual

```sql
-- No SQL Editor do Supabase, execute:
SELECT 
    column_name, 
    data_type, 
    column_default
FROM information_schema.columns
WHERE table_name = 'login_funcionarios'
AND column_name IN ('senha', 'senha_hash', 'precisa_trocar_senha')
ORDER BY column_name;
```

**Resultado esperado antes da correção:**
```
column_name          | data_type | column_default
senha                | text      | NULL
precisa_trocar_senha | boolean   | false          (se já executou 1_ADICIONAR_COLUNA_PRECISA_TROCAR_SENHA.sql)
```

---

### 📋 Passo 2: Adicionar Coluna `precisa_trocar_senha` (se não existir)

**Arquivo:** `1_ADICIONAR_COLUNA_PRECISA_TROCAR_SENHA.sql`

```bash
# Abra o arquivo e execute TODO o conteúdo no SQL Editor
```

✅ **Verificação:**
```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'login_funcionarios'
AND column_name = 'precisa_trocar_senha';
```

Deve retornar: `precisa_trocar_senha`

---

### 📋 Passo 3: Migrar Senha para Senha Hash

**Arquivo:** `MIGRAR_SENHA_PARA_HASH.sql`

```bash
# Execute TODO o conteúdo deste arquivo no SQL Editor
```

**O que acontece:**
1. ✅ Adiciona coluna `senha_hash`
2. ✅ Migra senhas existentes de `senha` → `senha_hash` (criptografadas)
3. ✅ Mantém coluna `senha` antiga (para rollback se necessário)

✅ **Verificação:**
```sql
SELECT 
    COUNT(*) FILTER (WHERE senha_hash IS NOT NULL) as com_hash,
    COUNT(*) FILTER (WHERE senha_hash IS NULL) as sem_hash,
    COUNT(*) as total
FROM login_funcionarios;
```

**Resultado esperado:**
```
com_hash | sem_hash | total
2        | 0        | 2      (todos os funcionários devem ter senha_hash)
```

---

### 📋 Passo 4: Atualizar RPCs (Funções de Autenticação)

**Arquivo:** `CORRIGIR_RPCS_SENHA_HASH.sql`

```bash
# Execute TODO o conteúdo deste arquivo no SQL Editor
```

**O que acontece:**
1. ✅ Atualiza `autenticar_funcionario` para usar `senha_hash` (ou `senha` como fallback)
2. ✅ Atualiza `atualizar_senha_funcionario` para usar `senha_hash`
3. ✅ Cria `trocar_senha_propria` (funcionário troca senha)
4. ✅ Cria `autenticar_funcionario_local` (versão completa)

✅ **Verificação:**
```sql
SELECT 
    routine_name as funcao,
    routine_type as tipo
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
    'autenticar_funcionario',
    'atualizar_senha_funcionario',
    'trocar_senha_propria'
)
ORDER BY routine_name;
```

**Resultado esperado:**
```
funcao                        | tipo
atualizar_senha_funcionario   | FUNCTION
autenticar_funcionario        | FUNCTION
trocar_senha_propria          | FUNCTION
```

---

### 📋 Passo 5: Testar no Sistema

#### 5.1. Testar Atualização de Senha (Admin)

1. Acesse: **Dashboard → Administração → Usuários**
2. Clique no ícone de **editar** (✏️) de um funcionário
3. Digite uma nova senha (ex: `Teste@123`)
4. Clique em **Salvar**

✅ **Resultado esperado:** 
```
✅ Senha atualizada com sucesso
```

❌ **Se der erro:**
- Verifique se executou os passos 1-4 em ordem
- Veja os logs no Console do Supabase (SQL Editor → Logs)

---

#### 5.2. Testar Login do Funcionário

1. Faça logout do sistema
2. Tente fazer login com o funcionário que teve a senha resetada
3. Use a nova senha definida pelo admin

✅ **Resultado esperado:**
- Login bem-sucedido
- Se `precisa_trocar_senha = TRUE`, deve mostrar modal de troca de senha

---

## 🧪 Testes SQL Manuais (Opcional)

### Teste 1: Autenticar Funcionário
```sql
SELECT * FROM autenticar_funcionario_local('usuario_teste', 'senha123');
```

**Resultado esperado (se senha correta):**
```json
{
  "success": true,
  "funcionario": {...},
  "empresa": {...},
  "login_id": "uuid-do-login",
  "precisa_trocar_senha": false
}
```

---

### Teste 2: Atualizar Senha (Admin)
```sql
SELECT atualizar_senha_funcionario(
    'id-do-funcionario-aqui',
    'NovaSenha@456'
);
```

**Resultado esperado:**
```
(sem erro)
NOTICE: Senha resetada. Funcionário deve trocar no próximo login: ...
```

---

### Teste 3: Trocar Senha Própria
```sql
SELECT * FROM trocar_senha_propria(
    'id-do-funcionario-aqui',
    'senhaAtual',
    'novaSenha789'
);
```

**Resultado esperado:**
```json
{
  "success": true,
  "message": "Senha atualizada com sucesso"
}
```

---

## 📊 Estrutura Final Esperada

```sql
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'login_funcionarios'
AND column_name IN ('senha', 'senha_hash', 'precisa_trocar_senha')
ORDER BY column_name;
```

**Resultado:**
```
column_name           | data_type | is_nullable
precisa_trocar_senha  | boolean   | YES         (default: false)
senha                 | text      | NO          (mantida temporariamente)
senha_hash            | text      | YES         (será NOT NULL depois)
```

---

## 🚨 Troubleshooting

### Erro: "function atualizar_senha_funcionario does not exist"

**Solução:** Execute `CORRIGIR_RPCS_SENHA_HASH.sql` novamente

---

### Erro: "column senha_hash does not exist"

**Solução:** Execute `MIGRAR_SENHA_PARA_HASH.sql` primeiro

---

### Senhas não funcionam após migração

**Solução:**
1. Verifique se `senha_hash` foi populada:
   ```sql
   SELECT id, usuario, senha_hash IS NOT NULL as tem_hash 
   FROM login_funcionarios;
   ```
2. Se `tem_hash = false`, execute passo 3 novamente
3. Se persistir, use o rollback:
   ```sql
   ALTER TABLE login_funcionarios DROP COLUMN IF EXISTS senha_hash;
   ```

---

## 🔄 Rollback (Em Caso de Emergência)

Se algo der errado e você quiser voltar ao estado anterior:

```sql
-- 1. Remover coluna senha_hash
ALTER TABLE login_funcionarios DROP COLUMN IF EXISTS senha_hash;

-- 2. Remover coluna precisa_trocar_senha
ALTER TABLE login_funcionarios DROP COLUMN IF EXISTS precisa_trocar_senha;

-- 3. Restaurar RPC antiga (execute CORRIGIR_LOGIN_FUNCIONARIOS.sql)
```

---

## ✅ Checklist Final

- [ ] Executei `1_ADICIONAR_COLUNA_PRECISA_TROCAR_SENHA.sql`
- [ ] Executei `MIGRAR_SENHA_PARA_HASH.sql`
- [ ] Verifiquei que todas as senhas foram migradas (passo 3 - verificação)
- [ ] Executei `CORRIGIR_RPCS_SENHA_HASH.sql`
- [ ] Verifiquei que as RPCs foram criadas (passo 4 - verificação)
- [ ] Testei atualizar senha no AdminUsersPage (passo 5.1)
- [ ] Testei login com a nova senha (passo 5.2)
- [ ] ✅ Sistema funcionando normalmente

---

## 📝 Próximos Passos (Após Tudo Funcionar)

1. **Aguardar 1-2 semanas** em produção
2. **Tornar senha_hash obrigatória:**
   ```sql
   ALTER TABLE login_funcionarios 
   ALTER COLUMN senha_hash SET NOT NULL;
   ```
3. **Aguardar mais 1-2 semanas**
4. **Remover coluna senha antiga** (se tudo estiver OK):
   ```sql
   ALTER TABLE login_funcionarios 
   DROP COLUMN IF EXISTS senha;
   ```

---

## 📞 Suporte

Se o problema persistir após seguir todos os passos:

1. Abra o Console do Navegador (F12)
2. Vá na aba **Console**
3. Copie o erro completo
4. Abra o Supabase → SQL Editor → Logs
5. Procure por erros relacionados a `login_funcionarios`
