# 🚨 GUIA PASSO A PASSO - CORRIGIR PERMISSÕES USER_APPROVALS

## ❗ PROBLEMA IDENTIFICADO
- A tabela `user_approvals` existe no banco
- **MAS** está bloqueada por permissões (RLS - Row Level Security)
- Código de erro: `42501 - permission denied for table user_approvals`

## 🎯 SOLUÇÃO URGENTE

### PASSO 1: Abrir Supabase Dashboard
1. Vá para: https://supabase.com/dashboard
2. Faça login na sua conta
3. Selecione o projeto: **kmcaaqetxtwkdcczdomw**

### PASSO 2: Executar Script SQL
1. No painel esquerdo, clique em **SQL Editor**
2. Clique em **New Query**
3. Cole o seguinte código SQL:

```sql
-- ===================================================
-- 🚨 CORREÇÃO URGENTE - PERMISSÕES USER_APPROVALS
-- ===================================================

-- 1. Desabilitar RLS temporariamente
ALTER TABLE user_approvals DISABLE ROW LEVEL SECURITY;

-- 2. Dar permissões completas
GRANT ALL ON TABLE user_approvals TO anon;
GRANT ALL ON TABLE user_approvals TO authenticated;
GRANT ALL ON TABLE user_approvals TO service_role;

-- 3. Criar políticas permissivas
DROP POLICY IF EXISTS "user_approvals_select_policy" ON user_approvals;
CREATE POLICY "user_approvals_select_policy" ON user_approvals FOR SELECT USING (true);

DROP POLICY IF EXISTS "user_approvals_insert_policy" ON user_approvals;
CREATE POLICY "user_approvals_insert_policy" ON user_approvals FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "user_approvals_update_policy" ON user_approvals;
CREATE POLICY "user_approvals_update_policy" ON user_approvals FOR UPDATE USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "user_approvals_delete_policy" ON user_approvals;
CREATE POLICY "user_approvals_delete_policy" ON user_approvals FOR DELETE USING (true);

-- 4. Reabilitar RLS (agora com políticas permissivas)
ALTER TABLE user_approvals ENABLE ROW LEVEL SECURITY;

-- 5. Inserir o admin
INSERT INTO user_approvals (email, status, created_at, updated_at)
VALUES (
    'novaradiosystem@outlook.com',
    'approved',
    now(),
    now()
)
ON CONFLICT (email) DO UPDATE SET
    status = 'approved',
    updated_at = now();

-- 6. Verificar se funcionou
SELECT * FROM user_approvals WHERE email = 'novaradiosystem@outlook.com';
```

4. Clique em **RUN** para executar

### PASSO 3: Verificar se Funcionou
Você deve ver no resultado:
- ✅ Uma linha mostrando: `novaradiosystem@outlook.com | approved`

### PASSO 4: Testar o Frontend
1. Volte para o sistema no navegador: http://localhost:5175
2. Tente fazer login com: `novaradiosystem@outlook.com`
3. Acesse o AdminPanel

## 🔍 SE NÃO FUNCIONAR

Execute este teste após o script SQL:
```bash
node testar-tabela-user-approvals.js
```

Deve mostrar:
- ✅ Tabela existe!
- ✅ Select funcionou!
- ✅ Admin encontrado!

## 📞 STATUS ATUAL
- ❌ **Tabela user_approvals com permissões bloqueadas**
- ✅ Supabase funcionando
- ✅ Outras tabelas acessíveis
- ✅ Frontend rodando na porta 5175

## ⚡ RESULTADO ESPERADO
Após executar o script SQL, o AdminPanel deve carregar sem erros e mostrar a lista de usuários para aprovação.

---
*Criado em: $(Get-Date)*
*Projeto: PDV Allimport*
*Issue: Correção de permissões user_approvals*
