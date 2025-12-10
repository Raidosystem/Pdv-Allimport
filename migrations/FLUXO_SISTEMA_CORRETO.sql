-- =====================================================
-- FLUXO CORRETO DO SISTEMA - CONFORME ESPECIFICAÇÃO
-- =====================================================

/**
 * 🎯 FLUXO ESPERADO DO SISTEMA:
 * 
 * 1. CADASTRO EMPRESA (Email principal)
 *    - Cliente compra o sistema
 *    - Cadastra com email@empresa.com + senha
 *    - Este é o "LOGIN PRINCIPAL" da empresa
 * 
 * 2. PRIMEIRO ACESSO COM EMAIL PRINCIPAL
 *    - Login com email@empresa.com + senha
 *    - Sistema verifica se tem funcionários cadastrados
 *    - SE NÃO TEM → Mostrar mensagem "Cadastre o primeiro funcionário"
 *    - SE TEM → Redirecionar para "Login Local" (seleção de funcionário)
 * 
 * 3. CRIAR PRIMEIRO FUNCIONÁRIO (Admin Completo)
 *    - Primeiro funcionário criado = ADMIN EMPRESA automático
 *    - Tem acesso total ao sistema (77 permissões)
 *    - Cadastro: Nome, Cargo, Email (opcional), Usuário, Senha
 * 
 * 4. CRIAR OUTROS FUNCIONÁRIOS (Funcionários Limitados)
 *    - Admin cria novos funcionários
 *    - Define função (Vendedor, Caixa, etc.) → Controla permissões
 *    - Cada funcionário tem: Nome, Cargo, Usuário, Senha
 *    - SEM CONFLITO: Cada funcionário tem permissões próprias
 * 
 * 5. LOGIN FINAL (Dois passos)
 *    PASSO 1: Email principal da empresa (email@empresa.com)
 *    PASSO 2: Selecionar funcionário + senha dele
 * 
 * 6. PERMISSÕES ISOLADAS
 *    - Cada funcionário vê apenas o que TEM PERMISSÃO
 *    - Admin Empresa: Vê tudo (is_admin_empresa = true)
 *    - Funcionários: Veem apenas suas permissões (is_admin = false)
 *    - SEM CONFLITO de permissões entre funcionários
 */

-- =====================================================
-- VERIFICAR SE O SISTEMA ESTÁ CORRETO
-- =====================================================

-- 1️⃣ VERIFICAR TRIGGER DO PRIMEIRO FUNCIONÁRIO
SELECT 
  '🔍 TRIGGER PRIMEIRO FUNCIONÁRIO' as verificacao,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_trigger 
      WHERE tgname = 'trigger_first_user_admin'
    ) THEN '✅ EXISTE'
    ELSE '❌ NÃO EXISTE - CRIAR!'
  END as status;

-- 2️⃣ VERIFICAR FUNÇÃO listar_usuarios_ativos (deve ter campo 'usuario')
SELECT 
  '🔍 FUNÇÃO listar_usuarios_ativos' as verificacao,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_proc 
      WHERE proname = 'listar_usuarios_ativos'
    ) THEN '✅ EXISTE'
    ELSE '❌ NÃO EXISTE - CRIAR!'
  END as status;

-- 3️⃣ VERIFICAR TABELA login_funcionarios
SELECT 
  '🔍 TABELA login_funcionarios' as verificacao,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_name = 'login_funcionarios'
    ) THEN '✅ EXISTE'
    ELSE '❌ NÃO EXISTE - CRIAR!'
  END as status;

-- 4️⃣ LISTAR EMPRESAS E SEUS FUNCIONÁRIOS
SELECT 
  '👥 EMPRESAS E FUNCIONÁRIOS' as secao,
  e.nome as empresa,
  e.email as email_principal,
  COUNT(f.id) as total_funcionarios,
  COUNT(CASE WHEN f.tipo_admin = 'admin_empresa' THEN 1 END) as total_admins,
  COUNT(CASE WHEN f.tipo_admin = 'funcionario' THEN 1 END) as total_funcionarios_comuns
FROM empresas e
LEFT JOIN funcionarios f ON f.empresa_id = e.id
GROUP BY e.id, e.nome, e.email
ORDER BY e.created_at;

-- 5️⃣ VERIFICAR PRIMEIRO FUNCIONÁRIO DE CADA EMPRESA (deve ser admin)
SELECT 
  '🎯 PRIMEIRO FUNCIONÁRIO' as info,
  e.nome as empresa,
  f.nome as funcionario,
  f.tipo_admin,
  CASE 
    WHEN f.tipo_admin = 'admin_empresa' THEN '✅ CORRETO'
    ELSE '❌ DEVERIA SER ADMIN!'
  END as status,
  f.created_at
FROM funcionarios f
JOIN empresas e ON f.empresa_id = e.id
WHERE f.id IN (
  SELECT DISTINCT ON (empresa_id) id
  FROM funcionarios
  ORDER BY empresa_id, created_at ASC
)
ORDER BY f.created_at;

