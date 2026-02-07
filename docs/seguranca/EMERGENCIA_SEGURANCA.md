# 🚨 ALERTA DE SEGURANÇA - ROTAÇÃO DE CHAVES OBRIGATÓRIA

## ⚠️ SITUAÇÃO CRÍTICA
Os seguintes tokens/chaves foram **EXPOSTOS PUBLICAMENTE** no GitHub e devem ser **ROTACIONADOS IMEDIATAMENTE**:

### 🔑 MercadoPago - ROTACIONAR AGORA
- **ACCESS_TOKEN**: `APP_USR-3807636986700595-080418-898de2d3ad6f6c10d2c5da46e68007d2-167089193`
- **CLIENT_SECRET**: `nFckffUiLyT3adZPgagmj8kTEH7Z3po5`
- **WEBHOOK_SECRET**: `a7ca1966224cf9b475087c98142fec03c57b211778d31a7ef888d6736ff162b7`

### 🛡️ Supabase - VERIFICAR E ROTACIONAR
- Verificar se SERVICE_ROLE_KEY foi exposto
- Rotacionar anon key por precaução

### 🚀 Vercel - TOKEN EXPOSTO
- **OIDC_TOKEN**: Foi exposto - regenerar se necessário

---

## 📋 CHECKLIST DE EMERGÊNCIA

### ✅ CONCLUÍDO
- [x] Arquivos sensíveis removidos do repositório
- [x] .gitignore atualizado para prevenir vazamentos futuros
- [x] Histórico Git limpo com git-filter-repo
- [x] Force push para remover histórico comprometido

### 🔄 EM ANDAMENTO
- [ ] **Rotacionar credenciais MercadoPago**
- [ ] **Verificar/Rotacionar credenciais Supabase**
- [ ] **Configurar Environment Variables no Vercel**

### ⏳ PRÓXIMOS PASSOS
- [ ] Ativar GitHub Secret Scanning
- [ ] Configurar Push Protection
- [ ] Instalar git-secrets localmente
- [ ] Revisar todo o código para outros segredos

---

## 🔧 PASSOS PARA ROTAÇÃO

### 1. MercadoPago
1. Acessar: https://www.mercadopago.com.br/developers/panel
2. Ir em **Credenciais** > **Tokens de acesso**
3. **REVOGAR** o token atual: `APP_USR-3807636986700595-080418-...`
4. Gerar novos tokens
5. Atualizar no Vercel Environment Variables

### 2. Supabase
1. Acessar: https://supabase.com/dashboard
2. Ir em **Settings** > **API**
3. **Reset** anon key e service_role key
4. Atualizar no Vercel Environment Variables

### 3. Webhook Secrets
1. Gerar novo webhook secret: `openssl rand -hex 32`
2. Atualizar no MercadoPago e Vercel

### 4. Vercel Environment Variables
1. Acessar: https://vercel.com/raidosystem/pdv-allimport/settings/environment-variables
2. **DELETAR** todas as variáveis antigas
3. Adicionar novas variáveis com valores rotacionados

---

## 🚨 URGÊNCIA MÁXIMA
**ESTAS CHAVES ESTÃO PÚBLICAS NO GITHUB E DEVEM SER ROTACIONADAS IMEDIATAMENTE**

Qualquer pessoa pode:
- Acessar seu MercadoPago
- Fazer operações no Supabase
- Interceptar webhooks
- Comprometer o sistema inteiro

**AÇÃO NECESSÁRIA: AGORA!**