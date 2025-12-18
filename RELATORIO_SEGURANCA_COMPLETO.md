# 🔒 RELATÓRIO COMPLETO DE SEGURANÇA DO SISTEMA PDV ALLIMPORT

**Data**: ${new Date().toLocaleString('pt-BR')}  
**Versão do Sistema**: 2.2.5  
**Ambiente**: Multi-tenant com Supabase + React + Vercel

---

## 🚨 RESUMO EXECUTIVO

### ⚠️ VULNERABILIDADES CRÍTICAS ENCONTRADAS: 5

| Severidade | Quantidade | Status |
|------------|-----------|---------|
| 🔴 **CRÍTICA** | 3 | ⚠️ Requer ação imediata |
| 🟠 **ALTA** | 2 | ⚠️ Requer correção urgente |
| 🟡 **MÉDIA** | 4 | ⚠️ Requer correção |
| 🟢 **BAIXA** | 6 | ℹ️ Melhorias recomendadas |

---

## 🔴 VULNERABILIDADES CRÍTICAS

### 1. 🚨 RLS (ROW LEVEL SECURITY) DESABILITADO EM TABELAS CORE

**Severidade**: 🔴 CRÍTICA  
**Risco**: Qualquer usuário pode acessar dados de outros usuários/empresas  
**Impacto**: Quebra completa do isolamento multi-tenant

**Arquivos Afetados**:
- `CORRECAO_URGENTE_DADOS_SUMIRAM.sql` - Desabilita RLS em:
  - `clientes`
  - `produtos`
  - `vendas`
  - `caixa`
  - `ordens_servico`

- `CORRECAO_SIMPLIFICADA_RLS.sql` - Desabilita RLS em:
  - `fornecedores`

- `migrations/CORRIGIR_RLS_BUCKET_LOGO.sql` - Desabilita RLS em:
  - `storage.objects` (bucket de logos)

**Status Atual**: ⚠️ **DESCONHECIDO** - Necessário executar `VERIFICAR_RLS_ATUAL.sql` no Supabase

**Correção Urgente**:
```sql
-- EXECUTAR NO SUPABASE SQL EDITOR AGORA:

-- 1. Reativar RLS em TODAS as tabelas críticas
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas_itens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ordens_servico ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fornecedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_pagar ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contas_receber ENABLE ROW LEVEL SECURITY;

-- 2. Verificar se as políticas existem
SELECT tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('clientes', 'produtos', 'vendas', 'caixa');

-- 3. Se NÃO existirem políticas, criar:
-- (Use o arquivo CORRIGIR_RLS_CONTAS_PAGAR.sql como modelo)
```

**Teste de Verificação**:
1. Execute `VERIFICAR_RLS_ATUAL.sql` no Supabase
2. Confirme que TODAS as tabelas mostram `rls_habilitado = true`
3. Teste com usuário não-admin para garantir isolamento

---

### 2. 🚨 ARQUIVO .env COM CREDENCIAIS REAIS

**Severidade**: 🔴 CRÍTICA  
**Risco**: Exposição de chaves API do MercadoPago e Supabase  
**Impacto**: Acesso total ao banco de dados e pagamentos

**Credenciais Expostas**:
```env
VITE_SUPABASE_URL=https://kmcaaqetxtwkdcczdomw.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGc... (JWT token)
VITE_MP_ACCESS_TOKEN=APP_USR-3807636986700595-...
VITE_MP_CLIENT_SECRET=nFckffUiLyT3adZPgagmj8kTEH7Z3po5
```

**Status do .gitignore**: ✅ `.env` está no .gitignore (linha 16)  
**Status do Git**: ⚠️ **VERIFICAR HISTÓRICO** - Executar comando para confirmar se já foi commitado antes

**Ação Imediata**:
```powershell
# 1. Verificar se .env está no histórico do Git
git log --all --full-history -- ".env"

# 2. Se retornar algo, ROTACIONAR TODAS AS CHAVES IMEDIATAMENTE:
# - Regenerar SUPABASE_ANON_KEY no dashboard Supabase
# - Regenerar ACCESS_TOKEN no Mercado Pago
# - Atualizar CLIENT_SECRET no Mercado Pago
# - Atualizar .env local e variáveis Vercel

# 3. Se necessário, remover do histórico Git:
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all

# 4. Forçar push (ATENÇÃO: reescreve histórico)
git push origin --force --all
```

