# 🚀 Guia Rápido - Sistema de Verificação de Email

## ⚡ Como Funciona (Resumo)

1. **Usuário se cadastra** → Conta criada mas INATIVA
2. **Sistema gera código** → 6 dígitos no banco
3. **Email enviado** → Código via SMTP Supabase
4. **Usuário digita código** → Verifica no banco
5. **Se correto** → Ativa + 15 dias teste gratuito ✅
6. **Se errado** → Mostra tentativas restantes (max 5)

---

## 📋 Setup Rápido

### 1. Executar SQL no Supabase

```sql
-- Execute na ordem:
-- 1. migrations/create-custom-email-verification-system.sql
-- 2. migrations/activate-user-after-email-verification.sql
```

### 2. Verificar Funções Criadas

```sql
-- Deve retornar 3 funções:
SELECT proname FROM pg_proc 
WHERE proname LIKE '%verification%' OR proname LIKE '%activate_user%';
```

### 3. Testar

```bash
# Frontend
npm run dev

# Acessar
http://localhost:5174/signup

# Cadastrar com email real
# Verificar código recebido
```

---

## 🎯 Endpoints/Funções

### Frontend (TypeScript)

```typescript
import { 
  sendVerificationCode, 
  verifyCode, 
  resendVerificationCode 
} from './services/customEmailVerification';

// Enviar código
await sendVerificationCode('user@example.com');

// Verificar código
await verifyCode('user@example.com', '123456');

// Reenviar
await resendVerificationCode('user@example.com');
```

### Backend (SQL)

```sql
-- Gerar código
SELECT generate_and_send_verification_code('user@example.com');

-- Verificar código
SELECT verify_email_verification_code('user@example.com', '123456');

-- Ativar usuário
SELECT activate_user_after_email_verification('user@example.com');
```

---

## ✅ Verificações Importantes

### Verificar se código foi gerado:
```sql
SELECT * FROM email_verification_codes 
WHERE email = 'seu-email@exemplo.com' 
ORDER BY created_at DESC LIMIT 1;
```

### Verificar se usuário foi ativado:
```sql
SELECT 
  email, 
  email_verified, 
  status, 
  subscription_end_date 
FROM subscriptions 
WHERE email = 'seu-email@exemplo.com';
```

### Ver tentativas de verificação:
```sql
SELECT 
  code, 
  attempts, 
  max_attempts, 
  verified, 
  expires_at 
FROM email_verification_codes 
WHERE email = 'seu-email@exemplo.com' 
ORDER BY created_at DESC;
```

---

## 🐛 Problemas Comuns

### "Código não encontrado ou expirado"
- ✅ Código expira em 15 minutos
- ✅ Solicite novo código

### "Número máximo de tentativas excedido"
- ✅ 5 tentativas por código
- ✅ Solicite novo código

### "Código inválido"
- ✅ Verifique se digitou corretamente
- ✅ Código tem 6 dígitos
- ✅ Tentativas restantes mostradas na mensagem

### Email não chega
- ✅ Verifique spam
- ✅ Confirme SMTP configurado no Supabase
- ✅ Ver logs no console do navegador

---

## 📊 Monitoramento

### Ver códigos gerados hoje:
```sql
SELECT 
  email,
  code,
  TO_CHAR(created_at, 'HH24:MI:SS') as hora,
  verified,
  attempts
FROM email_verification_codes 
WHERE created_at::date = CURRENT_DATE
ORDER BY created_at DESC;
```

### Ver ativações de hoje:
```sql
SELECT 
  email,
  status,
  TO_CHAR(subscription_start_date, 'HH24:MI:SS') as hora_ativacao,
  EXTRACT(DAY FROM (subscription_end_date - NOW())) as dias_restantes
FROM subscriptions 
WHERE subscription_start_date::date = CURRENT_DATE
ORDER BY subscription_start_date DESC;
```

### Estatísticas:
```sql
-- Total de códigos gerados hoje
SELECT COUNT(*) as total_codigos FROM email_verification_codes 
WHERE created_at::date = CURRENT_DATE;

-- Total de verificações bem-sucedidas
SELECT COUNT(*) as verificados FROM email_verification_codes 
WHERE verified = TRUE AND created_at::date = CURRENT_DATE;

-- Taxa de sucesso
SELECT 
  COUNT(CASE WHEN verified = TRUE THEN 1 END) as verificados,
  COUNT(*) as total,
  ROUND(COUNT(CASE WHEN verified = TRUE THEN 1 END)::numeric / COUNT(*)::numeric * 100, 2) as taxa_sucesso_pct
FROM email_verification_codes 
WHERE created_at::date = CURRENT_DATE;
```

---

## 🔧 Manutenção

### Limpar códigos expirados (executar semanalmente):
```sql
DELETE FROM email_verification_codes 
WHERE expires_at < NOW() - INTERVAL '7 days';
```

### Ver códigos que estão para expirar:
```sql
SELECT 
  email,
  code,
  EXTRACT(MINUTE FROM (expires_at - NOW())) as minutos_restantes
FROM email_verification_codes 
WHERE verified = FALSE 
  AND expires_at > NOW()
  AND expires_at < NOW() + INTERVAL '5 minutes'
ORDER BY expires_at;
```

---

## 📈 KPIs

```sql
-- Última semana
SELECT 
  DATE(created_at) as data,
  COUNT(*) as codigos_gerados,
  COUNT(CASE WHEN verified = TRUE THEN 1 END) as verificados,
  ROUND(AVG(attempts), 2) as media_tentativas
FROM email_verification_codes 
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY data DESC;
```

---

## 🎯 Checklist de Produção

- [ ] SQL executado no Supabase
- [ ] Funções testadas manualmente
- [ ] SMTP configurado e testado
- [ ] Build sem erros
- [ ] Deploy realizado
- [ ] Teste em produção completo
- [ ] Email real testado
- [ ] Verificação testada
- [ ] Login após verificação testado
- [ ] 15 dias de teste confirmados

---

## 📞 Suporte

Em caso de problemas:

1. Verificar logs do console (F12)
2. Verificar tabela `email_verification_codes`
3. Verificar tabela `subscriptions`
4. Ver documentação completa: `SISTEMA-VERIFICACAO-EMAIL-CUSTOMIZADO.md`

---

**Sistema pronto para uso! ✅**

Documentação completa: `docs/SISTEMA-VERIFICACAO-EMAIL-CUSTOMIZADO.md`
