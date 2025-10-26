-- =========================================================
-- 🔧 CONFIGURAÇÃO COMPLETA: ATRIBUIÇÃO AUTOMÁTICA DE FUNÇÃO
-- =========================================================
-- Este script:
-- 1. Adiciona coluna funcao_id se não existir
-- 2. Atribui função Administrador aos primeiros usuários de cada empresa
-- 3. Configura trigger para novos usuários
-- 4. Garante que o sistema funcione automaticamente

-- =========================================================
-- PARTE 1: ADICIONAR COLUNA funcao_id
-- =========================================================

DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'funcionarios' 
        AND column_name = 'funcao_id'
    ) THEN
        ALTER TABLE funcionarios 
        ADD COLUMN funcao_id UUID REFERENCES funcoes(id) ON DELETE SET NULL;
        
        RAISE NOTICE '✅ Coluna funcao_id adicionada com sucesso!';
    ELSE
        RAISE NOTICE 'ℹ️ Coluna funcao_id já existe.';
    END IF;
END $$;

-- Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_funcionarios_funcao_id 
ON funcionarios(funcao_id);

-- =========================================================
-- PARTE 2: ATRIBUIR ADMIN AOS PRIMEIROS USUÁRIOS EXISTENTES
-- =========================================================

DO $$
DECLARE
  v_funcionario RECORD;
  v_funcao_admin_id UUID;
  v_count_atribuidos INTEGER := 0;
  v_empresa_id UUID;
BEGIN
  RAISE NOTICE '🔍 Buscando primeiros usuários de cada empresa...';
  
  -- Para cada empresa que tem funcionários
  FOR v_empresa_id IN (
    SELECT DISTINCT empresa_id 
    FROM funcionarios 
    WHERE empresa_id IS NOT NULL
  )
  LOOP
    RAISE NOTICE '📋 Processando empresa: %', v_empresa_id;
    
    -- Buscar ou criar função Administrador
    SELECT id INTO v_funcao_admin_id
    FROM funcoes
    WHERE empresa_id = v_empresa_id
    AND nome = 'Administrador'
    LIMIT 1;

    IF v_funcao_admin_id IS NULL THEN
      RAISE NOTICE '⚠️ Criando função Administrador para empresa %', v_empresa_id;
      
      INSERT INTO funcoes (empresa_id, nome, descricao)
      VALUES (v_empresa_id, 'Administrador', 'Acesso total ao sistema')
      RETURNING id INTO v_funcao_admin_id;
      
      RAISE NOTICE '✅ Função Administrador criada: %', v_funcao_admin_id;
    END IF;

    -- Buscar o primeiro funcionário desta empresa (mais antigo)
    SELECT id, nome, email, funcao_id, tipo_admin
    INTO v_funcionario
    FROM funcionarios
    WHERE empresa_id = v_empresa_id
    ORDER BY created_at ASC
    LIMIT 1;

    IF v_funcionario.id IS NOT NULL THEN
      -- Atribuir função Admin se ainda não tiver
      IF v_funcionario.funcao_id IS NULL THEN
        UPDATE funcionarios
        SET 
          funcao_id = v_funcao_admin_id,
          tipo_admin = 'admin_empresa'
        WHERE id = v_funcionario.id;

        v_count_atribuidos := v_count_atribuidos + 1;
        RAISE NOTICE '✅ Admin atribuído a: % (email: %)', v_funcionario.nome, v_funcionario.email;
      ELSE
        RAISE NOTICE 'ℹ️ Usuário % já tem função: %', v_funcionario.nome, v_funcionario.funcao_id;
      END IF;
    END IF;
  END LOOP;

  RAISE NOTICE '🎉 Total de administradores configurados: %', v_count_atribuidos;
END $$;

-- =========================================================
-- PARTE 3: CRIAR TRIGGER PARA NOVOS USUÁRIOS
-- =========================================================

-- Função do trigger
CREATE OR REPLACE FUNCTION atribuir_admin_primeiro_usuario()
RETURNS TRIGGER AS $$
DECLARE
  v_funcao_admin_id UUID;
  v_count_funcionarios INTEGER;
BEGIN
  -- Verificar se NEW.empresa_id não é NULL
  IF NEW.empresa_id IS NULL THEN
    RAISE NOTICE '⚠️ Funcionário sem empresa_id, pulando atribuição automática';
    RETURN NEW;
  END IF;

  -- Contar quantos funcionários já existem para esta empresa
  SELECT COUNT(*) INTO v_count_funcionarios
  FROM funcionarios
  WHERE empresa_id = NEW.empresa_id
  AND id != NEW.id;

  RAISE NOTICE '🔍 Empresa %, funcionários existentes: %', NEW.empresa_id, v_count_funcionarios;

  -- Se for o primeiro usuário da empresa (count = 0)
  IF v_count_funcionarios = 0 THEN
    RAISE NOTICE '✅ PRIMEIRO USUÁRIO DETECTADO! Atribuindo Admin...';

    -- Buscar função Administrador
    SELECT id INTO v_funcao_admin_id
    FROM funcoes
    WHERE empresa_id = NEW.empresa_id
    AND nome = 'Administrador'
    LIMIT 1;

    IF v_funcao_admin_id IS NULL THEN
      RAISE NOTICE '⚠️ Criando função Administrador para nova empresa';
      
      INSERT INTO funcoes (empresa_id, nome, descricao)
      VALUES (NEW.empresa_id, 'Administrador', 'Acesso total ao sistema')
      RETURNING id INTO v_funcao_admin_id;
    END IF;

    -- Atribuir função e tipo_admin
    NEW.funcao_id := v_funcao_admin_id;
    NEW.tipo_admin := 'admin_empresa';

    RAISE NOTICE '✅ Admin atribuído automaticamente: funcao_id=%', v_funcao_admin_id;
  ELSE
    RAISE NOTICE 'ℹ️ Não é o primeiro usuário (existem %)', v_count_funcionarios;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Remover trigger se já existir
