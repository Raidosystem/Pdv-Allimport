# 🚨 CORREÇÃO URGENTE: Funcionários Sem Login

## ⚡ SOLUÇÃO RÁPIDA (2 minutos)

### Passo 1: Corrigir Jennifer AGORA

1. Abra o **SQL Editor do Supabase**
2. Cole e execute: **`migrations/CORRIGIR_JENNIFER_URGENTE.sql`**
3. ✅ Jennifer poderá fazer login imediatamente

**Credenciais da Jennifer:**
- Usuário: `jennifer`
- Senha: `Senha@123`

### Passo 2: Corrigir TODOS + Prevenir Futuros

1. No mesmo **SQL Editor do Supabase**
2. Cole e execute: **`migrations/EXECUTAR_AGORA_CORRECAO_COMPLETA.sql`**
3. ✅ Todos os funcionários estarão corrigidos
4. ✅ Trigger automático criado (nunca mais terá esse problema)

---

## 📝 Como Acessar o SQL Editor do Supabase

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Menu lateral: **SQL Editor**
4. Clique em **New Query**
5. Cole o script
6. Clique em **Run** (ou Ctrl+Enter)

---

## 🧪 Testar se Funcionou

Acesse: https://pdv.gruporaval.com.br/login-local

Você deve ver **TODOS** os funcionários ativos listados, incluindo Jennifer.

---

## 📋 Arquivos Criados

| Arquivo | Descrição |
|---------|-----------|
| `CORRIGIR_JENNIFER_URGENTE.sql` | ⚡ Correção imediata só da Jennifer |
| `EXECUTAR_AGORA_CORRECAO_COMPLETA.sql` | ✅ Correção completa + trigger automático |
| `DIAGNOSTICAR_LOGIN_FUNCIONARIOS.sql` | 🔍 Investigar problemas |
| `GARANTIR_LOGIN_UNIVERSAL.sql` | 🔧 Função reutilizável |
| `SOLUCAO_DEFINITIVA_LOGIN.sql` | 📦 Pacote completo |

---

## 🔐 Credenciais Padrão

Todos os funcionários terão:

- **Usuário:** primeiro nome minúsculo sem acentos
  - Jennifer → `jennifer`
  - João Paulo → `joao`
  - María José → `maria`

- **Senha:** `Senha@123`

- **Obrigação:** Trocar senha no primeiro acesso

---

## 🤖 Automação Futura

Após executar `EXECUTAR_AGORA_CORRECAO_COMPLETA.sql`, o sistema terá um **trigger** que:

- ✅ Cria login automaticamente para todo funcionário novo
- ✅ Reativa login quando funcionário for reativado
- ✅ Desativa login quando funcionário for inativado

**Você nunca mais precisará se preocupar com isso!**

---

## ❓ Precisa de Ajuda?

Se algum funcionário ainda não aparecer:

```sql
-- Execute no SQL Editor do Supabase
SELECT * FROM garantir_login_funcionario(
  (SELECT id FROM funcionarios WHERE email = 'EMAIL_DO_FUNCIONARIO')
);
```

---

**Última atualização:** 13/12/2024 - 21:00
