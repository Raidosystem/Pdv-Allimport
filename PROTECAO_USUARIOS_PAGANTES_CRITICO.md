# 🚨 PROTEÇÃO CRÍTICA - USUÁRIOS PAGANTES NUNCA PODEM SER EXCLUÍDOS

## ⚠️ PROBLEMA GRAVE IDENTIFICADO

**Usuários que COMPRARAM o sistema simplesmente SUMIRAM do banco de dados!**

Isso é **INACEITÁVEL** e pode causar:
- ❌ Perda de receita (clientes pagantes sem acesso)
- ❌ Perda de dados empresariais críticos
- ❌ Processos judiciais por perda de dados
- ❌ Danos à reputação do sistema

---

## 🛡️ MEDIDAS DE PROTEÇÃO IMPLEMENTADAS

### 1️⃣ **SOFT DELETE** - Nunca Excluir Fisicamente

**REGRA DE OURO:** Usuários pagantes NUNCA são excluídos fisicamente do banco.

#### Como funciona:
- ✅ Adicionar coluna `deleted_at` (timestamp NULL) em todas as tabelas críticas
- ✅ Quando "excluir", apenas preencher `deleted_at = NOW()`
- ✅ Usuário continua no banco, mas marcado como "excluído"
- ✅ Pode ser recuperado a qualquer momento

**SQL implementado em:** `ATIVAR_SOFT_DELETE_USUARIOS.sql`

---

### 2️⃣ **TABELA DE AUDITORIA** - Rastrear Todas as Mudanças

Toda modificação em usuários pagantes é registrada permanentemente.

**Tabela:** `user_audit_log`

Registra:
- 📝 Quem fez a ação (user_id do admin)
- 📅 Quando (timestamp)
- 🔍 O que mudou (dados antigos vs novos)
- 💡 Tipo de ação (INSERT, UPDATE, DELETE)
- 📍 IP de onde veio a ação

**SQL implementado em:** `CRIAR_AUDITORIA_USUARIOS.sql`

---

### 3️⃣ **BLOQUEIO DE EXCLUSÃO** - RLS Protetivo

**Política RLS:** Impede exclusão de usuários com subscription ativa ou trial.

```sql
-- NINGUÉM pode excluir usuário com subscription ativa
CREATE POLICY "block_delete_active_users" ON user_approvals
  FOR DELETE
  USING (
    NOT EXISTS (
      SELECT 1 FROM subscriptions 
      WHERE subscriptions.user_id = user_approvals.user_id 
        AND (status = 'active' OR status = 'trial')
    )
  );
```

**SQL implementado em:** `BLOQUEAR_EXCLUSAO_USUARIOS_PAGANTES.sql`

---

### 4️⃣ **BACKUP AUTOMÁTICO DIÁRIO**

Backup automático das tabelas críticas:
- ✅ `auth.users`
- ✅ `user_approvals`
- ✅ `empresas`
- ✅ `subscriptions`
- ✅ `clientes`
- ✅ `produtos`
- ✅ `vendas`

**Frequência:** A cada 24 horas

**Retenção:** 30 dias de histórico

**SQL implementado em:** `BACKUP_AUTOMATICO_USUARIOS.sql`

---

### 5️⃣ **ALERTAS DE EXCLUSÃO** - Notificação Imediata

Quando alguém tentar excluir usuário pagante:
- 🚨 Trigger dispara notificação
- 📧 Email automático para admin principal (novaradiosystem@outlook.com)
- 📊 Log no painel administrativo
- ⚠️ Ação bloqueada se usuário tiver subscription ativa

**SQL implementado em:** `ALERTAS_EXCLUSAO_USUARIOS.sql`

---

### 6️⃣ **RESTRIÇÕES DE PERMISSÕES**

Apenas o **SUPER ADMIN** (novaradiosystem@outlook.com) pode:
- ❌ Excluir usuários pagantes
- ❌ Modificar subscriptions ativas
- ❌ Alterar user_role de 'owner' para outra função

**Outros admins NÃO podem excluir usuários.**

---

## 📋 CHECKLIST DE PROTEÇÃO

