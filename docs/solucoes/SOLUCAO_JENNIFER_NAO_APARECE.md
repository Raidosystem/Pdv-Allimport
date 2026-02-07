# ?? SOLUÇÃO: Jennifer não aparece no login local

## ?? **PROBLEMA IDENTIFICADO**

Você tem **2 funcionários**:
1. ? **Cristiano** (admin_empresa) ? Aparece
2. ? **Jennifer** (vendedor) ? NÃO aparece

**Causa provável:**
- Jennifer pode estar com `usuario_ativo = FALSE`
- OU não tem registro em `login_funcionarios`
- OU `senha_definida = FALSE`
- OU `ativo = FALSE`

---

## ? **SOLUÇÃO RÁPIDA (3 minutos)**

### **1?? Execute o Diagnóstico**

Abra **Supabase SQL Editor** e execute:

```sql
-- Ver status de Jennifer
SELECT 
  nome,
  email,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  status,
  ativo
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY nome;
```

Anote o resultado de Jennifer. Se algum campo estiver:
- `usuario_ativo = FALSE` ? PROBLEMA!
- `senha_definida = FALSE` ? PROBLEMA!
- `ativo = FALSE` ? PROBLEMA!
- `status != 'ativo'` ? PROBLEMA!

---

### **2?? Execute a Correção Automática**

Execute **TODO** o conteúdo do arquivo:

```sql
-- Arquivo: FIX_JENNIFER_NAO_APARECE.sql
```

Este script vai:
1. ? Diagnosticar o problema exato
2. ? Ativar Jennifer automaticamente
3. ? Criar/Atualizar login com senha `123456`
4. ? Testar a RPC

---

### **3?? Execute a RPC Corrigida**

Execute o script atualizado:

```sql
-- Arquivo: CORRECAO_COMPLETA_EXECUTAR_AGORA.sql
```

**Importante:** A RPC foi corrigida para aceitar campos NULL.

---

### **4?? Teste no Frontend**

1. Acesse: `http://localhost:5173/login-local`
2. **Deve aparecer 2 cards:**
   - ?? Cristiano Ramos Mendes (Administrador)
   - ?? Jennifer (Vendedor)
3. **Senha de Jennifer:** `123456` (se foi criado novo login)

---

## ?? **SE AINDA NÃO FUNCIONAR**

### **Opção A: Forçar criação do login de Jennifer**

```sql
-- Substituir pelo ID real de Jennifer
INSERT INTO login_funcionarios (funcionario_id, usuario, senha_hash, ativo, senha_definida, precisa_trocar_senha)
VALUES (
  '866ae21a-ba51-4fca-bbba-4d4610017a4e',  -- ?? Substitua pelo ID de Jennifer
  'jennifer',
  crypt('123456', gen_salt('bf')),
  TRUE,
  TRUE,
  TRUE
)
ON CONFLICT (funcionario_id) DO UPDATE
SET 
  ativo = TRUE,
  senha_definida = TRUE,
  precisa_trocar_senha = TRUE;
```

---

### **Opção B: Ativar Jennifer manualmente**

```sql
-- Ativar Jennifer
UPDATE funcionarios
SET 
  usuario_ativo = TRUE,
  senha_definida = TRUE,
  status = 'ativo',
  ativo = TRUE,
  primeiro_acesso = TRUE
WHERE id = '866ae21a-ba51-4fca-bbba-4d4610017a4e';  -- ?? ID de Jennifer
```

---

### **Opção C: Resetar senha de Jennifer**

```sql
-- Se login já existe mas senha não funciona
SELECT atualizar_senha_funcionario(
  '866ae21a-ba51-4fca-bbba-4d4610017a4e'::UUID,  -- ?? ID de Jennifer
  '123456'
);
```

---

## ?? **VERIFICAÇÃO FINAL**

Execute este comando para ver quantos funcionários DEVEM aparecer:

```sql
SELECT 
  nome,
  email,
  tipo_admin,
  usuario_ativo,
  senha_definida,
  ativo,
  status,
  CASE 
    WHEN usuario_ativo = TRUE 
     AND senha_definida = TRUE 
     AND (ativo = TRUE OR ativo IS NULL)
     AND (status = 'ativo' OR status IS NULL)
    THEN '? DEVE APARECER'
    ELSE '? NÃO VAI APARECER'
  END as vai_aparecer
FROM funcionarios
WHERE empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY nome;
```

---

## ?? **RESPOSTA ESPERADA**

Após executar os scripts, a query acima deve mostrar:

```
nome                    | vai_aparecer
-----------------------|----------------
Cristiano Ramos Mendes | ? DEVE APARECER
Jennifer               | ? DEVE APARECER
```

E no frontend (`/login-local`):

```
????????????????  ????????????????
?   ?? Cris    ?  ?   ?? Jen     ?
?              ?  ?              ?
?Administrador ?  ?   Vendedor   ?
????????????????  ????????????????
```

---

## ?? **ORDEM DE EXECUÇÃO**

1. ? `FIX_JENNIFER_NAO_APARECE.sql` (Diagnóstico + Correção)
2. ? `CORRECAO_COMPLETA_EXECUTAR_AGORA.sql` (RPC corrigida)
3. ? Teste em `http://localhost:5173/login-local`

---

## ?? **DICA FINAL**

Se Cristiano é **admin_empresa** e você NÃO quer que ele apareça no login local (pois ele deve usar `/login` com email+senha), modifique a RPC:

```sql
-- Trocar esta linha na RPC:
AND (f.tipo_admin IS NULL OR f.tipo_admin != 'super_admin')

-- Por esta:
AND (f.tipo_admin IS NULL OR f.tipo_admin NOT IN ('admin_empresa', 'super_admin'))
```

Isso fará com que apenas **Jennifer** apareça no `/login-local`, e Cristiano use o `/login` normal.

---

**?? Execute os scripts e teste! Me diga o resultado!**
