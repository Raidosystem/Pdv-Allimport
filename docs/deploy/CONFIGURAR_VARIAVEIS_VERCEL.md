# 🚨 AÇÃO URGENTE NECESSÁRIA

## Problema Identificado
As variáveis de ambiente do Supabase **NÃO** estão configuradas no Vercel, por isso o site está lento e não funciona em produção.

## Como Configurar no Vercel

1. **Acesse o Dashboard da Vercel:**
   - https://vercel.com/
   - Login com sua conta
   - Selecione o projeto "Pdv-Allimport"

2. **Configure as Variáveis:**
   - Clique em "Settings" (Configurações)
   - Vá em "Environment Variables"
   - Adicione estas variáveis (copie do arquivo `.env` ou `.env.production`):

### Variáveis Obrigatórias:

```
VITE_SUPABASE_URL
Valor: https://kmcaaqetxtwkdcczdomw.supabase.co
Environments: Production, Preview, Development
```

```
VITE_SUPABASE_ANON_KEY
Valor: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MjY1MTMsImV4cCI6MjA3MjAwMjUxM30.sBOHwFeZ2e558puxCN7-h2nkRvuz2srxdb2LNGS9Ny4
Environments: Production, Preview, Development
```

```
VITE_ADMIN_EMAILS
Valor: novaradiosystem@outlook.com
Environments: Production, Preview, Development
```

```
VITE_APP_URL
Valor: https://pdv.gruporaval.com.br
Environments: Production
```

```
VITE_APP_NAME
Valor: RaVal PDV
Environments: Production, Preview, Development
```

3. **Após adicionar, faça Redeploy:**
   - Vá em "Deployments"
   - Clique nos 3 pontinhos do último deploy
   - Clique em "Redeploy"
   - Aguarde o build terminar

## Alternativa via CLI (se tiver Vercel CLI instalado)

```bash
cd /Users/gruporaval/Documents/Pdv-Allimport

# Adicionar cada variável
vercel env add VITE_SUPABASE_URL production
# Cole o valor quando solicitado

vercel env add VITE_SUPABASE_ANON_KEY production
# Cole o valor quando solicitado

vercel env add VITE_ADMIN_EMAILS production
# Cole o valor quando solicitado

# Fazer redeploy
vercel --prod
```

## Verificação

Após o redeploy, acesse `https://pdv.gruporaval.com.br` e abra o Console (F12).
Você NÃO deve mais ver o erro: `⚠️ Supabase environment variables are not set.`

## Importante

⚠️ O arquivo `.env` é local e **não vai para o GitHub** (está no .gitignore)
⚠️ Por isso é necessário configurar manualmente no Vercel
⚠️ Sem essas variáveis, o site não consegue conectar ao banco de dados
