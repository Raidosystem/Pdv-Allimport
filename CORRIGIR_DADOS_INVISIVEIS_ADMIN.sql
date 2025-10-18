-- =====================================================
-- CORREÇÃO: DADOS INVISÍVEIS APÓS LOGIN LOCAL
-- =====================================================
-- Admin faz login mas produtos, clientes e OS sumiram
-- Problema: RLS não reconhece sessão local
-- =====================================================

-- 1. VERIFICAR EMPRESA DO ADMIN
SELECT 
  '1️⃣ DADOS DO ADMIN' as etapa,
  f.id as funcionario_id,
  f.nome,
  f.email,
  f.tipo_admin,
  f.empresa_id,
  e.nome as empresa_nome,
  e.user_id as empresa_user_id
FROM funcionarios f
LEFT JOIN empresas e ON e.id = f.empresa_id
WHERE f.email = 'assistenciaallimport10@gmail.com';

-- 2. CONTAR PRODUTOS DA EMPRESA
SELECT 
  '2️⃣ PRODUTOS DA EMPRESA' as etapa,
  COUNT(*) as total_produtos,
  p.empresa_id
FROM produtos p
WHERE p.empresa_id = (
  SELECT empresa_id FROM funcionarios WHERE email = 'assistenciaallimport10@gmail.com'
)
GROUP BY p.empresa_id;

-- 3. CONTAR CLIENTES DA EMPRESA
SELECT 
  '3️⃣ CLIENTES DA EMPRESA' as etapa,
  COUNT(*) as total_clientes,
  c.empresa_id
FROM clientes c
WHERE c.empresa_id = (
  SELECT empresa_id FROM funcionarios WHERE email = 'assistenciaallimport10@gmail.com'
)
GROUP BY c.empresa_id;

-- 4. CONTAR ORDENS DE SERVIÇO DA EMPRESA
SELECT 
  '4️⃣ ORDENS DE SERVIÇO' as etapa,
  COUNT(*) as total_os,
  os.empresa_id
FROM ordem_servico os
WHERE os.empresa_id = (
  SELECT empresa_id FROM funcionarios WHERE email = 'assistenciaallimport10@gmail.com'
)
GROUP BY os.empresa_id;

-- 5. VERIFICAR RLS DAS TABELAS
SELECT 
  '5️⃣ POLÍTICAS RLS' as etapa,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('produtos', 'clientes', 'ordem_servico')
ORDER BY tablename, policyname;

-- 6. PROBLEMA IDENTIFICADO: RLS usa auth.uid() mas login local não tem auth
-- SOLUÇÃO: Ajustar políticas RLS para aceitar empresa_id do funcionário

-- 6.1 CRIAR FUNÇÃO HELPER PARA PEGAR EMPRESA DO FUNCIONÁRIO LOGADO
CREATE OR REPLACE FUNCTION get_empresa_id_from_session()
RETURNS UUID AS $$
DECLARE
  v_empresa_id UUID;
BEGIN
  -- Tentar pegar do auth.uid() (login tradicional)
  SELECT empresa_id INTO v_empresa_id
  FROM empresas
  WHERE user_id = auth.uid()
  LIMIT 1;
  
  -- Se não encontrou, retornar NULL (login local usa outro método)
  RETURN v_empresa_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6.2 FUNÇÃO PARA VERIFICAR SE USUÁRIO TEM ACESSO À EMPRESA
CREATE OR REPLACE FUNCTION tem_acesso_empresa(p_empresa_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  -- Admin tradicional (via auth)
  IF EXISTS (
    SELECT 1 FROM empresas 
    WHERE id = p_empresa_id 
    AND user_id = auth.uid()
  ) THEN
    RETURN TRUE;
  END IF;
  
  -- Login local via funcionário
  -- (Será implementado via context no frontend)
  
  RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. VERIFICAR SE EXISTE user_id NA TABELA EMPRESAS
SELECT 
  '7️⃣ VERIFICAR user_id DA EMPRESA' as etapa,
  e.id as empresa_id,
  e.nome as empresa_nome,
  e.user_id,
  CASE 
    WHEN e.user_id IS NULL THEN '⚠️ SEM user_id - PROBLEMA!'
    ELSE '✅ user_id configurado'
  END as status
FROM empresas e
WHERE e.id = (
  SELECT empresa_id FROM funcionarios WHERE email = 'assistenciaallimport10@gmail.com'
);

-- 8. SE NÃO TEM user_id, PRECISA ASSOCIAR AO AUTH USER
-- Vamos ver se existe um auth.users para este email
SELECT 
  '8️⃣ VERIFICAR AUTH USER' as etapa,
  id as auth_user_id,
  email,
  created_at
FROM auth.users
WHERE email = 'assistenciaallimport10@gmail.com';

-- 9. ASSOCIAR empresa ao auth.users se existir
DO $$
DECLARE
  v_auth_user_id UUID;
  v_empresa_id UUID;
  v_empresa_user_id UUID;
BEGIN
  -- Buscar auth user
  SELECT id INTO v_auth_user_id
  FROM auth.users
  WHERE email = 'assistenciaallimport10@gmail.com'
  LIMIT 1;
  
  -- Buscar empresa
  SELECT empresa_id INTO v_empresa_id
  FROM funcionarios
  WHERE email = 'assistenciaallimport10@gmail.com'
  LIMIT 1;
  
  -- Buscar user_id atual da empresa
  SELECT user_id INTO v_empresa_user_id
  FROM empresas
  WHERE id = v_empresa_id;
  
  IF v_empresa_id IS NULL THEN
    RAISE NOTICE '❌ Empresa não encontrada';
  ELSIF v_auth_user_id IS NULL THEN
    RAISE NOTICE '⚠️ Não existe auth.users para este email';
    RAISE NOTICE '💡 Você está usando APENAS login local (sem email/senha)';
    RAISE NOTICE '💡 RLS precisa ser ajustado para login local';
  ELSIF v_empresa_user_id IS NULL THEN
    RAISE NOTICE '⚠️ Empresa sem user_id, associando...';
    
    UPDATE empresas
    SET user_id = v_auth_user_id
    WHERE id = v_empresa_id;
    
    RAISE NOTICE '✅ Empresa associada ao auth user!';
  ELSE
    RAISE NOTICE '✅ Empresa já tem user_id: %', v_empresa_user_id;
  END IF;
END $$;

-- 10. TESTAR ACESSO AOS DADOS
SELECT 
  '🧪 TESTE FINAL' as etapa,
  (SELECT COUNT(*) FROM produtos WHERE empresa_id = (
    SELECT empresa_id FROM funcionarios WHERE email = 'assistenciaallimport10@gmail.com'
  )) as produtos,
  (SELECT COUNT(*) FROM clientes WHERE empresa_id = (
    SELECT empresa_id FROM funcionarios WHERE email = 'assistenciaallimport10@gmail.com'
  )) as clientes,
  (SELECT COUNT(*) FROM ordem_servico WHERE empresa_id = (
    SELECT empresa_id FROM funcionarios WHERE email = 'assistenciaallimport10@gmail.com'
  )) as ordens_servico;

-- =====================================================
-- RESULTADO ESPERADO:
-- Se aparecer produtos/clientes/OS = dados estão lá
-- Problema é RLS bloqueando acesso no frontend
-- 
-- PRÓXIMO PASSO:
-- Ajustar AuthContext para passar empresa_id nas queries
-- =====================================================