**Prevenção**:
- ✅ .gitignore já configurado corretamente
- ⚠️ Adicionar verificação no CI/CD para detectar commits com .env
- ✅ Usar variáveis de ambiente no Vercel (já configurado)

---

### 3. 🚨 CORS CONFIGURADO COM `Access-Control-Allow-Origin: *`

**Severidade**: 🔴 CRÍTICA  
**Risco**: Qualquer site pode fazer requisições às suas APIs  
**Impacto**: Ataques CSRF, roubo de dados, execução não autorizada

**Arquivos Afetados**:
- `api/backup_funcionando/api/test-mp.js` (linha 4)
- `api/backup_funcionando/api/test.js` (linha 3)
- `api/backup_funcionando/api/test-backurls.js` (linha 3)

**Exemplo de Código Vulnerável**:
```javascript
// ❌ VULNERÁVEL - QUALQUER SITE PODE ACESSAR
res.setHeader('Access-Control-Allow-Origin', '*');
```

**Correção**:
```javascript
// ✅ SEGURO - APENAS DOMÍNIOS AUTORIZADOS
const allowedOrigins = [
  'https://pdv.crmvsystem.com',
  'https://pdv.gruporaval.com.br',
  'http://localhost:5174' // Apenas dev local
];

const origin = req.headers.origin;
if (allowedOrigins.includes(origin)) {
  res.setHeader('Access-Control-Allow-Origin', origin);
}

// OU usar a configuração já existente em process-payment.js:
res.setHeader('Access-Control-Allow-Origin', 'https://pdv.crmvsystem.com');
```

**Ação Imediata**:
1. Substituir todos os `'*'` por domínio específico
2. Revisar todos os arquivos em `api/backup_funcionando/` (são backups ou ativos?)
3. Se forem backups antigos, deletar a pasta inteira

---

## 🟠 VULNERABILIDADES DE ALTA SEVERIDADE

### 4. 🟠 SENHAS HARDCODED EM ARQUIVOS DE TESTE

**Severidade**: 🟠 ALTA  
**Risco**: Credenciais conhecidas podem ser usadas em ataques  
**Impacto**: Acesso não autorizado se scripts forem executados em produção

**Arquivos Afetados**:
```javascript
// ativar-usuario-admin.js (linha ~30)
password: 'admin123' // ❌ SENHA HARDCODED

// scripts de teste:
'test123', 'test-password', 'password123'
```

**Correção**:
```javascript
// ✅ USAR VARIÁVEL DE AMBIENTE
const password = process.env.ADMIN_PASSWORD || generateSecurePassword();

function generateSecurePassword() {
  return crypto.randomBytes(16).toString('hex');
}
```

**Ação**:
1. Substituir senhas hardcoded por variáveis de ambiente
2. Adicionar comentário: `// ⚠️ NUNCA USAR EM PRODUÇÃO`
3. Garantir que scripts de teste não rodam em prod

---

### 5. 🟠 SERVICE_ROLE_KEY EXPOSTO EM VARIÁVEIS DE AMBIENTE FRONTEND

**Severidade**: 🟠 ALTA  
**Risco**: Chave de admin exposta no código cliente  
**Impacto**: Bypass completo de RLS e segurança

**Status Atual**: ⚠️ Verificar se `SUPABASE_SERVICE_ROLE_KEY` está em `VITE_*`

**Verificação**:
```powershell
# Buscar uso de SERVICE_ROLE_KEY no frontend
Select-String -Path "src/**/*.{ts,tsx}" -Pattern "SERVICE_ROLE" -Recurse
```

**Regra de Ouro**:
```javascript
// ❌ NUNCA NO FRONTEND
const client = createClient(url, process.env.VITE_SERVICE_ROLE_KEY)

// ✅ APENAS NO BACKEND (api/)
const client = createClient(url, process.env.SUPABASE_SERVICE_ROLE_KEY)
```

**Status de Uso**:
- ✅ `api/process-payment.js` - Uso correto (backend)
- ✅ Arquivos em `api/` - Uso correto (serverless)
- ⚠️ Verificar se não há uso em `src/` (frontend)

---

## 🟡 VULNERABILIDADES MÉDIAS

### 6. 🟡 innerHTML SEM SANITIZAÇÃO

**Severidade**: 🟡 MÉDIA  
**Risco**: Possível XSS se dados forem de usuário  
**Impacto**: Roubo de sessão, injeção de scripts maliciosos

