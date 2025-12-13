# 🔧 Como Corrigir Funcionários Sem Login

## 🚨 Problema
Funcionários cadastrados não aparecem na tela de login (`/login-local`)

## ✅ Solução Definitiva

### Opção 1: Correção Completa (RECOMENDADO)
Execute o script que corrige todos os problemas e previne futuros:

```sql
-- No SQL Editor do Supabase
\i migrations/SOLUCAO_DEFINITIVA_LOGIN.sql
```

**Este script:**
- ✅ Corrige TODOS os funcionários existentes
- ✅ Cria trigger para funcionários futuros
- ✅ Garante que o problema nunca mais aconteça
- ✅ Define credenciais padrão automáticas

### Opção 2: Diagnóstico Primeiro
Se quiser investigar antes de corrigir:

```sql
-- No SQL Editor do Supabase
\i migrations/DIAGNOSTICAR_LOGIN_FUNCIONARIOS.sql
```

Depois execute a correção:

```sql
\i migrations/GARANTIR_LOGIN_UNIVERSAL.sql
```

## 🔐 Credenciais Padrão

Após executar a correção, os funcionários terão:

- **Usuário:** primeiro nome (minúsculo, sem acentos)
  - Exemplo: "Jennifer Silva" → `jennifer`
  - Exemplo: "João Paulo" → `joao`
  
- **Senha:** `Senha@123`

- **Obrigação:** Trocar senha no primeiro acesso

## 📋 Verificar se Funcionou

### 1. No Supabase (SQL Editor)

```sql
-- Ver todos os funcionários com login
SELECT 
  f.nome,
  lf.usuario,
  lf.ativo,
  CASE 
    WHEN lf.ativo = true AND lf.usuario IS NOT NULL 
    THEN '✅ VAI APARECER'
    ELSE '❌ NÃO VAI APARECER'
  END as status
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
WHERE f.status = 'ativo'
AND f.empresa_id = (SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com')
ORDER BY f.nome;
```

### 2. No Sistema (Interface)

1. Acesse: `https://pdv.gruporaval.com.br/login-local`
2. Verifique se TODOS os funcionários ativos aparecem
3. Teste o login de cada um:
   - Usuário: primeiro nome do funcionário
   - Senha: `Senha@123`

## 🆘 Solução Rápida para UM Funcionário

Se apenas um funcionário específico está com problema:

```sql
-- Substituir '[EMAIL_DO_FUNCIONARIO]' pelo email real
SELECT * FROM garantir_login_funcionario(
  (SELECT id FROM funcionarios WHERE email = '[EMAIL_DO_FUNCIONARIO]')
);
```

## 🔍 Entender o Problema

A tela de login usa a função `listar_usuarios_ativos` que filtra:
- ✅ `funcionarios.status = 'ativo'`
- ✅ `login_funcionarios.ativo = true`
- ✅ `login_funcionarios.usuario IS NOT NULL`

Se qualquer uma dessas condições falhar, o funcionário não aparece.

## 🚀 Prevenção Automática

Após executar `SOLUCAO_DEFINITIVA_LOGIN.sql`, o sistema terá um **trigger** que:

1. **Cria login automaticamente** para todo funcionário novo
2. **Reativa login** quando funcionário for reativado
3. **Desativa login** quando funcionário for inativado

**Você nunca mais precisará se preocupar com isso!**

## 📞 Informar aos Funcionários

Após a correção, envie esta mensagem aos funcionários:

---

**Assunto: Acesso ao Sistema PDV**

Olá!

Seu login foi configurado no sistema PDV.

**Como fazer login:**
1. Acesse: https://pdv.gruporaval.com.br/login-local
2. Clique no seu nome
3. Use a senha temporária: `Senha@123`
4. Você será solicitado a criar uma senha pessoal

**Seu usuário:** [primeiro nome minúsculo]

Qualquer dúvida, entre em contato.

---

## 🔐 Segurança

- ✅ Senhas são criptografadas com **bcrypt**
- ✅ Obrigação de trocar senha no primeiro acesso
- ✅ Sistema de bloqueio após tentativas falhas
- ✅ Isolamento por empresa (RLS)

## 📚 Scripts Disponíveis

1. **DIAGNOSTICAR_LOGIN_FUNCIONARIOS.sql** - Investigar problemas
2. **GARANTIR_LOGIN_UNIVERSAL.sql** - Correção manual
3. **SOLUCAO_DEFINITIVA_LOGIN.sql** - Correção + Trigger (RECOMENDADO)
4. **CORRIGIR_LOGIN_TODOS_FUNCIONARIOS.sql** - Alternativa de correção

## ✅ Checklist Pós-Correção

- [ ] Script executado no Supabase
- [ ] Todos os funcionários aparecem em `/login-local`
- [ ] Login testado com pelo menos um funcionário
- [ ] Funcionários informados sobre as credenciais
- [ ] Senha padrão trocada pelos funcionários

---

**Última atualização:** 13/12/2024
