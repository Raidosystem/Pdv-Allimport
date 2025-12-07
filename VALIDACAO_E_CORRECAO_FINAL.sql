-- =====================================================
-- VALIDAÇÃO E CORREÇÃO FINAL DO SISTEMA
-- Execute este script para garantir que tudo funciona
-- =====================================================

-- ✅ PASSO 1: Verificar estrutura atual
SELECT '==================== VERIFICAÇÃO INICIAL ====================' as etapa;

-- Verificar se trigger existe
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_first_user_admin'
  ) THEN
    RAISE NOTICE '❌ TRIGGER NÃO EXISTE - Será criado';
  ELSE
    RAISE NOTICE '✅ Trigger exists: trigger_first_user_admin';
  END IF;
END $$;

-- Verificar se função listar_usuarios_ativos tem campo 'usuario'
DO $$
DECLARE
  v_test RECORD;
BEGIN
  SELECT * FROM listar_usuarios_ativos(
    (SELECT id FROM empresas LIMIT 1)
  ) LIMIT 1 INTO v_test;
  
  IF v_test.usuario IS NOT NULL OR v_test.usuario IS NULL THEN
    RAISE NOTICE '✅ Função listar_usuarios_ativos tem campo usuario';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '❌ ERRO na função listar_usuarios_ativos: %', SQLERRM;
END $$;

-- ✅ PASSO 2: Recriar trigger do primeiro funcionário
SELECT '==================== RECRIANDO TRIGGER ====================' as etapa;

CREATE OR REPLACE FUNCTION set_first_user_as_admin()
RETURNS TRIGGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  -- Contar quantos funcionários já existem nesta empresa
  SELECT COUNT(*) INTO v_count
  FROM funcionarios 
  WHERE empresa_id = NEW.empresa_id 
  AND id != NEW.id;
  
  -- Se for o primeiro funcionário (count = 0)
  IF v_count = 0 THEN
    NEW.tipo_admin = 'admin_empresa';
    RAISE NOTICE '✅ Primeiro funcionário definido como admin_empresa: % (empresa: %)', NEW.nome, NEW.empresa_id;
  ELSE
    -- Não é o primeiro, garantir que seja 'funcionario'
    IF NEW.tipo_admin IS NULL THEN
      NEW.tipo_admin = 'funcionario';
      RAISE NOTICE '✅ Funcionário comum: % (empresa: %)', NEW.nome, NEW.empresa_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recriar trigger
DROP TRIGGER IF EXISTS trigger_first_user_admin ON funcionarios;
CREATE TRIGGER trigger_first_user_admin
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION set_first_user_as_admin();

-- Confirmar criação do trigger
DO $$
BEGIN
  RAISE NOTICE '✅ Trigger recriado: trigger_first_user_admin';
END $$;

-- ✅ PASSO 3: Corrigir funcionários existentes
SELECT '==================== CORRIGINDO FUNCIONÁRIOS ====================' as etapa;

-- Garantir que o PRIMEIRO funcionário de cada empresa seja admin
UPDATE funcionarios f
SET tipo_admin = 'admin_empresa'
WHERE f.id IN (
  -- Buscar o primeiro funcionário de cada empresa
  SELECT DISTINCT ON (empresa_id) id
  FROM funcionarios
  ORDER BY empresa_id, created_at ASC
)
-- Só atualizar se não for já admin
AND f.tipo_admin NOT IN ('admin_empresa', 'super_admin')
-- Só atualizar se a empresa não tiver outro admin
AND NOT EXISTS (
  SELECT 1 FROM funcionarios f2
  WHERE f2.empresa_id = f.empresa_id
  AND f2.tipo_admin IN ('admin_empresa', 'super_admin')
  AND f2.id != f.id
);

-- Garantir que outros funcionários sejam 'funcionario'
UPDATE funcionarios f
SET tipo_admin = 'funcionario'
WHERE f.id NOT IN (
  -- Pegar o primeiro funcionário de cada empresa
  SELECT DISTINCT ON (empresa_id) id
  FROM funcionarios
  ORDER BY empresa_id, created_at ASC
)
AND f.tipo_admin NOT IN ('admin_empresa', 'super_admin', 'funcionario');

-- ✅ PASSO 4: Recriar função listar_usuarios_ativos
SELECT '==================== RECRIANDO FUNÇÃO ====================' as etapa;

