-- =====================================================
-- ✅ CORREÇÃO - JENNIFER E PERMISSÕES DE OS
-- =====================================================
-- Execute DIAGNOSTICO_JENNIFER_OS.sql PRIMEIRO para identificar o problema!
-- Este script corrige os problemas mais comuns.

BEGIN;

-- 1. GARANTIR QUE JENNIFER ESTÁ ATIVA NO SISTEMA
-- =====================================================
UPDATE funcionarios
SET 
  ativo = true,
  status = 'ativo',
  usuario_ativo = true,
  senha_definida = COALESCE(senha_definida, true), -- Se já tem senha, manter
  primeiro_acesso = COALESCE(primeiro_acesso, false)
WHERE LOWER(nome) LIKE '%jennifer%'
  AND empresa_id = (
    SELECT id FROM empresas 
    WHERE email = 'assistenciaallimport10@gmail.com' 
    LIMIT 1
  );

-- Verificar atualização
SELECT 
  '✅ JENNIFER ATUALIZADA' as resultado,
  nome,
  ativo,
  status,
  usuario_ativo,
  senha_definida
FROM funcionarios
WHERE LOWER(nome) LIKE '%jennifer%';

-- 2. ADICIONAR/ATUALIZAR PERMISSÃO DE OS NO JSONB
-- =====================================================
UPDATE funcionarios
SET permissoes = COALESCE(permissoes, '{}'::jsonb) || '{"ordens_servico": true}'::jsonb
WHERE LOWER(nome) LIKE '%jennifer%'
  AND empresa_id = (
    SELECT id FROM empresas 
    WHERE email = 'assistenciaallimport10@gmail.com' 
    LIMIT 1
  );

-- Verificar permissões JSONB
SELECT 
  '📦 PERMISSÕES JSONB ATUALIZADAS' as resultado,
  nome,
  permissoes->>'ordens_servico' as os_ativo,
  permissoes->>'vendas' as vendas_ativo,
  permissoes->>'produtos' as produtos_ativo,
  permissoes->>'clientes' as clientes_ativo
FROM funcionarios
WHERE LOWER(nome) LIKE '%jennifer%';

-- 3. GARANTIR QUE FUNÇÃO DE JENNIFER TEM PERMISSÕES DE OS
-- =====================================================
-- Buscar função de Jennifer
DO $$
DECLARE
  v_funcao_id UUID;
  v_empresa_id UUID;
  v_perm_os_read UUID;
  v_perm_os_create UUID;
  v_perm_os_update UUID;
  v_count INT;
BEGIN
  -- Pegar empresa
  SELECT id INTO v_empresa_id
  FROM empresas
  WHERE email = 'assistenciaallimport10@gmail.com'
  LIMIT 1;

  -- Pegar função de Jennifer
  SELECT funcao_id INTO v_funcao_id
  FROM funcionarios
  WHERE LOWER(nome) LIKE '%jennifer%'
    AND empresa_id = v_empresa_id
  LIMIT 1;

  RAISE NOTICE '🎭 Função de Jennifer: %', v_funcao_id;

  IF v_funcao_id IS NULL THEN
    RAISE NOTICE '❌ Jennifer não tem função atribuída';
    RETURN;
  END IF;

  -- Buscar permissões de OS
  SELECT id INTO v_perm_os_read
  FROM permissoes
  WHERE recurso = 'ordens_servico' AND acao = 'read'
  LIMIT 1;

  SELECT id INTO v_perm_os_create
  FROM permissoes
  WHERE recurso = 'ordens_servico' AND acao = 'create'
  LIMIT 1;

  SELECT id INTO v_perm_os_update
  FROM permissoes
  WHERE recurso = 'ordens_servico' AND acao = 'update'
  LIMIT 1;

  RAISE NOTICE '🔑 Permissão OS Read: %', v_perm_os_read;

  -- Verificar se já tem permissões
  SELECT COUNT(*) INTO v_count
  FROM funcao_permissoes
  WHERE funcao_id = v_funcao_id
    AND permissao_id IN (v_perm_os_read, v_perm_os_create, v_perm_os_update);

  RAISE NOTICE '📊 Permissões OS existentes: %', v_count;

  -- Adicionar permissões se não existirem
  IF v_perm_os_read IS NOT NULL THEN
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_perm_os_read, v_empresa_id)
    ON CONFLICT DO NOTHING;
  END IF;

  IF v_perm_os_create IS NOT NULL THEN
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_perm_os_create, v_empresa_id)
    ON CONFLICT DO NOTHING;
  END IF;

  IF v_perm_os_update IS NOT NULL THEN
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_perm_os_update, v_empresa_id)
    ON CONFLICT DO NOTHING;
  END IF;

  RAISE NOTICE '✅ Permissões de OS adicionadas à função';
END $$;

-- 4. VERIFICAR RESULTADO FINAL
-- =====================================================
SELECT 
  '🎯 RESULTADO FINAL' as secao,
  f.nome as funcionario,
  f.ativo,
  f.status,
  f.usuario_ativo,
  f.senha_definida,
  f.permissoes->>'ordens_servico' as os_jsonb,
  func.nome as funcao,
  COUNT(fp.permissao_id) FILTER (WHERE p.recurso = 'ordens_servico') as permissoes_os_funcao
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
LEFT JOIN permissoes p ON fp.permissao_id = p.id
WHERE LOWER(f.nome) LIKE '%jennifer%'
GROUP BY f.id, f.nome, f.ativo, f.status, f.usuario_ativo, f.senha_definida, f.permissoes, func.nome;

-- 5. TESTAR RPC listar_usuarios_ativos
-- =====================================================
SELECT 
  '👥 TESTE RPC' as secao,
  *
FROM listar_usuarios_ativos(
  (SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1)
)
WHERE LOWER(nome) LIKE '%jennifer%';

COMMIT;

-- =====================================================
-- 📋 CHECKLIST PÓS-CORREÇÃO:
-- =====================================================
-- 
-- ✅ Jennifer deve aparecer com:
--    - ativo = true
--    - status = 'ativo'
--    - usuario_ativo = true
--    - senha_definida = true
--    - permissoes->>'ordens_servico' = 'true'
--    - permissoes_os_funcao >= 1
-- 
-- ✅ Jennifer deve aparecer na RPC listar_usuarios_ativos
-- 
-- ✅ No frontend, após login:
--    - Card "Ordens de Serviço" deve aparecer no dashboard
--    - Menu OS deve estar visível
-- 
-- =====================================================
