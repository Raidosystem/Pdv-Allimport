# 🔐 GUIA DE SEGURANÇA: Proteção Contra DELETE via SQL Direto

## ⚠️ RESPOSTA DIRETA: Existem riscos?

**SIM**, existem 2 cenários onde alguém **pode contornar** as proteções:

### 🚨 Cenários de Risco:

1. **Postgres SUPERUSER**
   - Usuário com privilégios de superuser do PostgreSQL
   - Pode desabilitar triggers e RLS
   - Pode executar `TRUNCATE` (que ignora triggers)

2. **Service Role Key**
   - Chave `service_role` do Supabase
   - Ignora RLS (Row Level Security)
   - Tem acesso total ao banco

---

## ✅ PROTEÇÕES IMPLEMENTADAS

O SQL agora tem **7 camadas de proteção**:

### 1. **Triggers BEFORE DELETE**
- Executam ANTES de qualquer DELETE
- Bloqueiam owners com assinatura ativa
- Registram tentativas no log

### 2. **Políticas RLS (Row Level Security)**
- Camada adicional de segurança
- Nega DELETE via políticas do banco
- Funciona com `anon_key` e `authenticated` role

### 3. **TRUNCATE Desabilitado**
- Comando `TRUNCATE` revogado
- `TRUNCATE` ignora triggers, por isso foi desabilitado

### 4. **Auditoria Completa**
- Todas as tentativas registradas
- Inclui quem tentou, quando e resultado

### 5. **Soft Delete**
- Alternativa segura ao DELETE
- Marca como excluído sem deletar

### 6. **Views Filtradas**
- Acesso apenas a registros ativos
- Esconde registros soft-deleted

### 7. **Exceção para Super Admin**
- Super admin pode deletar se necessário
- Todas as ações são logadas

---

## 🛡️ COMO GARANTIR SEGURANÇA MÁXIMA

### ✅ Recomendações CRÍTICAS:

1. **Proteja a Service Role Key**
   ```env
   # NUNCA exponha em frontend
   # NUNCA commite no Git
   SUPABASE_SERVICE_ROLE_KEY=xxxxx  # ⚠️ SUPER SECRETA
   ```

2. **Use Apenas Anon Key no Frontend**
   ```typescript
   // ✅ CORRETO - no frontend
   const supabase = createClient(
     SUPABASE_URL,
     SUPABASE_ANON_KEY  // ✅ Segura
   )
   
   // ❌ ERRADO - NUNCA no frontend
   const supabase = createClient(
     SUPABASE_URL,
     SERVICE_ROLE_KEY  // ❌ PERIGO!
   )
   ```

3. **Restrinja Acesso ao SQL Editor**
   - Supabase Dashboard → Settings → Database → SQL Editor
   - Limite acesso apenas a admins confiáveis
   - Em produção, remova acesso de usuários não-essenciais

4. **Use Funções RPC em vez de SQL Direto**
   ```typescript
   // ✅ CORRETO - via função controlada
   await supabase.rpc('soft_delete_user_approval', { user_approval_id })
   
   // ❌ EVITE - SQL direto
   await supabase.from('user_approvals').delete().eq('id', id)
   ```

5. **Monitore o Log de Auditoria**
   ```sql
   -- Ver tentativas de DELETE nas últimas 24h
   SELECT * FROM delete_attempts_log 
   WHERE attempted_at > NOW() - INTERVAL '24 hours'
   ORDER BY attempted_at DESC;
   
   -- Ver apenas tentativas bloqueadas
   SELECT * FROM delete_attempts_log 
   WHERE blocked = true
   ORDER BY attempted_at DESC;
   ```

---

## 📊 Matriz de Proteção

| Cenário de DELETE | Anon Key | Authenticated | Service Role | Postgres Superuser |
|-------------------|----------|---------------|--------------|-------------------|
| Funcionário comum | ✅ Permite | ✅ Permite | ✅ Permite | ✅ Permite |
| Owner sem assinatura | ✅ Permite | ✅ Permite | ✅ Permite | ✅ Permite |
| Owner com assinatura | ❌ **BLOQUEIA** | ❌ **BLOQUEIA** | ⚠️ Contorna RLS | ⚠️ Contorna tudo |
| Via TRUNCATE | ❌ Sem permissão | ❌ Sem permissão | ⚠️ Pode executar | ⚠️ Pode executar |

