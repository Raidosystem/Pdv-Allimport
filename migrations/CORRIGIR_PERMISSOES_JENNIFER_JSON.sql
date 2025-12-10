-- ============================================
-- CORRIGIR PERMISSÕES DA JENNIFER (CAMPO JSON)
-- ============================================

-- ============================================
-- 1️⃣ VER PERMISSÕES ATUAIS DA JENNIFER
-- ============================================
SELECT 
  nome,
  cargo,
  ativo,
  permissoes,
  funcao_id
FROM funcionarios 
WHERE LOWER(nome) LIKE '%jennifer%';

-- ============================================
-- 2️⃣ CORRIGIR PERMISSÕES DA JENNIFER
-- ============================================

UPDATE funcionarios
SET permissoes = jsonb_set(
  jsonb_set(
    jsonb_set(
      jsonb_set(
        jsonb_set(
          jsonb_set(
            jsonb_set(
              permissoes::jsonb,
              '{configuracoes}', 'false'::jsonb  -- ❌ Bloquear Configurações
            ),
            '{pode_alterar_configuracoes}', 'false'::jsonb  -- ❌ Bloquear alteração de configurações
          ),
          '{pode_deletar_clientes}', 'false'::jsonb  -- ❌ Bloquear deletar clientes
        ),
        '{pode_deletar_produtos}', 'false'::jsonb  -- ❌ Bloquear deletar produtos
      ),
      '{ordens_servico}', 'true'::jsonb  -- ✅ Permitir Ordens de Serviço
    ),
    '{pode_criar_os}', 'true'::jsonb  -- ✅ Permitir criar OS
  ),
  '{pode_editar_os}', 'true'::jsonb  -- ✅ Permitir editar OS
),
updated_at = NOW()
WHERE LOWER(nome) LIKE '%jennifer%';

-- ============================================
-- 3️⃣ VERIFICAÇÃO FINAL DAS PERMISSÕES
-- ============================================
SELECT 
  nome,
  permissoes->>'ordens_servico' as ordens_servico,
  permissoes->>'pode_criar_os' as pode_criar_os,
  permissoes->>'pode_editar_os' as pode_editar_os,
  permissoes->>'configuracoes' as configuracoes,
  permissoes->>'pode_alterar_configuracoes' as pode_alterar_config,
  permissoes->>'pode_deletar_clientes' as pode_deletar_clientes,
  permissoes->>'pode_deletar_produtos' as pode_deletar_produtos,
  permissoes->>'vendas' as vendas,
  permissoes->>'clientes' as clientes,
  permissoes->>'produtos' as produtos
FROM funcionarios 
WHERE LOWER(nome) LIKE '%jennifer%';

-- ============================================
-- 4️⃣ VER PERMISSÕES COMPLETAS (FORMATADO)
-- ============================================
SELECT 
  nome,
  jsonb_pretty(permissoes::jsonb) as permissoes_formatadas
FROM funcionarios 
WHERE LOWER(nome) LIKE '%jennifer%';

-- ============================================
-- ✅ RESULTADO ESPERADO PARA JENNIFER
-- ============================================
-- ✅ ordens_servico: true
-- ✅ pode_criar_os: true
-- ✅ pode_editar_os: true
-- ✅ vendas: true
-- ✅ clientes: true (visualizar/criar/editar)
-- ✅ produtos: true (visualizar)
-- ❌ configuracoes: false (não aparece no menu)
-- ❌ pode_alterar_configuracoes: false
-- ❌ pode_deletar_clientes: false
-- ❌ pode_deletar_produtos: false
