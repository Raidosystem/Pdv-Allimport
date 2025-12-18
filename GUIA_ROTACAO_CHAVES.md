# 🔒 GUIA DE ROTAÇÃO DE CHAVES DO MERCADO PAGO E SUPABASE

## ⚠️ QUANDO EXECUTAR ESTE GUIA

Execute este guia SE (e SOMENTE SE) o comando abaixo retornar histórico de commits:

```powershell
git log --all --full-history -- ".env"
```

Se o comando retornar vazio (sem commits), as chaves estão SEGURAS e você NÃO precisa rotacioná-las.

---

## 🔑 PASSO 1: ROTACIONAR CHAVES DO MERCADO PAGO

### 1.1 Acessar Painel do Mercado Pago

1. Acesse: https://www.mercadopago.com.br/developers/panel
2. Login com credenciais da conta `APP_USR-3807636986700595`

### 1.2 Gerar Novas Credenciais

**Access Token**:
1. Vá em: **Suas integrações** → **Credenciais**
2. Ambiente: **Produção**
3. Clique em **Regenerar credenciais**
4. Copie o novo `Access Token` (começa com `APP_USR-`)
5. ⚠️ ATENÇÃO: Token antigo será REVOGADO imediatamente

**Public Key**:
1. Na mesma página, copie a nova `Public Key` (começa com `APP_USR-`)

**Client Secret**:
1. Vá em: **Suas integrações** → **OAuth**
2. Clique em **Regenerar Client Secret**
3. Copie o novo `Client Secret`

### 1.3 Atualizar .env Local

```env
# === MERCADO PAGO - NOVAS CREDENCIAIS ===
VITE_MP_ACCESS_TOKEN=<NOVO_ACCESS_TOKEN>
VITE_MP_PUBLIC_KEY=<NOVA_PUBLIC_KEY>
VITE_MP_CLIENT_ID=3807636986700595
VITE_MP_CLIENT_SECRET=<NOVO_CLIENT_SECRET>
```

### 1.4 Atualizar Variáveis no Vercel

```powershell
# Instalar Vercel CLI (se não tiver)
npm i -g vercel

# Login
vercel login

# Atualizar variáveis (substituir <valores> pelos novos)
vercel env add VITE_MP_ACCESS_TOKEN production
vercel env add VITE_MP_PUBLIC_KEY production
vercel env add VITE_MP_CLIENT_SECRET production

# Forçar redeploy
vercel --prod
```

---

## 🔑 PASSO 2: ROTACIONAR CHAVES DO SUPABASE

### 2.1 Acessar Painel do Supabase

1. Acesse: https://supabase.com/dashboard
2. Login com sua conta
3. Selecione o projeto: `kmcaaqetxtwkdcczdomw`

### 2.2 Regenerar ANON Key

1. Vá em: **Settings** → **API**
2. Na seção **Project API keys**:
   - Localize `anon` / `public`
   - Clique em **Regenerate token**
   - ⚠️ CONFIRME: Token antigo será revogado
   - Copie o novo JWT token

### 2.3 Atualizar .env Local

```env
# === SUPABASE - NOVA ANON KEY ===
VITE_SUPABASE_URL=https://kmcaaqetxtwkdcczdomw.supabase.co
VITE_SUPABASE_ANON_KEY=<NOVO_JWT_TOKEN>
```

### 2.4 Atualizar Variáveis no Vercel

```powershell
vercel env add VITE_SUPABASE_ANON_KEY production
vercel --prod
```

---

## 🔑 PASSO 3: VERIFICAR SERVICE_ROLE_KEY

### 3.1 Verificar se Está Exposto

```powershell
# Buscar no código frontend (NÃO deve retornar nada)
Select-String -Path "src/**/*.{ts,tsx,js,jsx}" -Pattern "SERVICE_ROLE" -Recurse
```

Se retornar resultados, **REMOVER IMEDIATAMENTE** do código frontend.

### 3.2 Se Necessário, Rotacionar

1. Supabase Dashboard → **Settings** → **API**
2. Localize `service_role` / `secret`
3. Clique em **Regenerate token**
4. Atualizar APENAS no Vercel (NUNCA no frontend):

```powershell
vercel env add SUPABASE_SERVICE_ROLE_KEY production
```