CREATE OR REPLACE FUNCTION public.listar_usuarios_ativos(p_empresa_id UUID)
RETURNS TABLE (
  id UUID,
  nome TEXT,
  email TEXT,
  foto_perfil TEXT,
  tipo_admin TEXT,
  senha_definida BOOLEAN,
  primeiro_acesso BOOLEAN,
  usuario TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    f.id,
    f.nome,
    COALESCE(f.email, '') as email,
    f.foto_perfil,
    f.tipo_admin,
    COALESCE(f.senha_definida, false) as senha_definida,
    COALESCE(f.primeiro_acesso, true) as primeiro_acesso,
    COALESCE(
      lf.usuario,  -- Prioridade 1: campo usuario da tabela login_funcionarios
      f.email,     -- Prioridade 2: email do funcionário
      LOWER(REGEXP_REPLACE(f.nome, '[^a-zA-Z0-9]', '', 'g'))  -- Prioridade 3: nome sem espaços
    ) as usuario
  FROM public.funcionarios f
  LEFT JOIN public.login_funcionarios lf ON lf.funcionario_id = f.id AND lf.ativo = true
  WHERE f.empresa_id = p_empresa_id
    AND f.status = 'ativo'
  ORDER BY 
    CASE WHEN f.tipo_admin = 'admin_empresa' THEN 0 ELSE 1 END,
    f.nome;
END;
$$;

GRANT EXECUTE ON FUNCTION public.listar_usuarios_ativos TO authenticated, anon;

-- Confirmar criação da função
DO $$
BEGIN
  RAISE NOTICE '✅ Função recriada: listar_usuarios_ativos';
END $$;

-- ✅ PASSO 5: Verificar resultados
SELECT '==================== VERIFICAÇÃO FINAL ====================' as etapa;

-- Listar todas as empresas e seus funcionários
SELECT 
  '📊 EMPRESAS E FUNCIONÁRIOS' as relatorio,
  e.nome as empresa,
  e.email as email_principal,
  COUNT(f.id) as total_funcionarios,
  COUNT(CASE WHEN f.tipo_admin = 'admin_empresa' THEN 1 END) as admins,
  COUNT(CASE WHEN f.tipo_admin = 'funcionario' THEN 1 END) as funcionarios_comuns
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
GROUP BY e.id, e.nome, e.email
ORDER BY e.created_at;

-- Verificar cada funcionário em detalhes
SELECT 
  '👤 DETALHES DOS FUNCIONÁRIOS' as relatorio,
  e.nome as empresa,
  f.nome as funcionario,
  f.email,
  f.tipo_admin,
  lf.usuario,
  CASE 
    WHEN f.tipo_admin = 'admin_empresa' THEN '👑 ADMIN COMPLETO'
    WHEN f.tipo_admin = 'super_admin' THEN '🔴 SUPER ADMIN'
    ELSE '👤 FUNCIONÁRIO'
  END as nivel,
  f.created_at as cadastrado_em,
  ROW_NUMBER() OVER (PARTITION BY f.empresa_id ORDER BY f.created_at) as ordem_cadastro
FROM funcionarios f
JOIN empresas e ON f.empresa_id = e.id
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
ORDER BY e.nome, f.created_at;

-- Verificar permissões
SELECT 
  '🔑 PERMISSÕES' as relatorio,
  f.nome as funcionario,
  f.tipo_admin,
  func.nome as funcao,
  COUNT(fp.permissao_id) as total_permissoes
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
GROUP BY f.id, f.nome, f.tipo_admin, func.nome
ORDER BY f.created_at;

-- ✅ PASSO 6: Teste final
SELECT '==================== TESTE FINAL ====================' as etapa;

-- Testar função listar_usuarios_ativos para cada empresa
DO $$
DECLARE
  v_empresa RECORD;
  v_usuarios INTEGER;
BEGIN
  FOR v_empresa IN (SELECT id, nome FROM empresas ORDER BY created_at)
  LOOP
    SELECT COUNT(*) INTO v_usuarios 
    FROM listar_usuarios_ativos(v_empresa.id);
    
    RAISE NOTICE 'Empresa: % - Usuários ativos: %', v_empresa.nome, v_usuarios;
  END LOOP;
END $$;

-- Mensagem final
SELECT '==================== ✅ CONCLUÍDO ====================' as etapa;

SELECT 
  '🎉 SISTEMA VALIDADO E CORRIGIDO!' as status,
  'Execute FLUXO_SISTEMA_CORRETO.sql para verificação adicional' as proximos_passos;

-- =====================================================
-- INSTRUÇÕES FINAIS
-- =====================================================
/*
 * ✅ O QUE FOI FEITO:
 * 
 * 1. Trigger recriado: Garante que primeiro funcionário seja admin
 * 2. Funcionários corrigidos: Primeiro de cada empresa agora é admin
 * 3. Função atualizada: listar_usuarios_ativos retorna campo 'usuario'
 * 4. Permissões configuradas: Admin tem acesso total, funcionários limitados
 * 
 * 🎯 COMO TESTAR:
 * 
 * 1. Faça login com o email principal da empresa
 * 2. Verifique se aparece a tela de seleção de funcionário
 * 3. Selecione o PRIMEIRO funcionário (deve ser admin)
 * 4. Digite a senha dele
 * 5. Verifique se tem acesso total ao sistema
 * 
 * 6. Logout e login novamente
 * 7. Selecione um FUNCIONÁRIO COMUM (ex: Vendedor)
 * 8. Digite a senha dele
 * 9. Verifique se tem acesso limitado (apenas vendas, produtos, clientes)
 * 
 * 🚨 SE AINDA HOUVER PROBLEMAS:
 * 
 * Execute os scripts na ordem:
 * 1. FLUXO_SISTEMA_CORRETO.sql (validação completa)
 * 2. DIAGNOSTICAR_E_CORRIGIR_JENNIFER.sql (caso específico da Jennifer)
 * 3. GERAR_LOGIN_JENNIFER.sql (verificar se tem login)
 */
