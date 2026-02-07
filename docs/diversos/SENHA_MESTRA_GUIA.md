# 🔐 SISTEMA DE SENHA MESTRA PARA SQL

## 🎯 O QUE É?

Sistema de **autenticação adicional** que requer uma **senha mestra** antes de executar operações críticas no banco de dados Supabase.

---

## ✅ O QUE FOI INSTALADO

### 1. **Senha Mestra**
- Armazenada com hash bcrypt (criptografada)
- Apenas o super admin pode trocar
- Expiração de bypass temporário (5 minutos)

### 2. **Log de Tentativas**
- Registra todas as tentativas (válidas e inválidas)
- Permite auditoria completa
- Identifica acessos não autorizados

### 3. **Funções Protegidas**
- `delete_user_with_password()` - Deletar usuário
- `execute_sql_with_password()` - Executar SQL arbitrário
- `change_master_password()` - Trocar senha

---

## 🚀 INSTALAÇÃO

1. Abra **Supabase Dashboard** → **SQL Editor**
2. Cole o conteúdo de `SENHA_MESTRA_SQL.sql`
3. Execute (Run)
4. **TROQUE A SENHA IMEDIATAMENTE!**

---

## 🔑 SENHA PADRÃO INICIAL

```
SENHA: RaVal@2026Secure
```

⚠️ **CRÍTICO**: Troque imediatamente após instalação!

---

## 🛠️ COMO USAR

### 1. Trocar Senha Mestra (PRIMEIRO PASSO!)

```sql
SELECT change_master_password(
    'RaVal@2026Secure',  -- Senha atual
    'MinhaSenh@Forte123!'  -- Nova senha (mínimo 12 caracteres)
);
```

**Resultado esperado:**
```json
{
  "success": true,
  "message": "Senha mestra alterada com sucesso"
}
```

---

### 2. Validar Senha Mestra

```sql
SELECT validate_master_password('MinhaSenh@Forte123!');
-- Retorna: true ou false
```

---

### 3. Deletar Usuário (com senha)

```sql
SELECT delete_user_with_password(
    'MinhaSenh@Forte123!',  -- Senha mestra
    'uuid-do-usuario-aqui'   -- UUID do usuário
);
```

**Resultado esperado:**
```json
{
  "success": true,
  "message": "Usuário deletado com sucesso"
}
```

---

### 4. Executar SQL Crítico (com senha)

```sql
SELECT execute_sql_with_password(
    'MinhaSenh@Forte123!',
    'DELETE FROM user_approvals WHERE email = ''teste@teste.com'''
);
```

**Comandos bloqueados por segurança:**
- `DROP DATABASE`
- `DROP SCHEMA`
- `TRUNCATE auth.users`

---

### 5. Criar Bypass Temporário (5 minutos)

```sql
-- Útil para executar múltiplos comandos seguidos
SELECT create_temp_bypass('MinhaSenh@Forte123!');
-- Retorna: session_id único

-- Agora você tem 5 minutos para executar comandos sem pedir senha novamente
```

---

## 📊 MONITORAMENTO E AUDITORIA

### Ver Todas as Tentativas
```sql
SELECT 
    user_email,
    success,
    operation_type,
    attempted_at
FROM master_password_attempts 
ORDER BY attempted_at DESC 
LIMIT 20;
```

### Ver Apenas Falhas (tentativas inválidas)
```sql
SELECT 
    user_email,
    operation_type,
    blocked_reason,
    attempted_at
FROM master_password_attempts 
WHERE success = false
ORDER BY attempted_at DESC;
```

### Estatísticas de Hoje
```sql
SELECT 
    COUNT(*) FILTER (WHERE success = true) as tentativas_validas,
    COUNT(*) FILTER (WHERE success = false) as tentativas_invalidas,
    COUNT(DISTINCT user_email) as usuarios_distintos
FROM master_password_attempts 
WHERE attempted_at::date = CURRENT_DATE;
```

---

## 🔒 SEGURANÇA

### ✅ Proteções Implementadas:

1. **Hash Bcrypt** - Senha nunca armazenada em texto plano
2. **Super Admin Only** - Apenas novaradiosystem@outlook.com pode trocar senha
3. **Log Completo** - Todas as tentativas registradas
4. **Bypass Temporário** - Expira em 5 minutos automaticamente
5. **Bloqueio de Comandos** - DROP DATABASE, DROP SCHEMA bloqueados
6. **Requisito de Tamanho** - Senha mínima de 12 caracteres

---

## 💡 CENÁRIOS DE USO

### Cenário 1: Deletar Usuário Pagante em Emergência

