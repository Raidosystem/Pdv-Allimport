# 📋 GUIA DE BACKUP - SUPABASE

## 🗄️ Backups Automáticos do Supabase

### Planos e Retenção:

| Plano | Backup | Retenção | PITR |
|-------|--------|----------|------|
| Free | ❌ | - | ❌ |
| Pro ($25/mês) | ✅ | 7 dias | ✅ |
| Team ($599/mês) | ✅ | 30 dias | ✅ |

**PITR** = Point-in-Time Recovery (restaurar para qualquer momento específico)

---

## 📊 Verificar Seu Plano Atual

1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em **Settings** → **Billing**
4. Veja o plano atual

---

## 💾 Opções de Backup

### Opção 1: Upgrade para Plano Pro (Recomendado)

**Custo:** $25/mês  
**Benefícios:**
- ✅ Backups automáticos diários
- ✅ Restauração PITR (últimos 7 dias)
- ✅ Performance 2x melhor
- ✅ Suporte prioritário
- ✅ Zero trabalho manual

**Como fazer upgrade:**
1. Dashboard → Settings → Billing
2. Click em "Upgrade to Pro"
3. Preencher dados de pagamento

---

### Opção 2: Backups Manuais (Plano Free)

Use os scripts criados:

#### 1. Instalar Dependências
```bash
pip install supabase schedule
```

#### 2. Backup Manual Único
```bash
python scripts/backup-automatico.py
```

#### 3. Backup Automático Contínuo
```bash
# Inicia agendador (backup a cada 24h)
python scripts/agendador-backup.py
```

#### 4. Configurar para Rodar no Boot (Windows)

Criar arquivo `executar-backup.bat`:
```bat
@echo off
cd C:\Users\GrupoRaval\Desktop\Pdv-Allimport
python scripts\agendador-backup.py
```

Adicionar ao **Agendador de Tarefas do Windows**:
1. Win + R → `taskschd.msc`
2. Criar Tarefa Básica
3. Nome: "Backup Supabase PDV"
4. Gatilho: "Ao iniciar o computador"
5. Ação: Executar `executar-backup.bat`

---

## 📂 Estrutura dos Backups

```
backups/
├── user_approvals_20260116_103000.json
├── empresas_20260116_103001.json
├── funcionarios_20260116_103002.json
├── subscriptions_20260116_103003.json
├── produtos_20260116_103004.json
├── clientes_20260116_103005.json
├── vendas_20260116_103006.json
├── vendas_itens_20260116_103007.json
├── caixa_20260116_103008.json
├── ordens_servico_20260116_103009.json
└── backup_metadata_20260116_103010.json
```

---

## 🔄 Restaurar Backup Manual

### Via Python:
```python
import json
from supabase import create_client

# Configurar Supabase
supabase = create_client(SUPABASE_URL, SERVICE_ROLE_KEY)

# Ler arquivo de backup
with open('backups/user_approvals_20260116_103000.json', 'r') as f:
    data = json.load(f)

# Restaurar dados
for record in data:
    supabase.table('user_approvals').upsert(record).execute()

print(f"✅ {len(data)} registros restaurados!")
```

### Via SQL (Supabase Dashboard):
```sql
-- 1. Limpar tabela (cuidado!)
DELETE FROM user_approvals;

-- 2. Copiar conteúdo do JSON e inserir
INSERT INTO user_approvals (id, user_id, email, ...)
VALUES
  ('uuid1', 'uuid2', 'email@example.com', ...),
  ('uuid3', 'uuid4', 'email2@example.com', ...);
```

---

## ⚠️ Backups Críticos para Clientes Pagantes

**Tabelas essenciais:**
- ✅ `user_approvals` - Dados de login
- ✅ `empresas` - Dados da empresa
- ✅ `subscriptions` - Assinaturas ativas
- ✅ `funcionarios` - Usuários do sistema
- ✅ `produtos` - Catálogo de produtos
- ✅ `clientes` - Base de clientes
- ✅ `vendas` + `vendas_itens` - Histórico de vendas
- ✅ `caixa` - Movimentações financeiras

**Prioridade MÁXIMA:** Backups devem incluir estas tabelas!

---

## 🔐 Segurança dos Backups

### ✅ Boas Práticas:

1. **Armazenar em Local Seguro**
   - Cloud: Google Drive, Dropbox, OneDrive
   - Local: Disco externo ou NAS

2. **Criptografar Backups Sensíveis**
   ```bash
   # Windows: Usar BitLocker
   # Linux/Mac: Usar gpg
   gpg -c backup_user_approvals.json
   ```

3. **Múltiplas Cópias (Regra 3-2-1)**
   - 3 cópias dos dados
   - 2 tipos de mídia diferentes
   - 1 cópia offsite (nuvem)

4. **Testar Restauração Regularmente**
   - Mensal: Testar restaurar 1 tabela
   - Trimestral: Testar restaurar banco completo

---

## 📊 Comparação de Custos

| Método | Custo Mensal | Trabalho Manual | Confiabilidade |
|--------|--------------|-----------------|----------------|
| **Plano Pro** | $25 | Zero | ⭐⭐⭐⭐⭐ |
| **Scripts Manuais** | $0 | Alto | ⭐⭐⭐ |
| **Sem Backup** | $0 | - | ⚠️ PERIGOSO |

---

## 💡 Recomendação Final

### Para Produção com Clientes Pagantes:

**✅ UPGRADE PARA PLANO PRO**

**Motivos:**
1. ✅ Backups automáticos confiáveis
2. ✅ Restauração PITR (qualquer momento)
3. ✅ Zero risco de perda de dados
4. ✅ Performance melhor
5. ✅ Suporte prioritário
6. ✅ Custo baixo vs. valor protegido

**Custo x Benefício:**
- $25/mês = $0,83/dia
- Protege dados de TODOS os clientes
- Sem trabalho manual
- Peace of mind 😌

### Enquanto no Plano Free:

Use os scripts de backup manual como **proteção temporária**.

---

## 🆘 Em Caso de Perda de Dados

### Plano Pro:
1. Dashboard → Database → Backups
2. Selecionar data/hora desejada
3. Click em "Restore"

### Plano Free (com backups manuais):
1. Encontrar arquivo de backup mais recente
2. Executar script de restauração
3. Verificar integridade dos dados

### Sem Backup:
⚠️ **Dados irrecuperáveis** - Por isso backup é crítico!

---

## 📋 Checklist de Backup

- [ ] Verificar plano atual do Supabase
- [ ] Se Free: Instalar scripts de backup
- [ ] Se Free: Agendar backups automáticos
- [ ] Testar backup manual uma vez
- [ ] Testar restauração de 1 tabela
- [ ] Configurar armazenamento em nuvem
- [ ] Considerar upgrade para Pro se há clientes pagantes

---

## 🎯 Conclusão

**Sim, o Supabase faz backup de todos os clientes, MAS apenas no Plano Pro ou superior.**

Se você tem clientes pagantes usando o sistema, **investir $25/mês em backups automáticos é essencial** para proteção de dados e confiabilidade do sistema.