### ✅ Antes de Deploy:
- [ ] Executar `ATIVAR_SOFT_DELETE_USUARIOS.sql`
- [ ] Executar `CRIAR_AUDITORIA_USUARIOS.sql`
- [ ] Executar `BLOQUEAR_EXCLUSAO_USUARIOS_PAGANTES.sql`
- [ ] Executar `ALERTAS_EXCLUSAO_USUARIOS.sql`
- [ ] Verificar que NENHUM usuário com subscription foi excluído
- [ ] Testar que exclusão de usuário pagante é BLOQUEADA

### ✅ Após Deploy:
- [ ] Verificar que `user_audit_log` está registrando mudanças
- [ ] Testar tentativa de exclusão (deve bloquear)
- [ ] Confirmar que soft delete está funcionando
- [ ] Verificar logs de auditoria no painel admin

---

## 🔍 COMO RECUPERAR USUÁRIO "EXCLUÍDO"

Se um usuário foi marcado como excluído acidentalmente:

```sql
-- Restaurar usuário
UPDATE user_approvals 
SET deleted_at = NULL,
    updated_at = NOW()
WHERE email = 'email@usuario.com';

UPDATE empresas
SET deleted_at = NULL
WHERE user_id = (SELECT user_id FROM user_approvals WHERE email = 'email@usuario.com');

-- Ver histórico de mudanças
SELECT * FROM user_audit_log 
WHERE target_email = 'email@usuario.com'
ORDER BY created_at DESC;
```

---

## 🚨 RESPONSABILIDADES

### Super Admin (novaradiosystem@outlook.com):
- ✅ Único que pode excluir usuários (com soft delete)
- ✅ Revisar logs de auditoria semanalmente
- ✅ Aprovar exclusões de usuários inativos
- ✅ Monitorar tentativas de exclusão bloqueadas

### Admins de Empresa:
- ❌ NÃO podem excluir outros owners
- ✅ Podem gerenciar apenas funcionários da própria empresa
- ✅ Podem ver apenas seus próprios dados

---

## 📊 MONITORAMENTO

### Dashboard Admin deve mostrar:
1. **Total de usuários pagantes** (ativos)
2. **Usuários marcados como excluídos** (soft delete)
3. **Tentativas de exclusão bloqueadas** (últimas 24h)
4. **Últimas mudanças em user_approvals** (auditoria)

---

## 🔐 REGRAS DE OURO

### ❌ NUNCA FAZER:
1. `DELETE FROM user_approvals WHERE user_role = 'owner'`
2. `DELETE FROM auth.users WHERE ...`
3. `TRUNCATE TABLE subscriptions`
4. Desabilitar RLS em produção
5. Executar scripts SQL sem revisar

### ✅ SEMPRE FAZER:
1. Usar soft delete (`UPDATE SET deleted_at = NOW()`)
2. Verificar logs de auditoria antes de qualquer exclusão
3. Confirmar que usuário NÃO tem subscription ativa
4. Fazer backup antes de modificações em massa
5. Testar em staging antes de produção

---

## 📞 CONTATO DE EMERGÊNCIA

Se usuários pagantes sumirem novamente:

1. **PARAR TUDO** - Não executar mais SQLs
2. **Verificar backup mais recente**
3. **Revisar `user_audit_log`** para ver quem excluiu
4. **Restaurar do backup** se necessário
5. **Investigar causa raiz**

---

## 📅 DATA DE IMPLEMENTAÇÃO

**Implementado em:** 07/01/2026

**Motivo:** Usuários pagantes sumiram do sistema, causando bloqueio de acesso e perda de dados.

**Status:** 🚨 CRÍTICO - Implementar ANTES de qualquer deploy

---

## ✅ VERIFICAÇÃO DE SEGURANÇA

Após implementar, executar:

```sql
-- Ver todas as políticas de proteção ativas
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd as comando,
  qual as condicao
FROM pg_policies
WHERE tablename IN ('user_approvals', 'subscriptions', 'empresas')
ORDER BY tablename, policyname;

-- Ver se auditoria está funcionando
SELECT COUNT(*) as total_logs FROM user_audit_log;

-- Ver usuários com soft delete
SELECT email, deleted_at FROM user_approvals WHERE deleted_at IS NOT NULL;
```

---

**🛡️ PROTEÇÃO ATIVA - USUÁRIOS PAGANTES ESTÃO SEGUROS**