DROP TRIGGER IF EXISTS trigger_atribuir_admin_primeiro_usuario ON funcionarios;

-- Criar trigger
CREATE TRIGGER trigger_atribuir_admin_primeiro_usuario
BEFORE INSERT ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION atribuir_admin_primeiro_usuario();

-- =========================================================
-- PARTE 4: CORRIGIR FUNCIONÁRIOS SEM EMPRESA
-- =========================================================

-- Funcionários sem empresa_id mas com email que existe em auth.users
DO $$
DECLARE
  v_func RECORD;
  v_empresa_id UUID;
BEGIN
  RAISE NOTICE '🔍 Verificando funcionários sem empresa...';
  
  FOR v_func IN (
    SELECT id, nome, email 
    FROM funcionarios 
    WHERE empresa_id IS NULL 
    AND email IS NOT NULL
  )
  LOOP
    -- Tentar encontrar empresa pelo email
    SELECT id INTO v_empresa_id
    FROM empresas
    WHERE email = v_func.email
    LIMIT 1;

    IF v_empresa_id IS NOT NULL THEN
      UPDATE funcionarios
      SET empresa_id = v_empresa_id
      WHERE id = v_func.id;
      
      RAISE NOTICE '✅ Empresa atribuída a %: %', v_func.nome, v_empresa_id;
    ELSE
      RAISE NOTICE '⚠️ Empresa não encontrada para %', v_func.email;
    END IF;
  END LOOP;
END $$;

-- =========================================================
-- PARTE 5: VERIFICAÇÃO FINAL
-- =========================================================

-- Ver trigger criado
SELECT 
  '✅ TRIGGER CRIADO' as status,
  trigger_name,
  event_object_table,
  action_timing
FROM information_schema.triggers
WHERE trigger_name = 'trigger_atribuir_admin_primeiro_usuario';

-- Ver funcionários e suas funções
SELECT 
  '👥 FUNCIONÁRIOS E FUNÇÕES' as info,
  f.id,
  f.nome,
  f.email,
  f.empresa_id,
  f.funcao_id,
  f.tipo_admin,
  f.status,
  func.nome as nome_funcao,
  e.nome as empresa_nome,
  e.email as empresa_email
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN empresas e ON e.id = f.empresa_id
ORDER BY f.empresa_id NULLS LAST, f.created_at;

-- Resumo por empresa
SELECT 
  '📊 RESUMO POR EMPRESA' as info,
  COALESCE(e.nome, 'SEM EMPRESA') as empresa_nome,
  COUNT(f.id) as total_funcionarios,
  COUNT(f.funcao_id) as com_funcao,
  COUNT(CASE WHEN f.tipo_admin = 'admin_empresa' THEN 1 END) as admins,
  COUNT(CASE WHEN func.nome = 'Administrador' THEN 1 END) as com_funcao_admin
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
LEFT JOIN empresas e ON e.id = f.empresa_id
GROUP BY e.id, e.nome
ORDER BY empresa_nome;

-- Verificar empresas e suas funções
SELECT 
  '🏢 EMPRESAS E FUNÇÕES DISPONÍVEIS' as info,
  e.nome as empresa_nome,
  e.email,
  e.id as empresa_id,
  COUNT(f.id) as total_funcoes,
  string_agg(f.nome, ', ') as funcoes_disponiveis
FROM empresas e
LEFT JOIN funcoes f ON f.empresa_id = e.id
GROUP BY e.id, e.nome, e.email
ORDER BY e.nome;

-- =========================================================
-- ✅ RESULTADO ESPERADO
-- =========================================================
-- 1. Coluna funcao_id existe
-- 2. Primeiros usuários têm função Administrador
-- 3. Tipo_admin = 'admin_empresa' para admins
-- 4. Trigger configurado para novos usuários
-- 5. Funcionários sem empresa corrigidos (se possível)
-- =========================================================

DO $$
BEGIN
  RAISE NOTICE '
🎉 CONFIGURAÇÃO COMPLETA FINALIZADA!

📋 O que foi feito:
✅ Coluna funcao_id adicionada
✅ Primeiros usuários configurados como Admin
✅ Trigger ativo para novos usuários
✅ Funcionários sem empresa verificados

🔄 Como funciona agora:
1. Primeiro usuário de cada empresa = Administrador automático
2. Pode criar funcionários com outras funções
3. Se criar funcionários, aparece tela de seleção de login
4. Se NÃO criar funcionários, login vai direto ao dashboard

📝 Próximos passos:
1. Execute o script LIMPAR_E_RECRIAR_FUNCOES_CORRETO.sql
2. Isso criará as 5 funções padrão com permissões
3. Teste criar uma nova conta
4. Verifique se o primeiro usuário vira Admin automaticamente
';
END $$;