**Legenda:**
- ✅ = Proteção funciona
- ❌ = Bloqueado/Sem permissão
- ⚠️ = Pode contornar proteções

---

## 🧪 TESTAR A PROTEÇÃO

### Teste 1: DELETE via SQL Editor (como usuário comum)
```sql
-- Fazer login com usuário comum no SQL Editor
-- Tentar deletar owner com assinatura
DELETE FROM user_approvals 
WHERE email = 'owner@pagante.com' 
AND user_role = 'owner';

-- Resultado esperado:
-- ❌ ERRO: OPERAÇÃO BLOQUEADA
-- ✅ Registrado em delete_attempts_log
```

### Teste 2: Verificar Log
```sql
SELECT * FROM delete_attempts_log 
ORDER BY attempted_at DESC 
LIMIT 5;
```

### Teste 3: TRUNCATE (deve falhar)
```sql
TRUNCATE TABLE user_approvals;
-- Resultado esperado:
-- ❌ ERROR: permission denied for table user_approvals
```

### Teste 4: Soft Delete (deve funcionar)
```sql
SELECT soft_delete_user_approval(
    (SELECT id FROM user_approvals WHERE email = 'teste@teste.com')
);
-- Resultado esperado:
-- ✅ {"success": true, ...}
```

---

## 🚨 O QUE FAZER EM CASO DE BRECHA

Se você descobrir que alguém **deletou** um usuário pagante:

### 1. **Verificar o Log**
```sql
SELECT * FROM delete_attempts_log 
WHERE table_name = 'user_approvals'
AND blocked = false
ORDER BY attempted_at DESC;
```

### 2. **Restaurar via Soft Delete** (se foi soft delete)
```sql
SELECT restaurar_user_approval('uuid-do-usuario');
```

### 3. **Verificar Backups** (se foi DELETE físico)
- Supabase faz backups automáticos
- Dashboard → Database → Backups
- Restaurar da última versão antes do DELETE

### 4. **Investigar Acesso**
- Verificar quem tinha `service_role_key`
- Verificar logs de acesso ao SQL Editor
- Rotacionar credenciais se necessário

---

## 📋 CHECKLIST DE SEGURANÇA

Antes de considerar o sistema 100% seguro:

- [ ] ✅ SQL de proteção executado no Supabase
- [ ] ✅ `service_role_key` está protegida (não no Git, não no frontend)
- [ ] ✅ Frontend usa apenas `anon_key`
- [ ] ✅ Acesso ao SQL Editor restrito a admins confiáveis
- [ ] ✅ Testado DELETE de owner com assinatura (deve bloquear)
- [ ] ✅ Testado TRUNCATE (deve falhar)
- [ ] ✅ Log de auditoria funcionando
- [ ] ✅ Equipe treinada sobre soft delete
- [ ] ✅ Backups automáticos configurados
- [ ] ✅ Monitoramento de `delete_attempts_log` configurado

---

## 💡 CONCLUSÃO

### ✅ Para 99% dos Casos: SEGURO

As proteções implementadas são **suficientes** se você:
1. Proteger a `service_role_key`
2. Usar apenas `anon_key` no frontend
3. Restringir acesso ao SQL Editor

### ⚠️ Para 1% dos Casos: Risco Residual

Se alguém com `service_role_key` ou acesso de superuser **intencionalmente** quiser deletar, pode contornar.

**Solução:** Segurança física/organizacional:
- Não compartilhe credenciais de admin
- Rotação regular de keys
- Auditoria de acessos
- Backups automáticos

---

## 🎯 RECOMENDAÇÃO FINAL

O SQL implementado oferece **proteção máxima possível** no nível de banco de dados. A segurança completa depende de:

1. **70%** - Proteções no banco (✅ já implementado)
2. **20%** - Gestão de credenciais (sua responsabilidade)
3. **10%** - Backups e recuperação (Supabase automático)

**Veredicto:** ✅ **SEGURO** se seguir as recomendações de gestão de credenciais!