**Arquivos Afetados**:
- `src/utils/version-check.ts` (linha 139)
- `src/main.tsx` (linhas 75, 237, 278, 291, 297, 323)
- `src/pages/admin/LaudoTecnicoPage.tsx` (linha 302)
- `src/pages/admin/OrcamentoPage.tsx` (linha 350)

**Análise**:
```typescript
// src/main.tsx linha 75
body.innerHTML = ` // ⚠️ Se 'body' vier de API não confiável = XSS
  <div>Conteúdo dinâmico</div>
`
```

**Correção**:
```typescript
// ✅ USAR textContent para texto puro
element.textContent = userInput;

// ✅ USAR DOMPurify para HTML rico
import DOMPurify from 'dompurify';
element.innerHTML = DOMPurify.sanitize(htmlContent);

// ✅ OU React (já sanitiza automaticamente)
<div>{userInput}</div>
```

**Prioridade**: Verificar se algum `innerHTML` recebe dados de usuário. Se não, risco é BAIXO.

---

### 7. 🟡 FALTA DE RATE LIMITING NAS APIs

**Severidade**: 🟡 MÉDIA  
**Risco**: Ataques de força bruta e DDoS  
**Impacto**: Sobrecarga do servidor, custos elevados

**Status Atual**: ⚠️ Sem rate limiting explícito em `api/`

**Implementação Recomendada**:
```javascript
// Usar Vercel Edge Config ou Upstash Redis
import rateLimit from '@/utils/rate-limit';

export default async function handler(req, res) {
  // Rate limit: 10 requisições por minuto por IP
  const limiter = await rateLimit(req, { max: 10, window: 60000 });
  
  if (!limiter.success) {
    return res.status(429).json({ 
      error: 'Too many requests',
      retryAfter: limiter.retryAfter 
    });
  }
  
  // ... resto do código
}
```

**Alternativas**:
- Vercel Edge Middleware com rate limit
- Cloudflare na frente (proteção DDoS automática)
- Supabase Auth rate limiting (já existe parcialmente)

---

### 8. 🟡 FALTA DE VALIDAÇÃO DE INPUT EM ALGUMAS APIs

**Severidade**: 🟡 MÉDIA  
**Risco**: SQL Injection (mitigado por Supabase), dados inválidos  
**Impacto**: Erros, crash de servidor

**Exemplo em `api/process-payment.js`**:
```javascript
const { payment_id, user_email } = req.body;

// ✅ Tem validação básica
if (!payment_id || !user_email) {
  return res.status(400).json({ error: '...' });
}

// ⚠️ MAS falta validação de formato
// Adicionar:
if (!/^[0-9]+$/.test(payment_id)) {
  return res.status(400).json({ error: 'Invalid payment_id format' });
}

if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(user_email)) {
  return res.status(400).json({ error: 'Invalid email format' });
}
```

**Implementar**:
```javascript
import { z } from 'zod';

const paymentSchema = z.object({
  payment_id: z.string().regex(/^[0-9]+$/),
  user_email: z.string().email(),
  amount: z.number().positive()
});

// Validar antes de processar
const result = paymentSchema.safeParse(req.body);
if (!result.success) {
  return res.status(400).json({ errors: result.error.errors });
}
```

---

### 9. 🟡 LOGS PODEM EXPOR DADOS SENSÍVEIS

**Severidade**: 🟡 MÉDIA  
**Risco**: Senhas/tokens em logs de erro  
**Impacto**: Vazamento de credenciais

**Verificar**:
```javascript
// ❌ NÃO fazer:
console.log('User data:', req.body); // Pode conter senhas

// ✅ Fazer:
console.log('User data:', { email: req.body.email }); // Sem senha
```

**Ação**: Auditar todos os `console.log` em `api/` e garantir que não logam:
- Senhas
- Tokens de autenticação
- Dados de cartão
- PII (CPF, endereço completo)

---

## 🟢 MELHORIAS RECOMENDADAS (BAIXA PRIORIDADE)

### 10. 🟢 HEADERS DE SEGURANÇA HTTP

**Implementar em `vercel.json`**:
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        },
        {
          "key": "Referrer-Policy",
          "value": "strict-origin-when-cross-origin"
        },
        {
          "key": "Permissions-Policy",
          "value": "camera=(), microphone=(), geolocation=()"
        },
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';"
        }
      ]
    }
  ]
}
```

### 11. 🟢 IMPLEMENTAR AUDIT LOG

**Rastrear ações críticas**:
```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  action TEXT NOT NULL,
  table_name TEXT,
  record_id UUID,
  old_data JSONB,
  new_data JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own audit logs"
  ON audit_logs FOR SELECT
  USING (user_id = auth.uid());