-- 6️⃣ VERIFICAR PERMISSÕES DE CADA FUNCIONÁRIO
SELECT 
  '🔑 PERMISSÕES POR FUNCIONÁRIO' as info,
  f.nome,
  f.tipo_admin,
  func.nome as funcao,
  COUNT(fp.permissao_id) as total_permissoes,
  CASE 
    WHEN f.tipo_admin = 'admin_empresa' THEN '👑 ADMIN COMPLETO'
    WHEN f.tipo_admin = 'super_admin' THEN '🔴 SUPER ADMIN'
    ELSE '👤 FUNCIONÁRIO LIMITADO'
  END as nivel
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
GROUP BY f.id, f.nome, f.tipo_admin, func.nome
ORDER BY f.created_at;

-- =====================================================
-- CORRIGIR PROBLEMAS ENCONTRADOS
-- =====================================================

-- CORREÇÃO 1: Criar trigger se não existir
CREATE OR REPLACE FUNCTION set_first_user_as_admin()
RETURNS TRIGGER AS $$
BEGIN
  -- Se for o primeiro funcionário da empresa, torná-lo admin_empresa
  IF NOT EXISTS (
    SELECT 1 FROM funcionarios 
    WHERE empresa_id = NEW.empresa_id 
    AND id != NEW.id
  ) THEN
    NEW.tipo_admin = 'admin_empresa';
    RAISE NOTICE '✅ Primeiro funcionário definido como admin_empresa: %', NEW.nome;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_first_user_admin ON funcionarios;
CREATE TRIGGER trigger_first_user_admin
  BEFORE INSERT ON funcionarios
  FOR EACH ROW
  EXECUTE FUNCTION set_first_user_as_admin();

-- CORREÇÃO 2: Garantir que primeiro funcionário já cadastrado seja admin
UPDATE funcionarios f
SET tipo_admin = 'admin_empresa'
WHERE f.id IN (
  SELECT DISTINCT ON (empresa_id) id
  FROM funcionarios
  WHERE tipo_admin != 'admin_empresa'
  AND tipo_admin != 'super_admin'
  ORDER BY empresa_id, created_at ASC
)
AND NOT EXISTS (
  SELECT 1 FROM funcionarios f2
  WHERE f2.empresa_id = f.empresa_id
  AND f2.tipo_admin IN ('admin_empresa', 'super_admin')
  AND f2.id != f.id
);

-- CORREÇÃO 3: Garantir que listar_usuarios_ativos retorna campo 'usuario'
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
    COALESCE(lf.usuario, f.email, f.nome) as usuario
  FROM public.funcionarios f
  LEFT JOIN public.login_funcionarios lf ON lf.funcionario_id = f.id AND lf.ativo = true
  WHERE f.empresa_id = p_empresa_id
    AND f.status = 'ativo'
  ORDER BY 
    CASE WHEN f.tipo_admin = 'admin_empresa' THEN 0 ELSE 1 END,
    f.nome;
END;
$$;

-- =====================================================
-- TESTE COMPLETO DO FLUXO
-- =====================================================

-- Simular cadastro de empresa (já deve existir em auth.users)
-- SELECT email FROM auth.users WHERE email LIKE '%allimport%';

-- Verificar funcionários dessa empresa
SELECT 
  '🎯 FUNCIONÁRIOS DA EMPRESA' as teste,
  f.nome,
  f.email,
  f.tipo_admin,
  lf.usuario,
  func.nome as funcao,
  COUNT(fp.permissao_id) as permissoes
FROM funcionarios f
LEFT JOIN login_funcionarios lf ON lf.funcionario_id = f.id
LEFT JOIN funcoes func ON f.funcao_id = func.id
LEFT JOIN funcao_permissoes fp ON func.id = fp.funcao_id
WHERE f.empresa_id = (
  SELECT id FROM empresas WHERE email = 'assistenciaallimport10@gmail.com' LIMIT 1
)
GROUP BY f.id, f.nome, f.email, f.tipo_admin, lf.usuario, func.nome
ORDER BY f.created_at;

-- =====================================================
-- 📊 RELATÓRIO FINAL
-- =====================================================
SELECT 
  '📊 RESUMO DO SISTEMA' as relatorio,
  (SELECT COUNT(*) FROM empresas) as total_empresas,
  (SELECT COUNT(*) FROM funcionarios) as total_funcionarios,
  (SELECT COUNT(*) FROM funcionarios WHERE tipo_admin = 'admin_empresa') as total_admins,
  (SELECT COUNT(*) FROM funcionarios WHERE tipo_admin = 'funcionario') as total_funcionarios_comuns,
  (SELECT COUNT(*) FROM login_funcionarios) as total_logins;

-- =====================================================
-- ✅ CHECKLIST DE VALIDAÇÃO
-- =====================================================
/**
 * [ ] Trigger set_first_user_as_admin existe e está ativo
 * [ ] Primeiro funcionário de cada empresa é admin_empresa
 * [ ] Função listar_usuarios_ativos retorna campo 'usuario'
 * [ ] Tabela login_funcionarios existe e tem dados
 * [ ] Login funciona em 2 passos (email empresa → funcionário)
 * [ ] Admin empresa tem todas as permissões (is_admin_empresa = true)
 * [ ] Funcionários normais têm permissões limitadas por função
 * [ ] Não há conflito de permissões entre funcionários
 */
