-- ============================================
-- DELETAR TODOS OS EMAILS EXCETO OS ATIVOS
-- COM BYPASS DE CONSTRAINTS E TRIGGERS
-- Preserva: novaradiosystem@outlook.com e assistenciaallimport10@gmail.com
-- ============================================

-- ============================================
-- 1️⃣ VERIFICAR PROJETO CORRETO
-- ============================================
SELECT 
  current_database() as database_name,
  CASE 
    WHEN NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'categorias') 
    THEN '✅ PROJETO CORRETO (kmcaaqetxtwkdcczdomw - PDV Allimport)'
    ELSE '❌ PROJETO ERRADO (byjwcuqecojxqcvrljjv) - NÃO CONTINUE!'
  END as verificacao_projeto;

-- ⚠️ SE RETORNAR "PROJETO ERRADO", PARE AQUI!

-- ============================================
-- 2️⃣ VERIFICAR TODOS OS EMAILS NO SISTEMA
-- ============================================

SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  CASE 
    WHEN email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com') THEN '✅ ATIVO - Preservar'
    ELSE '❌ Deletar'
  END as acao
FROM auth.users
ORDER BY 
  CASE 
    WHEN email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com') THEN 0
    ELSE 1
  END,
  email;

-- ============================================
-- 3️⃣ CONTAR TOTAL A SER DELETADO
-- ============================================
SELECT 
  (SELECT COUNT(*) FROM auth.users WHERE email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')) as users_a_deletar,
  (SELECT COUNT(*) FROM auth.users WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')) as users_a_preservar;

-- ============================================
-- 4️⃣ DELETAR COM BYPASS DE CONSTRAINTS
-- ============================================

DO $$ 
DECLARE
  v_user_id uuid;
  v_email text;
  v_total_deletado int := 0;
BEGIN
  RAISE NOTICE '🚀 Iniciando limpeza de usuários (preservando 2 ativos)...';
  RAISE NOTICE '';
  
  -- Loop por TODOS os usuários EXCETO os 2 ativos
  FOR v_user_id, v_email IN 
    SELECT id, email
    FROM auth.users
    WHERE email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
  LOOP
    BEGIN
      RAISE NOTICE '🗑️ Deletando: % (ID: %)', v_email, v_user_id;
      
      -- Deletar registros relacionados PRIMEIRO (na ordem correta)
      
      -- 1. Deletar de funcao_permissoes (se existir FK com funcionarios)
      DELETE FROM funcao_permissoes WHERE funcao_id IN (
        SELECT id FROM funcoes WHERE empresa_id IN (
          SELECT id FROM empresas WHERE user_id = v_user_id
        )
      );
      RAISE NOTICE '   ✓ Deletado funcao_permissoes relacionadas';
      
      -- 2. Deletar de funcoes
      DELETE FROM funcoes WHERE empresa_id IN (
        SELECT id FROM empresas WHERE user_id = v_user_id
      );
      RAISE NOTICE '   ✓ Deletado funcoes relacionadas';
      
      -- 3. Deletar de funcionarios
      DELETE FROM funcionarios WHERE empresa_id IN (
        SELECT id FROM empresas WHERE user_id = v_user_id
      );
      RAISE NOTICE '   ✓ Deletado funcionarios relacionados';
      
      -- 4. Deletar de vendas (se existir)
      DELETE FROM vendas WHERE empresa_id IN (
        SELECT id FROM empresas WHERE user_id = v_user_id
      );
      RAISE NOTICE '   ✓ Deletado vendas relacionadas';
      
      -- 5. Deletar de produtos (se existir)
      DELETE FROM produtos WHERE empresa_id IN (
        SELECT id FROM empresas WHERE user_id = v_user_id
      );
      RAISE NOTICE '   ✓ Deletado produtos relacionados';
      
      -- 6. Deletar de clientes (se existir)
      DELETE FROM clientes WHERE empresa_id IN (
        SELECT id FROM empresas WHERE user_id = v_user_id
      );
      RAISE NOTICE '   ✓ Deletado clientes relacionados';
      
      -- 7. Deletar de ordens_servico (se existir)
      DELETE FROM ordens_servico WHERE empresa_id IN (
        SELECT id FROM empresas WHERE user_id = v_user_id
      );
      RAISE NOTICE '   ✓ Deletado ordens_servico relacionadas';
      
      -- 8. Deletar de caixas (se existir)
      DELETE FROM caixas WHERE empresa_id IN (
        SELECT id FROM empresas WHERE user_id = v_user_id
      );
      RAISE NOTICE '   ✓ Deletado caixas relacionados';
      
      -- 9. Deletar de empresas
      DELETE FROM empresas WHERE user_id = v_user_id;
      RAISE NOTICE '   ✓ Deletado de empresas';
      
      -- 10. FINALMENTE deletar de auth.users
      DELETE FROM auth.users WHERE id = v_user_id;
      RAISE NOTICE '   ✓ Deletado de auth.users';
      
      v_total_deletado := v_total_deletado + 1;
      RAISE NOTICE '   ✅ Concluído para: %', v_email;
      RAISE NOTICE '';
      
    EXCEPTION
      WHEN OTHERS THEN
        RAISE NOTICE '   ⚠️ ERRO ao deletar %: %', v_email, SQLERRM;
        RAISE NOTICE '   Continuando com próximo usuário...';
        RAISE NOTICE '';
    END;
  END LOOP;
  
  RAISE NOTICE '✅ Limpeza completa! Total deletado: %', v_total_deletado;
  RAISE NOTICE '✅ Preservados: novaradiosystem@outlook.com e assistenciaallimport10@gmail.com';
END $$;

-- ============================================
-- 5️⃣ VERIFICAÇÃO FINAL
-- ============================================

-- Deve retornar 0 (todos deletados)
SELECT 
  COUNT(*) as total_nao_ativos,
  'Usuários NÃO ativos restantes (deve ser 0)' as descricao
FROM auth.users
WHERE email NOT IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com');

-- Deve retornar 2 (apenas os ativos)
SELECT 
  COUNT(*) as total_ativos,
  'Usuários ativos preservados (deve ser 2)' as descricao
FROM auth.users
WHERE email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com');

-- ============================================
-- 6️⃣ LISTAR USUÁRIOS ATIVOS PRESERVADOS
-- ============================================

SELECT 
  u.id,
  u.email,
  u.created_at,
  u.email_confirmed_at,
  '✅ ATIVO - Preservado' as status
FROM auth.users u
WHERE u.email IN ('novaradiosystem@outlook.com', 'assistenciaallimport10@gmail.com')
ORDER BY u.email;

-- ============================================
-- ✅ RESUMO
-- ============================================
-- 1. Verifica se está no projeto correto (kmcaaqetxtwkdcczdomw)
-- 2. Deleta TODOS os registros relacionados ANTES de deletar auth.users
-- 3. Ordem de deleção: funcao_permissoes → funcoes → funcionarios → vendas → produtos → clientes → ordens_servico → caixas → empresas → auth.users
-- 4. Usa EXCEPTION para continuar mesmo se alguma tabela não existir
-- 5. Preserva APENAS: novaradiosystem@outlook.com e assistenciaallimport10@gmail.com
-- 6. Sistema limpo e pronto para novos cadastros
