-- =========================================================
-- 🔧 ATRIBUIR AUTOMATICAMENTE FUNÇÃO ADMINISTRADOR
-- AO PRIMEIRO USUÁRIO DE CADA EMPRESA
-- =========================================================

-- Este script cria:
-- 1. Trigger que detecta primeiro usuário da empresa
-- 2. Função que atribui automaticamente a função "Administrador"
-- 3. Atualiza usuários existentes que ainda não têm função

-- =========================================================
-- 1. FUNÇÃO PARA ATRIBUIR ADMIN AO PRIMEIRO USUÁRIO
-- =========================================================

CREATE OR REPLACE FUNCTION atribuir_admin_primeiro_usuario()
RETURNS TRIGGER AS $$
DECLARE
  v_funcao_admin_id UUID;
  v_count_funcionarios INTEGER;
BEGIN
  -- Contar quantos funcionários já existem para esta empresa
  SELECT COUNT(*) INTO v_count_funcionarios
  FROM funcionarios
  WHERE empresa_id = NEW.empresa_id
  AND id != NEW.id; -- Excluir o próprio usuário sendo inserido

  RAISE NOTICE '🔍 Verificando primeiro usuário - Total de funcionários existentes: %', v_count_funcionarios;

  -- Se for o primeiro usuário da empresa (count = 0)
  IF v_count_funcionarios = 0 THEN
    RAISE NOTICE '✅ Primeiro usuário detectado! Atribuindo função Administrador...';

    -- Buscar ID da função Administrador desta empresa
    SELECT id INTO v_funcao_admin_id
    FROM funcoes
    WHERE empresa_id = NEW.empresa_id
    AND nome = 'Administrador'
    LIMIT 1;

    IF v_funcao_admin_id IS NULL THEN
      RAISE WARNING '⚠️ Função Administrador não encontrada para empresa %. Será criada.', NEW.empresa_id;
      
      -- Se não existir, criar a função Administrador
      INSERT INTO funcoes (empresa_id, nome, descricao)
      VALUES (NEW.empresa_id, 'Administrador', 'Acesso total ao sistema')
      RETURNING id INTO v_funcao_admin_id;
      
      RAISE NOTICE '✅ Função Administrador criada: %', v_funcao_admin_id;
    END IF;

    -- Atribuir a função ao funcionário
    NEW.funcao_id := v_funcao_admin_id;
    NEW.tipo_admin := 'admin_empresa'; -- Também marcar como admin no tipo_admin

    RAISE NOTICE '✅ Função Administrador atribuída ao usuário % (funcao_id: %)', NEW.id, v_funcao_admin_id;
  ELSE
    RAISE NOTICE 'ℹ️ Não é o primeiro usuário (já existem % funcionários)', v_count_funcionarios;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =========================================================
-- 2. CRIAR TRIGGER BEFORE INSERT EM funcionarios
-- =========================================================

-- Remover trigger se já existir
DROP TRIGGER IF EXISTS trigger_atribuir_admin_primeiro_usuario ON funcionarios;

-- Criar trigger
CREATE TRIGGER trigger_atribuir_admin_primeiro_usuario
BEFORE INSERT ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION atribuir_admin_primeiro_usuario();

-- =========================================================
-- 3. CORRIGIR USUÁRIOS EXISTENTES SEM FUNÇÃO
-- =========================================================

-- Identificar funcionários sem funcao_id que deveriam ser admin
WITH primeiros_usuarios AS (
  SELECT DISTINCT ON (empresa_id)
    id,
    empresa_id,
    nome,
    email,
    created_at
  FROM funcionarios
  WHERE funcao_id IS NULL
  ORDER BY empresa_id, created_at ASC
)
SELECT 
  '🔍 USUÁRIOS SEM FUNÇÃO (PRIMEIRO DE CADA EMPRESA)' as info,
  pu.id as funcionario_id,
  pu.nome,
  pu.email,
  pu.empresa_id,
  e.nome as empresa_nome,
  pu.created_at
FROM primeiros_usuarios pu
LEFT JOIN empresas e ON e.id = pu.empresa_id
ORDER BY pu.created_at;

-- =========================================================
-- 4. ATRIBUIR FUNÇÃO ADMIN PARA PRIMEIROS USUÁRIOS
-- =========================================================

