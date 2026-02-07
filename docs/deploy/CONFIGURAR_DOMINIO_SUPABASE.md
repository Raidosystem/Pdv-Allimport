# 🚀 CONFIGURAR SUPABASE PARA NOVO DOMÍNIO

## ⚡ CONFIGURAÇÃO RÁPIDA VIA DASHBOARD

### 1️⃣ Acessar Dashboard Supabase
- Acesse: https://supabase.com/dashboard
- Faça login na sua conta
- Selecione seu projeto

### 2️⃣ Configurar Authentication
Vá em **Authentication > Settings > URL Configuration**

**Site URL:**
```
https://pdv.crmvsystem.com/
```

**Redirect URLs (adicione todas):**
```
https://pdv.crmvsystem.com/
https://pdv.crmvsystem.com/auth/callback
https://pdv.crmvsystem.com/login
https://pdv.crmvsystem.com/dashboard
https://localhost:5173/
https://localhost:3000/
```

### 3️⃣ Configurar CORS
Vá em **Settings > API > CORS**

**Additional allowed origins:**
```
https://pdv.crmvsystem.com
https://pdv-allimport.surge.sh
https://localhost:5173
https://localhost:3000
```

### 4️⃣ Criar Usuário Admin
Vá em **Authentication > Users** → **Add user**

```
Email: novaradiosystem@outlook.com
Password: Admin123!@#
✅ Auto Confirm User
```

### 5️⃣ Configurar RLS (Opcional)
Vá em **SQL Editor** e execute:

```sql
-- Habilitar RLS em todas as tabelas
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_venda ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.caixa ENABLE ROW LEVEL SECURITY;

-- Criar políticas básicas (permitir tudo para usuários autenticados)
CREATE POLICY "Enable all for authenticated users" ON public.clientes
  FOR ALL USING (auth.role() = 'authenticated');
  
CREATE POLICY "Enable all for authenticated users" ON public.produtos
  FOR ALL USING (auth.role() = 'authenticated');
  
CREATE POLICY "Enable all for authenticated users" ON public.vendas
  FOR ALL USING (auth.role() = 'authenticated');
  
CREATE POLICY "Enable all for authenticated users" ON public.itens_venda
  FOR ALL USING (auth.role() = 'authenticated');
  
CREATE POLICY "Enable all for authenticated users" ON public.caixa
  FOR ALL USING (auth.role() = 'authenticated');
```

---

## 🧪 TESTAR CONFIGURAÇÃO

1. **Acessar aplicação:**
   ```
   https://pdv.crmvsystem.com/
   ```

2. **Fazer login:**
   ```
   Email: novaradiosystem@outlook.com
   Senha: Admin123!@#
   ```

3. **Verificar funcionamento:**
   - Login deve funcionar
   - Dashboard deve carregar
   - Dados devem ser acessíveis

---

## ⚙️ CONFIGURAÇÃO VIA CÓDIGO (Alternativa)

Se preferir via código, edite o arquivo `src/lib/supabase.ts`:

```typescript
const supabaseUrl = 'https://SEU_SUPABASE_URL.supabase.co'
const supabaseKey = 'SUA_CHAVE_PUBLICA'

export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    redirectTo: 'https://pdv.crmvsystem.com/auth/callback',
    flowType: 'pkce'
  },
  global: {
    headers: {
      'Access-Control-Allow-Origin': 'https://pdv.crmvsystem.com'
    }
  }
})
```

---

## 🔧 SOLUÇÃO DE PROBLEMAS

**Erro "Invalid login credentials":**
- Verifique se o usuário foi criado
- Confirme se o email está verificado
- Tente resetar a senha

**Erro CORS:**
- Adicione o domínio nas configurações CORS
- Verifique se a URL está correta (com/sem barra final)

**Erro "User not found":**
- Crie o usuário manualmente no dashboard
- Verifique se o projeto está correto

---

## ✅ CHECKLIST FINAL

- [ ] Site URL configurada
- [ ] Redirect URLs adicionadas
- [ ] CORS configurado
- [ ] Usuário admin criado
- [ ] RLS configurado (opcional)
- [ ] Teste de login realizado
- [ ] Dashboard funcionando

🎉 **Pronto! Seu PDV está configurado para o novo domínio!**