---

## 🧹 PASSO 4: REMOVER .ENV DO HISTÓRICO GIT

### 4.1 Instalar BFG Repo-Cleaner (Recomendado)

```powershell
# Windows com Chocolatey
choco install bfg

# OU baixar em: https://rtyley.github.io/bfg-repo-cleaner/
```

### 4.2 Fazer Backup do Repositório

```powershell
cd "C:\Users\GrupoRaval\Desktop"
git clone --mirror "C:\Users\GrupoRaval\Desktop\Pdv-Allimport\.git" pdv-backup.git
```

### 4.3 Remover .env do Histórico

**Método 1: BFG (Mais rápido)**
```powershell
bfg --delete-files .env "C:\Users\GrupoRaval\Desktop\Pdv-Allimport\.git"
cd "C:\Users\GrupoRaval\Desktop\Pdv-Allimport"
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

**Método 2: filter-branch (Nativo Git)**
```powershell
cd "C:\Users\GrupoRaval\Desktop\Pdv-Allimport"

git filter-branch --force --index-filter `
  "git rm --cached --ignore-unmatch .env" `
  --prune-empty --tag-name-filter cat -- --all

git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

### 4.4 Forçar Push (ATENÇÃO: Reescreve Histórico)

```powershell
# ⚠️ AVISO: Isso reescreve o histórico Git
# Se outras pessoas têm clones do repositório, elas precisarão re-clonar

git push origin --force --all
git push origin --force --tags
```

---

## ✅ PASSO 5: VERIFICAÇÃO FINAL

### 5.1 Confirmar Remoção do .env

```powershell
# Deve retornar vazio
git log --all --full-history -- ".env"
```

### 5.2 Testar Sistema em Produção

1. Acesse: https://pdv.crmvsystem.com
2. Teste login
3. Teste criação de produto
4. Teste venda com pagamento MercadoPago
5. Verifique se não há erros de autenticação

### 5.3 Verificar Logs do Vercel

```powershell
vercel logs --prod --follow
```

Procure por erros como:
- `401 Unauthorized`
- `Invalid credentials`
- `Token expired`

### 5.4 Registrar Rotação no Banco

Execute no Supabase SQL Editor:

```sql
INSERT INTO public.security_audit (check_type, status, details)
VALUES (
    'key_rotation',
    'completed',
    jsonb_build_object(
        'timestamp', NOW(),
        'keys_rotated', ARRAY[
            'VITE_MP_ACCESS_TOKEN',
            'VITE_MP_CLIENT_SECRET',
            'VITE_SUPABASE_ANON_KEY'
        ],
        'git_history_cleaned', true
    )
);
```

---

## 📞 SE ALGO DER ERRADO

### Restaurar Backup

```powershell
cd "C:\Users\GrupoRaval\Desktop\Pdv-Allimport"
git fetch "C:\Users\GrupoRaval\Desktop\pdv-backup.git" "*:*"
```

### Reverter Chaves Antigas (Emergência)

1. Supabase Dashboard → **Settings** → **API**
2. Clique em **View old tokens** (se disponível)
3. Reative temporariamente enquanto investiga

### Suporte

- Mercado Pago: https://www.mercadopago.com.br/developers/pt/support
- Supabase: https://supabase.com/dashboard/support

---

## 🎯 CHECKLIST FINAL

- [ ] Verificou se .env está no git history
- [ ] Regenerou Access Token do Mercado Pago
- [ ] Regenerou Public Key do Mercado Pago
- [ ] Regenerou Client Secret do Mercado Pago
- [ ] Regenerou Anon Key do Supabase
- [ ] Atualizou .env local com novas chaves
- [ ] Atualizou variáveis no Vercel
- [ ] Fez redeploy no Vercel
- [ ] Removeu .env do histórico Git (se necessário)
- [ ] Forçou push (se necessário)
- [ ] Testou sistema em produção
- [ ] Verificou logs do Vercel
- [ ] Registrou rotação no banco
- [ ] Deletou backup do repositório (pdv-backup.git)

---

**Criado em**: ${new Date().toLocaleString('pt-BR')}  
**Tempo estimado**: 30-45 minutos  
**Nível de risco**: Alto (envolve reescrita de histórico Git)