DO $$
DECLARE
  v_funcionario RECORD;
  v_funcao_admin_id UUID;
  v_count_atribuidos INTEGER := 0;
BEGIN
  -- Para cada primeiro funcionário sem função
  FOR v_funcionario IN (
    SELECT DISTINCT ON (empresa_id)
      id,
      empresa_id,
      nome
    FROM funcionarios
    WHERE funcao_id IS NULL
    ORDER BY empresa_id, created_at ASC
  )
  LOOP
    -- Buscar função Administrador da empresa
    SELECT id INTO v_funcao_admin_id
    FROM funcoes
    WHERE empresa_id = v_funcionario.empresa_id
    AND nome = 'Administrador'
    LIMIT 1;

    IF v_funcao_admin_id IS NULL THEN
      RAISE NOTICE '⚠️ Criando função Administrador para empresa %', v_funcionario.empresa_id;
      
      -- Criar função se não existir
      INSERT INTO funcoes (empresa_id, nome, descricao)
      VALUES (v_funcionario.empresa_id, 'Administrador', 'Acesso total ao sistema')
      RETURNING id INTO v_funcao_admin_id;
    END IF;

    -- Atribuir função ao funcionário
    UPDATE funcionarios
    SET 
      funcao_id = v_funcao_admin_id,
      tipo_admin = 'admin_empresa'
    WHERE id = v_funcionario.id;

    v_count_atribuidos := v_count_atribuidos + 1;
    RAISE NOTICE '✅ Função Administrador atribuída a: % (empresa: %)', v_funcionario.nome, v_funcionario.empresa_id;
  END LOOP;

  RAISE NOTICE '🎉 Total de usuários corrigidos: %', v_count_atribuidos;
END $$;

-- =========================================================
-- 5. VERIFICAÇÃO FINAL
-- =========================================================

-- Verificar se trigger foi criado
SELECT 
  '✅ TRIGGER CRIADO' as status,
  trigger_name,
  event_manipulation,
  event_object_table,
  action_timing
FROM information_schema.triggers
WHERE trigger_name = 'trigger_atribuir_admin_primeiro_usuario';

-- Verificar funcionários com suas funções
SELECT 
  '👥 FUNCIONÁRIOS E SUAS FUNÇÕES' as info,
  f.id,
  f.nome,
  f.email,
  f.empresa_id,
  f.funcao_id,
  f.tipo_admin,
  func.nome as nome_funcao,
  e.nome as empresa_nome,
  f.created_at
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN empresas e ON e.id = f.empresa_id
ORDER BY f.empresa_id, f.created_at;

-- Contar funcionários por empresa e suas funções
SELECT 
  '📊 RESUMO POR EMPRESA' as info,
  e.nome as empresa_nome,
  COUNT(f.id) as total_funcionarios,
  COUNT(f.funcao_id) as com_funcao,
  COUNT(CASE WHEN func.nome = 'Administrador' THEN 1 END) as administradores
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
LEFT JOIN funcoes func ON func.id = f.funcao_id
GROUP BY e.id, e.nome
ORDER BY e.nome;

-- =========================================================
-- ✅ RESULTADO ESPERADO
-- =========================================================
-- 1. Trigger criado: trigger_atribuir_admin_primeiro_usuario
-- 2. Função criada: atribuir_admin_primeiro_usuario()
-- 3. Primeiros usuários existentes corrigidos com função Admin
-- 4. Novos usuários serão automaticamente Admin se forem primeiro da empresa
-- =========================================================

DO $$
BEGIN
  RAISE NOTICE '
🎉 SISTEMA DE ATRIBUIÇÃO AUTOMÁTICA DE ADMIN CONFIGURADO!

📋 O que foi implementado:
- ✅ Trigger que detecta primeiro usuário de cada empresa
- ✅ Atribuição automática da função "Administrador"
- ✅ Correção de usuários existentes sem função
- ✅ Tipo_admin também definido como "admin_empresa"

🔄 Como funciona agora:
1. Novo usuário se registra
2. Sistema detecta se é o primeiro da empresa
3. Se for, busca função "Administrador" (ou cria se não existir)
4. Atribui automaticamente funcao_id e tipo_admin
5. Usuário já loga com acesso de Administrador

⚠️ IMPORTANTE:
- Execute este script no Supabase SQL Editor
- Verifique os resultados nas consultas acima
- Teste criando uma nova conta
';
END $$;
