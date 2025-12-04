-- =====================================================
-- TESTE COMPLETO: API login_funcionarios
-- =====================================================

-- 1. TESTE: Criar Funcionário com Login (RPC)
-- =====================================================
SELECT public.criar_funcionario_completo(
  'Funcionário Teste API',
  'teste.api@email.com',
  '(11) 99999-9999',
  'Vendedor',
  NULL,
  'func_teste_api',
  'SenhaSegura@123'
) as "🧪 Teste: Criar Funcionário";

-- 2. VERIFICAR: Funcionário foi criado?
-- =====================================================
SELECT 
  id,
  nome,
  email,
  ativo,
  created_at
FROM public.funcionarios
WHERE email = 'teste.api@email.com'
ORDER BY created_at DESC
LIMIT 1;

-- 3. VERIFICAR: Login foi criado?
-- =====================================================
SELECT 
  lf.id,
  lf.usuario,
  lf.ativo,
  f.nome as funcionario_nome,
  lf.created_at
FROM public.login_funcionarios lf
INNER JOIN public.funcionarios f ON lf.funcionario_id = f.id
WHERE lf.usuario = 'func_teste_api'
ORDER BY lf.created_at DESC
LIMIT 1;

-- 4. TESTE: Autenticar Funcionário (RPC)
-- =====================================================
SELECT public.autenticar_funcionario(
  'func_teste_api',
  'SenhaSegura@123'
) as "🔐 Teste: Autenticação";

-- 5. TESTE: Autenticação com senha errada (deve falhar)
-- =====================================================
SELECT public.autenticar_funcionario(
  'func_teste_api',
  'SenhaErrada@123'
) as "❌ Teste: Senha Errada (deve retornar erro)";

-- 6. LIMPAR DADOS DE TESTE
-- =====================================================
-- ⚠️ Descomente as linhas abaixo para limpar os dados de teste

-- DELETE FROM public.login_funcionarios 
-- WHERE usuario = 'func_teste_api';

-- DELETE FROM public.funcionarios 
-- WHERE email = 'teste.api@email.com';

-- SELECT 'Dados de teste removidos' as "🧹 Limpeza";

-- =====================================================
-- RESUMO DOS TESTES
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════';
  RAISE NOTICE '🧪 RESUMO DOS TESTES';
  RAISE NOTICE '═══════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Se você viu resultados acima:';
  RAISE NOTICE '   1. criar_funcionario_completo() → {"success": true, ...}';
  RAISE NOTICE '   2. Funcionário apareceu na tabela funcionarios';
  RAISE NOTICE '   3. Login apareceu na tabela login_funcionarios';
  RAISE NOTICE '   4. autenticar_funcionario() → {"success": true, ...}';
  RAISE NOTICE '   5. Senha errada retornou erro';
  RAISE NOTICE '';
  RAISE NOTICE '🎉 TUDO ESTÁ FUNCIONANDO!';
  RAISE NOTICE '';
  RAISE NOTICE '🚀 Próximo passo:';
  RAISE NOTICE '   - Testar no frontend da aplicação';
  RAISE NOTICE '   - Criar logins para funcionários existentes (MIGRAR_LOGINS_FUNCIONARIOS.sql)';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  Não esqueça de limpar os dados de teste!';
  RAISE NOTICE '   (Descomente a seção 6 deste script e execute novamente)';
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════';
END $$;
