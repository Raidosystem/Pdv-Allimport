# ?? SOLUÇÃO: Só aparece 1 usuário no login local

## ?? **PROBLEMA IDENTIFICADO**

Você tem **2 funcionários** cadastrados:
- ? **Jennifer** (Vendedor)
- ? **Cristiano Ramos Mendes** (Administrador)

Mas apenas **1 aparece** no login local.

**Causa provável:**
- Um dos funcionários não está com `usuario_ativo = TRUE`
- OU não tem registro em `login_funcionarios`
- OU o campo `senha_definida` está como `FALSE`

---

## ? **SOLUÇÃO RÁPIDA (Execute em ordem)**

### **1?? Diagnóstico (OPCIONAL)**

Execute no Supabase SQL Editor:

```sql
-- Arquivo: DEBUG_LOGIN_LOCAL_USUARIOS.sql
```

Isso vai mostrar EXATAMENTE qual campo está bloqueando o usuário.

---

### **2?? Correção Automática (EXECUTAR AGORA)**

Execute no Supabase SQL Editor:

```sql
-- Arquivo: ATIVAR_TODOS_USUARIOS_LOGIN.sql
```

**O que este script faz:**
1. ? Ativa todos os funcionários (`usuario_ativo = TRUE`)
2. ? Define `senha_definida = TRUE` para todos
3. ? Ativa todos os registros em `login_funcionarios`
4. ? Cria registros de login para quem não tem
5. ? Define senha padrão `123456` para novos logins

---

### **3?? Testar no Sistema**

Após executar o script:

1. Acesse: `http://localhost:5173/login-local`
2. **Deve aparecer 2 cards:**
   - ?? **Jennifer** (Vendedor)
   - ?? **Cristiano Ramos Mendes** (Administrador)
3. **Senha padrão:** `123456` (se foi criado novo login)

---

## ?? **SE AINDA NÃO APARECER**

Execute este comando no Supabase para verificar:

```sql
-- Ver o resultado da RPC
SELECT * FROM listar_usuarios_ativos('f7fdf4cf-7101-45ab-86db-5248a7ac58c1');

-- Deve retornar 2 linhas (Jennifer e Cristiano ou apenas Jennifer se Cristiano é admin_empresa)
```

---

## ?? **CASOS ESPECIAIS**

### **Se Cristiano for `admin_empresa`**

Administradores da empresa **NÃO aparecem** no login local, pois eles fazem login pelo sistema normal (Supabase Auth).

**Para verificar:**

```sql
SELECT nome, tipo_admin FROM funcionarios 
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';
```

Se Cristiano tiver `tipo_admin = 'admin_empresa'`, ele **NÃO deve aparecer** no login local.

---

### **Se Jennifer estiver desativada**

Execute:

```sql
UPDATE funcionarios
SET 
  usuario_ativo = TRUE,
  senha_definida = TRUE,
  status = 'ativo'
WHERE nome = 'Jennifer'
  AND empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- E garanta que ela tem login criado
INSERT INTO login_funcionarios (funcionario_id, usuario, senha_hash, ativo, senha_definida, precisa_trocar_senha)
SELECT 
  id,
  'jennifer',
  crypt('123456', gen_salt('bf')),
  TRUE,
  TRUE,
  TRUE
FROM funcionarios
WHERE nome = 'Jennifer'
  AND empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND NOT EXISTS (
    SELECT 1 FROM login_funcionarios WHERE funcionario_id = funcionarios.id
  );
```

---

## ? **RESULTADO ESPERADO**

Após executar `ATIVAR_TODOS_USUARIOS_LOGIN.sql`:

```
?? VERIFICAÇÃO PÓS-CORREÇÃO:
- total_funcionarios_nao_admin: 1 ou 2
- funcionarios_ativos: 1 ou 2
- logins_criados: 1 ou 2
- aparecendo_no_login: 1 ou 2

?? USUÁRIOS QUE DEVEM APARECER:
- Jennifer (usuario: jennifer, senha: 123456)
```

---

## ?? **RESUMO EXECUTIVO**

1. **Execute:** `DEBUG_LOGIN_LOCAL_USUARIOS.sql` (opcional)
2. **Execute:** `ATIVAR_TODOS_USUARIOS_LOGIN.sql` ? **PRINCIPAL**
3. **Teste:** `http://localhost:5173/login-local`
4. **Senha padrão:** `123456` (se criou novos logins)

**Tempo total:** ~2 minutos

---

## ?? **AINDA COM PROBLEMA?**

Execute no Supabase e me mostre o resultado:

```sql
-- Mostrar estado atual de TODOS os funcionários
SELECT 
  f.nome,
  f.tipo_admin,
  f.usuario_ativo,
  f.senha_definida,
  f.status,
  lf.usuario,
  lf.ativo as login_ativo,
  lf.senha_definida as login_senha_definida
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.nome;
```

Copie o resultado e me mostre!

---

**?? Execute o `ATIVAR_TODOS_USUARIOS_LOGIN.sql` e teste!**
