-- 🧪 TESTE COMPLETO - DELETAR E RECRIAR JENNIFER

-- ====================================
-- 1. DELETAR JENNIFER ATUAL
-- ====================================
DELETE FROM login_funcionarios 
WHERE funcionario_id = (
  SELECT id FROM funcionarios 
  WHERE nome = 'Jennifer Sousa' 
  ORDER BY created_at DESC 
  LIMIT 1
);

DELETE FROM funcionarios 
WHERE nome = 'Jennifer Sousa';

SELECT '🗑️ Jennifer deletada com sucesso!' as status;

-- ====================================
-- 2. RECRIAR JENNIFER USANDO RPC (FLUXO REAL)
-- ====================================
DO $$
DECLARE
  v_funcao_id UUID;
  v_result RECORD;
BEGIN
  -- Buscar ID de uma função disponível
  SELECT id INTO v_funcao_id 
  FROM funcoes 
  WHERE empresa_id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
  ORDER BY created_at DESC
  LIMIT 1;

  -- Criar Jennifer usando a RPC
  SELECT * INTO v_result
  FROM criar_funcionario_completo(
    'f1726fcf-d23b-4cca-8079-39314ae56e00',
    'Jennifer Sousa',
    '123456',
    v_funcao_id,
    NULL
  );

  -- Exibir resultado
  RAISE NOTICE '🆕 RECRIANDO JENNIFER';
  RAISE NOTICE 'Sucesso: %', v_result.sucesso;
  RAISE NOTICE 'Funcionário ID: %', v_result.funcionario_id;
  RAISE NOTICE 'Usuário: %', v_result.usuario;
END $$;

-- ====================================
-- 3. TESTAR LOGIN COM A NOVA JENNIFER
-- ====================================
DO $$
DECLARE
  v_funcionario_id UUID;
  v_result RECORD;
BEGIN
  -- Buscar ID da Jennifer
  SELECT id INTO v_funcionario_id
  FROM funcionarios 
  WHERE nome = 'Jennifer Sousa'
  ORDER BY created_at DESC
  LIMIT 1;

  -- Validar senha
  SELECT * INTO v_result
  FROM validar_senha_local(v_funcionario_id, '123456');

  -- Exibir resultado
  RAISE NOTICE '🧪 TESTE LOGIN JENNIFER';
  RAISE NOTICE 'Sucesso: %', v_result.sucesso;
  RAISE NOTICE 'Token: %', CASE WHEN v_result.token IS NOT NULL AND v_result.token != '' THEN 'Gerado ✅' ELSE 'Nulo ❌' END;
  RAISE NOTICE 'Nome: %', v_result.nome;
  RAISE NOTICE 'Email: %', v_result.email;
  RAISE NOTICE 'Empresa ID: %', v_result.empresa_id;
END $$;

-- ====================================
-- 4. LISTAR TODOS OS USUÁRIOS ATIVOS
-- ====================================
SELECT 
  '👥 USUÁRIOS DISPONÍVEIS NO LOGIN' as lista,
  nome,
  email,
  tipo_admin,
  senha_definida,
  primeiro_acesso,
  CASE 
    WHEN senha_definida AND NOT primeiro_acesso THEN '✅ Pode fazer login'
    WHEN senha_definida AND primeiro_acesso THEN '⚠️ Primeiro acesso'
    ELSE '❌ Sem senha definida'
  END as status
FROM listar_usuarios_ativos('f1726fcf-d23b-4cca-8079-39314ae56e00')
ORDER BY nome;

-- ====================================
-- 5. VERIFICAR DADOS DA EMPRESA
-- ====================================
SELECT 
  '🏢 STATUS DA EMPRESA' as info,
  e.razao_social,
  e.tipo_conta,
  CASE 
    WHEN e.tipo_conta = 'assinatura_ativa' THEN '✅ ACESSO TOTAL'
    WHEN e.tipo_conta = 'teste_ativo' THEN '⏰ EM TESTE'
    WHEN e.tipo_conta = 'teste_expirado' THEN '❌ TESTE EXPIRADO'
    WHEN e.tipo_conta = 'super_admin' THEN '👑 SUPER ADMIN'
    ELSE '⚠️ DESCONHECIDO'
  END as status_acesso,
  COUNT(f.id) as total_funcionarios,
  COUNT(CASE WHEN f.usuario_ativo THEN 1 END) as funcionarios_ativos
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
WHERE e.id = 'f1726fcf-d23b-4cca-8079-39314ae56e00'
GROUP BY e.id, e.razao_social, e.tipo_conta;

-- ====================================
-- ✅ CONCLUSÃO
-- ====================================
SELECT 
  '🎉 TESTE COMPLETO!' as resultado,
  'Se você viu "Sucesso: true" em todos os testes acima:' as passo_1,
  '1. Faça logout no sistema' as passo_2,
  '2. Faça login com assistenciaallimport10@gmail.com' as passo_3,
  '3. Selecione Jennifer Sousa no Login Local' as passo_4,
  '4. Digite a senha: 123456' as passo_5,
  '5. Você deve ser redirecionado para o Dashboard' as passo_6,
  '6. SEM tela de pagamento! ✅' as passo_7;
