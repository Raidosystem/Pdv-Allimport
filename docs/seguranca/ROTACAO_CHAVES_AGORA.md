# 🚨 CHECKLIST DE ROTAÇÃO DE CHAVES - EXECUÇÃO IMEDIATA

## 🎯 STATUS ATUAL
- ✅ Arquivos .env removidos do repositório
- ✅ Histórico Git limpo com git-filter-repo
- ✅ .gitignore configurado
- ✅ Scanners de segurança executados

---

## 🔑 ROTAÇÃO SUPABASE (FAZER AGORA!)

### Passo 1: Acessar Dashboard
👉 **IR PARA**: https://supabase.com/dashboard
1. Fazer login na sua conta
2. Selecionar projeto: **PDV AllImport**

### Passo 2: Rotacionar API Keys
👉 **CAMINHO**: Settings → API
1. ✅ **Regenerar anon key** (usado no frontend)
2. ✅ **Regenerar service_role key** (usado apenas no backend)
3. ✅ **Copiar as novas chaves**

### Passo 3: Rotacionar JWT Secret (OPCIONAL mas recomendado)
👉 **CAMINHO**: Authentication → URL Configuration
1. ✅ **JWT secret → Rotate**
2. ⚠️ **ATENÇÃO**: Isso invalida todos os tokens - usuários precisarão logar novamente

---

## 💳 ROTAÇÃO MERCADO PAGO (FAZER AGORA!)

### Passo 1: Acessar Credenciais
👉 **IR PARA**: https://www.mercadopago.com.br/developers/panel
1. Ir em **Credenciais**
2. Selecionar sua aplicação

### Passo 2: Rotacionar Tokens
1. ✅ **REVOGAR** Access Token atual: `APP_USR-3807636986700595-080418-...`
2. ✅ **GERAR** novo Access Token (PRODUÇÃO)
3. ✅ **GERAR** novo Public Key (se necessário)
4. ✅ **COPIAR** novas credenciais

### Passo 3: Webhook Secret
1. ✅ **GERAR** novo webhook secret: `openssl rand -hex 32`
2. ✅ **ANOTAR** o novo secret

---

## 🚀 CONFIGURAÇÃO VERCEL (FAZER AGORA!)

### Passo 1: Acessar Environment Variables
👉 **IR PARA**: https://vercel.com/raidosystem/pdv-allimport/settings/environment-variables

### Passo 2: Deletar Variáveis Antigas
1. ✅ **DELETAR TODAS** as variáveis antigas comprometidas

### Passo 3: Adicionar Novas Variáveis (nas 3 abas: Production, Preview, Development)

#### Supabase:
```
VITE_SUPABASE_URL=https://SEU-PROJECT-REF.supabase.co
VITE_SUPABASE_ANON_KEY=nova_anon_key_aqui
VITE_SUPABASE_SERVICE_ROLE_KEY=nova_service_role_key_aqui
```

#### MercadoPago:
```
MP_ACCESS_TOKEN=novo_access_token_aqui
VITE_MP_PUBLIC_KEY=nova_public_key_aqui
MP_WEBHOOK_SECRET=novo_webhook_secret_aqui
```

#### Aplicação:
```
VITE_APP_URL=https://pdv.crmvsystem.com
```

### Passo 4: Redeploy
1. ✅ **REDEPLOY** do projeto no Vercel

---

## 🔍 VERIFICAÇÃO FINAL

### Teste 1: API Funcionando
```bash
curl https://pdv.crmvsystem.com/api/health
```

### Teste 2: Frontend Conectando
```bash
# Abrir https://pdv.crmvsystem.com e verificar se carrega
```

### Teste 3: Webhook Seguro
```bash
# Testar endpoint webhook com novas credenciais
```

---

## 📋 CHECKLIST FINAL

### Supabase:
- [ ] anon key rotacionada
- [ ] service_role key rotacionada  
- [ ] JWT secret rotacionado (opcional)
- [ ] Variáveis atualizadas no Vercel

### MercadoPago:
- [ ] Access Token rotacionado
- [ ] Public Key atualizada
- [ ] Webhook Secret rotacionado
- [ ] Variáveis atualizadas no Vercel

### Vercel:
- [ ] Todas as variáveis antigas deletadas
- [ ] Novas variáveis configuradas em Prod/Preview/Dev
- [ ] Redeploy realizado

### Verificação:
- [ ] Sistema funcionando com novas credenciais
- [ ] API respondendo corretamente
- [ ] Frontend carregando sem erros
- [ ] Webhook processando pagamentos

---

## ⚠️ IMPORTANTE
**APÓS COMPLETAR ESTA ROTAÇÃO, TODAS AS CHAVES EXPOSTAS ESTARÃO INVALIDADAS!**

**Tempo estimado**: 15-20 minutos
**Prioridade**: CRÍTICA - FAZER AGORA!