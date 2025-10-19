-- ============================================
-- 🎯 TESTE RÁPIDO - PERMISSÕES DA JENNIFER
-- ============================================

-- ============================================
-- 1️⃣ VERIFICAR PERMISSÕES ATUAIS
-- ============================================
SELECT 
  nome,
  cargo,
  ativo,
  email,
  permissoes->>'ordens_servico' as "✅ Acesso OS",
  permissoes->>'pode_criar_os' as "✅ Criar OS",
  permissoes->>'pode_editar_os' as "✅ Editar OS",
  permissoes->>'pode_finalizar_os' as "✅ Finalizar OS",
  permissoes->>'configuracoes' as "❌ Config (deve ser false)",
  permissoes->>'pode_deletar_clientes' as "❌ Deletar Cliente (false)",
  permissoes->>'pode_deletar_produtos' as "❌ Deletar Produto (false)",
  permissoes->>'vendas' as "Info: Vendas",
  permissoes->>'produtos' as "Info: Produtos",
  permissoes->>'clientes' as "Info: Clientes"
FROM funcionarios 
WHERE LOWER(nome) LIKE '%jennifer%';

-- ============================================
-- 2️⃣ APLICAR PERMISSÕES CORRETAS (SE NECESSÁRIO)
-- ============================================
UPDATE funcionarios
SET permissoes = jsonb_build_object(
  -- ✅ MÓDULOS QUE JENNIFER DEVE VER
  'vendas', true,
  'produtos', true,
  'clientes', true,
  'ordens_servico', true,     -- ✅ PRINCIPAL: Acesso a OS
  
  -- ❌ MÓDULOS QUE JENNIFER NÃO DEVE VER
  'caixa', false,
  'funcionarios', false,
  'relatorios', false,
  'configuracoes', false,      -- ❌ NÃO deve ver Configurações
  'backup', false,
  
  -- ✅ PERMISSÕES DE VENDAS (básico)
  'pode_criar_vendas', true,
  'pode_editar_vendas', false,
  'pode_cancelar_vendas', false,
  'pode_aplicar_desconto', false,
  
  -- ⚠️ PERMISSÕES DE PRODUTOS (só visualização)
  'pode_criar_produtos', false,
  'pode_editar_produtos', false,
  'pode_deletar_produtos', false,  -- ❌ NÃO pode deletar produtos
  'pode_gerenciar_estoque', false,
  
  -- ✅ PERMISSÕES DE CLIENTES (criar e editar)
  'pode_criar_clientes', true,
  'pode_editar_clientes', true,
  'pode_deletar_clientes', false,  -- ❌ NÃO pode deletar clientes
  
  -- ❌ PERMISSÕES DE CAIXA (nenhuma)
  'pode_abrir_caixa', false,
  'pode_fechar_caixa', false,
  'pode_gerenciar_movimentacoes', false,
  
  -- ✅ PERMISSÕES DE OS (COMPLETAS)
  'pode_criar_os', true,       -- ✅ Criar OS
  'pode_editar_os', true,      -- ✅ Editar OS
  'pode_finalizar_os', true,   -- ✅ Finalizar OS
  
  -- ❌ PERMISSÕES DE ADMINISTRAÇÃO (nenhuma)
  'pode_ver_todos_relatorios', false,
  'pode_exportar_dados', false,
  'pode_alterar_configuracoes', false,  -- ❌ NÃO pode alterar configs
  'pode_gerenciar_funcionarios', false,
  'pode_fazer_backup', false
),
updated_at = NOW()
WHERE LOWER(nome) LIKE '%jennifer%';

-- ============================================
-- 3️⃣ VERIFICAÇÃO FINAL
-- ============================================
SELECT 
  '✅ VERIFICAÇÃO COMPLETA DAS PERMISSÕES DA JENNIFER' as titulo;

SELECT 
  nome,
  cargo,
  ativo,
  CASE WHEN ativo THEN '✅ Ativo' ELSE '❌ Inativo' END as status,
  CASE 
    WHEN (permissoes->>'ordens_servico')::boolean = true THEN '✅ SIM' 
    ELSE '❌ NÃO' 
  END as "Acessa OS?",
  CASE 
    WHEN (permissoes->>'configuracoes')::boolean = false THEN '✅ Correto (bloqueado)' 
    ELSE '❌ ERRO (tem acesso)' 
  END as "Config bloqueada?",
  CASE 
    WHEN (permissoes->>'pode_deletar_clientes')::boolean = false THEN '✅ Correto (bloqueado)' 
    ELSE '❌ ERRO (pode deletar)' 
  END as "Deletar clientes?",
  CASE 
    WHEN (permissoes->>'pode_deletar_produtos')::boolean = false THEN '✅ Correto (bloqueado)' 
    ELSE '❌ ERRO (pode deletar)' 
  END as "Deletar produtos?"
FROM funcionarios 
WHERE LOWER(nome) LIKE '%jennifer%';

-- ============================================
-- 4️⃣ VER TODAS AS PERMISSÕES (FORMATADO)
-- ============================================
SELECT 
  '📋 TODAS AS PERMISSÕES DA JENNIFER (FORMATADO)' as titulo;

SELECT 
  nome,
  cargo,
  jsonb_pretty(permissoes::jsonb) as permissoes_completas
FROM funcionarios 
WHERE LOWER(nome) LIKE '%jennifer%';

-- ============================================
-- 5️⃣ COMPARAR COM OUTROS FUNCIONÁRIOS
-- ============================================
SELECT 
  '📊 COMPARAÇÃO COM OUTROS FUNCIONÁRIOS' as titulo;

SELECT 
  nome,
  cargo,
  ativo,
  permissoes->>'ordens_servico' as "OS",
  permissoes->>'configuracoes' as "Config",
  permissoes->>'pode_deletar_clientes' as "Del Cliente",
  permissoes->>'pode_deletar_produtos' as "Del Produto"
FROM funcionarios
ORDER BY nome;

-- ============================================
-- ✅ RESULTADO ESPERADO PARA JENNIFER:
-- ============================================
-- ✅ Acessa OS? = SIM
-- ✅ Config bloqueada? = Correto (bloqueado)
-- ✅ Deletar clientes? = Correto (bloqueado)
-- ✅ Deletar produtos? = Correto (bloqueado)
-- ============================================

-- ============================================
-- 🔧 SE AINDA NÃO APARECER NO SISTEMA:
-- ============================================
-- 1. Limpar cache do navegador (Ctrl+Shift+Del)
-- 2. Fazer logout e login novamente com Jennifer
-- 3. Verificar se componente está lendo campo 'permissoes'
-- 4. Verificar console do navegador (F12) por erros
-- ============================================
