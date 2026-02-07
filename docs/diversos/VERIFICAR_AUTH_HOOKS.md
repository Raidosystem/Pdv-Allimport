# 🔍 Como Verificar Auth Hooks no Supabase

O erro 500 pode estar sendo causado por **Auth Hooks** configurados no Supabase Dashboard.

## 📋 Passos para Verificar:

### 1. Acesse o Supabase Dashboard
- Vá para: https://supabase.com/dashboard
- Selecione o projeto: **kmcaaqetxtwkdcczdomw**

### 2. Navegue até Auth Hooks
- Menu lateral: **Authentication** → **Hooks**
- Ou acesse diretamente: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw/auth/hooks

### 3. Verifique os Hooks Ativos
Procure por hooks configurados em:
- ✅ **Custom Access Token** - Pode adicionar claims customizados
- ✅ **Send Email** - Customização de emails
- ✅ **Send SMS** - Customização de SMS
- ✅ **MFA Verification Attempt** - Verificação de MFA

### 4. Se Houver Hooks Ativos:
- **DESABILITE temporariamente** para testar se o erro persiste
- Anote o conteúdo/URL do hook antes de desabilitar
- Teste o login novamente

## 🚨 Hooks Comuns que Causam 500:

1. **Custom Access Token Hook** com função PostgreSQL com erro
2. **Webhook HTTP** que retorna timeout ou erro
3. **Função RPC** que não existe mais ou tem bug

## 📊 Depois de Verificar:

Execute também o SQL de diagnóstico: `DIAGNOSTICO_500_ERROR_LOGIN.sql`

Me informe:
- ✅ Quantos hooks estão ativos?
- ✅ Quais tipos de hooks?
- ✅ O que eles fazem?