```

### 12. 🟢 ADICIONAR TESTES DE SEGURANÇA

**Criar suite de testes**:
```typescript
// security.test.ts
describe('Security Tests', () => {
  it('should prevent SQL injection', async () => {
    const maliciousInput = "'; DROP TABLE clientes; --";
    const response = await createCliente({ nome: maliciousInput });
    expect(response.error).toBeDefined();
  });

  it('should enforce RLS policies', async () => {
    // Login como user1
    const user1Client = await loginAs('user1@test.com');
    await user1Client.from('produtos').insert({ nome: 'Produto User1' });

    // Login como user2 e tentar acessar dados de user1
    const user2Client = await loginAs('user2@test.com');
    const { data } = await user2Client.from('produtos').select('*');
    
    expect(data).not.toContainEqual(
      expect.objectContaining({ nome: 'Produto User1' })
    );
  });
});
```

### 13. 🟢 MONITORAMENTO E ALERTAS

**Implementar**:
- Sentry para tracking de erros
- Supabase Realtime para atividade suspeita
- Alertas de login de IPs novos
- Notificações de mudanças em tabelas críticas

---

## ✅ PONTOS FORTES DE SEGURANÇA EXISTENTES

### 1. ✅ Row Level Security (RLS) Implementado

**Status**: ✅ Policies criadas para principais tabelas  
**Qualidade**: Excelente - Usa `get_current_user_id()` para funcionários

**Exemplo (contas_pagar)**:
```sql
CREATE POLICY "users_own_contas_pagar" ON contas_pagar
  FOR ALL USING (user_id = get_current_user_id());
