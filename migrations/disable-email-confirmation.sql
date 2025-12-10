-- Script para desabilitar confirmação obrigatória de email
-- Este script deve ser executado no Supabase Dashboard > SQL Editor

-- 1. Desabilitar confirmação de email obrigatória
-- Isso precisa ser feito no Dashboard do Supabase:
-- Settings > Authentication > Email Authentication > "Enable email confirmations" = OFF

-- 2. Confirmar automaticamente todos os emails pendentes (opcional)
-- CUIDADO: Isso confirmará TODOS os emails não confirmados no sistema
/*
UPDATE auth.users 
SET 
  email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
  updated_at = NOW()
WHERE email_confirmed_at IS NULL;
*/

-- 3. Verificar usuários não confirmados
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  CASE 
    WHEN email_confirmed_at IS NULL THEN 'Não confirmado'
    ELSE 'Confirmado'
  END as status
FROM auth.users
ORDER BY created_at DESC;

-- 4. Comentário sobre as mudanças
/*
Mudanças realizadas:

1. Configuração no config.toml:
   - [auth.email] enable_confirmations = false
   - Removido URLs de confirmação de email dos redirect_urls

2. No código:
   - AuthContext.tsx: removido emailRedirectTo do signUp
   - SignupPage.tsx: redirecionamento direto para dashboard após cadastro
   - App.tsx: removido rotas de confirmação de email

3. No AdminPanel:
   - Mantido funcionalidade para admin confirmar emails manualmente
   - Atualizado mensagens para refletir nova lógica

Agora os usuários podem:
- Fazer cadastro e acessar imediatamente o sistema
- Administradores podem confirmar emails manualmente pelo painel admin
- Emails ainda são enviados, mas não são obrigatórios para acesso
*/