```sql
-- 1. Validar que tem a senha
SELECT validate_master_password('MinhaSenh@Forte123!');

-- 2. Deletar com senha
SELECT delete_user_with_password(
    'MinhaSenh@Forte123!',
    (SELECT id FROM user_approvals WHERE email = 'usuario@pagante.com')
);

-- 3. Verificar no log
SELECT * FROM master_password_attempts 
WHERE operation_type LIKE '%DELETE_USER%' 
ORDER BY attempted_at DESC LIMIT 1;
```

### Cenário 2: Executar Manutenção no Banco

```sql
-- 1. Criar bypass temporário (evita digitar senha várias vezes)
SELECT create_temp_bypass('MinhaSenh@Forte123!');

-- 2. Executar múltiplos comandos (5 minutos de validade)
SELECT execute_sql_with_password(
    'MinhaSenh@Forte123!',
    'UPDATE user_approvals SET deleted_at = NOW() WHERE email = ''teste1@teste.com'''
);

SELECT execute_sql_with_password(
    'MinhaSenh@Forte123!',
    'UPDATE user_approvals SET deleted_at = NOW() WHERE email = ''teste2@teste.com'''
);

-- Bypass expira automaticamente em 5 minutos
```

### Cenário 3: Investigar Tentativas Suspeitas

```sql
-- Ver tentativas falhas nas últimas 24h
SELECT 
    user_email,
    operation_type,
    COUNT(*) as tentativas,
    MAX(attempted_at) as ultima_tentativa
FROM master_password_attempts 
WHERE success = false 
AND attempted_at > NOW() - INTERVAL '24 hours'
GROUP BY user_email, operation_type
ORDER BY tentativas DESC;
```

---

## ⚠️ BOAS PRÁTICAS

### ✅ FAÇA:
- ✅ Troque a senha padrão **IMEDIATAMENTE**
- ✅ Use senhas fortes (mínimo 12 caracteres, letras, números, símbolos)
- ✅ Monitore `master_password_attempts` regularmente
- ✅ Troque a senha periodicamente (a cada 3-6 meses)
- ✅ Use bypass temporário para múltiplos comandos

### ❌ NÃO FAÇA:
- ❌ Compartilhar a senha mestra
- ❌ Salvar senha em arquivos não criptografados
- ❌ Usar senhas fracas
- ❌ Ignorar tentativas falhas no log
- ❌ Deixar bypass ativo por muito tempo

---

## 🧪 TESTAR O SISTEMA

```sql
-- 1. Testar validação com senha correta
SELECT validate_master_password('RaVal@2026Secure');
-- Deve retornar: true

-- 2. Testar validação com senha errada
SELECT validate_master_password('senha_errada');
-- Deve retornar: false

-- 3. Verificar log de tentativas
SELECT * FROM master_password_attempts ORDER BY attempted_at DESC LIMIT 3;
-- Deve mostrar ambas as tentativas (success = true e success = false)

-- 4. Trocar senha
SELECT change_master_password('RaVal@2026Secure', 'MinhaNovaSenh@123!');
-- Deve retornar: {"success": true, ...}

-- 5. Testar nova senha
SELECT validate_master_password('MinhaNovaSenh@123!');
-- Deve retornar: true
```

---

## 🆘 RECUPERAÇÃO DE SENHA

Se você **esquecer a senha mestra**:

### Opção 1: Via Supabase Dashboard (Super User)
```sql
-- Resetar senha para uma nova (executar como postgres superuser)
UPDATE master_passwords SET active = false WHERE active = true;

INSERT INTO master_passwords (password_hash, description, active)
VALUES (
    crypt('NovaSenha@Emergencia2026', gen_salt('bf', 10)),
    'Senha resetada por emergência',
    true
);
```

### Opção 2: Via Service Role Key
Use um script Node.js com `service_role_key` para resetar a senha.

---

## 📋 CHECKLIST PÓS-INSTALAÇÃO

- [ ] ✅ SQL executado no Supabase
- [ ] ✅ Senha padrão trocada
- [ ] ✅ Nova senha testada e funcional
- [ ] ✅ Senha anotada em local seguro (gerenciador de senhas)
- [ ] ✅ Testado `delete_user_with_password()`
- [ ] ✅ Testado `execute_sql_with_password()`
- [ ] ✅ Log de tentativas verificado
- [ ] ✅ Bypass temporário testado

---

## 🎯 RESUMO

| Recurso | Descrição |
|---------|-----------|
| **Senha Mestra** | Autenticação adicional para SQLs críticos |
| **Log de Tentativas** | Auditoria completa de acessos |
| **Funções Protegidas** | Delete/SQL só com senha correta |
| **Bypass Temporário** | 5 minutos sem pedir senha |
| **Super Admin Only** | Apenas novaradiosystem@outlook.com controla |

**Resultado:** Nenhum SQL crítico pode ser executado sem a senha mestra, nem mesmo pelo super admin do Supabase! 🔒
