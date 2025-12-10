# ? CORREÇÃO EM 30 SEGUNDOS

## ?? EXECUTAR AGORA

### **1. Abra Supabase SQL Editor**
```
https://supabase.com/dashboard ? SQL Editor ? New query
```

### **2. Copie e Cole**
```
Arquivo: CORRECAO_COMPLETA_EXECUTAR_AGORA.sql
Ctrl+A ? Ctrl+C ? Colar no Supabase ? RUN
```

### **3. Teste**
```
http://localhost:5173/login-local
Deve aparecer cards de usuários
```

---

## ? RESULTADO ESPERADO

```
? Extension pgcrypto garantida
? RPC listar_usuarios_ativos corrigida
? RPC validar_senha_local corrigida
? RPC atualizar_senha_funcionario corrigida
? RPC trocar_senha_propria criada
?? CORREÇÃO COMPLETA!
```

---

## ?? SE DER ERRO

### **Cards não aparecem:**
```sql
UPDATE funcionarios SET usuario_ativo = true, senha_definida = true;
```

### **Senha não valida:**
```sql
SELECT atualizar_senha_funcionario(
  (SELECT funcionario_id FROM login_funcionarios WHERE usuario = 'seu_usuario'),
  'nova_senha_123'
);
```

### **Erro pgcrypto:**
```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

---

## ?? GUIAS COMPLETOS

- **GUIA_VISUAL_EXECUCAO.md** ? Passo a passo com imagens
- **CORRECAO_RAPIDA_LOGIN.md** ? Guia detalhado
- **DIAGNOSTICO_LOGIN_FUNCIONARIOS.sql** ? Diagnóstico completo

---

**?? Tempo: 30 segundos**

**?? Arquivo: `CORRECAO_COMPLETA_EXECUTAR_AGORA.sql`**

**?? Boa sorte!**
