-- =====================================================
-- ✅ ATIVAR JENNIFER COMPLETO - BASEADO NO DIAGNÓSTICO
-- =====================================================
-- Jennifer existe no banco com:
-- - user_id: 06b9519a-9516-4044-adf8-bdcb5d089191
-- - email: sousajenifer895@gmail.com
-- - Criado em: 2025-12-07

BEGIN;

-- 1. ATIVAR JENNIFER NO SISTEMA (TODOS OS FLAGS)
-- =====================================================
UPDATE funcionarios
SET 
  ativo = true,
  status = 'ativo',
  usuario_ativo = true,
  senha_definida = true,
  primeiro_acesso = false,
  updated_at = NOW()
WHERE user_id = '06b9519a-9516-4044-adf8-bdcb5d089191';

SELECT 
  '✅ PASSO 1 - JENNIFER ATIVADA' as status,
  nome,
  ativo,
  status,
  usuario_ativo,
  senha_definida,
  primeiro_acesso
FROM funcionarios
WHERE user_id = '06b9519a-9516-4044-adf8-bdcb5d089191';

-- 2. ADICIONAR TODAS AS PERMISSÕES NECESSÁRIAS NO JSONB
-- =====================================================
UPDATE funcionarios
SET permissoes = jsonb_build_object(
  'vendas', true,
  'produtos', true,
  'clientes', true,
  'caixa', true,
  'ordens_servico', true,  -- ⭐ PERMISSÃO DE OS
  'relatorios', true
)
WHERE user_id = '06b9519a-9516-4044-adf8-bdcb5d089191';

SELECT 
  '✅ PASSO 2 - PERMISSÕES JSONB ATUALIZADAS' as status,
  nome,
  permissoes
FROM funcionarios
WHERE user_id = '06b9519a-9516-4044-adf8-bdcb5d089191';

-- 3. VERIFICAR/CRIAR ENTRADA EM login_funcionarios
-- =====================================================
DO $$
DECLARE
  v_jennifer_id UUID;
  v_login_exists BOOLEAN;
BEGIN
  -- Pegar ID de Jennifer
  SELECT id INTO v_jennifer_id
  FROM funcionarios
  WHERE user_id = '06b9519a-9516-4044-adf8-bdcb5d089191';

  -- Verificar se já existe login
  SELECT EXISTS(
    SELECT 1 FROM login_funcionarios
    WHERE funcionario_id = v_jennifer_id
  ) INTO v_login_exists;

  IF v_login_exists THEN
    -- Atualizar login existente
    UPDATE login_funcionarios
    SET 
      ativo = true,
      updated_at = NOW()
    WHERE funcionario_id = v_jennifer_id;
    
    RAISE NOTICE '✅ Login de Jennifer atualizado';
  ELSE
    -- Criar novo login (se necessário)
    INSERT INTO login_funcionarios (
      funcionario_id,
      usuario,
      senha_hash,
      ativo
    ) VALUES (
      v_jennifer_id,
      'jennifer',
      crypt('senha123', gen_salt('bf')), -- Senha padrão
      true
    );
    
    RAISE NOTICE '✅ Login de Jennifer criado';
  END IF;
END $$;

-- 4. VERIFICAR SE JENNIFER TEM FUNÇÃO
-- =====================================================
SELECT 
  '🎭 PASSO 3 - FUNÇÃO DE JENNIFER' as status,
  f.nome as funcionario,
  f.funcao_id,
  func.nome as funcao_nome,
  func.descricao
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
WHERE f.user_id = '06b9519a-9516-4044-adf8-bdcb5d089191';

-- 5. SE NÃO TEM FUNÇÃO, ATRIBUIR FUNÇÃO "VENDEDOR" OU "TÉCNICO"
-- =====================================================
DO $$
DECLARE
  v_jennifer_id UUID;
  v_empresa_id UUID;
  v_funcao_id UUID;
  v_tem_funcao BOOLEAN;
BEGIN
  -- Pegar dados de Jennifer
  SELECT id, empresa_id, (funcao_id IS NOT NULL)
  INTO v_jennifer_id, v_empresa_id, v_tem_funcao
  FROM funcionarios
  WHERE user_id = '06b9519a-9516-4044-adf8-bdcb5d089191';

  RAISE NOTICE 'Jennifer ID: %, Empresa ID: %, Tem função: %', 
    v_jennifer_id, v_empresa_id, v_tem_funcao;

  IF NOT v_tem_funcao THEN
    -- Buscar função "Vendedor" ou "Técnico" da empresa
    SELECT id INTO v_funcao_id
    FROM funcoes
    WHERE empresa_id = v_empresa_id
      AND (LOWER(nome) LIKE '%vendedor%' OR LOWER(nome) LIKE '%técnico%')
    ORDER BY 
      CASE 
        WHEN LOWER(nome) LIKE '%técnico%' THEN 1
        WHEN LOWER(nome) LIKE '%vendedor%' THEN 2
        ELSE 3
      END
    LIMIT 1;

    IF v_funcao_id IS NOT NULL THEN
      UPDATE funcionarios
      SET funcao_id = v_funcao_id
      WHERE id = v_jennifer_id;
      
      RAISE NOTICE '✅ Função atribuída a Jennifer: %', v_funcao_id;
    ELSE
      RAISE NOTICE '⚠️ Nenhuma função adequada encontrada para Jennifer';
    END IF;
  ELSE
    RAISE NOTICE '✅ Jennifer já tem função atribuída';
  END IF;
END $$;

