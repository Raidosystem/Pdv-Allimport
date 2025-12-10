-- =====================================================
-- CRIAR PERMISSÕES BASEADAS NO JSONB DOS FUNCIONÁRIOS
-- =====================================================
-- Este script cria permissões do sistema NOVO baseado
-- nas permissões JSONB salvas em funcionarios.permissoes
-- =====================================================

-- 1. VERIFICAR PERMISSÕES ATUAIS NO JSONB
SELECT 
  f.nome,
  f.permissoes->'vendas' as vendas,
  f.permissoes->'produtos' as produtos,
  f.permissoes->'clientes' as clientes,
  f.permissoes->'caixa' as caixa,
  f.permissoes->'relatorios' as relatorios,
  f.permissoes->'ordens_servico' as ordens_servico,
  f.permissoes->'configuracoes' as configuracoes
FROM funcionarios f
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.nome;

-- =====================================================
-- 2. O PROBLEMA REAL: Dois sistemas de permissões
-- =====================================================
-- SISTEMA ANTIGO (ainda em uso):
--   funcionarios.permissoes JSONB { vendas: true, caixa: false, ... }
--
-- SISTEMA NOVO (parcialmente implementado):
--   Tabelas: funcoes → funcao_permissoes → permissoes
--   Formato: vendas:read, vendas:create, caixa:open, ...
--
-- SOLUÇÃO: Usar APENAS o sistema JSONB por enquanto
-- Ignorar tabelas funcao_permissoes e permissoes
-- =====================================================

-- 3. O CÓDIGO DEVE LER DIRETO DO JSONB
-- Verificar onde o código lê as permissões:
-- 
-- ❌ ERRADO (sistema novo):
--   permissoes.some(p => p.startsWith('vendas:read'))
--
-- ✅ CORRETO (sistema JSONB):
--   funcionario.permissoes.vendas === true
--
-- =====================================================

-- 4. RESULTADO ESPERADO PARA JENNIFER (VENDEDOR):
-- ✅ Deve ver:   Vendas, Produtos, Clientes, Ordens de Serviço
-- ❌ Não deve ver: Caixa, Relatórios, Configurações, Backup

SELECT 
  'Jennifer deve ver:' as status,
  CASE 
    WHEN f.permissoes->>'vendas' = 'true' THEN '✅ Vendas'
    ELSE '❌ Vendas'
  END as vendas,
  CASE 
    WHEN f.permissoes->>'produtos' = 'true' THEN '✅ Produtos'
    ELSE '❌ Produtos'
  END as produtos,
  CASE 
    WHEN f.permissoes->>'clientes' = 'true' THEN '✅ Clientes'
    ELSE '❌ Clientes'
  END as clientes,
  CASE 
    WHEN f.permissoes->>'ordens_servico' = 'true' THEN '✅ OS'
    ELSE '❌ OS'
  END as os,
  CASE 
    WHEN f.permissoes->>'caixa' = 'false' THEN '✅ Caixa OCULTO'
    ELSE '❌ Caixa VISÍVEL (erro!)'
  END as caixa,
  CASE 
    WHEN f.permissoes->>'relatorios' = 'false' THEN '✅ Relatórios OCULTO'
    ELSE '❌ Relatórios VISÍVEL (erro!)'
  END as relatorios
FROM funcionarios f
WHERE f.nome = 'Jennifer Sousa'
  AND f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';

-- =====================================================
-- 5. DIAGNÓSTICO FINAL
-- =====================================================
DO $$
DECLARE
  v_jennifer RECORD;
BEGIN
  SELECT * INTO v_jennifer
  FROM funcionarios
  WHERE nome = 'Jennifer Sousa'
    AND empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1';
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '🔍 DIAGNÓSTICO - PERMISSÕES JENNIFER';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '👤 Nome: %', v_jennifer.nome;
  RAISE NOTICE '📧 Email: %', v_jennifer.email;
  RAISE NOTICE '🎭 Função: %', (SELECT nome FROM funcoes WHERE id = v_jennifer.funcao_id);
  RAISE NOTICE '';
  RAISE NOTICE '📊 Permissões JSONB:';
  RAISE NOTICE '   Vendas: %', v_jennifer.permissoes->>'vendas';
  RAISE NOTICE '   Produtos: %', v_jennifer.permissoes->>'produtos';
  RAISE NOTICE '   Clientes: %', v_jennifer.permissoes->>'clientes';
  RAISE NOTICE '   Caixa: %', v_jennifer.permissoes->>'caixa';
  RAISE NOTICE '   Relatórios: %', v_jennifer.permissoes->>'relatorios';
  RAISE NOTICE '   OS: %', v_jennifer.permissoes->>'ordens_servico';
  RAISE NOTICE '   Configurações: %', v_jennifer.permissoes->>'configuracoes';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Deve ver: Vendas, Produtos, Clientes, OS';
  RAISE NOTICE '❌ Não deve ver: Caixa, Relatórios, Configurações';
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '🔧 PRÓXIMO PASSO:';
  RAISE NOTICE '   Corrigir useUserHierarchy.ts para ler do JSONB';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
END;
$$;
