-- =====================================================
-- VERIFICAR PERMISSÕES REAIS DOS FUNCIONÁRIOS
-- =====================================================

-- 1. Verificar estrutura completa de Jennifer
SELECT 
  f.id,
  f.nome,
  f.email,
  f.funcao_id,
  func.nome as funcao_nome,
  func.nivel as funcao_nivel,
  f.permissoes as permissoes_jsonb
FROM funcionarios f
LEFT JOIN funcoes func ON func.id = f.funcao_id
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
  AND f.nome = 'Jennifer Sousa';

-- 2. Verificar o que o código frontend espera (chaves JSONB)
-- O código verifica: permissoes.vendas, permissoes.produtos, permissoes.clientes, etc.

-- 3. Jennifer deve ver: Vendas, Produtos, Clientes, Ordens de Serviço
-- Jennifer NÃO deve ver: Caixa, Relatórios, Configurações, Backup

-- Verificar se JSONB está correto:
SELECT 
  f.nome,
  f.permissoes->'vendas' as pode_ver_vendas,
  f.permissoes->'produtos' as pode_ver_produtos,
  f.permissoes->'clientes' as pode_ver_clientes,
  f.permissoes->'caixa' as pode_ver_caixa,
  f.permissoes->'relatorios' as pode_ver_relatorios,
  f.permissoes->'configuracoes' as pode_ver_configuracoes,
  f.permissoes->'ordens_servico' as pode_ver_os,
  f.permissoes->'backup' as pode_ver_backup
FROM funcionarios f
WHERE f.empresa_id = 'f7fdf4cf-7101-45ab-86db-5248a7ac58c1'
ORDER BY f.nome;

-- =====================================================
-- 4. O PROBLEMA: As funções não estão corretas!
-- =====================================================
-- Jennifer está com função "Vendedor" mas o sistema espera 
-- que ela veja APENAS o que um vendedor pode ver

-- Vamos verificar onde no código o menu é filtrado
-- O sistema deve usar: usePermissions().can() ou checkPermissao()
