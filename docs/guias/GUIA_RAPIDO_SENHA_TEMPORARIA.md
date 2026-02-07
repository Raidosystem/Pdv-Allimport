# 🔐 Sistema de Senha Temporária - Guia Rápido

## 🎯 O Que Foi Implementado

```
ADMIN CRIA FUNCIONÁRIO
        ↓
    Senha Temporária (ex: temp123)
        ↓
FUNCIONÁRIO FAZ LOGIN
        ↓
    Sistema detecta: precisa_trocar_senha = TRUE
        ↓
REDIRECIONA AUTOMATICAMENTE → /trocar-senha
        ↓
FUNCIONÁRIO DEFINE SENHA PRÓPRIA
        ↓
    precisa_trocar_senha = FALSE
        ↓
NINGUÉM MAIS SABE A SENHA! ✅
```

---

## ⚡ Executar Agora (3 passos)

### 1️⃣ Executar no Supabase SQL Editor
```sql
-- PASSO 1: Adicionar coluna
-- Execute: 1_ADICIONAR_COLUNA_PRECISA_TROCAR_SENHA.sql

-- PASSO 2: Atualizar/Criar RPCs
-- Execute: 2_ATUALIZAR_RPCS_TROCAR_SENHA.sql
```

### 2️⃣ Testar Frontend
```bash
npm run dev
```

### 3️⃣ Testar Fluxo Completo
1. **Admin**: Criar funcionário com senha `temp123`
2. **Logout**
3. **Login como funcionário**: Usar `temp123`
4. **✅ Deve redirecionar** para tela de trocar senha
5. **Definir senha própria**: Ex: `minhaSenha456`
6. **Logout e login novamente**: Usar `minhaSenha456` ✅

---

## 📁 Arquivos Criados

### SQL (Banco de Dados)
- ✅ `1_ADICIONAR_COLUNA_PRECISA_TROCAR_SENHA.sql`
- ✅ `2_ATUALIZAR_RPCS_TROCAR_SENHA.sql`

### Frontend (React)
- ✅ `src/pages/TrocarSenhaPage.tsx` (NOVO)
- ✅ `src/modules/auth/LocalLoginPage.tsx` (MODIFICADO)
- ✅ `src/App.tsx` (MODIFICADO - nova rota `/trocar-senha`)

### Documentação
- ✅ `SISTEMA_SENHA_TEMPORARIA_COMPLETO.md` (Este arquivo + versão detalhada)

---

## 🔑 RPCs Criadas/Atualizadas

### 1. `criar_funcionario_com_senha` (ATUALIZADA)
```sql
-- Marca precisa_trocar_senha = TRUE ao criar
INSERT INTO login_funcionarios VALUES (
    ...,
    precisa_trocar_senha = TRUE  -- ⚠️ Força troca
);
```

### 2. `atualizar_senha_funcionario` (ATUALIZADA)
```sql
-- Marca precisa_trocar_senha = TRUE ao resetar
UPDATE login_funcionarios SET
    senha_hash = crypt(p_nova_senha, gen_salt('bf')),
    precisa_trocar_senha = TRUE  -- ⚠️ Força troca
WHERE funcionario_id = p_funcionario_id;
```

### 3. `trocar_senha_propria` (NOVA)
```sql
-- Funcionário troca sua própria senha
-- Valida senha antiga
-- Define nova senha
-- Marca precisa_trocar_senha = FALSE  -- ✅ Libera acesso
```

---

## 🧪 Como Testar Rapidamente

### Teste 1: Novo Funcionário
```bash
1. Admin → Ativar Usuários → Criar com senha "temp123"
2. Logout
3. Login como funcionário → Digite "temp123"
4. ✅ Redireciona para /trocar-senha
5. Definir nova senha → Ex: "minhaSenha789"
6. ✅ Vai para dashboard
7. Logout e login → Usar "minhaSenha789" ✅
```

### Teste 2: Reset de Senha
```bash
1. Admin → Usuários → Editar funcionário
2. Marcar "Alterar senha" → Digitar "reset456"
3. Salvar
4. Logout
5. Login como funcionário → Digite "reset456"
6. ✅ Redireciona para /trocar-senha
7. Definir nova senha → Ex: "novaSenha123"
8. ✅ Admin não sabe a nova senha!
```

---

## 🎯 Resultado Final

### Antes (Problema)
❌ Admin sabia senha de todos os funcionários  
❌ Senhas compartilhadas entre funcionários  
❌ Sem privacidade  

### Depois (Solução)
✅ Admin define apenas senha TEMPORÁRIA  
✅ Funcionário OBRIGADO a trocar no primeiro acesso  
✅ Senha final PRIVADA (só funcionário sabe)  
✅ Reset mantém privacidade (nova senha temporária → troca obrigatória)  
✅ Conformidade LGPD  

---

## 🔒 Fluxo de Segurança

```
┌──────────────────────────────────────┐
│ ADMIN                                 │
│ - Define: SenhaTemp123 (temporária)  │
│ - Comunica ao funcionário             │
│ - NÃO saberá senha final             │
└──────────────────────────────────────┘
                ↓
┌──────────────────────────────────────┐
│ SISTEMA                               │
│ - Marca: precisa_trocar_senha = TRUE │
│ - Detecta no login                    │
│ - Força redirecionamento              │
└──────────────────────────────────────┘
                ↓
┌──────────────────────────────────────┐
│ FUNCIONÁRIO                           │
│ - Login com SenhaTemp123              │
│ - Define: MinhaSenhaPrivada456        │
│ - Sistema: precisa_trocar_senha = FALSE│
│ - Próximo login direto ao dashboard   │
└──────────────────────────────────────┘
```

---

## 📊 Estrutura de Banco

```sql
-- Tabela: login_funcionarios
CREATE TABLE login_funcionarios (
    id UUID PRIMARY KEY,
    funcionario_id UUID,
    email TEXT,
    senha_hash TEXT,  -- Bcrypt
    precisa_trocar_senha BOOLEAN DEFAULT false,  -- ⭐ NOVA
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);
```

---

## 🚨 Troubleshooting Rápido

### Erro: "function trocar_senha_propria does not exist"
```sql
-- Executar: 2_ATUALIZAR_RPCS_TROCAR_SENHA.sql
```

### Erro: "column precisa_trocar_senha does not exist"
```sql
-- Executar: 1_ADICIONAR_COLUNA_PRECISA_TROCAR_SENHA.sql
```

### Loop infinito de troca
```sql
-- Verificar flag manualmente
SELECT precisa_trocar_senha FROM login_funcionarios
WHERE funcionario_id = 'SEU_ID';

-- Se necessário, resetar:
UPDATE login_funcionarios
SET precisa_trocar_senha = false
WHERE funcionario_id = 'SEU_ID';
```

---

## ✅ Checklist Rápido

- [ ] SQL 1 executado (coluna adicionada)
- [ ] SQL 2 executado (RPCs criadas/atualizadas)
- [ ] Frontend compila (`npm run dev`)
- [ ] Criar funcionário → Redireciona para trocar senha ✅
- [ ] Trocar senha → Salva com sucesso ✅
- [ ] Login com nova senha → Dashboard direto ✅
- [ ] Reset pelo admin → Funcionário troca novamente ✅

---

**Pronto! Sistema funcionando com privacidade garantida.** 🎉🔐

Para mais detalhes, consulte: `SISTEMA_SENHA_TEMPORARIA_COMPLETO.md`
