-- =====================================================
-- 🔧 CORREÇÃO ESPECÍFICA - JENNIFER PRECISA SER TÉCNICO
-- =====================================================
-- Jennifer está como "Vendedor" mas precisa ter acesso a OS
-- Solução: Mudar para função "Técnico" OU adicionar OS manualmente

BEGIN;

-- OPÇÃO 1: Mudar Jennifer para função Técnico
-- =====================================================
UPDATE funcionarios
SET 
  funcao_id = (
    SELECT id FROM funcoes 
    WHERE empresa_id = (
      SELECT empresa_id FROM funcionarios 
      WHERE nome = 'Jennifer' LIMIT 1
    )
    AND (LOWER(nome) LIKE '%técnico%' OR LOWER(nome) LIKE '%tecnico%')
    LIMIT 1
  ),
  permissoes = jsonb_build_object(
    'vendas', false,
    'produtos', true,
    'clientes', true,
    'caixa', false,
    'ordens_servico', true,  -- ✅ ATIVAR OS
    'relatorios', false,
    'configuracoes', false,
    'backup', false
  ),
  updated_at = NOW()
WHERE nome = 'Jennifer';

SELECT 
  '✅ JENNIFER ATUALIZADA PARA TÉCNICO' as resultado,
  nome,
  (SELECT nome FROM funcoes WHERE id = funcionarios.funcao_id) as nova_funcao,
  permissoes->>'ordens_servico' as os_ativo
FROM funcionarios
WHERE nome = 'Jennifer';

-- =====================================================
-- OPÇÃO 2 (ALTERNATIVA): Manter como Vendedor mas adicionar OS
-- =====================================================
-- Se preferir que Jennifer continue como Vendedor mas tenha OS:
-- (Descomente as linhas abaixo se preferir esta opção)

/*
UPDATE funcionarios
SET 
  permissoes = permissoes || jsonb_build_object('ordens_servico', true),
  updated_at = NOW()
WHERE nome = 'Jennifer';

SELECT 
  '✅ OS ADICIONADO PARA JENNIFER (VENDEDOR)' as resultado,
  nome,
  (SELECT nome FROM funcoes WHERE id = funcionarios.funcao_id) as funcao,
  permissoes->>'ordens_servico' as os_ativo,
  permissoes->>'vendas' as vendas_ativo
FROM funcionarios
WHERE nome = 'Jennifer';
*/

COMMIT;

-- =====================================================
-- 📋 VERIFICAÇÃO FINAL
-- =====================================================

SELECT 
  '📊 JENNIFER - DADOS FINAIS' as verificacao,
  f.nome,
  func.nome as funcao,
  f.permissoes->>'vendas' as vendas,
  f.permissoes->>'produtos' as produtos,
  f.permissoes->>'clientes' as clientes,
  f.permissoes->>'ordens_servico' as os,
  f.usuario_ativo,
  f.senha_definida,
  f.status
FROM funcionarios f
LEFT JOIN funcoes func ON f.funcao_id = func.id
WHERE f.nome = 'Jennifer';

-- =====================================================
-- 🧪 TESTE NO FRONTEND:
-- =====================================================
-- 
-- 1. Faça LOGOUT completo
-- 2. Login com: assistenciaallimport10@gmail.com
-- 3. Selecione Jennifer
-- 4. Digite a senha
-- 5. ✅ Card "Ordens de Serviço" DEVE aparecer agora!
-- 
-- =====================================================
