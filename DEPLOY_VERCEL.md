# 🚀 Deploy PDV Allimport no Vercel

## 📋 Pré-requisitos

1. **Conta no Vercel**: https://vercel.com
2. **Projeto no GitHub**: Repositório público ou privado
3. **Supabase configurado**: Database e credenciais

## 🛠️ Configuração de Deploy

### 1. Deploy Automático via GitHub

1. **Conecte o repositório**:
   - Acesse [Vercel Dashboard](https://vercel.com/dashboard)
   - Clique em "New Project"
   - Conecte seu repositório GitHub
   - Selecione o projeto `Pdv-Allimport`

2. **Configurações automáticas**:
   - ✅ Framework: Vite (detectado automaticamente)
   - ✅ Build Command: `npm run build`
   - ✅ Output Directory: `dist`
   - ✅ Install Command: `npm install`

### 2. Variáveis de Ambiente

Configure as seguintes variáveis no Vercel Dashboard:

```env
VITE_SUPABASE_URL=https://kmcaaqetxtwkdcczdomw.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
VITE_APP_NAME=PDV Allimport
VITE_APP_VERSION=1.0.0
VITE_DEV_MODE=false
```

### 3. Deploy Manual via CLI

```bash
# Login no Vercel
vercel login

# Deploy para preview
vercel

# Deploy para produção
vercel --prod
```

## 🔧 Scripts Disponíveis

```bash
# Desenvolvimento
npm run dev

# Build e deploy
npm run build:prod    # Build otimizado
npm run deploy:dev    # Deploy preview
npm run deploy        # Deploy produção

# Verificações
npm run type-check    # Verificar tipos TypeScript
npm run lint          # Verificar código
```

## 📱 Domínio e URLs

### URLs Automáticas
- **Produção**: `https://pdv-allimport.vercel.app`
- **Preview**: `https://pdv-allimport-[hash].vercel.app`

### Domínio Customizado (Opcional)
1. Acesse Project Settings no Vercel
2. Vá para "Domains"
3. Adicione seu domínio personalizado
4. Configure DNS conforme instruções

## 🚦 Status e Monitoramento

### Deploy Status
- ✅ **Build**: Automatizado via GitHub
- ✅ **Preview**: A cada Pull Request
- ✅ **Production**: A cada push na main/master

### Analytics (Opcional)
- Ative Vercel Analytics no dashboard
- Monitore performance e uso
- Relatórios de Core Web Vitals

## 🔐 Segurança

### Headers de Segurança
Configurados automaticamente via `vercel.json`:
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- X-XSS-Protection: 1; mode=block
- Referrer-Policy: strict-origin-when-cross-origin

### Variáveis Sensíveis
- ✅ Supabase keys configuradas como Environment Variables
- ✅ Não expostas no código fonte
- ✅ Diferentes para dev/prod

## 🐛 Troubleshooting

### Build Errors
```bash
# Testar build localmente
npm run build:prod

# Verificar tipos
npm run type-check

# Verificar lint
npm run lint
```

### Environment Issues
```bash
# Verificar variáveis
vercel env ls

# Adicionar variável
vercel env add VITE_VARIABLE_NAME

# Remover variável
vercel env rm VITE_VARIABLE_NAME
```

### Rollback
```bash
# Listar deployments
vercel ls

# Promover deployment anterior
vercel promote [deployment-url]
```

## 📈 Performance

### Otimizações Automáticas
- ✅ Compression (Gzip/Brotli)
- ✅ Image Optimization
- ✅ Edge Caching
- ✅ Static File Serving

### Métricas
- Core Web Vitals
- Bundle Size Analysis
- Performance Insights

---

## 🎯 Próximos Passos

1. **Deploy inicial**: `vercel --prod`
2. **Configurar domínio**: Se necessário
3. **Ativar analytics**: Para monitoramento
4. **Configurar CI/CD**: Testes automatizados

**URL do PDV**: Será gerada após o primeiro deploy! 🚀
