# 🚀 GUIA DE DEPLOY - PDV ALLIMPORT

## ✅ Build Concluído com Sucesso!

A pasta `dist/` está pronta para deploy com todos os arquivos otimizados.

---

## 📦 OPÇÕES DE DEPLOY

### 1️⃣ VERCEL (RECOMENDADO - GRÁTIS) ⚡

**Mais rápido e fácil!**

#### Opção A: Via CLI (Terminal)
```bash
# Instalar Vercel CLI
npm install -g vercel

# Fazer deploy
vercel

# Deploy para produção
vercel --prod
```

#### Opção B: Via GitHub
1. Acesse: https://vercel.com
2. Conecte seu repositório GitHub
3. Selecione o projeto `Pdv-Allimport`
4. Configure as variáveis de ambiente (copie do `.env.local`)
5. Deploy automático! ✨

**Variáveis de Ambiente para Configurar:**
```env
VITE_SUPABASE_URL=https://kmcaaqetxtwkdcczdomw.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
VITE_RESEND_API_KEY=re_HVHmZts1_JdnYg9mqspzRPCcahN5gA8oz
VITE_FROM_EMAIL=noreply@allimport.com.br
VITE_APP_URL=https://seu-dominio.vercel.app
VITE_APP_NAME=PDV Allimport
VITE_APP_VERSION=2.2.5
```

---

### 2️⃣ NETLIFY (GRÁTIS)

#### Via Netlify CLI:
```bash
# Instalar Netlify CLI
npm install -g netlify-cli

# Fazer deploy
netlify deploy

# Deploy para produção
netlify deploy --prod
```

#### Via Interface Web:
1. Acesse: https://netlify.com
2. Arraste a pasta `dist/` para o site
3. Configure variáveis de ambiente
4. Pronto! 🎉

---

### 3️⃣ GITHUB PAGES (GRÁTIS)

```bash
# Instalar gh-pages
npm install -D gh-pages

# Adicionar no package.json:
# "deploy": "gh-pages -d dist"

# Fazer deploy
npm run deploy
```

**⚠️ Atenção:** GitHub Pages só funciona para sites públicos no plano gratuito.

---

### 4️⃣ SERVIDOR PRÓPRIO (VPS/Hostinger/etc)

```bash
# 1. Copiar pasta dist/ para o servidor via FTP/SFTP
# 2. Configurar servidor web (Apache/Nginx)
# 3. Apontar para a pasta dist/

# Exemplo Nginx:
server {
    listen 80;
    server_name pdv.allimport.com.br;
    root /var/www/pdv-allimport/dist;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

### 5️⃣ SUPABASE HOSTING (Experimental)

```bash
# Instalar Supabase CLI
npm install -g supabase

# Deploy
supabase deploy
```

---

## 🔧 CONFIGURAÇÕES PÓS-DEPLOY

### 1. Configurar Domínio Customizado

**Vercel:**
- Settings → Domains → Add Domain

**Netlify:**
- Domain Settings → Add custom domain

### 2. Configurar SSL/HTTPS

Automático na Vercel e Netlify! ✅

### 3. Configurar CORS no Supabase

1. Acesse: https://kmcaaqetxtwkdcczdomw.supabase.co
2. Settings → API
3. Adicione seu domínio em "Additional URLs"

### 4. Atualizar URL no Supabase

Em "Authentication" → "URL Configuration":
- Site URL: `https://seu-dominio.vercel.app`
- Redirect URLs: `https://seu-dominio.vercel.app/*`

---

## 🎯 RECOMENDAÇÃO

**Use a VERCEL!** É a opção mais fácil e rápida:

1. Crie conta: https://vercel.com
2. Conecte GitHub
3. Selecione o repositório
4. Configure variáveis de ambiente
5. Deploy automático! 🚀

**Vantagens:**
- ✅ Deploy automático a cada commit
- ✅ HTTPS grátis
- ✅ CDN global
- ✅ Preview de PRs
- ✅ Rollback fácil
- ✅ Analytics grátis

---

## 📊 STATUS DO BUILD

```
✅ Build: SUCCESS
📦 Tamanho: ~2 MB
🗂️  Arquivos: 8 chunks
⚡ Performance: Otimizado
🔒 Segurança: Variáveis protegidas
```

---

## 🆘 PRECISA DE AJUDA?

1. **Deploy via Vercel CLI:**
   ```bash
   npm install -g vercel
   vercel
   ```

2. **Ver logs:**
   ```bash
   vercel logs
   ```

3. **Rollback:**
   ```bash
   vercel rollback
   ```

---

## 📝 PRÓXIMOS PASSOS

1. ☐ Fazer deploy
2. ☐ Testar no domínio de produção
3. ☐ Configurar domínio customizado (opcional)
4. ☐ Configurar monitoramento (Sentry, LogRocket, etc)
5. ☐ Configurar analytics (Google Analytics, Plausible, etc)

---

**Pronto para fazer deploy?** 

Execute: `npm install -g vercel && vercel`
