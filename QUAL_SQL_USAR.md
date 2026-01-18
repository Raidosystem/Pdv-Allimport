# ⚠️ IMPORTANTE: Qual SQL Usar?

## ❌ NÃO EXECUTE: `PROTECAO_MAXIMA_USUARIOS.sql`

Este arquivo tem **PROBLEMAS CRÍTICOS**:
- ❌ Bloqueia **TODOS** os DELETEs (incluindo funcionários comuns)
- ❌ Quebra `AdminUsersPage.tsx` (linha 398)
- ❌ Impede `ON DELETE CASCADE` de funcionar
- ❌ Revoga permissões que podem ser necessárias
- ❌ Scripts de manutenção param de funcionar

---

## ✅ EXECUTE: `PROTECAO_USUARIOS_PAGANTES_SEGURA.sql`

Este arquivo é **100% SEGURO** e inteligente:

### ✅ O que protege:
- Usuários **pagantes** (owners) com assinatura ativa
- Empresas com assinatura ativa

### ✅ O que permite:
- DELETE de funcionários comuns
- DELETE de owners **sem** assinatura
- DELETE de produtos, vendas, clientes (dados secundários)
- `ON DELETE CASCADE` funciona normalmente
- AdminUsersPage continua funcionando
- **SUPER ADMIN** (`novaradiosystem@outlook.com`) pode deletar **QUALQUER** usuário

### ✅ Recursos adicionais:
- Log de auditoria de **TODAS** as tentativas de DELETE
- Soft delete opcional
- Views para consultas otimizadas
- View `owners_protegidos` mostra quem está protegido

---

## 📊 Comparação

| Recurso | PROTECAO_MAXIMA | PROTECAO_SEGURA |
|---------|-----------------|-----------------|
| Protege owners pagantes | ✅ | ✅ |
| Permite DELETE funcionários | ❌ | ✅ |
| Permite DELETE dados secundários | ❌ | ✅ |
| AdminUsersPage funciona | ❌ | ✅ |
| ON DELETE CASCADE funciona | ❌ | ✅ |
| Log de auditoria | ✅ | ✅ |
| Soft delete | ✅ | ✅ |
| Quebra o sistema | ⚠️ SIM | ✅ NÃO |

---

## 🚀 Como Executar

1. Abra **Supabase Dashboard** → **SQL Editor**
2. Cole o conteúdo de `PROTECAO_USUARIOS_PAGANTES_SEGURA.sql`
3. Execute (Run)
4. Pronto! ✅

---

## 🧪 Testar

```sql
-- Ver owners protegidos
SELECT * FROM owners_protegidos;

-- Ver log de tentativas de DELETE
SELECT * FROM delete_attempts_log ORDER BY attempted_at DESC;

-- Tentar deletar owner com assinatura (deve BLOQUEAR)
-- DELETE FROM user_approvals WHERE email = 'owner@com-assinatura.com';

-- Deletar funcionário comum (deve PERMITIR)
-- DELETE FROM funcionarios WHERE id = 'funcionario-comum-uuid';
```

---

## 💡 Lógica da Proteção

```
DELETE solicitado
    ↓
Quem está deletando?
    ↓              ↓
SUPER ADMIN      Outro usuário
    ↓              ↓
PERMITE        É user_approval/funcionario/empresa?
+ LOG              ↓
               É owner (dono da conta)?
                   ↓         ↓
                 NÃO       SIM
                   ↓         ↓
               PERMITE   Tem assinatura ativa?
               + LOG         ↓         ↓
                          NÃO       SIM
                           ↓         ↓
                       PERMITE   BLOQUEIA
                       + LOG     + LOG
```

---

## ⚠️ Ações Recomendadas

1. ✅ **Execute** `PROTECAO_USUARIOS_PAGANTES_SEGURA.sql`
2. ❌ **DELETE** `PROTECAO_MAXIMA_USUARIOS.sql` (arquivo perigoso)
3. ✅ **Teste** com `SELECT * FROM owners_protegidos`
4. ✅ **Monitore** com `SELECT * FROM delete_attempts_log`

---

## 🆘 Em Caso de Dúvida

Sempre teste primeiro em um usuário de teste antes de aplicar em produção!
