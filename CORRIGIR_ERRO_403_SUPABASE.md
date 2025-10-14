# 🚨 ERRO 403 - CHAVE SUPABASE INVÁLIDA

## ❌ Problema Atual

O sistema está retornando erro `403 Forbidden` ao tentar acessar:
```
GET https://kmcaaqetxtwkdcczdomw.supabase.co/auth/v1/user 403 (Forbidden)
```

**Causa:** A chave ANON_KEY atual está sendo rejeitada pelo Supabase Auth.

---

## 🔑 SOLUÇÃO: OBTER NOVA CHAVE ANON

### Passo 1: Acessar o Dashboard do Supabase

1. Acesse: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw
2. Faça login com sua conta

### Passo 2: Obter as Chaves Atualizadas

1. No menu lateral, clique em: **Settings** (⚙️)
2. Clique em: **API**
3. Você verá duas seções:

#### Project URL:
```
https://kmcaaqetxtwkdcczdomw.supabase.co
```

#### API Keys:

**anon / public (Chave Pública)**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjYyMTA0MDcsImV4cCI6MjA0MTc4NjQwN30.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**service_role (Chave Secreta - NÃO usar no frontend)**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImttY2FhcWV0eHR3a2RjY3pkb213Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNjIxMDQwNywiZXhwIjoyMDQxNzg2NDA3fQ.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Passo 3: Atualizar o arquivo `.env.local`

1. Copie a chave **anon / public** do dashboard
2. Cole no arquivo `.env.local`:

```env
VITE_SUPABASE_URL=https://kmcaaqetxtwkdcczdomw.supabase.co
VITE_SUPABASE_ANON_KEY=SUA_CHAVE_ANON_AQUI
```

3. Salve o arquivo
4. Reinicie o servidor de desenvolvimento:

```bash
# Parar o servidor (Ctrl+C)
# Iniciar novamente:
npm run dev
```

---

## 🔍 POSSÍVEIS CAUSAS DO ERRO 403

1. **Chave Rotacionada**: As chaves podem ter sido regeneradas no Supabase
2. **Políticas RLS**: Pode haver políticas de segurança bloqueando acesso anônimo
3. **Configuração de Auth**: O email confirmation pode estar bloqueando

---

## ⚙️ CONFIGURAÇÕES ADICIONAIS NO SUPABASE

### Verificar Email Confirmation

1. Acesse: **Authentication** → **Providers** → **Email**
2. Certifique-se:
   - ✅ **Enable signups**: LIGADO
   - ❌ **Confirm email**: DESLIGADO (para nosso fluxo customizado)

### Verificar URL Configuration

1. Acesse: **Authentication** → **URL Configuration**
2. Configure:
   - **Site URL**: `http://localhost:5174`
   - **Redirect URLs**: `http://localhost:5174/**`

---

## 🧪 TESTAR A NOVA CHAVE

Após atualizar a chave, teste com curl:

```bash
curl -s "https://kmcaaqetxtwkdcczdomw.supabase.co/rest/v1/" \
  -H "apikey: SUA_CHAVE_ANON_AQUI"
```

**Resposta esperada:** JSON com a documentação da API (não erro 403)

---

## 📝 CHECKLIST

- [ ] Acessei o dashboard do Supabase
- [ ] Copiei a chave anon / public atual
- [ ] Atualizei o arquivo `.env.local`
- [ ] Reiniciei o servidor (`npm run dev`)
- [ ] Testei o acesso à API
- [ ] Página está carregando sem erro 403

---

## 🆘 SE O ERRO PERSISTIR

Se mesmo com a chave correta o erro 403 continuar:

1. Verifique se há **Database Webhooks** configurados incorretamente
2. Desabilite **Email Confirmation** temporariamente
3. Verifique **RLS Policies** nas tabelas
4. Entre em contato com o suporte do Supabase

---

## 📞 SUPORTE

- Dashboard: https://supabase.com/dashboard
- Documentação: https://supabase.com/docs
- Discord: https://discord.supabase.com
