# 🚀 PASSO A PASSO - EXECUTAR NO SUPABASE

## ⚠️ IMPORTANTE
Execute TODOS os scripts abaixo no **SQL Editor do Supabase** na ordem indicada.

---

## 📋 ORDEM DE EXECUÇÃO

### **PASSO 1: Criar Sistema de Assinaturas** ✅
**Arquivo:** `COPIAR_E_COLAR_NO_SUPABASE.sql`

**O que faz:**
- Cria tabela `subscriptions`
- Cria trigger automático para 15 dias de teste
- Cria funções para calcular dias restantes
- Ativa teste automaticamente ao aprovar usuário

**Como executar:**
```bash
1. Abra: https://supabase.com/dashboard/project/SEU-PROJECT-ID/sql
2. Copie TODO o conteúdo de: COPIAR_E_COLAR_NO_SUPABASE.sql
3. Cole no SQL Editor
4. Clique em RUN
5. Aguarde: "✅ SISTEMA CONFIGURADO COM SUCESSO!"
```

---

### **PASSO 2: Configurar Permissões de Admin** ✅
**Arquivo:** `CONFIGURAR_ACESSO_ADMIN_TOTAL.sql`

**O que faz:**
- Dá acesso TOTAL aos admins
- Permite ver TODAS as assinaturas
- Permite ver TODOS os usuários
- Permite modificar qualquer dado

**Como executar:**
```bash
1. No mesmo SQL Editor do Supabase
2. Copie TODO o conteúdo de: CONFIGURAR_ACESSO_ADMIN_TOTAL.sql
3. Cole no SQL Editor
4. Clique em RUN
5. Aguarde: "🎉 CONFIGURAÇÃO CONCLUÍDA!"
```

---

## 🔍 VERIFICAÇÃO

### Após executar TUDO, teste:

```sql
-- 1. Ver todas as assinaturas (deve funcionar)
SELECT * FROM subscriptions ORDER BY created_at DESC;

-- 2. Ver todos os usuários (deve funcionar)
SELECT * FROM user_approvals ORDER BY created_at DESC;

-- 3. Ver políticas (deve mostrar as políticas criadas)
SELECT * FROM pg_policies WHERE tablename IN ('subscriptions', 'user_approvals');
```

Se TUDO funcionar, você verá os dados! ✅

---

## 👤 QUEM TEM ACESSO ADMIN?

Os seguintes emails têm **acesso TOTAL** ao sistema:

✅ `admin@pdvallimport.com`  
✅ `novaradiosystem@outlook.com`

### Para adicionar outro admin:

```sql
-- Edite o email abaixo
UPDATE auth.users
SET raw_app_meta_data = 
  COALESCE(raw_app_meta_data, '{}'::jsonb) || '{"role": "admin"}'::jsonb
WHERE email = 'SEU-EMAIL@EXEMPLO.COM';
```

---

## 🎯 RESUMO

### Scripts para executar (NA ORDEM):

1. **COPIAR_E_COLAR_NO_SUPABASE.sql**
   - Cria sistema de assinaturas
   - Trigger de 15 dias automático

2. **CONFIGURAR_ACESSO_ADMIN_TOTAL.sql**
   - Dá permissões TOTAIS ao admin
   - Permite acessar TUDO no dashboard

---

## ✅ CHECKLIST

- [ ] Executei `COPIAR_E_COLAR_NO_SUPABASE.sql`
- [ ] Vi mensagem "✅ SISTEMA CONFIGURADO COM SUCESSO!"
- [ ] Executei `CONFIGURAR_ACESSO_ADMIN_TOTAL.sql`
- [ ] Vi mensagem "🎉 CONFIGURAÇÃO CONCLUÍDA!"
- [ ] Testei `SELECT * FROM subscriptions` (funciona!)
- [ ] Testei `SELECT * FROM user_approvals` (funciona!)
- [ ] Acessei `/admin` no sistema
- [ ] Vejo todos os assinantes no dashboard

---

## 🚨 PROBLEMAS COMUNS

### "Erro: permission denied for table subscriptions"
**Solução:** Execute `CONFIGURAR_ACESSO_ADMIN_TOTAL.sql`

### "Erro: relation subscriptions does not exist"
**Solução:** Execute `COPIAR_E_COLAR_NO_SUPABASE.sql` primeiro

### "Não vejo nenhum assinante no dashboard"
**Solução:** 
1. Verifique se tem usuários aprovados: `SELECT * FROM user_approvals WHERE status = 'approved'`
2. Verifique se eles têm assinaturas: `SELECT * FROM subscriptions`

### "Access Denied no dashboard"
**Solução:**
1. Verifique se seu email está na lista de admins
2. Execute a query UPDATE para tornar seu usuário admin

---

## 🎉 PRONTO!

Após executar os 2 scripts, você terá:

✅ Sistema de assinaturas funcionando  
✅ 15 dias de teste automático  
✅ Admin com acesso TOTAL ao banco  
✅ Dashboard mostrando todos os assinantes  
✅ Controle total de pausar/adicionar dias  

**Acesse `/admin` e gerencie seus assinantes!** 🚀