```

**Benefício**: Isolamento automático multi-tenant mesmo se houver bugs no frontend

---

### 2. ✅ Autenticação Supabase Auth

**Status**: ✅ PKCE flow configurado  
**Benefícios**:
- Proteção contra ataques de interceptação
- Refresh tokens automático
- MFA disponível (se habilitado)

---

### 3. ✅ Variáveis de Ambiente Separadas

**Status**: ✅ `.env` no .gitignore  
**Status**: ✅ Variáveis Vercel configuradas separadamente

---

### 4. ✅ Sistema de Permissões Robusto

**Status**: ✅ Tabelas `funcoes`, `permissoes`, `funcao_permissoes`  
**Hook**: `usePermissions()` valida antes de ações

---

### 5. ✅ HTTPS Forçado em Produção

**Status**: ✅ Vercel fornece SSL automático  
**Domínios**:
- https://pdv.crmvsystem.com
- https://pdv.gruporaval.com.br

---

### 6. ✅ Validação com Zod nos Forms

**Status**: ✅ React Hook Form + Zod em vários componentes  
**Benefício**: Previne dados inválidos chegarem ao backend

---

## 📋 CHECKLIST DE AÇÕES URGENTES

### 🔴 HOJE (CRÍTICO):

- [ ] **1. Verificar RLS no banco de produção**
  ```sql
  -- Executar VERIFICAR_RLS_ATUAL.sql no Supabase SQL Editor
  ```

- [ ] **2. Reativar RLS em todas as tabelas core**
  ```sql
  ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
  ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
  -- (ver seção de correção acima)
  ```

- [ ] **3. Verificar se .env está no histórico Git**
  ```powershell
  git log --all --full-history -- ".env"
  ```
  - Se SIM: Rotacionar TODAS as chaves imediatamente
  - Se NÃO: Prosseguir com próximos passos

- [ ] **4. Corrigir CORS em APIs de teste**
  - Substituir `'*'` por domínio específico
  - OU deletar pasta `api/backup_funcionando/` se forem backups antigos

### 🟠 ESTA SEMANA (ALTA):

- [ ] **5. Remover senhas hardcoded**
  - Substituir por variáveis de ambiente
  - Adicionar comentários de aviso

- [ ] **6. Auditar uso de SERVICE_ROLE_KEY**
  - Garantir que NUNCA está em `src/` (frontend)
  - Confirmar uso apenas em `api/` (backend)

- [ ] **7. Implementar rate limiting básico**
  - Adicionar em `api/process-payment.js` (prioritário)
  - Considerar Vercel Edge Middleware

### 🟡 PRÓXIMAS 2 SEMANAS (MÉDIA):

- [ ] **8. Sanitizar todos os innerHTML**
  - Instalar DOMPurify: `npm install dompurify`
  - Substituir innerHTML por DOMPurify.sanitize()

- [ ] **9. Adicionar validação de input em APIs**
  - Usar Zod em todos os endpoints `api/`
  - Validar formato de email, CPF, payment_id

- [ ] **10. Auditar logs**
  - Remover console.log com dados sensíveis
  - Implementar logger estruturado (Winston/Pino)

### 🟢 PRÓXIMO MÊS (BAIXA):

- [ ] **11. Adicionar headers de segurança HTTP**
  - Atualizar `vercel.json` com CSP, X-Frame-Options, etc.

- [ ] **12. Implementar audit log**
  - Criar tabela `audit_logs`
  - Trigger para ações críticas

- [ ] **13. Criar testes de segurança**
  - Testes de RLS
  - Testes de SQL injection
  - Testes de XSS

- [ ] **14. Monitoramento**
  - Integrar Sentry
  - Configurar alertas Supabase

---

## 📊 COMPARAÇÃO DE SEGURANÇA

| Aspecto | Antes | Depois (Meta) |
|---------|-------|---------------|
| RLS Ativo | ⚠️ Desconhecido | ✅ 100% das tabelas |
| CORS Config | ❌ Wildcard (*) | ✅ Domínios específicos |
| Senhas no código | ❌ Hardcoded | ✅ Variáveis de ambiente |
| Rate Limiting | ❌ Nenhum | ✅ 10 req/min por IP |
| Input Validation | 🟡 Parcial | ✅ Zod em todos endpoints |
| Headers HTTP | 🟡 Básicos | ✅ CSP + Security Headers |
| Audit Log | ❌ Nenhum | ✅ Todas ações críticas |
| Testes Segurança | ❌ Nenhum | ✅ Suite completa |

---

## 🛡️ NÍVEL DE SEGURANÇA ATUAL

### Pontuação: 6.5/10

**Breakdown**:
- 🔴 Autenticação: 8/10 (Supabase Auth excelente, mas sem MFA obrigatório)
- 🔴 Autorização: 5/10 (RLS implementado mas possivelmente desabilitado)
- 🟠 Isolamento de Dados: 6/10 (Multi-tenant robusto quando RLS está ativo)
- 🟠 Proteção de APIs: 5/10 (CORS muito permissivo, sem rate limit)
- 🟡 Validação de Entrada: 7/10 (Zod no frontend, falta no backend)
- 🟢 Criptografia: 9/10 (HTTPS + Supabase encryption at rest)
- 🟢 Gestão de Chaves: 6/10 (.env no .gitignore mas pode ter sido commitado)
- 🟡 Logging e Auditoria: 4/10 (Console.log sem estrutura)

---

## 💡 RECOMENDAÇÕES GERAIS

### Segurança em Camadas (Defense in Depth):

1. **Camada 1 - Rede**: ✅ HTTPS, 🟡 CORS (corrigir)
2. **Camada 2 - Aplicação**: ✅ Validação Zod, ⚠️ Adicionar rate limit
3. **Camada 3 - Dados**: ⚠️ RLS (verificar status), ✅ Encryption at rest
4. **Camada 4 - Monitoramento**: ❌ Implementar logs estruturados

### Princípio do Menor Privilégio:

✅ **Já implementado**:
- Sistema de permissões por função
- RLS policies específicas por usuário

⚠️ **Melhorar**:
- Funcionários não devem ter acesso a rotas admin
- SERVICE_ROLE_KEY apenas em serverless (nunca frontend)

### Auditoria Contínua:

📅 **Estabelecer rotina**:
- Semanal: Revisar logs de erro
- Mensal: Auditar políticas RLS
- Trimestral: Penetration testing básico
- Anual: Revisão completa de segurança

---

## 📞 PRÓXIMOS PASSOS

1. **Execute `VERIFICAR_RLS_ATUAL.sql` no Supabase AGORA**
2. **Me envie o resultado** para eu validar o status real
3. **Siga o checklist de ações urgentes** (itens 1-4)
4. **Me informe quando concluir** para eu ajudar com próxima etapa

---

**Criado por**: GitHub Copilot (Claude Sonnet 4.5)  
**Ferramentas usadas**: grep_search, read_file, análise estática  
**Próxima revisão**: Após aplicar correções críticas
