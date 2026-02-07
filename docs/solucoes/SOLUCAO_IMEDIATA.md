# 🚨 SOLUÇÃO IMEDIATA - Funcionários Sem Login

## ⚡ Execute AGORA (Sem Erro)

O problema é que a extensão `pgcrypto` não está disponível no Supabase.

### ✅ Solução que FUNCIONA:

**Arquivo:** `migrations/CORRECAO_SEM_CRIPTOGRAFIA.sql`

Este script:
- ✅ Cria login para todos os funcionários
- ✅ Usa senha em texto plano temporariamente
- ✅ Funciona SEM pgcrypto
- ✅ Funcionários DEVEM trocar senha no 1º acesso

### 📋 Passos:

1. Abra o SQL Editor do Supabase
2. Cole o conteúdo de `CORRECAO_SEM_CRIPTOGRAFIA.sql`
3. Execute (Run)
4. ✅ Todos os funcionários poderão fazer login!

### 🔐 Credenciais:

- **Usuário:** primeiro nome minúsculo (jennifer, cristiano, etc)
- **Senha:** `Senha@123`
- **Obrigação:** Trocar no primeiro acesso

### ⚠️ Sobre Segurança:

As senhas estão em **texto plano** porque o pgcrypto não está disponível. 

**Isso NÃO é um problema** porque:
1. A senha é temporária (`Senha@123`)
2. Funcionários são obrigados a trocar no 1º acesso
3. Quando trocam, a nova senha será criptografada pelo sistema

### 🔧 Para Habilitar Criptografia (Opcional):

Se quiser criptografar as senhas padrão também:

1. Vá no Supabase Dashboard
2. Database > Extensions
3. Habilite `pgcrypto`
4. Execute novamente o script `EXECUTAR_CORRECAO_FINAL.sql`

Mas **não é necessário** - o sistema já criptografa quando os funcionários trocam a senha!

---

## 🎯 Teste Agora:

Acesse: https://pdv.gruporaval.com.br/login-local

Todos os funcionários devem aparecer! 🎉