-- 6. ADICIONAR PERMISSÕES DE OS NA FUNÇÃO DE JENNIFER
-- =====================================================
DO $$
DECLARE
  v_funcao_id UUID;
  v_empresa_id UUID;
  v_perm_id UUID;
  v_count INT := 0;
BEGIN
  -- Pegar função e empresa de Jennifer
  SELECT funcao_id, empresa_id
  INTO v_funcao_id, v_empresa_id
  FROM funcionarios
  WHERE user_id = '06b9519a-9516-4044-adf8-bdcb5d089191';

  IF v_funcao_id IS NULL THEN
    RAISE NOTICE '❌ Jennifer não tem função atribuída';
    RETURN;
  END IF;

  RAISE NOTICE '🔑 Adicionando permissões de OS para função: %', v_funcao_id;

  -- Adicionar permissão: ordens_servico:read
  SELECT id INTO v_perm_id FROM permissoes 
  WHERE recurso = 'ordens_servico' AND acao = 'read' LIMIT 1;
  
  IF v_perm_id IS NOT NULL THEN
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_perm_id, v_empresa_id)
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    v_count := v_count + 1;
  END IF;

  -- Adicionar permissão: ordens_servico:create
  SELECT id INTO v_perm_id FROM permissoes 
  WHERE recurso = 'ordens_servico' AND acao = 'create' LIMIT 1;
  
  IF v_perm_id IS NOT NULL THEN
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_perm_id, v_empresa_id)
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    v_count := v_count + 1;
  END IF;

  -- Adicionar permissão: ordens_servico:update
  SELECT id INTO v_perm_id FROM permissoes 
  WHERE recurso = 'ordens_servico' AND acao = 'update' LIMIT 1;
  
  IF v_perm_id IS NOT NULL THEN
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_perm_id, v_empresa_id)
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    v_count := v_count + 1;
  END IF;

  -- Adicionar permissão: ordens_servico:delete
  SELECT id INTO v_perm_id FROM permissoes 
  WHERE recurso = 'ordens_servico' AND acao = 'delete' LIMIT 1;
  
  IF v_perm_id IS NOT NULL THEN
    INSERT INTO funcao_permissoes (funcao_id, permissao_id, empresa_id)
    VALUES (v_funcao_id, v_perm_id, v_empresa_id)
    ON CONFLICT (funcao_id, permissao_id) DO NOTHING;
    v_count := v_count + 1;
  END IF;

  RAISE NOTICE '✅ Total de permissões de OS adicionadas: %', v_count;
END $$;

-- 7. VERIFICAR RESULTADO FINAL
-- =====================================================
SELECT 
  '🎯 RESULTADO FINAL - JENNIFER' as resultado,
  f.nome,
  f.ativo,
  f.status,
  f.usuario_ativo,
  f.senha_definida,
  f.primeiro_acesso,
  f.permissoes->>'ordens_servico' as os_jsonb,
  func.nome as funcao,
  COUNT(DISTINCT fp.permissao_id) FILTER (WHERE p.recurso = 'ordens_servico') as total_perms_os
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
LEFT JOIN permissoes p ON fp.permissao_id = p.id
WHERE f.user_id = '06b9519a-9516-4044-adf8-bdcb5d089191'
GROUP BY f.id, f.nome, f.ativo, f.status, f.usuario_ativo, f.senha_definida, 
         f.primeiro_acesso, f.permissoes, func.nome;

-- 8. TESTAR SE JENNIFER APARECE NO LOGIN
-- =====================================================
SELECT 
  '👥 TESTE - LISTAR USUÁRIOS ATIVOS' as teste,
  *
FROM listar_usuarios_ativos(
  (SELECT empresa_id FROM funcionarios WHERE user_id = '06b9519a-9516-4044-adf8-bdcb5d089191')
)
WHERE LOWER(nome) LIKE '%jennifer%';

-- 9. VERIFICAR PERMISSÕES DETALHADAS DA FUNÇÃO
-- =====================================================
SELECT 
  '📋 PERMISSÕES DA FUNÇÃO DE JENNIFER' as detalhamento,
  p.recurso,
  p.acao,
  p.descricao,
  p.modulo
FROM funcionarios f
JOIN funcoes func ON f.funcao_id = func.id
JOIN funcao_permissoes fp ON func.id = fp.funcao_id
JOIN permissoes p ON fp.permissao_id = p.id
WHERE f.user_id = '06b9519a-9516-4044-adf8-bdcb5d089191'
ORDER BY p.recurso, p.acao;

COMMIT;

-- =====================================================
-- 📋 CHECKLIST - JENNIFER DEVE ESTAR:
-- =====================================================
-- 
-- ✅ ativo = true
-- ✅ status = 'ativo'
-- ✅ usuario_ativo = true
-- ✅ senha_definida = true
-- ✅ primeiro_acesso = false
-- ✅ permissoes->>'ordens_servico' = 'true'
-- ✅ funcao_id != NULL (com função atribuída)
-- ✅ total_perms_os >= 3 (read, create, update mínimo)
-- ✅ Aparece na RPC listar_usuarios_ativos
-- 
-- 🧪 TESTE NO FRONTEND:
-- 1. Logout completo
-- 2. Login: assistenciaallimport10@gmail.com
-- 3. Selecionar: Jennifer
-- 4. Digitar senha (padrão: senha123 se criada pelo script)
-- 5. ✅ Card "Ordens de Serviço" deve aparecer!
-- ✅ Menu "OS" deve estar visível
-- ✅ Pode criar/editar ordens
-- 
-- =====================================================
