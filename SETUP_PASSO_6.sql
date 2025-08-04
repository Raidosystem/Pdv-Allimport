-- ================================
-- PASSO 6: VERIFICAÇÃO FINAL
-- ================================

-- Verificar se tudo foi criado
SELECT 
  'Tabela user_approvals criada' as status,
  EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'user_approvals') as exists;

SELECT 
  'Trigger criado' as status,
  EXISTS(SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'on_auth_user_created') as exists;

-- Teste básico
SELECT 'Sistema configurado com sucesso!' as resultado;
