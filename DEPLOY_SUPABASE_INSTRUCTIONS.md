# 🗄️ INSTRUÇÕES DE DEPLOY NO SUPABASE

## 🚀 Como Executar o Deploy

### Método 1: SQL Editor (Recomendado)

1. **Acesse o Supabase Dashboard**:
   - URL: https://supabase.com/dashboard/project/kmcaaqetxtwkdcczdomw
   - Login: novaradiosystem@outlook.com

2. **Abra o SQL Editor**:
   - Menu lateral → SQL Editor
   - Clique em "New query"

3. **Execute o SQL**:
   - Copie todo o conteúdo do arquivo `DEPLOY_SUPABASE_FINAL.sql`
   - Cole no editor
   - Clique em "RUN" (ou Ctrl/Cmd + Enter)

### Método 2: Via Terminal (Alternativo)

```bash
# Instalar Supabase CLI
npm install -g supabase

# Login
supabase login

# Executar SQL
supabase db reset --db-url "postgresql://postgres:@qw12aszx##@db.kmcaaqetxtwkdcczdomw.supabase.co:5432/postgres"
```

---

## 📋 O que será Executado

### ✅ Atualizações de Preço
- Alterar valor padrão para R$ 59,90
- Atualizar registros existentes

### ✅ Tabela de Pagamentos
- Criar tabela `payments` para Mercado Pago
- Configurar índices e constraints
- Ativar Row Level Security (RLS)

### ✅ Políticas de Segurança
- Usuários podem ver próprios pagamentos
- Admins podem ver todos os pagamentos
- Service role pode inserir/atualizar

### ✅ Funções SQL
- `activate_subscription_after_payment()` - Ativar assinatura após pagamento
- `check_subscription_status()` - Verificar status da assinatura
- Triggers para `updated_at` automático

### ✅ Verificações
- Status da assinatura admin
- Contadores de registros
- Políticas RLS ativas

---

## 🎯 Resultado Esperado

Após executar o SQL, você verá:

```sql
✅ DEPLOY SUPABASE CONCLUÍDO COM SUCESSO!
timestamp: 2025-08-05 00:05:00
sistema: PDV Allimport v1.0
preco_atual: R$ 59,90/mês
```

---

## 🔍 Verificação Manual

Execute estas queries para confirmar:

```sql
-- Verificar preço atualizado
SELECT payment_amount FROM public.subscriptions 
WHERE email = 'novaradiosystem@outlook.com';

-- Verificar tabela de pagamentos
SELECT COUNT(*) FROM public.payments;

-- Verificar funções criadas
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name LIKE '%subscription%';
```

---

## 🆘 Em caso de erro

1. **Permissões**: Certifique-se de estar logado como admin
2. **Conexão**: Verifique conexão com internet
3. **Sintaxe**: Execute linha por linha se houver erro
4. **Rollback**: Use transações se necessário

---

## 📱 Próximos Passos

Após o deploy do Supabase:

1. ✅ **Deploy Backend**: `cd api && vercel --prod`
2. ✅ **Configurar Webhooks**: No painel Mercado Pago
3. ✅ **Testar Pagamentos**: PIX e cartão
4. ✅ **Monitorar Logs**: Dashboard Supabase

---

**🎉 Sistema PDV Allimport pronto para operar com pagamentos reais!**
